import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'board_room_booking_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Room Details Page
//  Receives [roomData] from RoomBookingPage grid card.
// ─────────────────────────────────────────────────────────────────────────────
class RoomDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? roomData;
  const RoomDetailsPage({super.key, this.roomData});

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  static const _navy = Color(0xFF1E1E2C);
  static const _gold = Color(0xFFC0A062);

  DateTime _selectedDate = DateTime.now();
  int _partySize = 1;

  // ── Amenity definitions ────────────────────────────────────────────────
  static const _amenities = [
    {'icon': LucideIcons.wifi,            'label': 'High-Speed Wi-Fi'},
    {'icon': LucideIcons.monitorPlay,     'label': '4K Projector'},
    {'icon': LucideIcons.layoutDashboard, 'label': 'Smart Whiteboard'},
    {'icon': LucideIcons.airVent,         'label': 'Climate Control'},
    {'icon': LucideIcons.coffee,          'label': 'Barista Station'},
    {'icon': LucideIcons.video,           'label': 'VC-Ready'},
  ];

  // ── Recommended rooms ──────────────────────────────────────────────────
  static const _related = [
    {
      'title': 'Aston Martin',
      'tag': 'BRAND ROOM',
      'image':
          'https://images.unsplash.com/photo-1577412647305-991150c7d163?w=800&q=80',
      'capacity': 'Up to 7 people',
      'description': 'Exclusive space designed with Aston Martin elegance.',
    },
    {
      'title': 'BMW M',
      'tag': 'BRAND ROOM',
      'image':
          'https://images.unsplash.com/photo-1621609764095-b32bbe35cf3a?w=800&q=80',
      'capacity': 'Up to 8 people',
      'description': 'Performance-inspired meeting room for fast decisions.',
    },
    {
      'title': 'Day Office',
      'tag': 'DAY OFFICE',
      'image':
          'https://images.unsplash.com/photo-1593642632823-8f7853647efd?w=800&q=80',
      'capacity': '1–2 people',
      'description': 'Private, quiet office for focused individual work.',
    },
  ];

  // ── Helpers ────────────────────────────────────────────────────────────
  String get _title =>
      widget.roomData?['title']?.toString() ?? 'Board Room';

  String get _image =>
      widget.roomData?['image']?.toString() ??
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80';

  String get _description =>
      widget.roomData?['description']?.toString() ??
      'Our finest conference room equipped with state-of-the-art technology for seamless presentations and executive meetings.';

  String get _capacity =>
      widget.roomData?['capacity']?.toString() ?? 'Up to 15 people';

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _navy,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _navy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E6E1),
      appBar: AppBar(
        title: Text(
          _title.toUpperCase(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.inter(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ───────────────────────────────────────────────
            Stack(
              children: [
                Image.network(
                  _image,
                  height: size.height * 0.40,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: size.height * 0.40,
                    color: Colors.grey[300],
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                // Bottom label
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        color: _gold,
                        child: Text(
                          widget.roomData?['tag']?.toString() ??
                              'BOARD ROOM',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Main content ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildAboutSection(size)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildAvailabilityCard(context)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAboutSection(size),
                        const SizedBox(height: 28),
                        _buildAvailabilityCard(context),
                      ],
                    ),
            ),

            // ── Recommended ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You might also like',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 310,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _related.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (ctx, i) {
                        final r = _related[i];
                        return _RelatedCard(room: r);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Sticky bottom CTA ────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoardRoomBookingPage(
                    roomData: widget.roomData,
                  ),
                ),
              ),
              icon: const Icon(LucideIcons.calendar,
                  size: 16, color: Colors.white),
              label: Text(
                'CHECK AVAILABILITY',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── About section ─────────────────────────────────────────────────────
  Widget _buildAboutSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick stat chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatChip(LucideIcons.users, _capacity),
            _StatChip(LucideIcons.mapPin, '5th Floor, Tower A'),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          'About This Room',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _description,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.75,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 28),

        // Amenity grid
        Text(
          'Corporate Amenities',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size.width > 400 ? 3 : 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: _amenities.length,
          itemBuilder: (_, i) => _AmenityTile(
            icon: _amenities[i]['icon'] as IconData,
            label: _amenities[i]['label'] as String,
          ),
        ),
      ],
    );
  }

  // ── Quick availability card ───────────────────────────────────────────
  Widget _buildAvailabilityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Booking',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 20),

          // Date field
          _fieldLabel('Date'),
          GestureDetector(
            onTap: _pickDate,
            child: _inputBox(
              _formatDate(_selectedDate),
              LucideIcons.calendarDays,
            ),
          ),

          const SizedBox(height: 14),

          // Party size
          _fieldLabel('Party Size'),
          _inputBox('$_partySize guest${_partySize == 1 ? '' : 's'}',
              LucideIcons.users),
          const SizedBox(height: 4),
          // Guest counter
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SmallBtn(
                  icon: LucideIcons.minus,
                  onPressed: _partySize > 1
                      ? () => setState(() => _partySize--)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$_partySize',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                ),
                _SmallBtn(
                  icon: LucideIcons.plus,
                  onPressed: () => setState(() => _partySize++),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoardRoomBookingPage(
                    roomData: widget.roomData,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                'BOOK NOW',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _inputBox(String val, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                val,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: Colors.grey[400]),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFC0A062)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E1E2C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AmenityTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: const Color(0xFFC0A062)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: const Color(0xFF1E1E2C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final Map<String, String> room;
  const _RelatedCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailsPage(roomData: room),
        ),
      ),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                room['image']!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 150, color: Colors.grey[200]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    color: Colors.grey[100],
                    child: Text(
                      room['tag']!,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room['title']!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E2C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.users,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          room['capacity']!,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RoomDetailsPage(roomData: room),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'VIEW ROOM',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
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

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _SmallBtn({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onPressed != null
              ? const Color(0xFFF5F4F0)
              : Colors.grey[100],
          border: Border.all(
            color: onPressed != null
                ? Colors.grey.shade300
                : Colors.grey.shade200,
          ),
        ),
        child: Icon(icon,
            size: 16,
            color: onPressed != null
                ? const Color(0xFF1E1E2C)
                : Colors.grey[300]),
      ),
    );
  }
}
