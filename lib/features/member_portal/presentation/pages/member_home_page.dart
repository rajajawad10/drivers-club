
import 'dart:convert';
import 'dart:typed_data';
import 'package:pitstop/core/responsive.dart';
import 'package:pitstop/features/member_portal/presentation/pages/blog_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/explore_events_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/club_house_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/club_benefits_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/profile_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/booking_details_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/notifications_page.dart';

import 'package:pitstop/features/member_portal/presentation/pages/dining_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/room_booking_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/core/web_utils.dart';

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const BookingsScreen(),
    const ClubBenefitsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().loadProfile();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthProvider>().loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    if (kIsWeb) {
      return const BlogListPage();
    }
    // On wide screens show a side nav instead of bottom nav
    if (r.isDesktop || r.isTablet) {
      return _WideLayout(
        currentIndex: _currentIndex,
        screens: _screens,
        onNavTap: (i) => setState(() => _currentIndex = i),
      );
    }
    return _MobileLayout(
      currentIndex: _currentIndex,
      screens: _screens,
      onNavTap: (i) => setState(() => _currentIndex = i),
    );
  }
}

// ── Mobile Layout ──────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final List<Widget> screens;
  final ValueChanged<int> onNavTap;
  const _MobileLayout(
      {required this.currentIndex,
        required this.screens,
        required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _confirmExit(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(context),
        body: screens[currentIndex],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    title: Text(
      "CLUB PORTAL",
      style: GoogleFonts.inter(
        color: const Color(0xFF1E1E2C),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
        fontSize: 16,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    actions: [
      IconButton(
        icon: const Icon(LucideIcons.bell, color: Color(0xFF1E1E2C)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const NotificationsPage()),
        ),
      ),
      const SizedBox(width: 8),
      // REPLACE YOUR ENTIRE constPadding BLOCK WITH THIS:
      Padding(
        padding: const EdgeInsets.only(right: 16.0), // The 'const' goes here
        child: Consumer2<UserProvider, AuthProvider>(
          // Rebuild when local image or profile changes
          builder: (context, userProvider, authProvider, child) {
            final avatarBase64 = authProvider.currentUser?.avatarBase64;
            final avatarUrl = authProvider.currentUser?.avatarUrl;
            final avatarBytes = _decodeBase64Image(avatarBase64);
            final imageProvider = userProvider.profileImageProvider ??
                (avatarBytes != null
                    ? MemoryImage(avatarBytes)
                    : (avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/user_profile.png')
                            as ImageProvider));
            return CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageProvider,
            );
          },
        ),
      ),
    ],
  );

  Uint8List? _decodeBase64Image(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final cleaned = value.startsWith('data:image')
          ? value.split(',').last
          : value;
      return base64Decode(cleaned);
    } catch (_) {
      return null;
    }
  }

  Widget _buildBottomNav() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFE45D25),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
      GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      elevation: 0,
      onTap: onNavTap,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendarCheck), label: "Bookings"),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.crown), label: "Club"),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.user), label: "Profile"),
      ],
    ),
  );

  Future<bool> _confirmExit(BuildContext context) async {
    if (currentIndex != 0) {
      onNavTap(0);
      return false;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("EXIT"),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ── Tablet / Desktop Side-Nav Layout ──────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final int currentIndex;
  final List<Widget> screens;
  final ValueChanged<int> onNavTap;
  const _WideLayout(
      {required this.currentIndex,
        required this.screens,
        required this.onNavTap});

  static const _items = [
    (icon: LucideIcons.home, label: 'Home'),
    (icon: LucideIcons.calendarCheck, label: 'Bookings'),
    (icon: LucideIcons.crown, label: 'Club'),
    (icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    final navWidth = r.isDesktop ? 200.0 : 72.0;
    return WillPopScope(
      onWillPop: () => _confirmExit(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            // Side rail
            Container(
              width: navWidth,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: r.isDesktop
                        ? Text(
                      'CLUB\nPORTAL',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: const Color(0xFF1E1E2C),
                        height: 1.3,
                      ),
                    )
                        : const Icon(LucideIcons.crown,
                        color: Color(0xFFE45D25), size: 26),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  ...List.generate(_items.length, (i) {
                    final item = _items[i];
                    final selected = i == currentIndex;
                    return _NavRailItem(
                      icon: item.icon,
                      label: item.label,
                      selected: selected,
                      showLabel: r.isDesktop,
                      onTap: () => onNavTap(i),
                    );
                  }),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // Main content
            Expanded(
              child: MaxWidthPage(
                child: WebSelectionArea(
                  child: screens[currentIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    if (currentIndex != 0) {
      onNavTap(0);
      return false;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("EXIT"),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _NavRailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  const _NavRailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFE45D25).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: selected
                        ? const Color(0xFFE45D25)
                        : Colors.grey[600]),
                if (showLabel) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFFE45D25)
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(
          horizontal: r.hp, vertical: r.vs),
      children: [
        Text(
          "Welcome back, Alex!",
          style: GoogleFonts.inter(
              fontSize: r.sp(15), color: Colors.grey[600]),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 4),
        Text(
          "Explore Services",
          style: GoogleFonts.playfairDisplay(
            fontSize: r.sp(22),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1E2C),
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(),

        SizedBox(height: r.vs),

        // Quick actions — 4 cols on mobile, 8 on tablet/desktop
        _buildQuickActions(context, r),

        SizedBox(height: r.vs * 1.4),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Latest News",
              style: GoogleFonts.playfairDisplay(
                fontSize: r.sp(19),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E2C),
              ),
            ),
            HoverCursor(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BlogListPage()),
                ),
                child: Text(
                  "View All",
                  style: GoogleFonts.inter(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE45D25),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: r.vs * 0.7),

        // News cards — single column on mobile, 2-col on tablet+
        r.isMobile
            ? Column(
          children: [
            _newsCard(context, r,
                "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80",
                "Let's get this started!",
                "Discover how the new club portal works.",
                "GENERAL"),
            SizedBox(height: r.vs * 0.8),
            _newsCard(context, r,
                "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80",
                "Special Menus",
                "Check out our seasonal dining options.",
                "EXCLUSIVE"),
          ],
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _newsCard(context, r,
                  "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80",
                  "Let's get this started!",
                  "Discover how the new club portal works.",
                  "GENERAL"),
            ),
            SizedBox(width: r.vs * 0.8),
            Expanded(
              child: _newsCard(context, r,
                  "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80",
                  "Special Menus",
                  "Check out our seasonal dining options.",
                  "EXCLUSIVE"),
            ),
          ],
        ),
        SizedBox(height: r.vs),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, R r) {
    final actions = [
      (icon: LucideIcons.partyPopper, label: 'Events'),
      (icon: LucideIcons.utensils,    label: 'Dining'),
      (icon: LucideIcons.bedDouble,   label: 'Rooms'),
      (icon: LucideIcons.gem,         label: 'Club'),
    ];
    final cols = r.isMobile ? 4 : 8;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: r.isMobile ? 0.75 : 1.1,
      children: actions
          .map((a) => _quickAction(context, r, a.icon, a.label))
          .toList(),
    );
  }

  Widget _quickAction(
      BuildContext context, R r, IconData icon, String label) {
    return HoverCursor(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (label == "Events") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExploreEventsPage()));
            } else if (label == "Dining") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DiningPage()));
            } else if (label == "Rooms") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RoomBookingPage()));
            } else if (label == "Club") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClubHousePage()));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: r.adaptive(mobile: 56.0, tablet: 64.0, desktop: 68.0),
                width:  r.adaptive(mobile: 56.0, tablet: 64.0, desktop: 68.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon,
                    color: const Color(0xFFE45D25),
                    size: r.adaptive(mobile: 24.0, tablet: 28.0, desktop: 30.0)),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r.sp(11),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E2C),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ).animate().scale(delay: 200.ms),
        ),
      ),
    );
  }

  Widget _newsCard(BuildContext context, R r, String img, String title,
      String subtitle, String tag) {
    return HoverCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      img,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(LucideIcons.image,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: r.sp(9),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE45D25),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: r.sp(17),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E2C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: r.sp(12), color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOOKINGS SCREEN  — Real rooms data
// ─────────────────────────────────────────────────────────────────────────────

// type: 'room' | 'event' | 'dining'
const List<Map<String, String>> _realRooms = [
  // ── UPCOMING ─────────────────────────────────────────────────────────────
  {
    'title':    'Board Room',
    'date':     'Mar 15 – Mar 15, 2026',
    'status':   'Confirmed',
    'type':     'room',
    'subtitle': 'Up to 15 people',
    'image':    'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=400&q=80',
  },
  {
    'title':    'PETROL HOUR',
    'date':     'Mar 19 – Mar 19, 2026',
    'status':   'Confirmed',
    'type':     'event',
    'subtitle': 'CartWalk • 6:00 PM',
    'image':    'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=400&q=80',
  },
  {
    'title':    'Restaurant',
    'date':     'Mar 22 – Mar 22, 2026',
    'status':   'Confirmed',
    'type':     'dining',
    'subtitle': 'Dinner • 7:30 PM',
    'image':    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&q=80',
  },
  {
    'title':    'Aston Martin',
    'date':     'Mar 28 – Mar 28, 2026',
    'status':   'Confirmed',
    'type':     'room',
    'subtitle': 'Up to 8 people',
    'image':    'https://images.unsplash.com/photo-1577412647305-991150c7d163?w=400&q=80',
  },

  // ── PAST ─────────────────────────────────────────────────────────────────
  {
    'title':    'BMW M',
    'date':     'Jan 10 – Jan 10, 2026',
    'status':   'Completed',
    'type':     'room',
    'subtitle': 'Up to 8 people',
    'image':    'https://images.unsplash.com/photo-1621609764095-b32bbe35cf3a?w=400&q=80',
  },
  {
    'title':    'GEOPOLITICAL LUNCH',
    'date':     'Feb 12 – Feb 12, 2026',
    'status':   'Completed',
    'type':     'event',
    'subtitle': 'Club House • 12:00 PM',
    'image':    'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=400&q=80',
  },
  {
    'title':    'Wine Cellar',
    'date':     'Jan 20 – Jan 20, 2026',
    'status':   'Completed',
    'type':     'dining',
    'subtitle': 'Private Dining • 8:00 PM',
    'image':    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
  },
  {
    'title':    'Genesis',
    'date':     'Jan 15 – Jan 15, 2026',
    'status':   'Completed',
    'type':     'room',
    'subtitle': 'Up to 6 people',
    'image':    'https://images.unsplash.com/photo-1497215842964-222b430dc094?w=400&q=80',
  },
  {
    'title':    'ASH WEDNESDAY',
    'date':     'Feb 18 – Feb 18, 2026',
    'status':   'Completed',
    'type':     'event',
    'subtitle': 'Restaurant • 8:00 AM',
    'image':    'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&q=80',
  },
  {
    'title':    'Garden Room',
    'date':     'Dec 15 – Dec 15, 2025',
    'status':   'Completed',
    'type':     'dining',
    'subtitle': 'Private Dining • 1:00 PM',
    'image':    'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=400&q=80',
  },
];

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFFE45D25),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFE45D25),
              labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 13),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Past"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBookingList(context, upcoming: true),
                _buildBookingList(context, upcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, {required bool upcoming}) {
    final r = R.of(context);
    final list = _realRooms
        .where((room) => upcoming
        ? room['status'] == 'Confirmed'
        : room['status'] == 'Completed')
        .toList();

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.calendarX2, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              upcoming ? "No upcoming bookings" : "No past bookings",
              style: GoogleFonts.inter(color: Colors.grey, fontSize: r.sp(14)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: r.hp, vertical: r.vs),
      itemCount: list.length,
      itemBuilder: (context, index) => _bookingCard(context, list[index], index),
    );
  }

  Widget _bookingCard(BuildContext context, Map<String, String> room, int index) {
    final r = R.of(context);
    final bool isConfirmed = room['status'] == 'Confirmed';
    final String type = room['type'] ?? 'room';

    // Type badge config
    final Map<String, dynamic> typeCfg = {
      'room':   {'label': 'ROOM',   'color': const Color(0xFF1E1E2C), 'icon': LucideIcons.doorOpen},
      'event':  {'label': 'EVENT',  'color': const Color(0xFF8B5E3C), 'icon': LucideIcons.calendarCheck},
      'dining': {'label': 'DINING', 'color': const Color(0xFF2E7D52), 'icon': LucideIcons.utensils},
    };
    final cfg = typeCfg[type]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── Image with type badge overlay ──────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.network(
                      room['image']!,
                      height: r.adaptive(mobile: 95.0, tablet: 110.0, desktop: 120.0),
                      width:  r.adaptive(mobile: 95.0, tablet: 110.0, desktop: 120.0),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 95, width: 95,
                        color: Colors.grey[200],
                        child: const Icon(LucideIcons.image, size: 30, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Type badge top-left
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: (cfg['color'] as Color),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cfg['icon'] as IconData, size: 9, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            cfg['label'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Text content ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              room['title']!,
                              style: GoogleFonts.inter(
                                fontSize: r.sp(13),
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              room['status']!,
                              style: GoogleFonts.inter(
                                fontSize: r.sp(8),
                                fontWeight: FontWeight.bold,
                                color: isConfirmed ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Subtitle (capacity / location+time)
                      Row(
                        children: [
                          Icon(cfg['icon'] as IconData, size: 12, color: Colors.grey),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              room['subtitle'] ?? '',
                              style: GoogleFonts.inter(fontSize: r.sp(11), color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Date
                      Row(
                        children: [
                          const Icon(LucideIcons.calendarDays, size: 12, color: Colors.grey),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              room['date']!,
                              style: GoogleFonts.inter(fontSize: r.sp(11), color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isConfirmed)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailsPage(booking: room),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Colors.grey.withOpacity(0.1))),
                ),
                child: Center(
                  child: Text(
                    "View Details",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: r.sp(13),
                      color: const Color(0xFFE45D25),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProfileContent();
}

// ─────────────────────────────────────────────────────────────────────────────
//  NOTIFICATIONS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsPage();
  }
}
