import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const seedColor = Color(0xFF0D7E71);
    const accentColor = Color(0xFFF28E2B);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(secondary: accentColor, surface: const Color(0xFFFFFFFF));

    final textTheme = GoogleFonts.urbanistTextTheme().copyWith(
      displayLarge: GoogleFonts.urbanist(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      displayMedium: GoogleFonts.urbanist(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.9,
      ),
      headlineLarge: GoogleFonts.urbanist(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineMedium: GoogleFonts.urbanist(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFF7FBFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7FBFA),
        foregroundColor: Color(0xFF12232C),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFF0F6F4),
        indicatorColor: const Color(0xFFD3F0EA),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.urbanist(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seedColor,
          side: const BorderSide(color: Color(0xFFCDE2DD)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F6F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: seedColor, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F6F4),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      ),
    );
  }
}
