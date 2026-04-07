import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/core/web_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Corporate Workspace Booking Page
//  Route: RoomBookingPage → RoomDetailsPage → BoardRoomBookingPage
//  Accepts optional [roomData] map so every room type can reuse this screen.
// ─────────────────────────────────────────────────────────────────────────────

class BoardRoomBookingPage extends StatefulWidget {
  /// Passed from RoomDetailsPage – keys: title, tag, image, capacity, description
  final Map<String, dynamic>? roomData;

  const BoardRoomBookingPage({super.key, this.roomData});

  @override
  State<BoardRoomBookingPage> createState() => _BoardRoomBookingPageState();
}

class _BoardRoomBookingPageState extends State<BoardRoomBookingPage> {
  // ── State ────────────────────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _guests = 10;

  static const _navy = Color(0xFF1E1E2C);
  static const _gold = Color(0xFFC0A062);
  static const _bg = Color(0xFFF5F5F5);

  // ── Helpers ──────────────────────────────────────────────────────────────
  String get _roomTitle =>
      widget.roomData?['title']?.toString() ?? 'Board Room';

  String get _roomCapacity =>
      widget.roomData?['capacity']?.toString() ?? 'Up to 15 people';

  int get _maxGuests {
    final matches = RegExp(r'\d+').allMatches(_roomCapacity).toList();
    if (matches.isEmpty) {
      return 30;
    }
    final values = matches
        .map((m) => int.tryParse(m.group(0) ?? ''))
        .whereType<int>()
        .toList();
    if (values.isEmpty) {
      return 30;
    }
    return values.reduce((a, b) => a > b ? a : b);
  }

  @override
  void initState() {
    super.initState();
    final max = _maxGuests;
    _guests = _guests.clamp(1, max);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // ── Pickers ──────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: _datePickerTheme,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: _datePickerTheme,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Widget _datePickerTheme(BuildContext ctx, Widget? child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _navy,
            onPrimary: Colors.white,
            secondary: _gold,
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: _navy,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _navy),
          ),
        ),
        child: child!,
      );

  // ── Confirm Logic ─────────────────────────────────────────────────────────
  void _confirm() {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    if (endMins <= startMins) {
      _showSnack('End time must be after start time.');
      return;
    }
    _showSuccessDialog();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: _gold, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gold check icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle2,
                    size: 32, color: _gold),
              ),
              const SizedBox(height: 20),
              Text(
                'Request Submitted!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your $_roomTitle booking request\nhas been sent for approval.',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey[500], height: 1.6),
              ),
              const SizedBox(height: 20),
              // Summary box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F4F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    _dialogRow(LucideIcons.calendarDays,
                        _formatDate(_selectedDate)),
                    const SizedBox(height: 8),
                    _dialogRow(LucideIcons.clock,
                        '${_formatTime(_startTime)} – ${_formatTime(_endTime)}'),
                    const SizedBox(height: 8),
                    _dialogRow(LucideIcons.users, '$_guests Attendees'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // back to details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'DONE',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _navy,
              ),
            ),
          ),
        ],
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.05;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: HoverCursor(
          child: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'BOOK ${_roomTitle.toUpperCase()}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: hPad, vertical: size.height * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero compact header ────────────────────────────────────────
            _HeroHeader(roomData: widget.roomData),
            SizedBox(height: size.height * 0.03),

            // ── DATE ─────────────────────────────────────────────────────
            _sectionLabel('Meeting Date'),
            const SizedBox(height: 10),
            _TapCard(
              icon: LucideIcons.calendarDays,
              caption: 'Date',
              value: _formatDate(_selectedDate),
              onTap: _pickDate,
            ),

            SizedBox(height: size.height * 0.025),

            // ── TIME RANGE ───────────────────────────────────────────────
            _sectionLabel('Time Range'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TapCard(
                    icon: LucideIcons.sunrise,
                    caption: 'Start',
                    value: _formatTime(_startTime),
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(LucideIcons.moveRight,
                      size: 16, color: Colors.grey[400]),
                ),
                Expanded(
                  child: _TapCard(
                    icon: LucideIcons.sunset,
                    caption: 'End',
                    value: _formatTime(_endTime),
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.025),

            // ── GUEST COUNTER ────────────────────────────────────────────
            _sectionLabel('Number of Guests'),
            const SizedBox(height: 10),
            _GuestSelector(
              guests: _guests,
              maxGuests: _maxGuests.clamp(5, 30),
              onChanged: (v) => setState(() => _guests = v),
            ),

            SizedBox(height: size.height * 0.03),

            // ── SUMMARY CARD ─────────────────────────────────────────────
            _SummaryCard(
              roomTitle: _roomTitle,
              date: _formatDate(_selectedDate),
              timeRange: '${_formatTime(_startTime)} – ${_formatTime(_endTime)}',
              guests: _guests,
            ),

            SizedBox(height: size.height * 0.035),

            // ── CTA ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(LucideIcons.calendarCheck,
                    size: 18, color: Colors.white),
                label: Text(
                  'REQUEST RESERVATION',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Colors.grey[500],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hero compact header  (shows room image + name at top of booking page)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final Map<String, dynamic>? roomData;
  const _HeroHeader({this.roomData});

  @override
  Widget build(BuildContext context) {
    final img = roomData?['image'] as String? ??
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80';
    final title = roomData?['title']?.toString() ?? 'Board Room';
    final cap = roomData?['capacity']?.toString() ?? 'Up to 15 people';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(img, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1E1E2C))),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.70),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(LucideIcons.users,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                cap,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0A062),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'CORPORATE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
//  Tappable field card  (Date / Start / End)
// ─────────────────────────────────────────────────────────────────────────────
class _TapCard extends StatelessWidget {
  final IconData icon;
  final String caption;
  final String value;
  final VoidCallback onTap;

  const _TapCard({
    required this.icon,
    required this.caption,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 13, color: const Color(0xFFC0A062)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Guest selector widget  (counter + slider combined)
// ─────────────────────────────────────────────────────────────────────────────
class _GuestSelector extends StatelessWidget {
  final int guests;
  final int maxGuests;
  final ValueChanged<int> onChanged;

  const _GuestSelector({
    required this.guests,
    required this.maxGuests,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
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
      child: Column(
        children: [
          // Counter row — FittedBox prevents overflow on small screens
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleBtn(
                  icon: LucideIcons.minus,
                  onPressed: guests > 5
                      ? () => onChanged((guests - 1).clamp(5, maxGuests))
                      : null,
                ),
                const SizedBox(width: 28),
                Column(
                  children: [
                    Text(
                      '$guests',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1E2C),
                      ),
                    ),
                    Text(
                      'people',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 28),
                _CircleBtn(
                  icon: LucideIcons.plus,
                  onPressed: guests < maxGuests
                      ? () => onChanged((guests + 1).clamp(5, maxGuests))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: const Color(0xFF1E1E2C),
              inactiveTrackColor: Colors.grey[200],
              thumbColor: const Color(0xFFC0A062),
              overlayColor: const Color(0xFFC0A062).withOpacity(0.15),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              min: 5,
              max: maxGuests.toDouble(),
              value: guests.toDouble().clamp(5, maxGuests.toDouble()),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5 min',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.grey[400])),
              Text('$maxGuests max',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleBtn({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final active = onPressed != null;
    return HoverCursor(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFFF5F4F0) : Colors.grey[100],
            border: Border.all(
              color: active ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? const Color(0xFF1E1E2C) : Colors.grey[300],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Booking Summary card
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String roomTitle;
  final String date;
  final String timeRange;
  final int guests;

  const _SummaryCard({
    required this.roomTitle,
    required this.date,
    required this.timeRange,
    required this.guests,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(LucideIcons.clipboardList,
                  size: 14, color: Color(0xFFC0A062)),
              const SizedBox(width: 8),
              Text(
                'BOOKING SUMMARY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: const Color(0xFFC0A062),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.white12, height: 20),
          _row(LucideIcons.building2, 'Room', roomTitle),
          const SizedBox(height: 10),
          _row(LucideIcons.calendarDays, 'Date', date),
          const SizedBox(height: 10),
          _row(LucideIcons.clock, 'Time', timeRange),
          const SizedBox(height: 10),
          _row(LucideIcons.users, 'Guests', '$guests people'),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                  fontSize: 11, color: Colors.white38),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
}
