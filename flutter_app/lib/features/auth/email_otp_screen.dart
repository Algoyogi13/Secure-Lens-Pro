import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/services/firebase_auth_service.dart';
import 'auth_brand_logo.dart';
import 'login_screen.dart';

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _otpController = TextEditingController();

  bool _verifying = false;
  bool _resending = false;

  Future<void> _verifyOtpAndCreateAccount() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _showMessage('Enter the 6-digit verification code.');
      return;
    }

    setState(() => _verifying = true);

    final verifyResult = await _apiService.verifyEmailOtp(
      email: widget.email,
      code: code,
      purpose: 'signup',
    );

    if (!mounted) return;

    if (verifyResult['success'] != true) {
      setState(() => _verifying = false);
      _showMessage(
        verifyResult['message']?.toString() ??
            'Verification failed. Please try again.',
      );
      return;
    }

    final signupError = await _authService.signUpUser(
      name: widget.name,
      email: widget.email,
      password: widget.password,
    );

    if (!mounted) return;
    setState(() => _verifying = false);

    if (signupError != null) {
      _showMessage(signupError);
      return;
    }

    _showMessage('Account created successfully. Please sign in.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);

    final result = await _apiService.requestEmailOtp(
      email: widget.email,
      purpose: 'signup',
    );

    if (!mounted) return;
    setState(() => _resending = false);

    _showMessage(
      result['message']?.toString() ?? 'A new verification code has been sent.',
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1120),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1627), Color(0xFF0A1120)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const AuthBrandLogo(size: 104),
                    const SizedBox(height: 18),
                    const Text(
                      'Verify Email OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We sent a 6-digit code to ${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF9AA3B2),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Verification Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A313B).withOpacity(0.78),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xAA8B4DFF),
                          width: 1.15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B4DFF).withOpacity(0.14),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                        decoration: const InputDecoration(
                          hintText: '000000',
                          hintStyle: TextStyle(color: Color(0xFF8C95A5)),
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: _verifying ? null : _verifyOtpAndCreateAccount,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF632BE8), Color(0xFFA45BFF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B4DFF).withOpacity(0.30),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          _verifying ? 'Verifying...' : 'Verify & Create Account',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resending ? null : _resendOtp,
                      child: Text(
                        _resending ? 'Sending...' : 'Resend Code',
                        style: const TextStyle(
                          color: Color(0xFFB98CFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
