import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Dining Booking Page
//  Receives [title], [image], [capacity] from the detail page.
// ─────────────────────────────────────────────────────────────────────────────
class DiningBookingPage extends StatefulWidget {
  final String title;
  final String image;
  final String? capacity;
  final DateTime? preselectedDate;
  final int? preselectedHour;
  final int? preselectedMinute;
  final int? preselectedGuests;

  const DiningBookingPage({
    super.key,
    required this.title,
    required this.image,
    this.capacity,
    this.preselectedDate,
    this.preselectedHour,
    this.preselectedMinute,
    this.preselectedGuests,
  });

  @override
  State<DiningBookingPage> createState() => _DiningBookingPageState();
}

class _DiningBookingPageState extends State<DiningBookingPage> {
  static const _bg   = Color(0xFFF5F5F5);
  static const _dark = Color(0xFF1A1A1A);

  late DateTime _date;
  late int _hour;
  late int _minute;
  late int _guests;

  final _notesCtrl = TextEditingController();
  bool _confirmed  = false;

  // ── Occasion options ───────────────────────────────────────────────────
  final _occasions = [
    'None',
    'Birthday',
    'Anniversary',
    'Business Dinner',
    'Celebration',
    'Other',
  ];
  String _selectedOccasion = 'None';

  @override
  void initState() {
    super.initState();
    _date   = widget.preselectedDate   ?? DateTime.now();
    _hour   = widget.preselectedHour   ?? 19;
    _minute = widget.preselectedMinute ?? 0;
    _guests = widget.preselectedGuests ?? 2;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _shortDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  String get _timeStr {
    final suffix = _hour < 12 ? 'AM' : 'PM';
    final h      = _hour % 12 == 0 ? 12 : _hour % 12;
    return '${_pad(h)}:${_pad(_minute)} $suffix';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A1A1A),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title.toUpperCase(),
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            color: Colors.black,
          ),
        ),
      ),
      body: _confirmed ? _buildConfirmation() : _buildForm(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  FORM
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero ──────────────────────────────────────────────────────
          Stack(
            children: [
              Image.network(
                widget.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 200, color: Colors.grey[400]),
              ),
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
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16, left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESERVATION',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.capacity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.users,
                              size: 12, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text(
                            widget.capacity!,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section label ──────────────────────────────────────
                _sectionLabel('Reservation Details'),
                const SizedBox(height: 16),

                // ── Date ──────────────────────────────────────────────
                _fieldLabel('DATE'),
                GestureDetector(
                  onTap: _pickDate,
                  child: _inputRow(
                    _shortDate(_date),
                    LucideIcons.calendarDays,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Time ──────────────────────────────────────────────
                _fieldLabel('TIME'),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: _boxDecor(),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.clock,
                          size: 16, color: Colors.black45),
                      const SizedBox(width: 12),
                      // Hour
                      _timeSpin(
                        value: _hour,
                        onUp: () =>
                            setState(() => _hour = (_hour + 1) % 24),
                        onDown: () => setState(
                            () => _hour = (_hour - 1 + 24) % 24),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ),
                      // Minute
                      _timeSpin(
                        value: _minute,
                        onUp: () => setState(
                            () => _minute = (_minute + 15) % 60),
                        onDown: () => setState(
                            () => _minute = (_minute - 15 + 60) % 60),
                      ),
                      const Spacer(),
                      Text(
                        _timeStr,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Guests ────────────────────────────────────────────
                _fieldLabel('NUMBER OF GUESTS'),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: _boxDecor(),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.users,
                          size: 16, color: Colors.black45),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _guests,
                            icon: const Icon(LucideIcons.chevronDown,
                                size: 16, color: Colors.black45),
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
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Occasion ──────────────────────────────────────────
                _sectionLabel('Special Occasion'),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _occasions.map((o) {
                    final selected = _selectedOccasion == o;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedOccasion = o),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? _dark : Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color:
                                selected ? _dark : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          o,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // ── Special Requests ──────────────────────────────────
                _sectionLabel('Special Requests'),
                const SizedBox(height: 12),
                Container(
                  decoration: _boxDecor(),
                  child: TextField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.black87),
                    cursorColor: _dark,
                    decoration: InputDecoration(
                      hintText:
                          'Dietary requirements, table preferences, allergies...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Summary card ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _dark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reservation Summary',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _summaryRow(
                          LucideIcons.utensils, 'Venue', widget.title),
                      _summaryRow(LucideIcons.calendarDays, 'Date',
                          _shortDate(_date)),
                      _summaryRow(
                          LucideIcons.clock, 'Time', _timeStr),
                      _summaryRow(LucideIcons.users, 'Guests',
                          '$_guests guest${_guests == 1 ? '' : 's'}'),
                      if (_selectedOccasion != 'None')
                        _summaryRow(LucideIcons.partyPopper, 'Occasion',
                            _selectedOccasion),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── CTA ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _confirmed = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _dark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    icon: const Icon(LucideIcons.calendarCheck,
                        size: 16, color: Colors.white),
                    label: Text(
                      'CONFIRM RESERVATION',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'You can cancel or modify up to 24 hours before',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.black38),
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  CONFIRMATION SCREEN
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildConfirmation() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: const Icon(LucideIcons.calendarCheck,
                  size: 36, color: Colors.green),
            ),
            const SizedBox(height: 24),

            Text(
              'RESERVATION CONFIRMED!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: _dark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your table has been reserved. A confirmation\nwill be sent to your registered email.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 32),

            // Booking card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                  Row(
                    children: [
                      const Icon(LucideIcons.utensils,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFF0EFEB)),
                  const SizedBox(height: 16),
                  _confirmRow('Date', _formatDate(_date)),
                  _confirmRow('Time', _timeStr),
                  _confirmRow('Guests',
                      '$_guests guest${_guests == 1 ? '' : 's'}'),
                  if (_selectedOccasion != 'None')
                    _confirmRow('Occasion', _selectedOccasion),
                  if (_notesCtrl.text.trim().isNotEmpty)
                    _confirmRow('Notes', _notesCtrl.text.trim()),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Ref number
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.hash,
                      size: 13, color: Colors.black45),
                  const SizedBox(width: 6),
                  Text(
                    'Ref: DC-${DateTime.now().millisecondsSinceEpoch % 100000}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () {
                  // Pop all the way back to dining
                  int count = 0;
                  Navigator.popUntil(context, (route) => count++ >= 2);
                },
                child: Text(
                  'BACK TO DINING',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'View Dining',
                style: GoogleFonts.inter(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────────

  BoxDecoration _boxDecor() => BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _dark,
        ),
      );

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black38,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _inputRow(String val, IconData icon) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: _boxDecor(),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black45),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronDown,
                size: 14, color: Colors.black38),
          ],
        ),
      );

  Widget _timeSpin({
    required int value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) =>
      Column(
        children: [
          GestureDetector(
            onTap: onUp,
            child: const Icon(LucideIcons.chevronUp,
                size: 18, color: Colors.black45),
          ),
          const SizedBox(height: 4),
          Text(
            _pad(value),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onDown,
            child: const Icon(LucideIcons.chevronDown,
                size: 18, color: Colors.black45),
          ),
        ],
      );

  Widget _summaryRow(IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: Colors.white54),
            const SizedBox(width: 10),
            Text(
              '$label: ',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _confirmRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
              ),
            ),
          ],
        ),
      );
}
