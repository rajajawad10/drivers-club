import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/core/utils/external_links.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Club Benefits Page
//  Matches reference design exactly:
//  · Warm-beige background
//  · "CLUB BENEFITS" top-left + outlined bell/calendar icons
//  · 4 category tabs: Motorworld | Services | Travel | Committees
//  · 3-column (wide) / 1-column (mobile) grid
//  · White cards with circular image/icon + title caption
//  · Tap → modal popup (circular image + title)
//  · Committees tab: coloured circle + Lucide icon (no photo)
//  · Footer: logo · Instagram · FAQ Terms Privacy
// ─────────────────────────────────────────────────────────────────────────────
class ClubBenefitsContent extends StatefulWidget {
  const ClubBenefitsContent({super.key});

  @override
  State<ClubBenefitsContent> createState() => _ClubBenefitsContentState();
}

class _ClubBenefitsContentState extends State<ClubBenefitsContent> {
  static const _bg       = Color(0xFFF5F5F5);
  static const _cardBg = Colors.white;
  static const _divider  = Color(0xFFBFBDB7);

  // ── Active tab ─────────────────────────────────────────────────────────────
  int _tabIndex = 0;
  static const _tabs = ['Motorworld', 'Services', 'Travel', 'Committees'];

  // ── Data ──────────────────────────────────────────────────────────────────
  // Photo-based cards
  static const _motorworld = <Map<String, String>>[
    {
      'title': 'MOTORWORLD',
      'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80',
    },
    {
      'title': 'HOTEL AMERON MUNICH MOTORWORLD',
      'image': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=600&q=80',
    },
    {
      'title': 'RACING UNLEASHED',
      'image': 'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=600&q=80',
    },
    {
      'title': 'ZENITH HALL',
      'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=80',
    },
    {
      'title': 'ROSEWOOD MUNICH',
      'image': 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=600&q=80',
    },
  ];

  static const _services = <Map<String, String>>[
    {
      'title': 'WhatsApp Community',
      'image': 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=600&q=80',
    },
    {
      'title': 'Car Care Package',
      'image': 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=600&q=80',
    },
    {
      'title': 'Connect & Converse',
      'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
    },
  ];

  static const _travel = <Map<String, String>>[
    {
      'title': 'IAC Network',
      'image': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=600&q=80',
      'link':  'https://www.iacworldwide.com',
    },
  ];

  // Icon-based committees — no photo
  static const _committees = <Map<String, dynamic>>[
    {'title': "Cigar Regular's Table",    'icon': LucideIcons.flame,       'color': 0xFF5C3317},
    {'title': "Off-Road Regular's Table", 'icon': LucideIcons.truck,       'color': 0xFF7A7252},
    {'title': "Golf Regular's Table",     'icon': LucideIcons.target,      'color': 0xFF2A7B9B},
    {'title': "Hunting Regular's Table",  'icon': LucideIcons.leaf,        'color': 0xFF3A6B3A},
    {'title': "Classic Cars Table",       'icon': LucideIcons.car,         'color': 0xFF6B5E3A},
    {'title': "Real Estate Table",        'icon': LucideIcons.building2,   'color': 0xFF2A5F9E},
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showModal(BuildContext context, String title, String image) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close chevron
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.chevronDown,
                        size: 22, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                // Large circle image
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIconModal(BuildContext context, String title, IconData icon, int color) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.chevronDown,
                        size: 22, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(color),
                  ),
                  child: Icon(icon, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final cols   = isWide ? 3 : 1;

    return Container(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'CLUB BENEFITS',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _OutlinedIcon(icon: LucideIcons.bell,     onTap: () {}),
                const SizedBox(width: 8),
                _OutlinedIcon(icon: LucideIcons.calendar, onTap: () {}),
              ],
            ),
          ),

          // ── Category tabs ──────────────────────────────────────────────────
          Container(
            color: _bg,
            child: Column(
              children: [
                // Tab row
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
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? Colors.black
                                    : Colors.black45,
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
                // Full-width divider
                Divider(height: 1, color: _divider),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Grid ───────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 20 : 16),
                    child: _buildGrid(context, isWide, cols),
                  ),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid builder ──────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, bool isWide, int cols) {
    switch (_tabIndex) {
      case 0:
        return _photoGrid(context, _motorworld, isWide, cols);
      case 1:
        return _photoGrid(context, _services, isWide, cols);
      case 2:
        return _travelGrid(context, isWide, cols);
      case 3:
        return _iconGrid(context, isWide, cols);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _photoGrid(
    BuildContext context,
    List<Map<String, String>> items,
    bool isWide,
    int cols,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: isWide ? 20 : 16,
        crossAxisSpacing: isWide ? 20 : 12,
        childAspectRatio: isWide ? 0.9 : 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _PhotoCard(
        title: items[i]['title']!,
        image: items[i]['image']!,
        onTap: () => _showModal(ctx, items[i]['title']!, items[i]['image']!),
      ),
    );
  }

  Widget _travelGrid(BuildContext context, bool isWide, int cols) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: isWide ? 20 : 16,
        crossAxisSpacing: isWide ? 20 : 12,
        childAspectRatio: isWide ? 0.9 : 1.1,
      ),
      itemCount: _travel.length,
      itemBuilder: (ctx, i) {
        final item = _travel[i];
        return _PhotoCard(
          title: item['title']!,
          image: item['image']!,
          link:  item['link'],
          onTap: () => _showModal(ctx, item['title']!, item['image']!),
        );
      },
    );
  }

  Widget _iconGrid(BuildContext context, bool isWide, int cols) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: isWide ? 20 : 16,
        crossAxisSpacing: isWide ? 20 : 12,
        childAspectRatio: isWide ? 0.9 : 1.1,
      ),
      itemCount: _committees.length,
      itemBuilder: (ctx, i) {
        final c = _committees[i];
        return _IconCard(
          title:  c['title'] as String,
          icon:   c['icon']  as IconData,
          color:  Color(c['color'] as int),
          onTap: () => _showIconModal(
            ctx,
            c['title'] as String,
            c['icon']  as IconData,
            c['color'] as int,
          ),
        );
      },
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.10), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Club logo circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: const Center(
              child: Icon(LucideIcons.crown, size: 14, color: Colors.black87),
            ),
          ),
          // Instagram
          GestureDetector(
            onTap: ExternalLinks.openInstagram,
            child: const Icon(LucideIcons.instagram, size: 20, color: Colors.black54),
          ),
          // Links
          Row(
            children: ['FAQ', 'Terms', 'Privacy'].map((label) {
              return Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Card: circular photo
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoCard extends StatelessWidget {
  final String     title;
  final String     image;
  final String?    link;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.title,
    required this.image,
    this.link,
    required this.onTap,
  });

  static const _cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: _cardBg,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered circle image
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.4,
              ),
            ),
            // Optional link
            if (link != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.link, size: 12, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      link!,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF2563EB),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Card: coloured circle + Lucide icon (Committees tab)
// ─────────────────────────────────────────────────────────────────────────────
class _IconCard extends StatelessWidget {
  final String     title;
  final IconData   icon;
  final Color      color;
  final VoidCallback onTap;

  const _IconCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  static const _cardBg = Color(0xFFF0EFEB);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: _cardBg,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centred coloured circle
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Icon(icon, size: 52, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Outlined square icon button (bell / calendar) — reused from ClubHousePage
// ─────────────────────────────────────────────────────────────────────────────
class _OutlinedIcon extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;

  const _OutlinedIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
