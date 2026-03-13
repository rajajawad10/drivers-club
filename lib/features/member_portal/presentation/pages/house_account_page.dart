import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HouseAccountPage extends StatelessWidget {
  const HouseAccountPage({super.key});

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
          "HOUSE ACCOUNT",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.receipt, color: Colors.black45),
              const SizedBox(width: 10),
              Text(
                "You have no pending invoices.",
                style: GoogleFonts.inter(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
