import { Hono, Context } from 'hono';
import { eq } from 'drizzle-orm';
import { db } from '../db/index.js';
import { cartItems, products, orders, orderItems } from '../db/schema.js';
import { z } from 'zod';

const router = new Hono();

const orderInputSchema = z.object({
  userId: z.number().int().positive(),
  paymentMethod: z.string().optional().default('upi'),
});

const payOrderSchema = z.object({
  transactionRef: z.string().min(1),
});

// POST / - Place an order (checkout cart with UPI details generated)
router.post('/', async (c: Context) => {
  try {
    const body = await c.req.json();
    const parsed = orderInputSchema.safeParse(body);
    if (!parsed.success) {
      return c.json({ error: parsed.error.format() }, 400);
    }

    const { userId, paymentMethod } = parsed.data;

    // Get current cart items
    const cartList = await db
      .select({
        cartItemId: cartItems.id,
        productId: cartItems.productId,
        quantity: cartItems.quantity,
        productPrice: products.price,
      })
      .from(cartItems)
      .innerJoin(products, eq(cartItems.productId, products.id));

    if (cartList.length === 0) {
      return c.json({ error: 'Cart is empty' }, 400);
    }

    // Calculate total price
    let total = 0;
    for (const item of cartList) {
      const priceNum = Number(item.productPrice);
      total += priceNum * item.quantity;
    }

    // Perform transaction to create order, order items, and clear cart
    const orderResult = await db.transaction(async (tx) => {
      // 1. Create Order
      const [newOrder] = await tx
        .insert(orders)
        .values({
          userId,
          totalPrice: total.toFixed(2),
          paymentMethod,
          paymentStatus: 'pending',
        })
        .returning();

      // 2. Create Order Items
      const itemsData = cartList.map((item) => ({
        orderId: newOrder.id,
        productId: item.productId,
        quantity: item.quantity,
        price: item.productPrice,
      }));

      const createdItems = await tx.insert(orderItems).values(itemsData).returning();

      // 3. Clear Cart
      await tx.delete(cartItems);

      return {
        ...newOrder,
        items: createdItems,
      };
    });

    // Generate UPI URI & QR code URL for GPay/PhonePe
    const UPI_ID = process.env.UPI_ID || 'saravananbmsd@okaxis';
    const upiUri = `upi://pay?pa=${UPI_ID}&pn=eShop&am=${Number(orderResult.totalPrice).toFixed(2)}&cu=INR&tn=Order_${orderResult.id}`;
    const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(upiUri)}`;

    return c.json({
      ...orderResult,
      upiUri,
      qrCodeUrl,
    }, 201);
  } catch (err) {
    console.error('[orders] POST /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST /:id/pay - Confirm payment for an order
router.post('/:id/pay', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) {
      return c.json({ error: 'Invalid id parameter' }, 400);
    }

    const body = await c.req.json();
    const parsed = payOrderSchema.safeParse(body);
    if (!parsed.success) {
      return c.json({ error: parsed.error.format() }, 400);
    }

    const { transactionRef } = parsed.data;

    // Check if order exists
    const orderRecord = await db.select().from(orders).where(eq(orders.id, id)).limit(1);
    if (orderRecord.length === 0) {
      return c.notFound();
    }

    // Update order status to paid and save transaction reference
    const [updatedOrder] = await db
      .update(orders)
      .set({
        paymentStatus: 'paid',
        transactionRef,
      })
      .where(eq(orders.id, id))
      .returning();

    // Get order items
    const items = await db.select().from(orderItems).where(eq(orderItems.orderId, id));

    return c.json({
      ...updatedOrder,
      items,
    });
  } catch (err) {
    console.error('[orders] POST /:id/pay', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// GET / - List orders (optionally filtered by userId)
router.get('/', async (c: Context) => {
  try {
    const userIdQuery = c.req.query('userId');
    let orderList;

    if (userIdQuery) {
      const userId = Number(userIdQuery);
      if (isNaN(userId)) {
        return c.json({ error: 'Invalid userId query parameter' }, 400);
      }
      orderList = await db.select().from(orders).where(eq(orders.userId, userId));
    } else {
      orderList = await db.select().from(orders);
    }

    return c.json(orderList);
  } catch (err) {
    console.error('[orders] GET /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// GET /:id - Get order by ID with its items
router.get('/:id', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) {
      return c.json({ error: 'Invalid id parameter' }, 400);
    }

    const orderRecord = await db.select().from(orders).where(eq(orders.id, id)).limit(1);
    if (orderRecord.length === 0) {
      return c.notFound();
    }

    const items = await db.select().from(orderItems).where(eq(orderItems.orderId, id));

    return c.json({
      ...orderRecord[0],
      items,
    });
  } catch (err) {
    console.error('[orders] GET /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default router;
