import 'package:flutter/material.dart';

import '../../core/services/firebase_auth_service.dart';
import '../../core/utils/responsive.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuthService().signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);

    return Scaffold(
      backgroundColor: const Color(0xFF221E1D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF302A28), Color(0xFF221E1D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.horizontalPadding(context),
                  compact ? 12 : 14,
                  Responsive.horizontalPadding(context),
                  compact ? 8 : 10,
                ),
                child: Row(
                  children: [
                    SizedBox(width: compact ? 36 : 40),
                    Expanded(
                      child: Text(
                        'Admin Dashboard',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.titleSize(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _logout(context),
                      child: Container(
                        width: compact ? 36 : 40,
                        height: compact ? 36 : 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3431),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF7C6F6A)),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFFFDDCE),
                          size: compact ? 18 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: AdminDashboardScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
