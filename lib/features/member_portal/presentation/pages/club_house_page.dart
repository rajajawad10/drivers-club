import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'booking_form_page.dart';
import 'notifications_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Club House Page  –  Matches the reference design exactly:
//  · Light warm-beige background
//  · "CLUB HOUSE" top-left, bell + calendar icons top-right
//  · 3-column (tablet) / 1-column (mobile) image grid
//  · Card = image + title + short description, NO background banner
//  · Tapping a venue card → ClubDetailPage
//  · Tapping Board Room / Brand Room / Day Office card → BookingFormPage
// ─────────────────────────────────────────────────────────────────────────────
class ClubHousePage extends StatelessWidget {
  const ClubHousePage({super.key});

  static const _bg = Color(0xFFF5F5F5);

  // ── Facility data ──────────────────────────────────────────────────────────
  static const List<Map<String, String>> _facilities = [
    {
      'title':       'Cartwalk',
      'image':       'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80',
      'description': 'The centerpiece is the 19 m long and almost 4 m high CartWalk. Here there are changing exhibitions of special vehicles and exhibits by renowned artists...',
      'bookable':    'false',
      'detail':      'The centerpiece is the 19-meter-long and almost 4-meter-high CartWalk. Here, changing exhibitions of special vehicles and exhibits by renowned artists are showcased. "Cars and Art" is the theme of this walk of fame. From the CartWalk, one can access the club\'s most important rooms: the restaurant, the Havana Lounge, the library, and the piazza. It also connects the two separate side wings. Up to 600 guests can be seated here, including the side wings with their spacious entrances.\n\nRequest for events via frontdesk@driversclub.biz',
    },
    {
      'title':       'Club Cinema',
      'image':       'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&q=80',
      'description': 'Whether it\'s a private viewing of a movie or F1 race, a company presentation or watching a vacation video with...',
      'bookable':    'false',
      'detail':      'The Club Cinema seats up to 40 guests in luxurious leather seating. Whether it\'s a private viewing of a movie or F1 race, a company presentation, or watching a vacation video with friends — the cinema is available for exclusive private hire with state-of-the-art 4K projection and surround sound.\n\nRequest for bookings via frontdesk@driversclub.biz',
    },
    {
      'title':       'Games Room',
      'image':       'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      'description': 'Whether darts, pool billiards or table football – in the Games Room with its own bar you can play a round in a...',
      'bookable':    'false',
      'detail':      'Whether darts, pool billiards, or table football — in the Games Room with its own bar you can play a round in a sophisticated atmosphere. The Games Room is open to all members and their guests during club hours. The integrated bar serves a curated selection of spirits, cocktails, and light bites.',
    },
    {
      'title':       'Rooftop',
      'image':       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      'description': 'Panoramic rooftop terrace for events, sundowners, and private gatherings above the city skyline...',
      'bookable':    'false',
      'detail':      'The Rooftop terrace offers breathtaking panoramic views of the city skyline. Ideal for sundowners, private events, and informal gatherings. The space can accommodate up to 80 guests and features outdoor lounge furniture, a bar, and a retractable sun shade.\n\nRequest for bookings via frontdesk@driversclub.biz',
    },
    {
      'title':       'Atrium',
      'image':       'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
      'description': 'Grand glass-roofed atrium for galas, product launches, and formal dinners up to 250 guests...',
      'bookable':    'false',
      'detail':      'The Atrium is the club\'s grandest event space — a stunning glass-roofed hall flooded with natural light. Perfect for product launches, gala dinners, fashion shows, and corporate events up to 250 guests. The space connects seamlessly to the CartWalk and the restaurant.\n\nRequest for bookings via frontdesk@driversclub.biz',
    },
    {
      'title':       'Havana Lounge',
      'image':       'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
      'description': 'Cuban-inspired luxury lounge with premium cigars, aged rum, and leather armchairs for after-dinner relaxation...',
      'bookable':    'false',
      'detail':      'The Havana Lounge is an intimate, Cuban-inspired retreat featuring curated premium cigars, aged rums, and classic leather armchairs. The ideal setting for post-dinner conversations, private gatherings, and a moment of refined relaxation away from the bustle of the city.',
    },
    // ── Bookable workspace rooms ────────────────────────────────────────────
    {
      'title':       'Board Room',
      'image':       'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=800&q=80',
      'description': 'Our executive board room is equipped with state-of-the-art technology for seamless presentations and global VC calls for up to 20 people...',
      'bookable':    'true',
      'detail':      'The Executive Board Room seats up to 20 people and is equipped with a 4K display, video conferencing system, high-speed Wi-Fi, and full catering service. Ideal for board meetings, executive briefings, and confidential negotiations.\n\nBook via the availability checker below.',
    },
    {
      'title':       'Brand Rooms',
      'image':       'https://images.unsplash.com/photo-1497215842964-222b430dc094?w=800&q=80',
      'description': 'Exclusively designed brand-themed meeting rooms — Aston Martin, BMW M, Genesis — each with its own character and identity...',
      'bookable':    'true',
      'detail':      'Our Brand Rooms are exclusively designed spaces themed after iconic luxury automotive brands. Each room — Aston Martin, BMW M, and Genesis — has its own bespoke interior, character, and atmosphere. Ideal for creative workshops, brand activations, and intimate strategy sessions.\n\nBook via the availability checker below.',
    },
    {
      'title':       'Day Offices',
      'image':       'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=800&q=80',
      'description': 'Private, quiet offices available for daily rental. Perfect for focused work, confidential calls or creative solitude...',
      'bookable':    'true',
      'detail':      'Our Day Offices are fully private, soundproofed workspaces available for rent by the day. Each office includes ergonomic seating, a standing desk, dual monitor setup, dedicated high-speed internet, and complimentary coffee service.\n\nBook via the availability checker below.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final cols   = isWide ? 3 : 1;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 20, color: Colors.black87),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Text(
                        'CLUB HOUSE',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Action icons
                    _HeaderIcon(
                      icon: LucideIcons.bell,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage())),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIcon(icon: LucideIcons.calendar, onTap: () {}),
                  ],
                ),
              ),
            ),

            // ── Grid ─────────────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  isWide ? 20 : 16,
                  0,
                  isWide ? 20 : 16,
                  40),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final f = _facilities[i];
                    return _FacilityCard(
                      facility: f,
                      onTap: () {
                        if (f['bookable'] == 'true') {
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => BookingFormPage(
                                roomName: f['title']!,
                                imageUrl: f['image'],
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => ClubDetailPage(
                                facility: f,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                  childCount: _facilities.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: isWide ? 24 : 20,
                  crossAxisSpacing: isWide ? 20 : 0,
                  // Let grid items size naturally
                  childAspectRatio: isWide ? 0.72 : 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Club Facility Grid Card
//  Design: bare image, then title + clipped description below — NO rounded
//  radius, NO coloured background, matches the reference screenshot exactly.
// ─────────────────────────────────────────────────────────────────────────────
class _FacilityCard extends StatelessWidget {
  final Map<String, String> facility;
  final VoidCallback onTap;

  const _FacilityCard({required this.facility, required this.onTap});

  bool get _bookable => facility['bookable'] == 'true';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white, // same as page bg — seamless
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ────────────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                color: Colors.grey[300],
                child: Image.network(
                  facility['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(LucideIcons.image,
                        size: 32, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // ── Text ─────────────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      facility['title']!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Description snippet
                    Flexible(
                      child: Text(
                        facility['description']!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.55,
                        ),
                      ),
                    ),
                    // "Book" hint for bookable rooms
                    if (_bookable) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar,
                              size: 11, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to check availability',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.black45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Club Detail Page
//  Matches the "CARTWALK" detail page in the reference:
//  breadcrumb, large title left, image right, body text
// ─────────────────────────────────────────────────────────────────────────────
class ClubDetailPage extends StatelessWidget {
  final Map<String, String> facility;

  const ClubDetailPage({super.key, required this.facility});

  static const _bg = Colors.white;

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
              // ── Header ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  children: [
                    // Breadcrumb
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Club House',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('/',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black45)),
                    ),
                    Text(
                      facility['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    const Spacer(),
                    _HeaderIcon(
                      icon: LucideIcons.bell,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage())),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIcon(icon: LucideIcons.calendar, onTap: () {}),
                  ],
                ),
              ),

              // ── Title ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Text(
                  facility['title']!.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: isWide ? 40 : 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // ── Body: text left + image right (wide) or stacked (narrow) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text
                          Expanded(
                            flex: 5,
                            child: _DetailBody(facility: facility),
                          ),
                          const SizedBox(width: 48),
                          // Image
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(
                                facility['image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(
                                  height: 260,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              facility['image']!,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(
                                height: 220,
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _DetailBody(facility: facility),
                        ],
                      ),
              ),

              // ── Footer ──────────────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black.withOpacity(0.08))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo placeholder
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.black87, width: 2),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.crown,
                            size: 16, color: Colors.black87),
                      ),
                    ),
                    // Socials
                    const Icon(LucideIcons.instagram,
                        size: 22, color: Colors.black54),
                    // Links
                    Row(
                      children: [
                        _link('FAQ'),
                        const SizedBox(width: 20),
                        _link('Terms'),
                        const SizedBox(width: 20),
                        _link('Privacy'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _link(String label) => Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.black54,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Detail Page body text
// ─────────────────────────────────────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  final Map<String, String> facility;
  const _DetailBody({required this.facility});

  @override
  Widget build(BuildContext context) {
    final paragraphs =
        (facility['detail'] ?? facility['description'] ?? '').split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((p) {
        final text = p.trim();
        final isLink = text.contains('frontdesk@') ||
            text.contains('Book via');
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.75,
              color: isLink
                  ? const Color(0xFFB5651D) // warm brown for links
                  : Colors.black87,
              fontStyle: FontStyle.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared header icon button (outlined square, as in the reference)
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.black26, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
