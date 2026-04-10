import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/core/responsive.dart';
import 'room_details_page.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/features/member_portal/presentation/pages/profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Room Booking Page  –  Browse & filter all available rooms
// ─────────────────────────────────────────────────────────────────────────────
class RoomBookingPage extends StatefulWidget {
  const RoomBookingPage({super.key});

  @override
  State<RoomBookingPage> createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  static const _navy = Color(0xFF1E1E2C);
  static const _gold = Color(0xFFC0A062);
  static const _bg   = Color(0xFFF5F5F5);

  // ── Room Data ──────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _allRooms = [
    {
      'title':       'Board Room',
      'tag':         'BOARD ROOM',
      'category':    'Board Room',
      'image':       'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=800&q=80',
      'description': 'Our finest conference room equipped with state-of-the-art technology for seamless executive meetings.',
      'capacity':    'Up to 15 people',
    },
    {
      'title':       'Aston Martin',
      'tag':         'BRAND ROOMS',
      'category':    'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1577412647305-991150c7d163?w=800&q=80',
      'description': 'An exclusive space designed with the elegance and precision of Aston Martin.',
      'capacity':    'Up to 8 people',
    },
    {
      'title':       'BMW M',
      'tag':         'BRAND ROOMS',
      'category':    'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1621609764095-b32bbe35cf3a?w=800&q=80',
      'description': 'Performance-inspired meeting room for high-octane discussions and fast decisions.',
      'capacity':    'Up to 8 people',
    },
    {
      'title':       'Genesis',
      'tag':         'BRAND ROOMS',
      'category':    'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1497215842964-222b430dc094?w=800&q=80',
      'description': 'Premium brand room with sophisticated interiors and advanced presentation amenities.',
      'capacity':    'Up to 6 people',
    },
    {
      'title':       'Fly With Me',
      'tag':         'BRAND ROOMS',
      'category':    'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1504384308090-c54be3855091?w=800&q=80',
      'description': 'Aviation-themed creative space designed to let your ideas take flight.',
      'capacity':    'Up to 10 people',
    },
    {
      'title':       'Rimowa',
      'tag':         'BRAND ROOMS',
      'category':    'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&q=80',
      'description': 'Iconic design meets functional meeting space for sharp, modern teams.',
      'capacity':    'Up to 8 people',
    },
    {
      'title':       'St. Moritz',
      'tag':         'BRAND ROOMS',
      'category':    'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1600508774662-8e11283d6a36?w=800&q=80',
      'description': 'Inspired by the luxury of the Swiss Alps — cozy, refined, and professional.',
      'capacity':    'Up to 6 people',
    },
    {
      'title':       'Day Office',
      'tag':         'DAY OFFICES',
      'category':    'Day Offices',
      'image':       'https://images.unsplash.com/photo-1593642632823-8f7853647efd?w=800&q=80',
      'description': 'Private, quiet offices available for daily rental. Perfect for deep focused work.',
      'capacity':    '1–2 people',
    },
  ];

  static const _tabs = ['All', 'Board Room', 'Brand Rooms', 'Day Offices'];
  String _activeTab = 'All';

  List<Map<String, String>> get _filtered => _activeTab == 'All'
      ? _allRooms
      : _allRooms.where((r) => r['category'] == _activeTab).toList();

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final cols   = isWide ? 2 : 1;
    final content = Column(
      children: [
          _buildTabs(),
          // Room count indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} room${_filtered.length == 1 ? '' : 's'} available',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? _emptyState()
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                        16, 0, 16, size.height * 0.04),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isWide ? 0.78 : 0.75,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _RoomCard(
                      room: _filtered[i],
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) =>
                              RoomDetailsPage(roomData: _filtered[i]),
                        ),
                      ),
                    ),
                  ),
          ),
      ],
    );

    if (kIsWeb) {
      return WebScaffold(
        title: 'Book a Room',
        selected: WebNavItem.bookRoom,
        onNavSelected: (item) => _handleWebNav(context, item),
        onCalendarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MySchedulePage()),
        ),
        child: content,
        showFooter: false,
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: content,
    );
  }

  void _handleWebNav(BuildContext context, WebNavItem item) {
    late String route;
    switch (item) {
      case WebNavItem.newsfeed:
        route = WebRoutes.newsfeed;
        break;
      case WebNavItem.events:
        route = WebRoutes.events;
        break;
      case WebNavItem.dining:
        route = WebRoutes.dining;
        break;
      case WebNavItem.bookRoom:
        route = WebRoutes.bookRoom;
        break;
      case WebNavItem.clubHouse:
        route = WebRoutes.clubHouse;
        break;
      case WebNavItem.clubBenefits:
        route = WebRoutes.clubBenefits;
        break;
      case WebNavItem.communities:
        route = WebRoutes.communities;
        break;
    }
    Navigator.pushReplacementNamed(context, route);
  }


  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BOOK A ROOM',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, color: Colors.black, size: 20),
            onPressed: () async {
              final result = await showSearch<Map<String, String>?>(
                context: context,
                delegate: _RoomSearchDelegate(rooms: _allRooms),
              );
              if (result != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomDetailsPage(roomData: result),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      );

  // ── Filter Tabs ───────────────────────────────────────────────────────────
  Widget _buildTabs() => Container(
        color: Colors.white,
        width: double.infinity,
        child: SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 0),
            itemBuilder: (_, i) {
              final tab = _tabs[i];
              final active = tab == _activeTab;
              return HoverCursor(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? _navy : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w800 : FontWeight.w500,
                        color: active ? _navy : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.layoutGrid, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No rooms in this category',
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Room Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final Map<String, String> room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  static const _navy = Color(0xFF1E1E2C);
  static const _gold = Color(0xFFC0A062);

  @override
  Widget build(BuildContext context) {
    return HoverCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── Image ──────────────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                    child: Image.network(
                      room['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(LucideIcons.image,
                            size: 32, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  // Subtle gradient so tag is readable
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),
                  ),
                  // Tag
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      color: _gold,
                      child: Text(
                        room['tag']!,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Capacity badge
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.users,
                              size: 10, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text(
                            room['capacity']!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          room['title']!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Amenity chips
                        Wrap(
                          spacing: 10,
                          children: [
                            _Chip(LucideIcons.wifi, 'Wi-Fi'),
                            _Chip(LucideIcons.monitorPlay, 'Projector'),
                            _Chip(LucideIcons.airVent, 'AC'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          room['description']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[500],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(LucideIcons.calendar,
                            size: 14, color: Colors.white),
                        label: Text(
                          'CHECK AVAILABILITY',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small amenity chip ────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFFC0A062)),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Room Search Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _RoomSearchDelegate extends SearchDelegate<Map<String, String>?> {
  final List<Map<String, String>> rooms;
  _RoomSearchDelegate({required this.rooms});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.search, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Type to search rooms...',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final q = query.toLowerCase().trim();
    final results = rooms.where((r) {
      return r['title']!.toLowerCase().contains(q) ||
             r['tag']!.toLowerCase().contains(q)   ||
             r['description']!.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.searchX, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No rooms found for "$query"',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final room = results[index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                room['image']!,
                width: 52, height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52, height: 52,
                  color: Colors.grey[200],
                  child: const Icon(LucideIcons.building2, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              room['title']!,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${room['tag']}  ·  ${room['capacity']}',
              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11),
            ),
            trailing: const Icon(LucideIcons.arrowRight,
                size: 16, color: Colors.black38),
            onTap: () => close(context, room),
          );
        },
      ),
    );
  }
}
