import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/features/member_portal/presentation/pages/explore_events_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/order_details_page.dart';
import 'package:pitstop/features/member_portal/domain/models/cart_item.dart';

class OrderSuccessPage extends StatelessWidget {
  final List<CartItem> items;
  final double subtotal;
  final double serviceFee;
  final double total;

  const OrderSuccessPage({
    super.key,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double textScale = screenWidth / 375.0;

    return Scaffold(
      backgroundColor: const Color(0xFFD6D7D2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 86,
                width: 86,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.check, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                "Payment Successful",
                style: GoogleFonts.inter(
                  fontSize: 22 * textScale,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E2C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your order has been placed successfully.",
                style: GoogleFonts.inter(
                  fontSize: 13 * textScale,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsPage(
                          items: items,
                          subtotal: subtotal,
                          serviceFee: serviceFee,
                          total: total,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "VIEW ORDER DETAILS",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const ExploreEventsPage()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "BACK TO EVENTS",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
