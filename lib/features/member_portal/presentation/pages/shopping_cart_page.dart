import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/features/member_portal/domain/models/cart_item.dart';
import 'package:pitstop/core/providers/cart_provider.dart';
import 'package:pitstop/features/member_portal/presentation/pages/checkout_delivery_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/explore_events_page.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

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
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildCartContent(context, cartProvider);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildCartContent(BuildContext context, CartProvider cartProvider) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double textScale = screenWidth / 375.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SHOPPING CART",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24 * textScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E2C),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                "${cartProvider.totalCount} Item${cartProvider.totalCount != 1 ? 's' : ''}",
                style: GoogleFonts.inter(
                  fontSize: 13 * textScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          Expanded(
            child: ListView.separated(
              itemCount: cartProvider.items.length,
              separatorBuilder: (_, __) => const Divider(height: 24, color: Colors.black12),
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return _CartItemTile(
                  item: item,
                  onIncrease: () => cartProvider.increaseQty(item.id),
                  onDecrease: () => cartProvider.decreaseQty(item.id),
                  onRemove: () => cartProvider.removeItem(item.id),
                );
              },
            ),
          ),
          _buildSummary(context, cartProvider, textScale, screenHeight),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    CartProvider cartProvider,
    double textScale,
    double screenHeight,
  ) {
    return Column(
      children: [
        const Divider(color: Colors.black12, thickness: 1),
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subtotal",
              style: GoogleFonts.inter(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              "€${cartProvider.totalPrice.toStringAsFixed(2)}",
              style: GoogleFonts.inter(
                fontSize: 18 * textScale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E1E2C),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.03),
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: cartProvider.isEmpty
                ? null
                : () {
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
          height: screenHeight * 0.07,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.black12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ExploreEventsPage()),
                (route) => false,
              );
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
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double textScale = screenWidth / 375.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: screenWidth * 0.085,
          backgroundColor: Colors.grey[300],
          backgroundImage: item.image.isNotEmpty ? NetworkImage(item.image) : null,
          child: item.image.isEmpty
              ? const Icon(LucideIcons.image, size: 20, color: Colors.grey)
              : null,
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 15 * textScale,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12 * textScale,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _QtyButton(icon: LucideIcons.minus, onTap: onDecrease),
                  _QtyDisplay(value: item.quantity),
                  _QtyButton(icon: LucideIcons.plus, onTap: onIncrease),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _confirmRemove(context),
                    child: const Icon(Icons.delete_outline, size: 18, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          item.price == 0 ? "Free" : "€${item.price.toStringAsFixed(2)}",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 14 * textScale,
            color: const Color(0xFF1E1E2C),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text("Are you sure you want to remove this item from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (shouldRemove == true) {
      onRemove();
    }
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}

class _QtyDisplay extends StatelessWidget {
  final int value;

  const _QtyDisplay({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        value.toString(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
}
