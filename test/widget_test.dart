// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/auth/presentation/pages/minimal_login_page.dart';

void main() {
  testWidgets('Shows login screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: MinimalLoginPage(),
        ),
      ),
    );

    expect(find.text('Please sign in to continue'), findsOneWidget);
  });
}
