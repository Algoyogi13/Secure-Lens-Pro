import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

class SecureLensApp extends StatelessWidget {
  const SecureLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Lens Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}