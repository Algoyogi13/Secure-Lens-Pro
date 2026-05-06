import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

class AdminGateScreen extends StatelessWidget {
  const AdminGateScreen({super.key});

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
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.horizontalPadding(context),
                  compact ? 14 : 18,
                  Responsive.horizontalPadding(context),
                  compact ? 18 : 22,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: compact ? 88 : 104,
                      height: compact ? 88 : 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF6B493).withOpacity(0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(compact ? 16 : 18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3A3431),
                          border: Border.all(
                            color: const Color(0xAAF2A47F),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF2A47F).withOpacity(0.14),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.block_rounded,
                          color: const Color(0xFFFFCEB6),
                          size: compact ? 32 : 38,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 18 : 22),
                    Text(
                      'Access Denied',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 24 : 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 10),
                    Text(
                      'Only admins can access this section.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFD3C3BC),
                        fontSize: compact ? 13 : 14,
                        height: 1.5,
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
