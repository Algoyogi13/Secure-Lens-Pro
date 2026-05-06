import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF221E1D);
  static const backgroundTop = Color(0xFF302A28);
  static const panel = Color(0xFF3B3432);
  static const panelSoft = Color(0xFF4A413E);
  static const panelDark = Color(0xFF332D2B);

  static const peach = Color(0xFFF2A47F);
  static const peachBright = Color(0xFFF6B493);
  static const peachSoft = Color(0xFFFFD7C4);

  static const text = Colors.white;
  static const muted = Color(0xFFD3C3BC);
  static const border = Color(0xFF7C6F6A);

  static const warning = Color(0xFFFFC44F);
  static const danger = Color(0xFFFF8B82);
  static const success = Color(0xFF6FD0A1);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: peachBright,
      secondary: peachSoft,
      surface: panel,
      error: danger,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: text),
      bodyMedium: TextStyle(color: text),
      titleLarge: TextStyle(color: text, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: text, fontWeight: FontWeight.w700),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: panel,
      contentTextStyle: const TextStyle(color: text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: panelSoft.withOpacity(0.84),
      hintStyle: const TextStyle(color: muted),
      labelStyle: const TextStyle(color: text),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xAAF2A47F), width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: peachBright, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: peach,
        foregroundColor: const Color(0xFF2B2524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
