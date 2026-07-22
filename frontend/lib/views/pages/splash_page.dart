import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add a small delay for aesthetic purposes if needed, or just proceed
    await Future.delayed(const Duration(milliseconds: 500));
    
    final token = await StorageService.getToken();
    
    if (!mounted) return;
    
    if (token != null && token.isNotEmpty) {
      try {
        // Validate JWT token properly using the validation API
        final isValid = await ApiService.validateToken();
        if (!mounted) return;
        
        if (isValid) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (!mounted) return;
        // If the error was 401, ApiService interceptor already handled logout and navigation.
        // For other errors (like network issues), we proceed to home and let the main screens handle offline states
        // as long as we still have a token, otherwise we go to login.
        final currentToken = await StorageService.getToken();
        if (!mounted) return;
        if (currentToken != null && currentToken.isNotEmpty) {
           Navigator.pushReplacementNamed(context, '/home');
        } else {
           Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
