import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// 1. CONTEXT EXTENSIONS (Layout, Dimensions & Theme)
extension UIContextExt on BuildContext {
  // --- Screen Information ---
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // --- Responsive Sizing Generators ---
  double responsiveSize(double mobileSize, double desktopSize) => isMobile ? mobileSize.sp : desktopSize;
  double responsiveWidth(double mobileWidth, double desktopWidth) => isMobile ? mobileWidth.w : desktopWidth;
  double responsiveHeight(double mobileHeight, double desktopHeight) => isMobile ? mobileHeight.h : desktopHeight;

  BorderRadius responsiveRadius(double mobileRadius, double desktopRadius) => BorderRadius.circular(isMobile ? mobileRadius.r : desktopRadius);

  // --- Typography ---
  TextStyle get mainHeadingTextStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 72.sp : 28,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    fontWeight: FontWeight.w600,
  );

  TextStyle get headingTextStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 20.sp : 24,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    fontWeight: FontWeight.w500,
  );

  TextStyle get titleStyleActive => GoogleFonts.poppins(
    fontSize: isMobile ? 44.sp : 22,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    fontWeight: FontWeight.w600,
  );

  TextStyle get titleStyleRegular => GoogleFonts.poppins(
    fontSize: isMobile ? 16.sp : 18,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    fontWeight: FontWeight.w500,
  );

  TextStyle get bodyTextStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 50.sp : 16,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    fontWeight: FontWeight.w400,
  );

  TextStyle get subTitleStyle => GoogleFonts.poppins(
    fontSize: isMobile ? 40.sp : 14,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    fontWeight: FontWeight.w400,
  );

  // --- Decorations (Adaptive to Light/Dark Surfaces) ---
  BoxDecoration get defaultDecoration => BoxDecoration(
    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(20.r),
    border: Border.all(color: AppColors.primaryBrandOrange),
    boxShadow: [
      BoxShadow(
        blurRadius: 12.0,
        spreadRadius: 2,
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
        offset: const Offset(1, 1),
      ),
    ],
  );
}

/// 2. DATA TYPE EXTENSIONS (Int, String)
extension IntExt on int {
  /// Converts large numbers to K or M formats (e.g., 1500 -> 1.5K)
  String formatAsK() {
    if (this >= 1000000) {
      return this % 1000000 == 0 ? '${(this / 1000000).toStringAsFixed(0)}M' : '${(this / 1000000).toStringAsFixed(2)}M';
    } else if (this >= 1000) {
      return this % 1000 == 0 ? '${(this / 1000).toStringAsFixed(0)}K' : '${(this / 1000).toStringAsFixed(2)}K';
    } else {
      return toString();
    }
  }
}

extension StringExtensions on String {
  /// Capitalizes the first letter safely
  String get capitalizeFirst {
    if (trim().isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  /// Converts to fixed string safely. Returns "0.00" on failure.
  String toFixedString() {
    final parsedDouble = double.tryParse(this);
    if (parsedDouble == null) return "0.00";
    return parsedDouble.toStringAsFixed(2);
  }

  /// Removes HTML elements safely for displaying raw text
  String removeHtmlTags() {
    if (trim().isEmpty) return "";
    String formatted = replaceAll(RegExp(r'<br\s*/?>'), "\n").replaceAll(RegExp(r'</p>'), "\n").replaceAll(RegExp(r'</div>'), "\n");
    formatted = formatted.replaceAll(RegExp(r'<[^>]*>'), "");
    formatted = formatted.replaceAll("&nbsp;", " ");
    return formatted.trim();
  }

  String replaceBackslash() => replaceAll(RegExp(r'\n'), "");

  /// Converts Hex String to Color safely
  Color toColor() {
    try {
      var hexColor = replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      if (hexColor.length == 8) return Color(int.parse("0x$hexColor"));
    } catch (_) {
      return Colors.grey;
    }
    return Colors.grey;
  }
}
