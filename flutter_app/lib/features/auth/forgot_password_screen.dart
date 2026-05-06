import 'package:flutter/material.dart';

import '../../core/services/firebase_auth_service.dart';
import '../../core/utils/responsive.dart';
import 'auth_brand_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email address to continue.');
      return;
    }

    setState(() => _loading = true);
    final error = await _authService.sendPasswordResetLink(email);

    if (!mounted) return;
    setState(() => _loading = false);

    _showMessage(
      error ?? 'Password reset link sent. Check your inbox and spam folder.',
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final maxWidth = Responsive.pageMaxWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFF221E1D),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF302A28), Color(0xFF221E1D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context),
                compact ? 14 : 18,
                Responsive.horizontalPadding(context),
                compact ? 14 : 18,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth > 420 ? 420 : maxWidth),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: compact ? 22 : 24,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 2 : 6),
                    AuthBrandLogo(size: compact ? 92 : 104),
                    SizedBox(height: compact ? 14 : 18),
                    Text(
                      'Forgot Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 24 : 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 10),
                    Text(
                      'Enter your registered email address and we will send you a reset link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFD3C3BC),
                        fontSize: compact ? 12.5 : 13,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: compact ? 20 : 24),
                    _FieldLabel(compact: compact, text: 'Email'),
                    const SizedBox(height: 8),
                    _GlowField(
                      compact: compact,
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 14 : 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 18 : 22),
                    _PrimaryGlowButton(
                      compact: compact,
                      text: _loading ? 'Sending...' : 'Send Reset Link',
                      onTap: _loading ? null : _sendResetLink,
                    ),
                    SizedBox(height: compact ? 10 : 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: const Color(0xFFFFCEB6),
                          fontSize: compact ? 14 : 15,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.compact,
  });

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 14 : 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GlowField extends StatelessWidget {
  const _GlowField({
    required this.child,
    required this.compact,
  });

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A413E).withOpacity(0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xAAF2A47F),
          width: 1.15,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF2A47F).withOpacity(0.12),
            blurRadius: 14,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: const Color(0xFFC7B9B2),
              fontSize: compact ? 13.5 : 14.5,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compact ? 14 : 16,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _PrimaryGlowButton extends StatelessWidget {
  const _PrimaryGlowButton({
    required this.text,
    required this.onTap,
    required this.compact,
  });

  final String text;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: compact ? 52 : 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFE68F66), Color(0xFFF6B493)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF2A47F).withOpacity(0.28),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF2B2524),
            fontSize: compact ? 16 : 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
