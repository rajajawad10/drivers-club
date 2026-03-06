
import 'package:pitstop/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pitstop/features/auth/presentation/pages/minimal_login_page.dart';



void main() {
  runApp(const PiTStopApp());
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
      themeMode: ThemeMode.system, // Or user preference
      home: const MinimalLoginPage(),
    );
  }
}
