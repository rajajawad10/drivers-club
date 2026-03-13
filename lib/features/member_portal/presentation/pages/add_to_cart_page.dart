import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/features/member_portal/domain/models/cart_item.dart';
import 'package:pitstop/core/providers/cart_provider.dart';
import 'package:pitstop/features/member_portal/presentation/pages/shopping_cart_page.dart';

class AddToCartPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String imageUrl;
  final String date;
  final double price;

  const AddToCartPage({
    super.key,
    this.eventId = "event-1",
    this.eventName = "Petrol Hour",
    this.imageUrl = "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200",
    this.date = "",
    this.price = 0.00
  });

  @override
  State<AddToCartPage> createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    // 1. Screen size variables
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    // Calculate a text scale factor based on width to keep text proportional
    final double textScale = screenWidth / 375.0; // Base design width approx 375

    return Scaffold(
      // Background set to Charcoal Black for premium look
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.08), // Dynamic padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title in high contrast, broad serif font
                    Text(
                      widget.eventName.toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 32 * textScale, // Dynamic font size
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08), // Dynamic spacing

                    // Ticket Price & Selection Section
                    // Ticket Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Standard Entry",
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 18 * textScale)
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                                widget.price == 0 ? "Free" : "€${widget.price.toStringAsFixed(2)}",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20 * textScale,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ],
                        ),
                        // Compact Dropdown for Quantity Selection
                        Container(
                          height: screenHeight * 0.06, // Dynamic height
                          constraints: const BoxConstraints(minHeight: 45),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              menuMaxHeight: screenHeight * 0.3, // Dynamic menu height
                              value: quantity,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                              dropdownColor: Colors.white,
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.black,
                                fontSize: 20 * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    quantity = newValue;
                                  });
                                  HapticFeedback.selectionClick();
                                }
                              },
                              items: List.generate(11, (index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    "$index",
                                    style: GoogleFonts.playfairDisplay(
                                      color: quantity == index ? Colors.black : Colors.grey,
                                      fontWeight: quantity == index ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),
                    const Divider(color: Colors.white24),
                    SizedBox(height: screenHeight * 0.05),

                    // Total Section
                    double.parse((widget.price * quantity).toStringAsFixed(2)) > 0
                        ? Text(
                      "Total: €${(widget.price * quantity).toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22 * textScale,
                          fontWeight: FontWeight.bold
                      ),
                    ) : const SizedBox(),

                    SizedBox(height: screenHeight * 0.1),

                    // High-Contrast Button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07, // Dynamic button height
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700), // PitStop Yellow
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: Colors.grey[800],
                        ),
                        onPressed: quantity > 0 ? () {
                          Provider.of<CartProvider>(context, listen: false).addItem(
                            CartItem(
                              id: widget.eventId,
                              title: widget.eventName,
                              type: 'event',
                              image: widget.imageUrl,
                              subtitle: widget.date.isEmpty
                                  ? widget.eventName
                                  : widget.date,
                              price: widget.price,
                              quantity: quantity,
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShoppingCartPage(),
                            ),
                          );
                        } : null,
                        child: Text(
                          "ADD TO CART",
                          style: GoogleFonts.inter(
                            color: quantity > 0 ? Colors.black : Colors.white38,
                            fontSize: 18 * textScale,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }



}