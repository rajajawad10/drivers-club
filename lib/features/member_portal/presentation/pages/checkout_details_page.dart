import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/providers/cart_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/features/member_portal/presentation/pages/order_success_page.dart';
import 'package:pitstop/features/member_portal/domain/models/cart_item.dart';
import 'package:pitstop/core/providers/order_history_provider.dart';
import 'package:pitstop/core/models/order_record.dart';
import 'package:flutter/services.dart';

class CheckoutDetailsPage extends StatefulWidget {
  const CheckoutDetailsPage({super.key});

  @override
  State<CheckoutDetailsPage> createState() => _CheckoutDetailsPageState();
}

class _CheckoutDetailsPageState extends State<CheckoutDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  String _selectedPayment = 'card';
  bool _isProcessing = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

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
          "CHECKOUT DETAILS",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 16 * textScale,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 24),
                children: [
                  Text(
                    "Contact Information",
                    style: GoogleFonts.inter(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1E2C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: "Full Name",
                    controller: _fullNameCtrl,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: "Email Address",
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return "Email is required";
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(email)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: "Phone Number",
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.isEmpty) {
                        return "Phone number is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Payment Method",
                    style: GoogleFonts.inter(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1E2C),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _paymentOption(
                    value: 'card',
                    label: "Credit / Debit Card",
                    subtitle: "Stripe secure checkout",
                    leadingIcon: LucideIcons.creditCard,
                  ),
                  if (_selectedPayment == 'card') ...[
                    const SizedBox(height: 14),
                    _buildField(
                      label: "Card Number",
                      controller: _cardNumberCtrl,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final input = value?.replaceAll(' ', '') ?? '';
                        if (input.isEmpty) {
                          return "Card number is required";
                        }
                        if (input.length < 12) {
                          return "Enter a valid card number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: "Name on Card",
                      controller: _cardNameCtrl,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name on card is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: "Expiry (MM/YY)",
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_ExpiryDateFormatter()],
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return "Expiry is required";
                              }
                              final expRegex = RegExp(r'^(\d{2})/(\d{2})$');
                              final match = expRegex.firstMatch(input);
                              if (match == null) {
                                return "Use MM/YY";
                              }
                              final month = int.tryParse(match.group(1) ?? '');
                              if (month == null || month < 1 || month > 12) {
                                return "Invalid month";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: "CVC",
                            controller: _cvcCtrl,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return "CVC is required";
                              }
                              if (input.length < 3) {
                                return "Invalid CVC";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  _paymentOption(
                    value: 'apple_pay',
                    label: "Apple Pay",
                    subtitle: "Fast and secure",
                    leadingIcon: LucideIcons.smartphone,
                  ),
                  const SizedBox(height: 10),
                  _paymentOption(
                    value: 'google_pay',
                    label: "Google Pay",
                    subtitle: "Tap to pay",
                    leadingIcon: LucideIcons.walletCards,
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final subtotal = cartProvider.totalPrice;
          const serviceFee = 5.00;
          final total = subtotal + serviceFee;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow("Subtotal", "€${subtotal.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  _summaryRow("Service Fee", "€${serviceFee.toStringAsFixed(2)}"),
                  const Divider(height: 20, color: Colors.black12),
                  _summaryRow(
                    "Total",
                    "€${total.toStringAsFixed(2)}",
                    isEmphasis: true,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) {
                                return;
                              }
              if (_selectedPayment == 'card' &&
                  ((_cardNumberCtrl.text.trim().isEmpty) ||
                      (_cardNameCtrl.text.trim().isEmpty) ||
                      (_expiryCtrl.text.trim().isEmpty) ||
                      (_cvcCtrl.text.trim().isEmpty))) {
                _formKey.currentState?.validate();
                return;
              }
                              final itemsSnapshot = cartProvider.items
                                  .map((item) => CartItem(
                                        id: item.id,
                                        title: item.title,
                                        type: item.type,
                                        image: item.image,
                                        subtitle: item.subtitle,
                                        price: item.price,
                                        quantity: item.quantity,
                                      ))
                                  .toList();
                              final subtotal = cartProvider.totalPrice;
                              const serviceFee = 5.00;
                              final total = subtotal + serviceFee;
                              final now = DateTime.now();
                              final orderRecord = OrderRecord(
                                id: now.millisecondsSinceEpoch.toString(),
                                date: "${now.day}/${now.month}/${now.year}",
                                itemSummary: itemsSnapshot.isEmpty
                                    ? "No items"
                                    : itemsSnapshot.length == 1
                                        ? itemsSnapshot.first.title
                                        : "${itemsSnapshot.first.title} +${itemsSnapshot.length - 1}",
                                price: "€${total.toStringAsFixed(2)}",
                                status: "COMPLETED",
                              );

                              setState(() => _isProcessing = true);
                              await Future.delayed(const Duration(seconds: 2));
                              if (!mounted) return;
                              setState(() => _isProcessing = false);
                              await Provider.of<OrderHistoryProvider>(context, listen: false)
                                  .addOrder(orderRecord);
                              cartProvider.clearCart();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderSuccessPage(
                                    items: itemsSnapshot,
                                    subtotal: subtotal,
                                    serviceFee: serviceFee,
                                    total: total,
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        "PAY NOW",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isEmphasis = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isEmphasis ? FontWeight.w900 : FontWeight.w600,
            color: const Color(0xFF1E1E2C),
          ),
        ),
      ],
    );
  }

  Widget _paymentOption({
    required String value,
    required String label,
    required String subtitle,
    required IconData leadingIcon,
  }) {
    final bool isSelected = _selectedPayment == value;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black12,
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(leadingIcon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
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
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? Colors.black : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.black),
              const SizedBox(height: 12),
              Text(
                "Processing Payment...",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
