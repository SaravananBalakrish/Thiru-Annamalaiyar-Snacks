import { Hono } from 'hono';
import { db } from '../db/index.js';
import { orders, orderItems, products, users } from '../db/schema.js';
import { eq, desc, sql, and, gte } from 'drizzle-orm';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth.middleware.js';
import { adminMiddleware } from '../middleware/admin.middleware.js';

const app = new Hono();

// Apply auth and admin middleware to all routes in this file
app.use('*', authMiddleware, adminMiddleware);

// ---------------------------------------------------------------------------
// Validation schemas
// ---------------------------------------------------------------------------

const ORDER_STATUSES = [
    'pending',
    'confirmed',
    'packed',
    'out_for_delivery',
    'delivered',
    'rejected',
] as const;

const updateStatusSchema = z.object({
    status: z.enum(ORDER_STATUSES, {
        error: `Status must be one of: ${ORDER_STATUSES.join(', ')}`,
    }),
    rejectionReason: z.string().max(500).optional(),
}).refine(
    (data) => data.status !== 'rejected' || (data.rejectionReason && data.rejectionReason.trim().length > 0),
    { message: 'A rejection reason is required when rejecting an order', path: ['rejectionReason'] },
);

// ---------------------------------------------------------------------------
// GET /v1/admin/orders — All orders with customer info, newest first
// ---------------------------------------------------------------------------

app.get('/orders', async (c) => {
    try {
        const allOrders = await db
            .select({
                order: orders,
                customer: {
                    id: users.id,
                    phoneNumber: users.phoneNumber,
                },
            })
            .from(orders)
            .leftJoin(users, eq(orders.userId, users.id))
            .orderBy(desc(orders.createdAt));

        return c.json({ success: true, data: allOrders });
    } catch {
        return c.json({ success: false, code: 'INTERNAL_ERROR', message: 'Failed to fetch orders' }, 500);
    }
});

// ---------------------------------------------------------------------------
// GET /v1/admin/orders/:id — Single order with full items + product names
// ---------------------------------------------------------------------------

app.get('/orders/:id', async (c) => {
    try {
        const orderId = parseInt(c.req.param('id'));
        if (isNaN(orderId)) {
            return c.json({ success: false, message: 'Invalid order ID' }, 400);
        }

        // Fetch order + customer in one query
        const [orderRow] = await db
            .select({
                order: orders,
                customer: {
                    id: users.id,
                    phoneNumber: users.phoneNumber,
                },
            })
            .from(orders)
            .leftJoin(users, eq(orders.userId, users.id))
            .where(eq(orders.id, orderId))
            .limit(1);

        if (!orderRow) {
            return c.json({ success: false, message: 'Order not found' }, 404);
        }

        // Fetch items with product names
        const items = await db
            .select({
                id: orderItems.id,
                productId: orderItems.productId,
                productName: products.name,
                productImageUrl: products.imageUrl,
                quantity: orderItems.quantity,
                price: orderItems.price,
            })
            .from(orderItems)
            .leftJoin(products, eq(orderItems.productId, products.id))
            .where(eq(orderItems.orderId, orderId));

        return c.json({
            success: true,
            data: {
                ...orderRow.order,
                customer: orderRow.customer,
                items,
            },
        });
    } catch {
        return c.json({ success: false, code: 'INTERNAL_ERROR', message: 'Failed to fetch order details' }, 500);
    }
});

// ---------------------------------------------------------------------------
// PUT /v1/admin/orders/:id/status — Update fulfillment status
// ---------------------------------------------------------------------------

app.put('/orders/:id/status', async (c) => {
    try {
        const orderId = parseInt(c.req.param('id'));
        if (isNaN(orderId)) {
            return c.json({ success: false, message: 'Invalid order ID' }, 400);
        }

        const body = await c.req.json();
        const parsed = updateStatusSchema.safeParse(body);

        if (!parsed.success) {
            return c.json({
                success: false,
                code: 'VALIDATION_ERROR',
                message: parsed.error.issues[0]?.message ?? 'Invalid request body',
            }, 400);
        }

        const { status, rejectionReason } = parsed.data;

        const [updatedOrder] = await db
            .update(orders)
            .set({
                status,
                rejectionReason: status === 'rejected' ? rejectionReason : null,
                updatedAt: new Date(),
            })
            .where(eq(orders.id, orderId))
            .returning();

        if (!updatedOrder) {
            return c.json({ success: false, message: 'Order not found' }, 404);
        }

        return c.json({ success: true, data: updatedOrder });
    } catch {
        return c.json({ success: false, code: 'INTERNAL_ERROR', message: 'Failed to update order status' }, 500);
    }
});

// ---------------------------------------------------------------------------
// PUT /v1/admin/orders/:id/verify-payment — Mark payment as verified
// ---------------------------------------------------------------------------

app.put('/orders/:id/verify-payment', async (c) => {
    try {
        const orderId = parseInt(c.req.param('id'));
        if (isNaN(orderId)) {
            return c.json({ success: false, message: 'Invalid order ID' }, 400);
        }

        const [updatedOrder] = await db
            .update(orders)
            .set({ paymentStatus: 'paid', updatedAt: new Date() })
            .where(and(eq(orders.id, orderId), eq(orders.paymentStatus, 'pending')))
            .returning();

        if (!updatedOrder) {
            // Either not found OR already paid — fetch to differentiate
            const [existing] = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);
            if (!existing) {
                return c.json({ success: false, message: 'Order not found' }, 404);
            }
            // Already paid — idempotent success
            return c.json({ success: true, data: existing });
        }

        return c.json({ success: true, data: updatedOrder });
    } catch {
        return c.json({ success: false, code: 'INTERNAL_ERROR', message: 'Failed to verify payment' }, 500);
    }
});

// ---------------------------------------------------------------------------
// GET /v1/admin/dashboard/stats — Summary numbers for the dashboard header
// ---------------------------------------------------------------------------

app.get('/dashboard/stats', async (c) => {
    try {
        // All orders stats
        const [totalRow] = await db
            .select({ count: sql<number>`count(*)::int` })
            .from(orders);

        const [pendingRow] = await db
            .select({ count: sql<number>`count(*)::int` })
            .from(orders)
            .where(eq(orders.status, 'pending'));

        const [confirmedRow] = await db
            .select({ count: sql<number>`count(*)::int` })
            .from(orders)
            .where(eq(orders.status, 'confirmed'));

        // Today's revenue: sum totalPrice for delivered orders placed today (IST offset)
        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);

        const [revenueRow] = await db
            .select({ total: sql<string>`coalesce(sum(total_price), 0)::text` })
            .from(orders)
            .where(
                and(
                    eq(orders.paymentStatus, 'paid'),
                    gte(orders.createdAt, todayStart),
                ),
            );

        return c.json({
            success: true,
            data: {
                totalOrders: totalRow?.count ?? 0,
                pendingOrders: pendingRow?.count ?? 0,
                confirmedOrders: confirmedRow?.count ?? 0,
                todayRevenue: parseFloat(revenueRow?.total ?? '0'),
            },
        });
    } catch {
        return c.json({ success: false, code: 'INTERNAL_ERROR', message: 'Failed to fetch stats' }, 500);
    }
});

export default app;
