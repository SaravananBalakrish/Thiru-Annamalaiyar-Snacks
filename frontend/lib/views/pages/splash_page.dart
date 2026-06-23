import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'main_screen.dart';
import 'auth/login_page.dart';
import '../../constants.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kGold.withValues(alpha: 0.2), width: 1),
              ),
              child: const Icon(Icons.bakery_dining, size: 60, color: kGold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: kGold),
          ],
        ),
      ),
    );
  }
}
