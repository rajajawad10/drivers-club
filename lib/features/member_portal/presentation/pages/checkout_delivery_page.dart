import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CheckoutDeliveryPage extends StatefulWidget {
  const CheckoutDeliveryPage({super.key});

  @override
  State<CheckoutDeliveryPage> createState() => _CheckoutDeliveryPageState();
}

class _CheckoutDeliveryPageState extends State<CheckoutDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  // Form values
  String firstName = "";
  String lastName = "";
  String email = "";

  @override
  Widget build(BuildContext context) {
    // Determine if screen is wide enough for split layout
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFD6D7D2), // Signature background
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CHECKOUT", 
                    style: GoogleFonts.inter(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1E2C),
                    )
                  ),
                  const SizedBox(height: 30),
                  
                  // 1. Progress Tracker
                  _buildProgressTracker(),
                  const SizedBox(height: 40),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: Form
                        Expanded(flex: 2, child: _buildContactForm(context)),
                        const SizedBox(width: 40),
                        // Right Side: Summary
                        Expanded(flex: 1, child: _buildOrderSummary()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildContactForm(context),
                        const SizedBox(height: 40),
                        _buildOrderSummary(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Row(
      children: [
        const Icon(LucideIcons.mapPin, size: 20, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          "Delivery", 
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)
        ),
        Container(
          width: 100, 
          height: 1, 
          color: Colors.grey, 
          margin: const EdgeInsets.symmetric(horizontal: 10)
        ),
        const Icon(LucideIcons.banknote, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          "Billing", 
          style: GoogleFonts.inter(color: Colors.grey)
        ),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Contact Information", 
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)
                ),
                Text(
                  "Edit", 
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Confirm your contact details are correct. This information will be used to receive your event ticket", 
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildTextField("First Name *", "", (val) => val!.isEmpty ? 'First Name is required' : null, (val) => firstName = val!)),
                const SizedBox(width: 20),
                Expanded(child: _buildTextField("Last Name *", "", (val) => val!.isEmpty ? 'Last Name is required' : null, (val) => lastName = val!)),
              ],
            ),
            const SizedBox(height: 20),
            // Email Field with Validation
            _buildTextField(
              "Email Address *", 
              "", 
              (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }

                // Email regex
                final emailRegex = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );

                if (!emailRegex.hasMatch(value)) {
                  return "Please enter a valid email";
                }

                return null;
              },
              (val) => email = val!,
              textInputType: TextInputType.emailAddress,
              hintText: "example@gmail.com"
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Proceed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Processing Checkout...")),
                    );
                    // Add your navigation logic here
                  }
                },
                child: Text(
                  "CONTINUE TO BILLING >", 
                  style: GoogleFonts.inter(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        // Item Details
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Stack for badge on icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF6A2B81), 
                  child: Icon(LucideIcons.dices, color: Colors.white, size: 28),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Text("1", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GAMES EVENING", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Games Evening", style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
                  Text("Ticket Reserved For", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("04:25", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w300, color: const Color(0xFF1E1E2C))),
                ],
              ),
            ),
            Text("€0.00", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 30),
        // Discount Code
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Color(0xFF212121), fontSize: 14), 
                decoration: InputDecoration(
                  hintText: "Enter discount code",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                debugPrint("Discount Applied!");
              },
              child: const Text(
                "APPLY",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            Text("€0.00", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, 
      String initialValue, 
      String? Function(String?)? validator,
      void Function(String?)? onSaved,
      {TextInputType textInputType = TextInputType.text, String? hintText}
    ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(color: Color(0xFF212121), fontSize: 16), 
          keyboardType: textInputType,
          validator: validator,
          onSaved: onSaved,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Show errors immediately
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFD700)),
            ),
            errorBorder: const OutlineInputBorder( // Red border on error
              borderSide: BorderSide(color: Colors.red),
            ),
            errorStyle: const TextStyle(color: Colors.red), // Red error text
          ),
        ),
      ],
    );
  }
}
