import 'package:flutter/material.dart';

import '../chatbot/chatbot_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  final List<_ShellItem> _items = const [
    _ShellItem(icon: Icons.home_filled, label: 'Home'),
    _ShellItem(icon: Icons.forum_rounded, label: 'AI Chat'),
    _ShellItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF221E1D),
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2725),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF675B57)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF2A47F).withOpacity(0.10),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0x33E39A75)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: selected ? 34 : 28,
                            height: 3,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFF6B493)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFF6B493)
                                            .withOpacity(0.35),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          Icon(
                            item.icon,
                            color: selected
                                ? const Color(0xFFFFDDCE)
                                : const Color(0xFFC7B9B2),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFFFFDDCE)
                                  : const Color(0xFFC7B9B2),
                              fontSize: 10.5,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellItem {
  const _ShellItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
