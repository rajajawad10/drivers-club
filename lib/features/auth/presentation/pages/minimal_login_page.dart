import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/features/member_portal/presentation/pages/member_home_page.dart';
import 'package:pitstop/features/auth/presentation/pages/signup_page.dart';
import 'package:pitstop/features/auth/presentation/pages/forgot_password_page.dart';

class MinimalLoginPage extends StatefulWidget {
  const MinimalLoginPage({super.key});

  @override
  State<MinimalLoginPage> createState() => _MinimalLoginPageState();
}

class _MinimalLoginPageState extends State<MinimalLoginPage> {
  final _formKey = GlobalKey<FormState>();

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
                // --- HEADER SECTION (LOGO + TEXT) ---
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/drivers_club.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(LucideIcons.car, size: 80, color: Colors.black);
                        },
                      ),

                      const SizedBox(height: 25),

                      // Main Title Center Aligned
                      const Text(
                        "DRIVERS & BUSINESS CLUB",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22, // Size adjusted for screen width
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Sub-header
                      Text(
                        "Please sign in to continue",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- LOGIN FIELDS ---
                TextFormField(
                  style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w500),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    // Email regex pattern
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                  decoration: _inputDecoration("Email Address", LucideIcons.mail),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  obscureText: true,
                  style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w500),
                  validator: (value) => value!.length < 6 ? "Password too short" : null,
                  decoration: _inputDecoration("Password", LucideIcons.lock),
                ),

                // --- FORGOT PASSWORD LINK ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- LOGIN BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MemberHomePage()),
                        );
                      }
                    },
                    child: Text(
                      "LOGIN",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      child: Text(
                        "Create Account",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Input Field Styling Helper
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w500),
    );
  }
}