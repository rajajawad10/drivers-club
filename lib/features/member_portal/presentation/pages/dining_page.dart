import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'notifications_page.dart';
import 'dining_booking_page.dart';
import 'package:pitstop/core/utils/external_links.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/features/member_portal/presentation/pages/profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Dining Page  — matches the reference design exactly
//  · Warm-beige background (#D9D7CF)
//  · "DINING" top-left + outlined bell/calendar icons
//  · 3 tabs: All | Restaurant | Private Dining (underline indicator)
//  · "All" tab: Restaurant section (1 card) + Private Dining section (3-col row)
//  · Tap restaurant card  → RestaurantDetailPage
//  · Tap private dining   → PrivateDiningDetailPage
// ─────────────────────────────────────────────────────────────────────────────
class DiningPage extends StatefulWidget {
  const DiningPage({super.key});

  @override
  State<DiningPage> createState() => _DiningPageState();
}

class _DiningPageState extends State<DiningPage> {
  static const _bg      = Color(0xFFF5F5F5);
  static const _divider = Color(0xFFBFBDB7);

  int _tabIndex = 0;
  static const _tabs = ['All', 'Restaurant', 'Private Dining'];

  // ── Data ──────────────────────────────────────────────────────────────────
  static const _restaurant = {
    'image':       'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=900&q=80',
    'title':       'Restaurant',
    'description': 'Our restaurant is the central meeting place in the club from breakfast to dinner...',
    'hours':       "Today's Hours: 8:00 AM - 11:00 PM",
  };

  static const _privateDining = <Map<String, String>>[
    {
      'image':       'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=700&q=80',
      'title':       'Wine Cellar',
      'description': 'An intimate candlelit setting surrounded by our finest wine collection. Perfect for exclusive dinners.',
      'capacity':    'Up to 10 guests',
    },
    {
      'image':       'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=700&q=80',
      'title':       'Executive Suite',
      'description': 'A sophisticated private dining suite with bespoke service, ideal for business entertaining.',
      'capacity':    'Up to 16 guests',
    },
    {
      'image':       'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=700&q=80',
      'title':       'Garden Room',
      'description': 'Light-flooded private room overlooking the landscaped gardens, ideal for celebratory lunches.',
      'capacity':    'Up to 14 guests',
    },
  ];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Container(
        color: _bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!kIsWeb)
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'DINING',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    _OutlinedIcon(
                      icon: LucideIcons.bell,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage())),
                    ),
                    const SizedBox(width: 8),
                    _OutlinedIcon(
                      icon: LucideIcons.calendar,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MySchedulePage()),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Tabs ─────────────────────────────────────────────────────────
              _tabBar(),
              // ── Content ──────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: _tabIndex == 0
                        ? _buildAll()
                        : _tabIndex == 1
                            ? _buildRestaurantTab()
                            : _buildPrivateDiningTab(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      return WebScaffold(
        title: 'Dining',
        selected: WebNavItem.dining,
        onNavSelected: (item) => _handleWebNav(context, item),
        onBellTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        ),
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
    }
    Navigator.pushReplacementNamed(context, route);
  }


  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _tabBar() {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (_, i) {
              final active = i == _tabIndex;
              return GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _tabs[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? Colors.black : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: active ? 28 : 0,
                      color: Colors.black,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Divider(height: 1, color: const Color(0xFFBFBDB7)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  "All" tab — Restaurant section + Private Dining section
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Restaurant section ────────────────────────────────────────────
        _sectionHeader('Restaurant', onSeeAll: () => setState(() => _tabIndex = 1)),
        const SizedBox(height: 12),
        _RestaurantCard(
          data: _restaurant,
          onTap: () => _goToRestaurant(),
        ),

        const SizedBox(height: 32),

        // ── Private Dining section ────────────────────────────────────────
        _sectionHeader('Private Dining', onSeeAll: () => setState(() => _tabIndex = 2)),
        const SizedBox(height: 12),
        _privateDiningRow(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  "Restaurant" tab
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRestaurantTab() {
    return _RestaurantCard(
      data: _restaurant,
      onTap: () => _goToRestaurant(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  "Private Dining" tab
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPrivateDiningTab() {
    final isWide = MediaQuery.of(context).size.width > 600;
    return isWide
        ? _privateDiningRow()
        : Column(
            children: _privateDining.map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PrivateDiningCard(
                    data: d,
                    onTap: () => _goToPrivateDining(d)),
              );
            }).toList(),
          );
  }

  // 3-column private dining row / horizontal scroll on mobile
  Widget _privateDiningRow() {
    final isWide = MediaQuery.of(context).size.width > 600;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _privateDining.map((d) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: d != _privateDining.last ? 12 : 0),
              child: _PrivateDiningCard(
                  data: d, onTap: () => _goToPrivateDining(d)),
            ),
          );
        }).toList(),
      );
    }
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _privateDining.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: 200,
          child: _PrivateDiningCard(
              data: _privateDining[i],
              onTap: () => _goToPrivateDining(_privateDining[i])),
        ),
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _goToRestaurant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RestaurantDetailPage(),
      ),
    );
  }

  void _goToPrivateDining(Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateDiningDetailPage(data: data),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black,
              decoration: TextDecoration.underline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Restaurant Card
// ─────────────────────────────────────────────────────────────────────────────
class _RestaurantCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onTap;

  const _RestaurantCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isWide ? 340 : double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image — no border radius
            Image.network(
              data['image']!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 200, color: Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title']!,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['description']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock,
                          size: 13, color: Colors.black54),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          data['hours']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private Dining Card  (image-only, no text below)
// ─────────────────────────────────────────────────────────────────────────────
class _PrivateDiningCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onTap;

  const _PrivateDiningCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Image.network(
            data['image']!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(height: 200, color: Colors.grey[400]),
          ),
          // Subtle gradient at bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.50),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10, left: 10,
            child: Text(
              data['title']!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Restaurant Detail Page
// ─────────────────────────────────────────────────────────────────────────────
class RestaurantDetailPage extends StatefulWidget {
  const RestaurantDetailPage({super.key});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  static const _bg = Color(0xFFD9D7CF);

  // Find Availability state
  DateTime _selectedDate = DateTime.now();
  int  _hour    = 16;
  int  _minute  = 0;
  int  _guests  = 1;

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 680;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    // Breadcrumb
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Dining',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                     Text(
                       '  /  Restaurant',
                       style: GoogleFonts.inter(
                           fontSize: 12, color: Colors.black45),
                     ),
                     const Spacer(),
                     _OutlinedIcon(
                       icon: LucideIcons.bell,
                       onTap: () => Navigator.push(context,
                           MaterialPageRoute(
                               builder: (_) => const NotificationsPage())),
                     ),
                     const SizedBox(width: 8),
                     _OutlinedIcon(
                       icon: LucideIcons.calendar,
                       onTap: () => Navigator.push(
                         context,
                         MaterialPageRoute(builder: (_) => const MySchedulePage()),
                       ),
                     ),
                   ],
                 ),
               ),

              // ── Title ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft,
                          size: 20, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'RESTAURANT',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hero image ───────────────────────────────────────────────
              Image.network(
                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80',
                height: isWide ? 320 : 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 220, color: Colors.grey[400]),
              ),

              const SizedBox(height: 24),

              // ── About + Find Availability ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildAbout()),
                          const SizedBox(width: 24),
                          SizedBox(
                              width: 280,
                              child: _buildFindAvailability()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAbout(),
                          const SizedBox(height: 24),
                          _buildFindAvailability(),
                        ],
                      ),
              ),

              const SizedBox(height: 32),

              // ── Hours ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hours',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Today's Hours: 8:00 AM - 11:00 PM",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.chevronRight,
                            size: 14, color: Colors.black54),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────────────────────
  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Our restaurant is the central meeting place in the club from breakfast to dinner. '
          'Here, members of our team are spoiled with culinary delights. Whether business lunch, '
          'candle light dinner, Sunday brunch, quick espresso or after work drink – in the various '
          'areas you and your guests can dine undisturbed or meet. The gastronomic concept was '
          'developed with Rainer Becker, founder of Roka and Zuma, among others. Our kitchen has '
          'specialized in changing, seasonal dishes with regional products.',
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.black87, height: 1.7),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
                fontSize: 13, color: Colors.black87, height: 1.7),
            children: const [
              TextSpan(
                  text:
                      'For reservations with more than 6 people, please contact our front desk via '),
              TextSpan(
                text: 'frontdesk@driversclub.biz',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' or +49 89 215 368 60'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Unser Restaurant ist vom Frühstück bis zum Abendessen der zentrale Treffpunkt im Club. '
          'Hier werden die Mitglieder unseres Teams mit kulinarischen Köstlichkeiten verwöhnt. '
          'Ob Business-Lunch, Candle-Light-Dinner, Sonntagsbrunch, schneller Espresso oder '
          'After-Work-Drink – in den verschiedenen Bereichen können Sie und Ihre Gäste ungestört '
          'speisen oder sich treffen. Das gastronomische Konzept wurde mit Rainer Becker, u.a. '
          'Gründer von Roka und Zuma, entwickelt. Unsere Küche hat sich auf wechselnde, saisonale '
          'Gerichte mit regionalen Produkten spezialisiert.',
          style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
              height: 1.7,
              fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black87,
                height: 1.7,
                fontStyle: FontStyle.italic),
            children: const [
              TextSpan(
                  text:
                      'Für Reservierungen mit mehr als 6 Personen, kontaktieren Sie bitte unseren Frontdesk via '),
              TextSpan(
                text: 'frontdesk@driversclub.biz',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
              TextSpan(text: ' oder +49 89 215 368 60'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Find Availability card ─────────────────────────────────────────────────
  Widget _buildFindAvailability() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Availability',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a date',
            style: GoogleFonts.inter(
                fontSize: 11, color: Colors.black45),
          ),
          const SizedBox(height: 14),

          // Date picker row
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_selectedDate),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(LucideIcons.calendarDays,
                      size: 18, color: Colors.black54),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time spinner
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour
                _timeSpinColumn(
                  value: _hour,
                  onUp:   () => setState(() => _hour = (_hour + 1) % 24),
                  onDown: () => setState(
                      () => _hour = (_hour - 1 + 24) % 24),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10),
                  child: Text(
                    ':',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                ),
                // Minute
                _timeSpinColumn(
                  value: _minute,
                  onUp:   () => setState(
                      () => _minute = (_minute + 15) % 60),
                  onDown: () => setState(
                      () => _minute = (_minute - 15 + 60) % 60),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Guests dropdown
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade200, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _guests,
                icon: const Icon(LucideIcons.chevronDown,
                    size: 16, color: Colors.black54),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                items: List.generate(
                  20,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(
                        '${i + 1} guest${i == 0 ? '' : 's'}'),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => _guests = v ?? _guests),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CHECK AVAILABILITY button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiningBookingPage(
                      title: 'Restaurant',
                      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80',
                      preselectedDate: _selectedDate,
                      preselectedHour: _hour,
                      preselectedMinute: _minute,
                      preselectedGuests: _guests,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'CHECK AVAILABILITY',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSpinColumn({
    required int value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onUp,
          child: const Icon(LucideIcons.chevronUp,
              size: 20, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          _pad(value),
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onDown,
          child: const Icon(LucideIcons.chevronDown,
              size: 20, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.black87, width: 2),
            ),
            child: const Center(
              child: Icon(LucideIcons.crown,
                  size: 12, color: Colors.black87),
            ),
          ),
          HoverCursor(
            child: GestureDetector(
              onTap: ExternalLinks.openInstagram,
              child: const Icon(LucideIcons.instagram,
                  size: 18, color: Colors.black54),
            ),
          ),
          Row(
            children: ['FAQ', 'Terms', 'Privacy'].map((l) =>
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(l,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.black54)),
              )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private Dining Detail Page
// ─────────────────────────────────────────────────────────────────────────────
class PrivateDiningDetailPage extends StatefulWidget {
  final Map<String, String> data;
  const PrivateDiningDetailPage({super.key, required this.data});

  @override
  State<PrivateDiningDetailPage> createState() =>
      _PrivateDiningDetailPageState();
}

class _PrivateDiningDetailPageState
    extends State<PrivateDiningDetailPage> {
  static const _bg = Color(0xFFD9D7CF);

  DateTime _selectedDate = DateTime.now();
  int _hour = 19, _minute = 0, _guests = 2;

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 680;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Dining',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black45)),
                    ),
                    Text('  /  ${widget.data['title']}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black45)),
                    const Spacer(),
                    _OutlinedIcon(
                      icon: LucideIcons.bell,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage())),
                    ),
                    const SizedBox(width: 8),
                    _OutlinedIcon(
                      icon: LucideIcons.calendar,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MySchedulePage()),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft,
                          size: 20, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.data['title']!.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hero image ────────────────────────────────────────────────
              Image.network(
                widget.data['image']!,
                height: isWide ? 320 : 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 220, color: Colors.grey[400]),
              ),

              const SizedBox(height: 24),

              // ── About + Availability ──────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: isWide
                    ? Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildAbout()),
                          const SizedBox(width: 24),
                          SizedBox(
                              width: 280,
                              child: _buildAvailability()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildAbout(),
                          const SizedBox(height: 24),
                          _buildAvailability(),
                        ],
                      ),
              ),

              const SizedBox(height: 32),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About',
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        const SizedBox(height: 12),
        Text(
          widget.data['description']!,
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.black87, height: 1.7),
        ),
        const SizedBox(height: 12),
        Text(
          'Capacity: ${widget.data['capacity']}',
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
                fontSize: 13, color: Colors.black87, height: 1.7),
            children: const [
              TextSpan(
                  text:
                      'To reserve a private dining room, please contact '),
              TextSpan(
                text: 'frontdesk@driversclub.biz',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' or +49 89 215 368 60'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailability() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find Availability',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          const SizedBox(height: 4),
          Text('Select a date',
              style: GoogleFonts.inter(
                  fontSize: 11, color: Colors.black45)),
          const SizedBox(height: 14),

          // Date
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(_selectedDate),
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  const Icon(LucideIcons.calendarDays,
                      size: 18, color: Colors.black54),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time spinner
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _spin(_hour,
                    () => setState(
                        () => _hour = (_hour + 1) % 24),
                    () => setState(
                        () => _hour = (_hour - 1 + 24) % 24)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10),
                  child: Text(':',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                ),
                _spin(_minute,
                    () => setState(
                        () => _minute = (_minute + 15) % 60),
                    () => setState(
                        () => _minute = (_minute - 15 + 60) % 60)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Guests
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade200, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _guests,
                icon: const Icon(LucideIcons.chevronDown,
                    size: 16, color: Colors.black54),
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
                items: List.generate(
                    20,
                    (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                            '${i + 1} guest${i == 0 ? '' : 's'}'))),
                onChanged: (v) =>
                    setState(() => _guests = v ?? _guests),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiningBookingPage(
                      title: widget.data['title']!,
                      image: widget.data['image']!,
                      capacity: widget.data['capacity'],
                      preselectedDate: _selectedDate,
                      preselectedHour: _hour,
                      preselectedMinute: _minute,
                      preselectedGuests: _guests,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'CHECK AVAILABILITY',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spin(int val, VoidCallback up, VoidCallback down) {
    return Column(
      children: [
        GestureDetector(
            onTap: up,
            child: const Icon(LucideIcons.chevronUp,
                size: 20, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(_pad(val),
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        const SizedBox(height: 4),
        GestureDetector(
            onTap: down,
            child: const Icon(LucideIcons.chevronDown,
                size: 20, color: Colors.black54)),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.black87, width: 2),
            ),
            child: const Center(
              child: Icon(LucideIcons.crown,
                  size: 12, color: Colors.black87),
            ),
          ),
          HoverCursor(
            child: GestureDetector(
              onTap: ExternalLinks.openInstagram,
              child: const Icon(LucideIcons.instagram,
                  size: 18, color: Colors.black54),
            ),
          ),
          Row(
            children: ['FAQ', 'Terms', 'Privacy'].map((l) =>
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(l,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54)),
              )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Outlined square icon button (shared)
// ─────────────────────────────────────────────────────────────────────────────
class _OutlinedIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OutlinedIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      );
}
