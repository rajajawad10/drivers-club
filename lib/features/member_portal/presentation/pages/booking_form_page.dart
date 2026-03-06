import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Booking Form Page
//  Matches the "Find Availability" UI in the design reference.
//  Reusable for Board Room, Brand Room, and Day Office.
// ─────────────────────────────────────────────────────────────────────────────
class BookingFormPage extends StatefulWidget {
  final String roomName;
  final String? imageUrl;

  const BookingFormPage({
    super.key,
    required this.roomName,
    this.imageUrl,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  static const _navy  = Color(0xFF1E1E2C);
  static const _gold  = Color(0xFFC0A062);

  DateTime _selectedDate = DateTime.now();
  int _startHour   = 15;
  int _startMinute = 15;
  int _endHour     = 15;
  int _endMinute   = 15;
  int _guests      = 1;

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
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
            primary: _navy,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _navy,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _navy),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  bool get _isValid {
    final startMins = _startHour * 60 + _startMinute;
    final endMins   = _endHour   * 60 + _endMinute;
    return endMins > startMins;
  }

  void _confirm() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          content: Row(children: [
            const Icon(LucideIcons.alertCircle, size: 16, color: _gold),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('End time must be after start time.',
                  style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      );
      return;
    }
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle2,
                    size: 30, color: _gold),
              ),
              const SizedBox(height: 18),
              Text(
                'Request Submitted!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.roomName} has been reserved\nfor $_guests guest${_guests == 1 ? '' : 's'} on ${_formatDate(_selectedDate)}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey[500], height: 1.6),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
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
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.2,
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

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.roomName.toUpperCase(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image (optional) ──────────────────────────────────────
            if (widget.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  widget.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 180, color: Colors.grey[200]),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Card ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Availability',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a date',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Date picker ────────────────────────────────────────
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _formatDate(_selectedDate),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _navy,
                              ),
                            ),
                          ),
                          const Icon(LucideIcons.calendarDays,
                              size: 18, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Time spinners ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _TimeSpinner(
                          label: 'Start',
                          hour: _startHour,
                          minute: _startMinute,
                          onHourUp:    () => setState(() => _startHour   = (_startHour   + 1) % 24),
                          onHourDown:  () => setState(() => _startHour   = (_startHour   - 1 + 24) % 24),
                          onMinUp:     () => setState(() => _startMinute = (_startMinute + 15) % 60),
                          onMinDown:   () => setState(() => _startMinute = (_startMinute - 15 + 60) % 60),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _TimeSpinner(
                          label: 'End',
                          hour: _endHour,
                          minute: _endMinute,
                          onHourUp:    () => setState(() => _endHour   = (_endHour   + 1) % 24),
                          onHourDown:  () => setState(() => _endHour   = (_endHour   - 1 + 24) % 24),
                          onMinUp:     () => setState(() => _endMinute = (_endMinute + 15) % 60),
                          onMinDown:   () => setState(() => _endMinute = (_endMinute - 15 + 60) % 60),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Guest dropdown ─────────────────────────────────────
                  _fieldLabel('Guests'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _guests,
                        icon: const Icon(LucideIcons.chevronDown, size: 18),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _navy,
                        ),
                        items: List.generate(
                          20,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(
                              '${i + 1} guest${i == 0 ? '' : 's'}',
                            ),
                          ),
                        ),
                        onChanged: (v) =>
                            setState(() => _guests = v ?? _guests),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── CTA ────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(
                        'CHECK AVAILABILITY',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.white,
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

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 0.4,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Time Spinner  (↑ HH : MM ↓)
// ─────────────────────────────────────────────────────────────────────────────
class _TimeSpinner extends StatelessWidget {
  final String label;
  final int    hour;
  final int    minute;
  final VoidCallback onHourUp;
  final VoidCallback onHourDown;
  final VoidCallback onMinUp;
  final VoidCallback onMinDown;

  const _TimeSpinner({
    required this.label,
    required this.hour,
    required this.minute,
    required this.onHourUp,
    required this.onHourDown,
    required this.onMinUp,
    required this.onMinDown,
  });

  static const _navy = Color(0xFF1E1E2C);
  static const _gold = Color(0xFFC0A062);

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Up arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SpinBtn(icon: LucideIcons.chevronUp, onTap: onHourUp),
              const SizedBox(width: 18),
              const Text('  ', style: TextStyle(fontSize: 18)), // spacer for colon
              const SizedBox(width: 18),
              _SpinBtn(icon: LucideIcons.chevronUp, onTap: onMinUp),
            ],
          ),
          // Values
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _pad(hour),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                ),
              ),
              Text(
                ' : ',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                _pad(minute),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                ),
              ),
            ],
          ),
          // Down arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SpinBtn(icon: LucideIcons.chevronDown, onTap: onHourDown),
              const SizedBox(width: 18),
              const Text('  ', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 18),
              _SpinBtn(icon: LucideIcons.chevronDown, onTap: onMinDown),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpinBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _SpinBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: Colors.black54),
    );
  }
}
