import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/core/providers/cart_provider.dart';
import 'package:pitstop/core/providers/order_history_provider.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/member_portal/presentation/providers/events_provider.dart';
import 'package:pitstop/features/auth/presentation/pages/minimal_login_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/member_home_page.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/features/member_portal/presentation/pages/blog_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/explore_events_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/dining_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/room_booking_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/club_house_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/club_benefits_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure debug paint overlays are disabled.
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintPointersEnabled = false;
  debugPaintLayerBordersEnabled = false;
  debugRepaintRainbowEnabled = false;

  // Check if user already has a saved token from previous session
  final token = await SecureStorage.getToken();
  final loggedOut = await SecureStorage.getLoggedOut();
  final hasLoggedIn = await SecureStorage.getHasLoggedIn();
  final isLoggedIn =
      !loggedOut && hasLoggedIn && token != null && token.isNotEmpty;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderHistoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
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
      scrollBehavior: AppScrollBehavior(),
      routes: {
        WebRoutes.newsfeed: (_) => const BlogListPage(),
        WebRoutes.events: (_) => const ExploreEventsPage(),
        WebRoutes.dining: (_) => const DiningPage(),
        WebRoutes.bookRoom: (_) => const RoomBookingPage(),
        WebRoutes.clubHouse: (_) => const ClubHousePage(),
        WebRoutes.clubBenefits: (_) => const ClubBenefitsScreen(),
      },
      // Go to home if token exists, otherwise go to login
      home: isLoggedIn ? const MemberHomePage() : const MinimalLoginPage(),
    );
  }
}