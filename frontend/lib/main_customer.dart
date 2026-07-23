import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thiru_annamalaiyar_snacks/services/storage_service.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/address_controller.dart';
import 'views/pages/auth/login_page.dart';
import 'views/pages/splash_page.dart';
import 'views/pages/main_screen.dart';
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
        // ── Customer controllers ──────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(
          create: (context) => ProductController(
            orderController: context.read<OrderController>(),
          ),
        ),
      ],
      child: const AnnamalaiyarCustomerApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  await [
    Permission.location,
    Permission.notification,
  ].request();
}

class AnnamalaiyarCustomerApp extends StatelessWidget {
  const AnnamalaiyarCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annamalaiyar Snacks',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        // We tell SplashPage to route successful auths directly to /home
        '/': (context) => const SplashPage(defaultRoute: '/home'),
        '/login': (context) => const LoginPage(),

        // ── Customer surface ──────────────────────────────────────────────
        '/home': (context) => const MainScreen(initialIndex: 0),
        '/menu': (context) => const MainScreen(initialIndex: 1),
        '/cart': (context) => const MainScreen(initialIndex: 2),
        '/settings': (context) => const MainScreen(initialIndex: 3),
      },
    );
  }
}
