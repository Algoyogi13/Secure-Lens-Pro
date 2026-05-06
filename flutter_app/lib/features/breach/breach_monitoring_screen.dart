import 'package:flutter/material.dart';

class BreachMonitoringScreen extends StatelessWidget {
  const BreachMonitoringScreen({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Breach Monitoring',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4740),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xAAEAA27F),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF2A47F).withOpacity(0.16),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Exposure Overview',
                            style: TextStyle(
                              color: Color(0xFFFFE6D9),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Real API Integration Pending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFCDB6),
                              fontSize: 22,
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
                        'This section will show real breach exposure results once the final API is connected.',
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
