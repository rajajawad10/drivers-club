import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:pitstop/features/member_portal/presentation/pages/member_home_page.dart';

class MinimalLoginPage extends StatefulWidget {
  const MinimalLoginPage({super.key});

  @override
  State<MinimalLoginPage> createState() => _MinimalLoginPageState();
}

class _MinimalLoginPageState extends State<MinimalLoginPage> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginTapped() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Remove login from stack so back button does not return here
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MemberHomePage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/drivers_club.png',
                        height: 100,
                        errorBuilder: (_, __, ___) =>
                        const Icon(LucideIcons.car,
                            size: 80, color: Colors.black),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'DRIVERS & BUSINESS CLUB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Please sign in to continue',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(
                      color: Colors.black, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration:
                  _inputDecoration('Email Address', LucideIcons.mail),
                ),
                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVisible,
                  style: GoogleFonts.inter(
                      color: Colors.black, fontWeight: FontWeight.w500),
                  validator: (value) =>
                  value!.length < 6 ? 'Password too short' : null,
                  decoration: _inputDecoration(
                    'Password',
                    LucideIcons.lock,
                    suffix: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // API error message box
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    if (auth.status == AuthStatus.error &&
                        auth.errorMessage.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            auth.errorMessage,
                            style: GoogleFonts.inter(
                                color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Login button — shows spinner while loading
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed:
                      auth.isLoading ? null : _onLoginTapped,
                      child: auth.isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        'LOGIN',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: GoogleFonts.inter(
          color: Colors.redAccent, fontWeight: FontWeight.w500),
    );
  }
}