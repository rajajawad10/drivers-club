
import 'package:pitstop/core/responsive.dart';
import 'package:pitstop/features/member_portal/presentation/pages/blog_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/explore_events_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/club_house_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/club_benefits_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/profile_page.dart';

import 'package:pitstop/features/member_portal/presentation/pages/dining_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/room_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const BookingsScreen(),
    const ClubBenefitsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: screens[currentIndex],
      bottomNavigationBar: _buildBottomNav(),
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
                  builder: (context) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
          ),
        ],
      );

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
    return Scaffold(
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
            child: screens[currentIndex],
          ),
        ],
      ),
    );
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
    return GestureDetector(
      onTap: onTap,
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
            GestureDetector(
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
    return GestureDetector(
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
    );
  }

  Widget _newsCard(BuildContext context, R r, String img, String title,
      String subtitle, String tag) {
    return Container(
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
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOOKINGS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
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
    return ListView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: r.hp, vertical: r.vs),
      itemCount: upcoming ? 2 : 5,
      itemBuilder: (context, index) =>
          _bookingCard(context, upcoming, index),
    );
  }

  Widget _bookingCard(BuildContext context, bool upcoming, int index) {
    final r = R.of(context);
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  upcoming
                      ? "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&q=80"
                      : "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=400&q=80",
                  height: r.adaptive(mobile: 90.0, tablet: 110.0, desktop: 120.0),
                  width:  r.adaptive(mobile: 90.0, tablet: 110.0, desktop: 120.0),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 90,
                    width: 90,
                    color: Colors.grey[200],
                    child: const Icon(LucideIcons.image,
                        size: 30, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              upcoming
                                  ? "Executive Suite"
                                  : "Deluxe Room",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: r.sp(15),
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: upcoming
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              upcoming ? "Confirmed" : "Completed",
                              style: GoogleFonts.inter(
                                fontSize: r.sp(9),
                                fontWeight: FontWeight.bold,
                                color: upcoming
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.calendarDays,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              upcoming
                                  ? "Feb 24 – Feb 26, 2026"
                                  : "Jan 10 – Jan 12, 2026",
                              style: GoogleFonts.inter(
                                  fontSize: r.sp(11),
                                  color: Colors.grey),
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
          if (upcoming)
            Container(
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
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CLUB BENEFITS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ClubBenefitsScreen extends StatelessWidget {
  const ClubBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ClubBenefitsContent();
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
    final r = R.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Notifications",
            style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: r.sp(16))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: EdgeInsets.symmetric(
                horizontal: r.hp, vertical: r.vs),
            children: [
              _notificationTile(r, LucideIcons.newspaper,
                  "Weekly Newsletter",
                  "Check out the new events for this week.",
                  "2 hrs ago"),
              _notificationTile(r, LucideIcons.checkCircle,
                  "Booking Confirmed",
                  "Your suite booking for Feb 24 is confirmed.",
                  "5 hrs ago"),
              _notificationTile(r, LucideIcons.info,
                  "Maintenance Alert",
                  "The pool will be closed for maintenance tomorrow.",
                  "1 day ago"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationTile(R r, IconData icon, String title,
      String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon,
            color: const Color(0xFFE45D25),
            size: r.adaptive(mobile: 22.0, tablet: 26.0, desktop: 28.0)),
        title: Text(title,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: r.sp(13))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: r.sp(12), color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text(time,
                style: GoogleFonts.inter(
                    fontSize: r.sp(10), color: Colors.grey[400])),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
