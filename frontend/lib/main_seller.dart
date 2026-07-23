import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thiru_annamalaiyar_snacks/services/storage_service.dart';
import 'controllers/seller_order_controller.dart';
import 'views/pages/auth/login_page.dart';
import 'views/pages/splash_page.dart';
import 'views/pages/seller/seller_dashboard_screen.dart';
import 'constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  debugPrint("Connected to: ${dotenv.env['API_BASE_URL']}");
  await StorageService.init();
  await _requestPermissions();
  runApp(
    MultiProvider(
      providers: [
        // ── Seller/admin controller ───────────────────────────────────────
        ChangeNotifierProvider(create: (_) => SellerOrderController()),
      ],
      child: const AnnamalaiyarSellerApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  await [
    Permission.location,
    Permission.notification,
  ].request();
}

class AnnamalaiyarSellerApp extends StatelessWidget {
  const AnnamalaiyarSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annamalaiyar Seller',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        // We tell SplashPage to route successful auths directly to /seller-dashboard
        '/': (context) => const SplashPage(defaultRoute: '/seller-dashboard'),
        '/login': (context) => const LoginPage(isSeller: true),

        // ── Seller surface (role = admin) ─────────────────────────────────
        '/seller-dashboard': (context) => const SellerDashboardScreen(),
      },
    );
  }
}
