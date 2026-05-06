import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({
    super.key,
    this.size = 108,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandAuraPainter(),
        child: Center(
          child: Container(
            width: size * 0.54,
            height: size * 0.54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B4740), Color(0xFF332D2B)],
              ),
              border: Border.all(
                color: const Color(0x66FFD6C4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF2A47F).withOpacity(0.24),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.shield_rounded,
              color: const Color(0xFFFFD7C4),
              size: size * 0.28,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandAuraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = const Color(0xAAF1A17D).withOpacity(0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final middleGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = const Color(0x99F6B493).withOpacity(0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0x66F6B493),
          Color(0xBBF6B493),
          Color(0x55FFD0B8),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, size.width * 0.34, outerGlow);
    canvas.drawCircle(center, size.width * 0.28, middleGlow);

    final arcRect = Rect.fromCircle(center: center, radius: size.width * 0.33);
    canvas.drawArc(arcRect, -math.pi / 2.6, math.pi * 1.75, false, highlight);

    final softRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x66FFD6C4);

    canvas.drawCircle(center, size.width * 0.3, softRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
