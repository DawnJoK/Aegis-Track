import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF05081C);
  static const Color surface = Color(0xFF0A0E24);
  static const Color primary = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color divider = Color(0xFF1E2338);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      // cardTheme: CardTheme(
      //   color: surface,
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     side: const BorderSide(color: Color(0xFF1E2338), width: 1),
      //   ),
      // ),
      iconTheme: const IconThemeData(color: textSecondary),
      dividerColor: divider,
      useMaterial3: true,
    );
  }
}
