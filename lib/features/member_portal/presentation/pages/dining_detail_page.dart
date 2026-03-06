import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DiningDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;

  const DiningDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<DiningDetailPage> createState() => _DiningDetailPageState();
}

class _DiningDetailPageState extends State<DiningDetailPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: CustomScrollView(
        slivers: [
          // 1. Hero Header
          SliverAppBar(
            expandedHeight: size.height * 0.5,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.imageUrl, // Ensure unique tag matching list
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300]),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Title Overlay
                  Positioned(
                    bottom: 40,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DINING / ${widget.title.toUpperCase()}",
                           style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: isWide ? 48 : 32,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Body
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, 
                vertical: 40
              ),
              child: _buildRestaurantDetails(context),
            ),
          ),
          
          // Bottom Padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildRestaurantDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1E2C),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.description,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Use our restaurant as the central meeting place in the club. Whether business lunch, candle light dinner, Sunday brunch, quick espresso or after work drink - in the various areas you and your guests can dine undisturbed or meet.",
           style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.6,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        
        // Info Grid
        _buildInfoRow(LucideIcons.clock, "Hours", "Today: 8:00 AM - 11:00 PM\nHappy Hour: 5:00 PM - 7:00 PM"),
        const Divider(height: 32),
        _buildInfoRow(LucideIcons.mapPin, "Location", "Level 3, Main Clubhouse\nOverlooking the race track"),
        const Divider(height: 32),
        _buildInfoRow(LucideIcons.shirt, "Dress Code", "Smart Casual\nNo sportswear after 6:00 PM"),
         const Divider(height: 32),
        _buildInfoRow(LucideIcons.phone, "Contact", "+49 89 215 368 60\nfrontdesk@driversclub.biz"),

      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, // Bold title
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }




}
