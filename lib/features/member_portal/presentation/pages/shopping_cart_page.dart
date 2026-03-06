import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'checkout_delivery_page.dart';

class ShoppingCartPage extends StatefulWidget {
  final String eventName;
  final String date;
  final String time;
  final String image;
  final double price;
  final int initialQuantity;

  const ShoppingCartPage({
    super.key,
    this.eventName = "PETROL HOUR",
    this.date = "Thursday, February 19th 2026",
    this.time = "6:00 PM",
    this.image = "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200",
    this.price = 0.00,
    this.initialQuantity = 1,
  });

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6D7D2), // Beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: quantity > 0 
          ? _buildCartContent() 
          : _buildEmptyState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Your cart is empty!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Back to Events"),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double textScale = screenWidth / 375.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "SHOPPING CART",
                          style: GoogleFonts.inter(
                            fontSize: 24 * textScale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E1E2C),
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          "$quantity Item${quantity != 1 ? 's' : ''}",
                          style: GoogleFonts.inter(
                            fontSize: 14 * textScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // 2. CART ITEM
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Circular Thumbnail
                          CircleAvatar(
                            radius: screenWidth * 0.09, // Responsive radius
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(widget.image),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          // Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.eventName.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16 * textScale,
                                    color: const Color(0xFF1E1E2C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.eventName, // Subtitle/Type
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * textScale,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.date,
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * textScale,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  widget.time,
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * textScale,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                // Quantity & Trash
                                Row(
                                  children: [
                                    _quantityBtn(LucideIcons.minus, () => setState(() => quantity > 1 ? quantity-- : null)),
                                    _quantityDisplay(quantity),
                                    _quantityBtn(LucideIcons.plus, () => setState(() => quantity++)),
                                    SizedBox(width: screenWidth * 0.02),
                                    // Delete Button (Compact)
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Remove Item"),
                                            content: const Text("Are you sure you want to remove this event from your cart?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("CANCEL"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    quantity = 0; 
                                                  });
                                                  Navigator.pop(context); // Close dialog
                                                  
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Item removed from cart")),
                                                  );
                                                },
                                                child: const Text("DELETE", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0), // Reduced padding for compact layout
                                        child: Icon(Icons.delete_outline, size: 20 * textScale, color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          // Price & Timer
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.price == 0 ? "Free" : "€${widget.price.toStringAsFixed(2)}",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16 * textScale,
                                  color: const Color(0xFF1E1E2C),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Ticket Reserved For",
                                style: GoogleFonts.inter(
                                  fontSize: 10 * textScale,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "04:58",
                                style: GoogleFonts.inter(
                                  fontSize: 18 * textScale,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF1E1E2C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Divider(color: Colors.grey, thickness: 0.5),
                    SizedBox(height: screenHeight * 0.02),

                    // 3. SUBTOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Subtotal: ",
                          style: GoogleFonts.inter(
                            fontSize: 16 * textScale,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "€${(widget.price * quantity).toStringAsFixed(2)}",
                          style: GoogleFonts.inter(
                            fontSize: 18 * textScale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E1E2C),
                          ),
                        ),
                      ],
                    ),
                    // Use Spacer to push buttons to bottom in IntrinsicHeight
                    const Spacer(), 
                    SizedBox(height: screenHeight * 0.04),

                    // 4. ACTION BUTTONS
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.07, // Dynamic height
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () {
                              if (quantity > 0) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const CheckoutDeliveryPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.ease;

                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "PROCEED TO CHECKOUT",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13 * textScale,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.07, // Dynamic height
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: Colors.black12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "CONTINUE SHOPPING",
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 13 * textScale,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  Widget _quantityDisplay(int val) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        val.toString(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
}
