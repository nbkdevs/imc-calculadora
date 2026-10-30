import 'package:flutter/material.dart';

class ImcColors {
  static const bg = Color(0xFFF4F6F5);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A2421);
  static const accent = Color(0xFF0E5C52);
  static const support = Color(0xFF3B5B6D);
  static const border = Color(0xFFDCE3E1);
  static const bajo = Color(0xFF3B7DD8);
  static const normal = Color(0xFF0E5C52);
  static const sobrepeso = Color(0xFFC98A1F);
  static const obesidad1 = Color(0xFFC1591F);
  static const obesidad2 = Color(0xFFA83A2A);
  static const obesidad3 = Color(0xFF7A2420);
}

ThemeData buildImcTheme() {
  const ink = ImcColors.ink;
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ImcColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ImcColors.accent,
      primary: ImcColors.accent,
      surface: ImcColors.surface,
      onPrimary: Colors.white,
      onSurface: ink,
      brightness: Brightness.light,
    ),
    dividerColor: ImcColors.border,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'IBM Plex Sans',
      bodyColor: ink,
      displayColor: ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ImcColors.surface,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: ImcColors.accent,
      ),
    ),
    cardTheme: CardThemeData(
      color: ImcColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: ImcColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ImcColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ImcColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ImcColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ImcColors.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: ImcColors.support),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ImcColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(
          fontFamily: 'IBM Plex Sans',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ImcColors.accent,
        side: const BorderSide(color: ImcColors.border),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
  );
}
