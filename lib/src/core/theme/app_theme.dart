import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  const AppTheme._();

  // LIGHT THEME CONFIGURATION
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.canvasLightGray,
    primaryColor: AppColors.primaryRed,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryRed,
      onPrimary: AppColors.onPrimaryWhite,
      primaryContainer: AppColors.primaryRedLight,
      secondary: AppColors.secondarySlate,
      onSecondary: AppColors.onSecondaryWhite,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textPrimarySlate,
      error: AppColors.statusRedError,
      onError: Colors.white,
      outline: AppColors.borderProminentSlate,
      outlineVariant: AppColors.borderSubtleSlate,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: AppColors.textPrimarySlate, displayColor: AppColors.textPrimarySlate),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceWhite,
      hintStyle: const TextStyle(color: AppColors.textMutedSlate, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondarySlate, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderSubtleSlate),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderSubtleSlate),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.statusRedError, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.statusRedError, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.onPrimaryWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondarySlate,
        side: const BorderSide(color: AppColors.borderProminentSlate),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceWhite,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.borderSubtleSlate),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderSubtleSlate, thickness: 1, space: 1),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.surfaceSubtleGray),
      headingTextStyle: const TextStyle(color: AppColors.textPrimarySlate, fontWeight: FontWeight.w600, fontSize: 13),
      dataTextStyle: const TextStyle(color: AppColors.textSecondarySlate, fontSize: 13),
      dividerThickness: 1,
    ),
  );

  // DARK THEME CONFIGURATION
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.canvasDarkSlate,
    primaryColor: AppColors.primaryRed,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryRed,
      onPrimary: AppColors.onPrimaryWhite,
      primaryContainer: AppColors.primaryRedDark,
      secondary: AppColors.secondarySlateLight,
      onSecondary: AppColors.onSecondaryWhite,
      surface: AppColors.surfaceElevatedSlate,
      onSurface: AppColors.textPrimaryWhite,
      error: AppColors.statusRedError,
      onError: Colors.white,
      outline: AppColors.borderProminentDark,
      outlineVariant: AppColors.borderSubtleDark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.textPrimaryWhite, displayColor: AppColors.textPrimaryWhite),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceSubtleSlate,
      hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondaryMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderSubtleDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderSubtleDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.statusRedError, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.statusRedError, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.onPrimaryWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryWhite,
        side: const BorderSide(color: AppColors.borderProminentDark),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceElevatedSlate,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.borderSubtleDark),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderSubtleDark, thickness: 1, space: 1),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.surfaceSubtleSlate),
      headingTextStyle: const TextStyle(color: AppColors.textPrimaryWhite, fontWeight: FontWeight.w600, fontSize: 13),
      dataTextStyle: const TextStyle(color: AppColors.textSecondaryMuted, fontSize: 13),
      dividerThickness: 1,
    ),
  );
}
