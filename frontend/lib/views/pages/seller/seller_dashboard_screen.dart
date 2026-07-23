import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/seller_order_controller.dart';
import '../../../services/api_service.dart';
import '../auth/login_page.dart';
import 'seller_orders_page.dart';
import 'seller_stats_page.dart';

/// Root shell for the seller/admin experience.
///
/// Completely separate from [MainScreen] — a seller who logs in never sees
/// the customer shopping UI. Shares the same [ThemeData] and color tokens.
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Trigger an initial data load as soon as the shell is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerOrderController>().loadAll();
    });
  }

  void _onTabTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          SellerOrdersPage(),
          SellerStatsPage(),
          _SellerSettingsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(colorScheme),
    );
  }

  Widget _buildBottomNav(ColorScheme colorScheme) {
    return Consumer<SellerOrderController>(
      builder: (context, controller, child) {
        final pendingCount = controller.pendingCount;

        return Material(
          elevation: 8,
          color: colorScheme.surface,
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor:
                  colorScheme.onSurface.withValues(alpha: 0.55),
              currentIndex: _selectedIndex,
              onTap: _onTabTap,
              items: [
                BottomNavigationBarItem(
                  icon: _PendingBadge(
                    count: pendingCount,
                    child: const Icon(Icons.receipt_long_outlined),
                  ),
                  activeIcon: _PendingBadge(
                    count: pendingCount,
                    child: const Icon(Icons.receipt_long),
                  ),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Stats',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Pending badge widget
// ---------------------------------------------------------------------------

class _PendingBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const _PendingBadge({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Inline settings tab (simple — no separate file needed)
// ---------------------------------------------------------------------------

class _SellerSettingsTab extends StatelessWidget {
  const _SellerSettingsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Settings',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kPaddingM),
        children: [
          // --- Profile card ---
          Container(
            padding: const EdgeInsets.all(kPaddingM),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(kRadiusL),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.storefront,
                      size: 32, color: colorScheme.primary),
                ),
                const SizedBox(width: kPaddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thiru Annamalaiyar',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(kRadiusXL),
                        ),
                        child: Text(
                          'Seller / Admin',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: kPaddingL),
          Text(
            'SESSION',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kPaddingS),

          // --- Logout ---
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(kRadiusL),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusL)),
              leading: Container(
                padding: const EdgeInsets.all(kPaddingS),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kRadiusS),
                ),
                child: Icon(Icons.logout,
                    color: colorScheme.error, size: kIconMedium),
              ),
              title: Text(
                'Log Out',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content:
            const Text('You will be signed out of the seller dashboard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ApiService.logout();
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}
