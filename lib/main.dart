import 'package:pitstop/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/features/auth/presentation/pages/minimal_login_page.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/core/providers/cart_provider.dart';
import 'package:pitstop/core/providers/order_history_provider.dart';

void main() {
  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderHistoryProvider()),

      ],
      child: const PiTStopApp(),
    ),
  );
}

class PiTStopApp extends StatelessWidget {
  const PiTStopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drivers Club',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MinimalLoginPage(),
    );
  }
}