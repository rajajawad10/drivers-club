import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/providers/order_history_provider.dart';
import 'package:pitstop/core/models/order_record.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          "MY ORDERS",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<OrderHistoryProvider>(
        builder: (context, historyProvider, child) {
          final orders = historyProvider.orders;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            children: [
              if (orders.isEmpty)
                _emptyState()
              else
                ...orders.map((order) => _orderTile(order)),
            ],
          );
        },
      ),
    );
  }

  Widget _orderTile(OrderRecord order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${order.id}",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                order.status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.itemSummary,
            style: GoogleFonts.inter(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.date,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                order.price,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.inbox, color: Colors.black45),
          const SizedBox(width: 10),
          Text(
            "No orders found.",
            style: GoogleFonts.inter(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
