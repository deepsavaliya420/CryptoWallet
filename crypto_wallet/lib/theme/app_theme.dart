import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color primaryBlue = Color(0xFF0EA5E9);
  static const Color deepBlue = Color(0xFF0284C7);

  static const Color navy = Color(0xFF102A43);
  static const Color navyLight = Color(0xFF243B53);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF1ECFF);

  static const Color mint = Color(0xFF10B981);
  static const Color mintLight = Color(0xFFE8FAF3);

  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFFF7E6);

  static const Color coral = Color(0xFFEF6A6A);
  static const Color coralLight = Color(0xFFFFEEEE);

  // ============================================================
  // NEUTRAL COLORS
  // ============================================================

  static const Color background = Color(0xFFF6FBFE);
  static const Color surface = Colors.white;

  static const Color softBlue = Color(0xFFEAF8FF);
  static const Color softCyan = Color(0xFFF0FBFF);

  static const Color border = Color(0xFFDCECF4);

  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF627D98);
  static const Color textMuted = Color(0xFF8AA1B2);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      onPrimary: Colors.white,

      primaryContainer: softBlue,
      onPrimaryContainer: deepBlue,

      secondary: purple,
      onSecondary: Colors.white,

      secondaryContainer: purpleLight,
      onSecondaryContainer: Color(0xFF5B21B6),

      tertiary: mint,
      onTertiary: Colors.white,

      tertiaryContainer: mintLight,
      onTertiaryContainer: Color(0xFF047857),

      surface: surface,
      onSurface: textPrimary,

      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFAFDFF),
      surfaceContainer: Color(0xFFF5FAFD),
      surfaceContainerHigh: Color(0xFFEFF7FB),
      surfaceContainerHighest: Color(0xFFE6F2F7),

      onSurfaceVariant: textSecondary,

      outline: Color(0xFFB8D3DF),
      outlineVariant: border,

      error: coral,
      onError: Colors.white,

      errorContainer: coralLight,
      onErrorContainer: Color(0xFFB42318),
    ),

    scaffoldBackgroundColor: background,

    fontFamily: 'Roboto',

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: const AppBarTheme(
      centerTitle: false,

      elevation: 0,
      scrolledUnderElevation: 0,

      backgroundColor: background,
      surfaceTintColor: Colors.transparent,

      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),

      iconTheme: IconThemeData(
        color: textPrimary,
        size: 23,
      ),
    ),

    // ==========================================================
    // CARDS
    // ==========================================================

    cardTheme: CardThemeData(
      elevation: 0,

      margin: EdgeInsets.zero,

      color: Colors.white,

      surfaceTintColor: Colors.transparent,

      shadowColor: const Color(0x160EA5E9),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: const Color(0xFFF9FCFE),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: border,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.6,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: coral,
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: coral,
          width: 1.6,
        ),
      ),

      labelStyle: const TextStyle(
        fontSize: 13,
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),

      hintStyle: const TextStyle(
        fontSize: 13,
        color: textMuted,
      ),

      prefixIconColor: deepBlue,

      suffixIconColor: textSecondary,
    ),

    // ==========================================================
    // FILLED BUTTON
    // ==========================================================

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          52,
        ),

        elevation: 0,

        backgroundColor: primaryBlue,

        foregroundColor: Colors.white,

        disabledBackgroundColor:
        const Color(0xFFB8D9E8),

        disabledForegroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          48,
        ),

        foregroundColor: deepBlue,

        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        side: const BorderSide(
          color: Color(0xFFBBDCEB),
          width: 1.2,
        ),

        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // ==========================================================
    // TEXT BUTTON
    // ==========================================================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: deepBlue,

        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // ==========================================================
    // ELEVATED BUTTON
    // ==========================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,

        backgroundColor: Colors.white,

        foregroundColor: deepBlue,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        shadowColor: const Color(0x220EA5E9),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),

          side: const BorderSide(
            color: border,
          ),
        ),
      ),
    ),

    // ==========================================================
    // ICON BUTTON
    // ==========================================================

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: deepBlue,

        backgroundColor: Colors.transparent,
      ),
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,

      backgroundColor: navy,

      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),

    // ==========================================================
    // DIALOG
    // ==========================================================

    dialogTheme: DialogThemeData(
      elevation: 10,

      backgroundColor: Colors.white,

      surfaceTintColor: Colors.transparent,

      shadowColor: const Color(0x250EA5E9),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),

      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),

      contentTextStyle: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: textSecondary,
      ),
    ),

    // ==========================================================
    // BOTTOM SHEET
    // ==========================================================

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,

      surfaceTintColor: Colors.transparent,

      showDragHandle: true,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
    ),

    // ==========================================================
    // DIVIDER
    // ==========================================================

    dividerTheme: const DividerThemeData(
      space: 1,

      thickness: 0.7,

      color: border,
    ),

    // ==========================================================
    // SWITCH
    // ==========================================================

    switchTheme: SwitchThemeData(
      materialTapTargetSize:
      MaterialTapTargetSize.shrinkWrap,

      thumbColor:
      WidgetStateProperty.resolveWith<Color?>(
            (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return Colors.white;
          }

          return const Color(0xFF8AA1B2);
        },
      ),

      trackColor:
      WidgetStateProperty.resolveWith<Color?>(
            (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return primaryBlue;
          }

          return const Color(0xFFDCE9EF);
        },
      ),
    ),

    // ==========================================================
    // CHIP
    // ==========================================================

    chipTheme: ChipThemeData(
      backgroundColor: softBlue,

      selectedColor: const Color(0xFFD8F2FF),

      disabledColor: const Color(0xFFEFF3F5),

      labelStyle: const TextStyle(
        color: deepBlue,

        fontSize: 12,

        fontWeight: FontWeight.w700,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),

      side: BorderSide.none,
    ),

    // ==========================================================
    // NAVIGATION BAR
    // ==========================================================

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,

      surfaceTintColor: Colors.transparent,

      elevation: 8,

      shadowColor: const Color(0x200EA5E9),

      indicatorColor: const Color(0xFFDDF4FF),

      height: 72,

      labelTextStyle:
      WidgetStateProperty.resolveWith<TextStyle?>(
            (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: deepBlue,
            );
          }

          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          );
        },
      ),

      iconTheme:
      WidgetStateProperty.resolveWith<IconThemeData?>(
            (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return const IconThemeData(
              color: deepBlue,
              size: 23,
            );
          }

          return const IconThemeData(
            color: textSecondary,
            size: 22,
          );
        },
      ),
    ),

    // ==========================================================
    // FLOATING ACTION BUTTON
    // ==========================================================

    floatingActionButtonTheme:
    const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,

      foregroundColor: Colors.white,

      elevation: 5,

      shape: CircleBorder(),
    ),

    // ==========================================================
    // PROGRESS
    // ==========================================================

    progressIndicatorTheme:
    const ProgressIndicatorThemeData(
      color: primaryBlue,

      linearTrackColor: softBlue,
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  // ChainVault will intentionally remain in the premium
  // white/light visual language.
  static final ThemeData darkTheme = lightTheme;
}