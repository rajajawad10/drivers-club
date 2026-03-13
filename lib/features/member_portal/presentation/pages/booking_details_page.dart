import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, String> booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double textScale = screenWidth / 375.0;

    final title = booking['title'] ?? 'Booking';
    final date = booking['date'] ?? '';
    final status = booking['status'] ?? '';
    final subtitle = booking['subtitle'] ?? '';
    final image = booking['image'] ?? '';
    final type = booking['type'] ?? 'booking';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "BOOKING DETAILS",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 14 * textScale,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 18),
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                height: screenWidth * 0.52,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: screenWidth * 0.52,
                  color: Colors.grey[200],
                  child: const Icon(LucideIcons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22 * textScale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1E2C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13 * textScale,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _infoCard(
            rows: [
              _infoRow(LucideIcons.calendarDays, "Date", date),
              _infoRow(LucideIcons.tag, "Type", type.toUpperCase()),
              _infoRow(LucideIcons.badgeCheck, "Status", status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required List<Widget> rows}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
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
