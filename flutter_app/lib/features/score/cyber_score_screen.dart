import 'package:flutter/material.dart';

class CyberScoreScreen extends StatelessWidget {
  const CyberScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  children: [
                    const Text(
                      'Cyber Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4740),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xAAEAA27F),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF2A47F).withOpacity(0.18),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Current Score',
                            style: TextStyle(
                              color: Color(0xFFFFE6D9),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '78 - MODERATE',
                            style: TextStyle(
                              color: Color(0xFFFFCDB6),
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3431),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF7C6F6A)),
                      ),
                      child: const Text(
                        'Your score reflects password strength, account hygiene, suspicious activity, and breach exposure patterns.',
                        style: TextStyle(
                          color: Color(0xFFD3C3BC),
                          fontSize: 14,
                          height: 1.5,
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
