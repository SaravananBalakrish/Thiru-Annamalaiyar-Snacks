import 'package:flutter/material.dart';
import '../../constants.dart';
import 'auth/login_page.dart';
import 'orders_page.dart';
import 'saved_addresses_page.dart';
import 'active_orders_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(kSettings),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileSection(theme, colorScheme),
            _buildSection(theme, colorScheme, kAccount, [
              _buildListTile(
                theme,
                colorScheme,
                Icons.shopping_bag_outlined,
                kMyOrders,
                colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrdersPage()),
                  );
                },
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.calendar_today_outlined,
                kActiveOrders,
                colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActiveOrdersPage()),
                  );
                },
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.location_on_outlined,
                kSavedAddresses,
                colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SavedAddressesPage()),
                  );
                },
              ),
            ]),
            _buildSection(theme, colorScheme, kSupportLegal, [
              _buildListTile(
                theme,
                colorScheme,
                Icons.help_outline,
                kContactUs,
                colorScheme.primary,
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.info_outline,
                kHelpFaq,
                colorScheme.primary,
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.star_outline,
                kRateReview,
                colorScheme.primary,
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.security_outlined,
                kPrivacyPolicy,
                colorScheme.primary,
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.description_outlined,
                kTermsConditions,
                colorScheme.primary,
              ),
            ]),
            _buildSection(theme, colorScheme, kSession, [
              _buildListTile(
                theme,
                colorScheme,
                Icons.logout,
                kLogOut,
                colorScheme.error,
                isDestructive: true,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
              _buildListTile(
                theme,
                colorScheme,
                Icons.delete_outline,
                kDeleteAccount,
                colorScheme.outline,
              ),
            ]),
            const SizedBox(height: kPaddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(kPaddingM),
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(kRadiusL),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(Icons.person, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(width: kPaddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "saravanan",
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  "8681020301",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadiusXL),
              ),
              padding: const EdgeInsets.symmetric(horizontal: kPaddingL),
            ),
            child: Text(
              kEdit,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: kPaddingL,
            top: kPaddingL,
            bottom: kPaddingS,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: kPaddingM),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(kRadiusL),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    Color iconColor, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(kPaddingS),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(kRadiusS),
        ),
        child: Icon(icon, color: iconColor, size: kIconMedium),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}
