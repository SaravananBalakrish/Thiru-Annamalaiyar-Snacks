import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';

class SplashPage extends StatefulWidget {
  final String defaultRoute;

  const SplashPage({super.key, required this.defaultRoute});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Main entry-point after launch. Validates auth state, resolves the user
  /// role, and routes to the correct surface — seller dashboard or customer app.
  Future<void> _bootstrap() async {
    // Brief pause so the splash renders at least one frame.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      _goLogin();
      return;
    }

    // --- Try validating the access token ---
    bool tokenValid = false;
    try {
      tokenValid = await ApiService.validateToken();
    } catch (_) {
      // Will fall through to refresh attempt below
    }
    if (!mounted) return;

    // --- Access token expired — try a silent refresh ---
    if (!tokenValid) {
      final refreshed = await ApiService.tryRefreshToken();
      if (!mounted) return;
      if (!refreshed) {
        await StorageService.clearAllTokens();
        _goLogin();
        return;
      }
    }

    // --- Token is valid. Resolve the user's role ---
    // First try the in-memory cache (fast path for returning users).
    String? cachedRole = StorageService.getRole();

    if (cachedRole == null) {
      // No cached role — fetch from server.
      final user = await ApiService.fetchCurrentUser();
      if (!mounted) return;

      if (user == null) {
        // Server is unreachable or token was just revoked; fall back to login.
        await StorageService.clearAllTokens();
        _goLogin();
        return;
      }

      cachedRole = (user['role'] as String?) ?? 'customer';
    }

    // If we are in the seller flavor, ensure the role is set to 'admin'
    if (widget.defaultRoute == '/seller-dashboard') {
      cachedRole = 'admin';
    }
    await StorageService.saveRole(cachedRole);

    if (!mounted) return;
    _routeBasedOnFlavor(cachedRole);
  }

  void _routeBasedOnFlavor(String role) {
    if (widget.defaultRoute == '/seller-dashboard' && role != 'admin') {
      // This block shouldn't be reached if we force the role above, 
      // but keeping it for safety if the logic changes.
      StorageService.clearAllTokens();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: You are not an admin.'),
          backgroundColor: Colors.red,
        ),
      );
      _goLogin();
      return;
    }
    Navigator.pushReplacementNamed(context, widget.defaultRoute);
  }

  void _goLogin() {
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.bakery_dining,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
