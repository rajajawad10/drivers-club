import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Notifications Page
//  Centralised page reached from the bell icon on Dining, Club House, Account.
//  Shows:  • My Orders table  (Order ID / Date / Items / Price / Status)
//          • House Account    (pending invoices)
// ─────────────────────────────────────────────────────────────────────────────

// ── Sample order data (replace with real API data later) ─────────────────────
const List<Map<String, String>> _kOrders = [
  {
    'id':     '1491969',
    'date':   'Feb 21, 2026',
    'item':   'PETROL HOUR Ticket',
    'price':  '€0.00',
    'status': 'COMPLETED',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _bg      = Color(0xFFF5F5F5);
  static const _divider = Color(0xFFBFBDB7);
  static const _amber   = Color(0xFFC0742A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'NOTIFICATIONS',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  // Bell (active – this is the notifications page)
                  _IconBtn(
                    icon: LucideIcons.bell,
                    active: true,
                    onTap: () {},          // already here
                  ),
                  const SizedBox(width: 8),
                  // Calendar
                  _IconBtn(
                    icon: LucideIcons.calendar,
                    active: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: _divider),

            // ── Body ──────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── My Orders section ─────────────────────────────────────
                    _sectionHeader(
                      title:    'My Orders',
                      badge:    _kOrders.length,
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 12),
                    _ordersTable(context),

                    const SizedBox(height: 36),

                    // ── House Account section ─────────────────────────────────
                    _sectionHeader(
                      title:    'House Account',
                      badge:    0,
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You have no pending invoices',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 48),
                    _footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header with optional badge + See All link ──────────────────────
  Widget _sectionHeader({
    required String title,
    required int badge,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        if (badge > 0) ...[ 
          const SizedBox(width: 8),
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$badge',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // ── Orders table ───────────────────────────────────────────────────────────
  Widget _ordersTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Table header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _colHeader('Order ID',  flex: 2),
                _colHeader('Date',      flex: 2),
                _colHeader('Items',     flex: 5, color: _amber),
                _colHeader('Price',     flex: 2, align: TextAlign.right),
                _colHeader('Status',    flex: 2, align: TextAlign.right),
              ],
            ),
          ),
          Divider(height: 1, color: _divider),
          // Data rows
          ..._kOrders.map((order) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    _colCell(order['id']!,    flex: 2),
                    _colCell(order['date']!,  flex: 2),
                    Expanded(
                      flex: 5,
                      child: Text(
                        order['item']!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _amber,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _colCell(order['price']!, flex: 2, align: TextAlign.right),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order['status']!,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: _divider),
            ],
          )),
        ],
      ),
    );
  }

  Widget _colHeader(String label, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    Color color = Colors.black54,
  }) =>
      Expanded(
        flex: flex,
        child: Text(
          label,
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      );

  Widget _colCell(String value, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) =>
      Expanded(
        flex: flex,
        child: Text(
          value,
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      );

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _footer() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: const Center(
              child: Icon(LucideIcons.crown, size: 12, color: Colors.black87),
            ),
          ),
          const Icon(LucideIcons.instagram, size: 18, color: Colors.black54),
          Row(
            children: ['FAQ', 'Terms', 'Privacy'].map((l) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                l,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              ),
            )).toList(),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reusable outlined icon button used in the header
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.transparent,
            border: Border.all(color: Colors.black38, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      );
}
