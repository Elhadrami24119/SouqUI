import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_strings.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/seller/seller_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/notifications_screen.dart';
import 'mock/mock_service.dart';
import 'utils/theme.dart';
import 'widgets/connectivity_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConnectivityService().init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MarketplaceApp());
}

class MarketplaceApp extends StatefulWidget {
  const MarketplaceApp({super.key});

  @override
  State<MarketplaceApp> createState() => _MarketplaceAppState();
}

class _MarketplaceAppState extends State<MarketplaceApp> {
  final _locale = AppLocale();

  @override
  void initState() {
    super.initState();
    _locale.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _locale.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Souq Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale.value,
      supportedLocales: const [Locale('fr'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => ConnectivityWrapper(child: child!),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/seller': (ctx) => const SellerDashboard(),
        '/admin': (ctx) => const AdminDashboard(),
        '/notifications': (ctx) => const NotificationsScreen(),
      },
    );
  }
}
