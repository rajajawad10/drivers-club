import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/core/providers/cart_provider.dart';
import 'package:pitstop/core/providers/order_history_provider.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/auth/presentation/pages/minimal_login_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/member_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user already has a saved token from previous session
  final token = await SecureStorage.getToken();
  final isLoggedIn = token != null && token.isNotEmpty;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderHistoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: PiTStopApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class PiTStopApp extends StatelessWidget {
  final bool isLoggedIn;
  const PiTStopApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drivers Club',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Go to home if token exists, otherwise go to login
      home: isLoggedIn ? const MemberHomePage() : const MinimalLoginPage(),
    );
  }
}