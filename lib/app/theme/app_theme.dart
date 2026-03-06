import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF); // Vibrant purple
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color accent = Color(0xFFFF6584); // Warm pink accent
  static const Color success = Color(0xFF2DD4BF); // Teal green
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // ── Dark Palette ──────────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF232338);
  static const Color textDark = Color(0xFFF1F1F8);
  static const Color subtextDark = Color(0xFF9090B0);

  // ── Light Palette ─────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF5F5FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFEEEEFF);
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color subtextLight = Color(0xFF6060A0);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surfaceDark,
          error: error,
        ),
        scaffoldBackgroundColor: bgDark,
        cardColor: cardDark,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: textDark, displayColor: textDark),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: textDark,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: subtextDark),
          hintStyle: const TextStyle(color: subtextDark),
        ),
        cardTheme: const CardThemeData(
          color: cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceDark,
          selectedColor: primary.withOpacity(0.3),
          labelStyle: const TextStyle(color: textDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: surfaceLight,
          error: error,
        ),
        scaffoldBackgroundColor: bgLight,
        cardColor: cardLight,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ).apply(bodyColor: textLight, displayColor: textLight),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceLight,
          foregroundColor: textLight,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: textLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: subtextLight),
          hintStyle: const TextStyle(color: subtextLight),
        ),
        cardTheme: const CardThemeData(
          color: cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
}
