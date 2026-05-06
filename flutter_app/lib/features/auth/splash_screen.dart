import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final auraSize = compact ? 220.0 : 260.0;
    final iconSize = compact ? 78.0 : 92.0;

    return Scaffold(
      backgroundColor: const Color(0xFF2D2826),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF352F2D),
              Color(0xFF221E1D),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.horizontalPadding(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPaint(
                      size: Size(auraSize, auraSize),
                      painter: _AuraPainter(progress: _controller.value),
                      child: SizedBox(
                        width: auraSize,
                        height: auraSize,
                        child: Center(
                          child: Icon(
                            Icons.shield_rounded,
                            size: iconSize,
                            color: const Color(0xFFFFD7C4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure Lens\nPro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 30 : 36,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        shadows: const [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  const _AuraPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16 - (i * 3)
        ..color = const Color(0xFFF1A17D).withOpacity(0.18 - (i * 0.03))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

      final radius = (size.width * 0.29) + (i * size.width * 0.07);
      canvas.drawCircle(center, radius, paint);
    }

    final swirl = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.058
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0xAAF6B493),
          Color(0x66FFD7C4),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    final r = size.width * 0.34;

    for (double a = 0; a < math.pi * 2; a += 0.05) {
      final wobble = math.sin((a * 3) + (progress * math.pi * 2)) * (size.width * 0.038);
      final x = center.dx + math.cos(a) * (r + wobble);
      final y = center.dy + math.sin(a) * (r + wobble);

      if (a == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, swirl);
  }

  @override
  bool shouldRepaint(covariant _AuraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
