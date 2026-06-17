import 'package:flutter/material.dart';
import 'package:svareign/core/colors/app_theme_color.dart';

// ──────────────────────────── DARK THEME ────────────────────────────
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryAccent,
  scaffoldBackgroundColor: kPrimaryDark,
  canvasColor: kPrimaryDark,

  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Color(0xFF151538),
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1A1A40),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: kSecondaryAccent),
  ),

  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Colors.white70),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
    prefixIconColor: Colors.white60,
    suffixIconColor: Colors.white54,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kPrimaryAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(color: Colors.white70),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white54),
    labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryAccent,
    foregroundColor: Colors.white,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.08),
    selectedColor: kPrimaryAccent.withOpacity(0.2),
    labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
    secondaryLabelStyle: const TextStyle(color: kPrimaryAccent),
    side: BorderSide(color: Colors.white.withOpacity(0.1)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.08),
    thickness: 1,
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1A1A40),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(
      color: Colors.white.withOpacity(0.7),
      fontSize: 15,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1A1A40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  listTileTheme: ListTileThemeData(
    iconColor: Colors.white70,
    textColor: Colors.white,
    tileColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: kPrimaryAccent,
    unselectedLabelColor: Colors.white54,
    indicatorColor: kPrimaryAccent,
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: kPrimaryAccent,
  ),

  colorScheme: const ColorScheme.dark(
    primary: kPrimaryAccent,
    secondary: kSecondaryAccent,
    surface: Color(0xFF1A1A40),
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
  ),
);

// ──────────────────────────── LIGHT THEME ────────────────────────────
const Color _lightGreen = Colors.lightGreen;
const Color _textDark = Color(0xFF212121);
const Color _textMedium = Color(0xFF616161);
const Color _textLight = Color(0xFF9E9E9E);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: _lightGreen,
  scaffoldBackgroundColor: Colors.white,
  canvasColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: _textDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: _textDark,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: _textDark),
  ),

  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Colors.white,
    elevation: 4,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightGreen,
      foregroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: _lightGreen),
  ),

  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: _textDark),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    labelStyle: const TextStyle(color: _textMedium, fontSize: 14),
    hintStyle: const TextStyle(color: _textLight),
    prefixIconColor: _textDark,
    suffixIconColor: _textMedium,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _lightGreen, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: _textDark, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: _textDark, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: _textDark, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: _textDark, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: _textDark, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(color: _textMedium),
    bodyLarge: TextStyle(color: _textDark),
    bodyMedium: TextStyle(color: _textMedium),
    bodySmall: TextStyle(color: _textLight),
    labelLarge: TextStyle(color: _textDark, fontWeight: FontWeight.w600),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _lightGreen,
    foregroundColor: Colors.white,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey.shade100,
    selectedColor: _lightGreen.withOpacity(0.15),
    labelStyle: const TextStyle(color: _textMedium, fontSize: 13),
    secondaryLabelStyle: const TextStyle(color: _lightGreen),
    side: BorderSide(color: Colors.grey.shade300),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),

  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: _textDark,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: const TextStyle(color: _textMedium, fontSize: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),

  listTileTheme: ListTileThemeData(
    iconColor: _textMedium,
    textColor: _textDark,
    tileColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: _lightGreen,
    unselectedLabelColor: _textLight,
    indicatorColor: _lightGreen,
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(color: _lightGreen),

  colorScheme: ColorScheme.light(
    primary: _lightGreen,
    secondary: Colors.green,
    surface: Colors.white,
    surfaceContainerHighest: Colors.grey.shade200,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: _textDark,
  ),
);
