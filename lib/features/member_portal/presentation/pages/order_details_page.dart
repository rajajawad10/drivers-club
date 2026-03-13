import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/features/member_portal/domain/models/cart_item.dart';

class OrderDetailsPage extends StatelessWidget {
  final List<CartItem> items;
  final double subtotal;
  final double serviceFee;
  final double total;

  const OrderDetailsPage({
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "ORDER DETAILS",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 16 * textScale,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 16),
          children: [
            _infoCard(
              title: "Order Summary",
              rows: [
                _infoRow("Subtotal", "€${subtotal.toStringAsFixed(2)}"),
                _infoRow("Service Fee", "€${serviceFee.toStringAsFixed(2)}"),
                _infoRow("Total", "€${total.toStringAsFixed(2)}", isEmphasis: true),
              ],
            ),
            const SizedBox(height: 16),
            _infoCard(
              title: "Payment",
              rows: [
                _infoRow("Method", "Card / Wallet"),
                _infoRow("Status", "Paid"),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Items",
              style: GoogleFonts.inter(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E2C),
              ),
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              _emptyItems()
            else
              ...items.map(
                (item) => _itemTile(
                  title: item.title,
                  subtitle: item.subtitle,
                  quantity: item.quantity,
                  price: item.price,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required List<Widget> rows}) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isEmphasis = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isEmphasis ? FontWeight.w900 : FontWeight.w600,
              color: const Color(0xFF1E1E2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile({
    required String title,
    required String subtitle,
    required int quantity,
    required double price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.ticket, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "x$quantity",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "€${price.toStringAsFixed(2)}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1E2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.inbox, color: Colors.black45),
          const SizedBox(width: 10),
          Text(
            "No items found.",
            style: GoogleFonts.inter(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
