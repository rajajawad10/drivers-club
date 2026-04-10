import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'notifications_page.dart';
import 'package:pitstop/core/responsive.dart';
import 'package:pitstop/core/utils/external_links.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/features/member_portal/presentation/pages/profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NEWSFEED PAGE  — matches website grid layout exactly
//  · Beige background
//  · "NEWSFEED" top-left bold heading + bell + calendar icons (outlined)
//  · 2-column grid: image on top, title + description below
//  · Footer: logo circle | Instagram | FAQ Terms Privacy
// ─────────────────────────────────────────────────────────────────────────────

// ── Data ──────────────────────────────────────────────────────────────────────
const List<Map<String, String>> _newsItems = [
  {
    'title':       "Let's get this started!",
    'description': 'Hier erfahren Sie alles, was Sie über diese App wissen müssen: Wie funktioniert\'s? Wo finde ich was?',
    'image':       'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    'date':        'Mar 01, 2026',
    'author':      'Club Team',
    'tag':         'WELCOME',
  },
  {
    'title':       'Special Menus',
    'description': 'Here you can find our current special menus.',
    'image':       'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
    'date':        'Feb 28, 2026',
    'author':      'Chef Team',
    'tag':         'DINING',
  },
  {
    'title':       'PETROL HOUR — March Edition',
    'description': 'The perfect opportunity to get to know other members in a relaxed setting over curated drinks.',
    'image':       'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80',
    'date':        'Feb 25, 2026',
    'author':      'Events Team',
    'tag':         'EVENT',
  },
  {
    'title':       'New Brand Rooms Available',
    'description': 'Discover our newly designed Aston Martin and BMW M brand rooms — now available for booking.',
    'image':       'https://images.unsplash.com/photo-1577412647305-991150c7d163?w=800&q=80',
    'date':        'Feb 20, 2026',
    'author':      'Club Team',
    'tag':         'ROOMS',
  },
  {
    'title':       'Geopolitical Lunch Series',
    'description': 'Join us for an exclusive afternoon discussing global trends with industry leaders.',
    'image':       'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&q=80',
    'date':        'Feb 12, 2026',
    'author':      'Club Team',
    'tag':         'LIFESTYLE',
  },
  {
    'title':       'Wine Cellar — Private Dinners',
    'description': 'An intimate candlelit setting surrounded by our finest wine collection. Reserve your table now.',
    'image':       'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800&q=80',
    'date':        'Feb 05, 2026',
    'author':      'Dining Team',
    'tag':         'DINING',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
class BlogListPage extends StatelessWidget {
  const BlogListPage({super.key});

  static const _bg      = Color(0xFFE8E6E0);
  static const _divider = Color(0xFFBFBDB7);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final r = R.of(context);
    final crossAxisCount =
        kIsWeb ? (r.isMobile ? 1 : 2) : (isWide ? 2 : 1);
    final content = SafeArea(
      child: Column(
        children: [
          if (!kIsWeb) ...[
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'NEWSFEED',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Bell icon
                  _OutlinedIconBtn(
                    icon: LucideIcons.bell,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage())),
                  ),
                  const SizedBox(width: 8),
                  // Calendar icon
                  _OutlinedIconBtn(
                    icon: LucideIcons.calendarDays,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MySchedulePage()),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: _divider, height: 1),
          ],

            // ── Grid ─────────────────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount >= 2 ? 0.85 : 0.72,
                ),
                itemCount: _newsItems.length,
                itemBuilder: (context, index) => _NewsCard(
                  item: _newsItems[index],
                  index: index,
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────────
            Divider(color: _divider, height: 1),
            LayoutBuilder(
              builder: (context, bc) {
                final compactFooter = bc.maxWidth < 520;
                final crown = Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 2),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.crown,
                        size: 13, color: Colors.black87),
                  ),
                );
                final ig = HoverCursor(
                  child: GestureDetector(
                    onTap: ExternalLinks.openInstagram,
                    child: const Icon(LucideIcons.instagram,
                        size: 20, color: Colors.black54),
                  ),
                );
                final links = Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: ['FAQ', 'Terms', 'Privacy']
                      .map(
                        (l) => Text(
                          l,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.black54),
                        ),
                      )
                      .toList(),
                );
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: compactFooter
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                crown,
                                const SizedBox(width: 12),
                                ig,
                              ],
                            ),
                            links,
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            crown,
                            ig,
                            links,
                          ],
                        ),
                );
              },
            ),
          ],
        ),
      );
    if (kIsWeb) {
      return WebScaffold(
        title: 'Newsfeed',
        selected: WebNavItem.newsfeed,
        onNavSelected: (item) => _handleWebNav(context, item),
        onBellTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotificationsPage())),
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
      case WebNavItem.communities:
        route = WebRoutes.communities;
        break;
    }
    Navigator.pushReplacementNamed(context, route);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  News Card — image top, title + description bottom (website style)
// ─────────────────────────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final Map<String, String> item;
  final int index;
  const _NewsCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlogDetailsPage(
            title:    item['title']!,
            author:   item['author']!,
            date:     item['date']!,
            imageUrl: item['image']!,
            tag:      item['tag']!,
            description: item['description']!,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image (top, full width) ─────────────────────────────────────
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  item['image']!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8E6E0),
                    child: const Icon(LucideIcons.image,
                        size: 36, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // ── Title + Description (bottom) ────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Expanded(
                      child: Text(
                        item['description']!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.5,
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
    ).animate().fadeIn(delay: (index * 80).ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Outlined icon button (bell / calendar)
// ─────────────────────────────────────────────────────────────────────────────
class _OutlinedIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OutlinedIconBtn({required this.icon, required this.onTap});

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

// ─────────────────────────────────────────────────────────────────────────────
//  Blog Details Page
// ─────────────────────────────────────────────────────────────────────────────
class BlogDetailsPage extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String imageUrl;
  final String tag;
  final String description;

  const BlogDetailsPage({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    required this.imageUrl,
    this.tag = 'NEWS',
    this.description = '',
  });

  static const _bg = Color(0xFFE8E6E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ── Hero image + back button ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: Colors.black, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8E6E0),
                  child: const Icon(LucideIcons.image,
                      size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    color: Colors.black,
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author + Date row
                  Row(
                    children: [
                      const Icon(LucideIcons.user,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(author,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.calendar,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(date,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE0D8CC)),
                  const SizedBox(height: 20),

                  // Description / body
                  Text(
                    description.isNotEmpty
                        ? description
                        : 'Stay tuned for more details about this story.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.8,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Full article body
                  Text(
                    'As a member of our exclusive club, you are among the first to receive this update. '
                        'We continuously strive to bring you the finest experiences — from curated events and '
                        'premium dining to world-class meeting facilities.\n\n'
                        'Our team is dedicated to ensuring every visit exceeds your expectations. '
                        'Whether you are here for business or leisure, we have crafted every detail '
                        'with your comfort and satisfaction in mind.\n\n'
                        'We look forward to welcoming you and making every moment memorable.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.8,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Colors.black87, width: 2),
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
                        children: ['FAQ', 'Terms', 'Privacy']
                            .map((l) => Padding(
                          padding:
                          const EdgeInsets.only(left: 16),
                          child: Text(l,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black54)),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}