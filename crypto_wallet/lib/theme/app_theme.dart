import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5FEF),
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
    ),

    scaffoldBackgroundColor:
    const Color(0xFFF6F7FB),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Color(0xFFF6F7FB),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF181A20),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF181A20),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
    ),

    inputDecorationTheme:
    InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFD),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE4E6EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF5B5FEF),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFD32F2F),
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFD32F2F),
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
      ),
    ),

    filledButtonTheme:
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize:
        const Size(double.infinity, 52),
        elevation: 0,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    outlinedButtonTheme:
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize:
        const Size(double.infinity, 48),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        side: const BorderSide(
          color: Color(0xFFD9DCE7),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    textButtonTheme:
    TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize:
        const Size(double.infinity, 52),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
    ),

    snackBarTheme:
    const SnackBarThemeData(
      behavior:
      SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(14),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(24),
      ),
    ),

    bottomSheetTheme:
    const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
    ),

    dividerTheme:
    const DividerThemeData(
      space: 1,
      thickness: 0.7,
      color: Color(0xFFE7E8EE),
    ),

    switchTheme:
    SwitchThemeData(
      materialTapTargetSize:
      MaterialTapTargetSize.shrinkWrap,
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(12),
      ),
      side: BorderSide.none,
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF777BFF),
      brightness: Brightness.dark,
      surface: const Color(0xFF111318),
    ),

    scaffoldBackgroundColor:
    const Color(0xFF0C0D11),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Color(0xFF0C0D11),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFFF4F5F7),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFF4F5F7),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Color(0xFF16181E),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
    ),

    inputDecorationTheme:
    InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF17191F),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF292C35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF777BFF),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B),
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B),
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
      ),
    ),

    filledButtonTheme:
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize:
        const Size(double.infinity, 52),
        elevation: 0,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    outlinedButtonTheme:
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize:
        const Size(double.infinity, 48),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        side: const BorderSide(
          color: Color(0xFF30333D),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    textButtonTheme:
    TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize:
        const Size(double.infinity, 52),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
    ),

    snackBarTheme:
    const SnackBarThemeData(
      behavior:
      SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(14),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor:
      const Color(0xFF181A20),
      surfaceTintColor:
      Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(24),
      ),
    ),

    bottomSheetTheme:
    const BottomSheetThemeData(
      backgroundColor:
      Color(0xFF15171C),
      surfaceTintColor:
      Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
    ),

    dividerTheme:
    const DividerThemeData(
      space: 1,
      thickness: 0.7,
      color: Color(0xFF292C34),
    ),

    switchTheme:
    SwitchThemeData(
      materialTapTargetSize:
      MaterialTapTargetSize.shrinkWrap,
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(12),
      ),
      side: BorderSide.none,
    ),
  );
}