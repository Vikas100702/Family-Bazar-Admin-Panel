import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension UIContextExt on BuildContext {
  // Screen Information
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Dynamic Mobile Proportional Scaling Engine
  /// Standard Mobile Baseline: 390px.
  /// Bounded between 0.85x and 1.15x to guarantee readability and eliminate microscopic rendering.
  double get _mobileScale => (screenWidth / 390.0).clamp(0.85, 1.15);

  double responsiveSize(double mobileSize, double desktopSize) => isMobile ? (mobileSize * _mobileScale).roundToDouble() : desktopSize;

  double responsiveWidth(double mobileWidth, double desktopWidth) => isMobile ? (mobileWidth * _mobileScale).roundToDouble() : desktopWidth;

  double responsiveHeight(double mobileHeight, double desktopHeight) => isMobile ? (mobileHeight * _mobileScale).roundToDouble() : desktopHeight;

  BorderRadius responsiveRadius(double mobileRadius, double desktopRadius) =>
      BorderRadius.circular(isMobile ? (mobileRadius * _mobileScale).roundToDouble() : desktopRadius);

  // Semantic Typography Hierarchy (Enterprise Web & Proportionally Scaled Mobile)
  TextStyle get mainHeadingTextStyle => GoogleFonts.poppins(
    fontSize: responsiveSize(22, 28),
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  TextStyle get headingTextStyle => GoogleFonts.poppins(
    fontSize: responsiveSize(18, 22),
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w600,
  );

  TextStyle get titleStyleActive => GoogleFonts.poppins(
    fontSize: responsiveSize(16, 18),
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w600,
  );

  TextStyle get titleStyleRegular => GoogleFonts.poppins(
    fontSize: responsiveSize(15, 16),
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w500,
  );

  TextStyle get bodyTextStyle => GoogleFonts.poppins(
    fontSize: responsiveSize(13, 14),
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w400,
  );

  TextStyle get subTitleStyle => GoogleFonts.poppins(
    fontSize: responsiveSize(12, 13),
    color: isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate,
    fontWeight: FontWeight.w400,
  );

  TextStyle get captionStyle => GoogleFonts.poppins(
    fontSize: responsiveSize(11, 12),
    color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
    fontWeight: FontWeight.w400,
  );

  // Structural Surface Decorations
  BoxDecoration get defaultDecoration => BoxDecoration(
    color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
    borderRadius: responsiveRadius(8, 10),
    border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
    boxShadow: [
      BoxShadow(
        blurRadius: 10,
        spreadRadius: 0,
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
        offset: const Offset(0, 2),
      ),
    ],
  );

  BoxDecoration get activeCardDecoration => BoxDecoration(
    color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
    borderRadius: responsiveRadius(8, 10),
    border: Border.all(color: AppColors.primaryRed, width: 1.5),
    boxShadow: [BoxShadow(blurRadius: 12, spreadRadius: 0, color: AppColors.primaryRed.withValues(alpha: 0.12), offset: const Offset(0, 3))],
  );
}

/// DATA TYPE EXTENSIONS (Int, Num, String, Dynamic)
extension IntExt on int {
  // Converts numerical metrics to standard abbreviated strings (e.g., 1.5K, 2.4M)
  String formatAsK() {
    if (this >= 1000000) {
      return this % 1000000 == 0 ? '${(this / 1000000).toStringAsFixed(0)}M' : '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return this % 1000 == 0 ? '${(this / 1000).toStringAsFixed(0)}K' : '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return toString();
    }
  }
}

extension NumberFormattingExtensions on num {
  /// Converts numeric values directly into standard currency format
  String toCurrency({int fractionDigits = 2, String symbol = '₹'}) {
    return '$symbol${toStringAsFixed(fractionDigits)}';
  }
}

extension StringExtensions on String {
  /// Capitalizes the initial character safely
  String get capitalizeFirstLetter {
    if (trim().isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts to fixed decimal string safely. Returns "0.00" on parse failure.
  String toFixedString({int fractionDigits = 2}) {
    final parsedDouble = double.tryParse(this);
    if (parsedDouble == null) return '0.00';
    return parsedDouble.toStringAsFixed(fractionDigits);
  }

  /// Converts numerical strings to clean currency format (e.g., '120' -> '₹120.00')
  String toPrice({int fractionDigits = 2, String symbol = '₹'}) {
    if (trim().isEmpty) return '$symbol${(0.0).toStringAsFixed(fractionDigits)}';
    final double? parsed = double.tryParse(trim());
    if (parsed == null) return '$symbol${(0.0).toStringAsFixed(fractionDigits)}';
    return '$symbol${parsed.toStringAsFixed(fractionDigits)}';
  }

  /// Returns fallback placeholder ('—') if string is empty
  // String get withDashFallback => trim().isEmpty ? '-' : trim();

  /// Safe integer conversion from string values (e.g. stock quantities)
  int toSafeInt([int defaultValue = 0]) {
    final double? parsedDouble = double.tryParse(trim());
    if (parsedDouble == null) return defaultValue;
    return parsedDouble.toInt();
  }

  /// Removes HTML tags to prevent malicious scripts (XSS) and formatting issues.
  String removeHtmlTags() {
    if (trim().isEmpty) return '';
    return replaceAll(
      RegExp(r'<br\s*/?>'),
      '\n',
    ).replaceAll(RegExp(r'</p>'), '\n').replaceAll(RegExp(r'</div>'), '\n').replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
  }

  String replaceBackslash() => replaceAll(RegExp(r'\n'), '');

  /// Converts a Hex String to a Color instance safely
  Color toColor() {
    try {
      var hexColor = replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      if (hexColor.length == 8) return Color(int.parse('0x$hexColor'));
    } catch (_) {
      return AppColors.textMutedSlate;
    }
    return AppColors.textMutedSlate;
  }
}

extension NullableStringExtensions on String? {
  /// Returns trimmed string, or fallback '—' if null or empty
  String get withDashFallback {
    if (this == null || this!.trim().isEmpty) return '—';
    return this!.trim();
  }
}
