import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/features/member_portal/presentation/pages/add_to_cart_page.dart';
import 'package:pitstop/core/web_utils.dart';

class BalancedEventDetailsPage extends StatelessWidget {
  final String eventId;
  final String eventName;
  final String category;
  final String description;
  final String date;
  final String time;
  final String location;
  final String image;
  final Uint8List? imageBytes;
  final double price;

  const BalancedEventDetailsPage({
    super.key,
    this.eventId = "event-1",
    this.eventName = "GEOPOLITICAL LUNCH",
    this.category = "LIFESTYLE",
    this.description = "Join us for an exclusive afternoon discussing global trends with industry leaders.",
    this.date = "12 FEB",
    this.time = "12:00 PM",
    this.location = "Club House",
    this.image = "https://images.unsplash.com/photo-1528605248644-14dd04022ae1?w=800",
    this.imageBytes,
    this.price = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebScaffold(
        title: 'Event Details',
        selected: WebNavItem.events,
        onNavSelected: (item) => Navigator.pop(context),
        showFooter: false,
        child: _buildWebBody(context),
      );
    }
    // 1. Screen ki real dimensions
    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "EVENT DETAILS",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: screenW > 600 ? 20 : 16, // Responsive font size
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Proportional Image Height
              if (image.isNotEmpty || imageBytes != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: _buildImage(screenW, screenH),
                ),
  
              Padding(
                // Responsive padding (5% of width)
                padding: EdgeInsets.symmetric(horizontal: screenW * 0.05, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Responsive Text Sizes
                    Text(
                      eventName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: screenW * 0.07, // Approx 7% of width
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTag(category),
                    
                    const SizedBox(height: 24),
  
                    // 4 About Section
                    Text(
                      "About",
                      style: GoogleFonts.inter(
                        fontSize: screenW * 0.05, // Responsive header
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1E2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.isNotEmpty ? description : "Join us for an exclusive afternoon discussing global trends with industry leaders.",
                      style: GoogleFonts.inter(
                        fontSize: screenW * 0.04 > 15 ? 15 : screenW * 0.04, // Cap minimum readable size or scale
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
  
                    const SizedBox(height: 32),
  
                    // 5. Compact Event Card
                    _buildDetailsCard(context),
                    
                    // Bottom padding
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth >= 1200 ? 1100.0 : 960.0;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: _buildHeroImage(height: 360),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildTag(category),
                            const SizedBox(height: 24),
                            Text(
                              "About",
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1E2C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description.isNotEmpty
                                  ? description
                                  : "Join us for an exclusive afternoon discussing global trends with industry leaders.",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _buildDetailsCard(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroImage({required double height}) {
    final bytes = imageBytes ?? _decodeDataImage(image);
    if (bytes != null) {
      return Image.memory(
        bytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      image,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(LucideIcons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildImage(double screenW, double screenH) {
    final bytes = imageBytes ?? _decodeDataImage(image);
    if (bytes != null) {
      return Image.memory(
        bytes,
        height: screenH * 0.3,
        width: screenW,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      image,
      height: screenH * 0.3,
      width: screenW,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: screenH * 0.3,
        width: screenW,
        color: Colors.grey[200],
        child: const Icon(LucideIcons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Uint8List? _decodeDataImage(String value) {
    if (!value.startsWith('data:image')) return null;
    final parts = value.split(',');
    if (parts.length < 2) return null;
    try {
      return base64Decode(parts[1]);
    } catch (_) {
      return null;
    }
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Very light grey card
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _row(LucideIcons.calendar, "Date", date),
          const Divider(height: 24),
          _row(LucideIcons.clock, "Time", time),
          const Divider(height: 24),
          _row(LucideIcons.mapPin, "Location", location),
          
          const SizedBox(height: 24),
          // Bold Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddToCartPage(
                      eventId: eventId,
                      eventName: eventName,
                      price: price,
                      imageUrl: image,
                      date: date,
                    ),
                  ),
                );
              },
              child: Text(
                "REGISTER",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey[300]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E2C),
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
