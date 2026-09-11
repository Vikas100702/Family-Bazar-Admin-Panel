import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// 1. CONTEXT EXTENSIONS (Layout, Responsive Sizing & Theme Typography)
extension UIContextExt on BuildContext {
  // --- Screen Information ---
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  double responsiveSize(double mobileSize, double desktopSize) => isMobile ? mobileSize.sp : desktopSize;
  double responsiveWidth(double mobileWidth, double desktopWidth) => isMobile ? mobileWidth.w : desktopWidth;
  double responsiveHeight(double mobileHeight, double desktopHeight) => isMobile ? mobileHeight.h : desktopHeight;
  BorderRadius responsiveRadius(double mobileRadius, double desktopRadius) => BorderRadius.circular(isMobile ? mobileRadius.r : desktopRadius);

  // --- Semantic Typography Hierarchy (Enterprise Web & Mobile Scaled) ---
  TextStyle get mainHeadingTextStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 22.sp : 28,
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  TextStyle get headingTextStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 18.sp : 22,
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w600,
  );
  TextStyle get titleStyleActive => GoogleFonts.poppins(
    fontSize: isMobile ? 16.sp : 18,
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w600,
  );
  TextStyle get titleStyleRegular => GoogleFonts.poppins(
    fontSize: isMobile ? 15.sp : 16,
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w500,
  );
  TextStyle get bodyTextStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 13.sp : 14,
    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    fontWeight: FontWeight.w400,
  );
  TextStyle get subTitleStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 12.sp : 13,
    color: isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate,
    fontWeight: FontWeight.w400,
  );
  TextStyle get captionStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 11.sp : 12,
    color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
    fontWeight: FontWeight.w400,
  );

  // --- Structural Surface Decorations ---
  BoxDecoration get defaultDecoration => BoxDecoration(
    color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(isMobile ? 8.r : 10),
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
    borderRadius: BorderRadius.circular(isMobile ? 8.r : 10),
    border: Border.all(color: AppColors.primaryRed, width: 1.5),
    boxShadow: [BoxShadow(blurRadius: 12, spreadRadius: 0, color: AppColors.primaryRed.withValues(alpha: 0.12), offset: const Offset(0, 3))],
  );
}

/// 2. DATA TYPE EXTENSIONS (Int, String)
extension IntExt on int {
  /// Converts numerical metrics to standard abbreviated strings (e.g., 1.5K, 2.4M)
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

extension StringExtensions on String {
  /// Capitalizes the initial character safely
  String get capitalizeFirstLetter {
    if (trim().isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  /// Converts to fixed decimal string safely. Returns "0.00" on parse failure.
  String toFixedString({int fractionDigits = 2}) {
    final parsedDouble = double.tryParse(this);
    if (parsedDouble == null) return "0.00";
    return parsedDouble.toStringAsFixed(fractionDigits);
  }

  /// Strips raw HTML tags from API payloads to prevent XSS and layout breakage
  String removeHtmlTags() {
    if (trim().isEmpty) return "";
    return replaceAll(
      RegExp(r'<br\s*/?>'),
      "\n",
    ).replaceAll(RegExp(r'</p>'), "\n").replaceAll(RegExp(r'</div>'), "\n").replaceAll(RegExp(r'<[^>]*>'), "").replaceAll("&nbsp;", " ").trim();
  }

  String replaceBackslash() => replaceAll(RegExp(r'\n'), "");

  /// Converts a Hex String to a Color instance safely
  Color toColor() {
    try {
      var hexColor = replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      if (hexColor.length == 8) return Color(int.parse("0x$hexColor"));
    } catch (_) {
      return AppColors.textMutedSlate;
    }
    return AppColors.textMutedSlate;
  }
}
