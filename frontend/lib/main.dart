import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'views/pages/auth/login_page.dart';
import 'views/pages/splash_page.dart';
import 'constants.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(
          create: (context) => ProductController(
            orderController: context.read<OrderController>(),
          ),
        ),
      ],
      child: const AnnamalaiyarApp(),
    ),
  );
}

class AnnamalaiyarApp extends StatelessWidget {
  const AnnamalaiyarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annamalaiyar Chettinadu Snacks',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGold,
          primary: kGold,
          secondary: kRed,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.latoTextTheme(),
        scaffoldBackgroundColor: kCream,
      ),
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
