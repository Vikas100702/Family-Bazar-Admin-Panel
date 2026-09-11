import 'package:flutter/material.dart';

@immutable
abstract final class AppColors {
  const AppColors._();

  /// 1. PRIMARY ACTIONS & IDENTITY (Priority 1: Core Action / Active Buttons)
  /// Hue: Family Bazar Brand Red
  static const Color primaryRed = Color(0xFFE51924); // Main brand red for key actions
  static const Color primaryRedLight = Color(0xFFFF4D57); // Hover / Highlight state
  static const Color primaryRedDark = Color(0xFFB30E17); // Pressed / Focused state
  static const Color onPrimaryWhite = Color(0xFFFFFFFF); // High-contrast text/icon over red

  /// 2. STRUCTURAL CHROME (Priority 2: Sidebar, Top Bar, Elevated Containers)
  /// Hue: Deep Navy Slate
  static const Color secondarySlate = Color(0xFF0F172A); // Primary navigation/sidebar base
  static const Color secondarySlateLight = Color(0xFF1E293B); // Elevated structural chrome
  static const Color secondarySlateDark = Color(0xFF020617); // Deep contrast structural canvas
  static const Color onSecondaryWhite = Color(0xFFFFFFFF); // High-contrast text/icon over slate

  /// 3. ACCENTS & PROMOTIONAL CALLOUTS (Priority 3: Badges, Flags, Highlights)
  /// Hue: Gold Amber & Azure Blue (Extracted from Logo Swoosh)
  static const Color accentGoldAmber = Color(0xFFF59E0B); // Amber / Gold highlight badge
  static const Color accentAzureBlue = Color(0xFF0284C7); // Azure / Blue secondary badge

  /// 4. CANVAS & SURFACES (Spatial Hierarchy: Base Canvas vs Cards & Modals)
  /// Hue: Cool Gray, White, Deep Slate
  /// Light Mode Surfaces
  static const Color canvasLightGray = Color(0xFFF8FAFC); // Main web background canvas
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Cards, modals, dialog surfaces
  static const Color surfaceSubtleGray = Color(0xFFF1F5F9); // Nested tables, form fill backgrounds

  /// Dark Mode Surfaces
  static const Color canvasDarkSlate = Color(0xFF0B0F19); // Dark web background canvas
  static const Color surfaceElevatedSlate = Color(0xFF161B26); // Dark cards & modals
  static const Color surfaceSubtleSlate = Color(0xFF1E2638); // Nested dark containers & rows

  /// 5. CONTENT & TYPOGRAPHY (Visual Hierarchy: Readability & Contrast)
  /// Hue: Slate Scale & Off-White
  /// Light Mode Text
  static const Color textPrimarySlate = Color(0xFF0F172A); // High emphasis: Titles, headers, critical KPIs
  static const Color textSecondarySlate = Color(0xFF475569); // Medium emphasis: Body text, table rows, labels
  static const Color textMutedSlate = Color(0xFF94A3B8); // Low emphasis: Placeholders, hints, disabled text

  /// Dark Mode Text
  static const Color textPrimaryWhite = Color(0xFFF8FAFC); // High emphasis: Crisp off-white titles
  static const Color textSecondaryMuted = Color(0xFF94A3B8); // Medium emphasis: Subtitle slate
  static const Color textMutedDark = Color(0xFF475569); // Low emphasis: Dimmed placeholders

  /// 6. BORDERS & SEPARATORS (Structural Priority: Focus vs Divider Lines)
  /// Hue: Slate Gray
  static const Color borderProminentSlate = Color(0xFFCBD5E1); // Active input outlines & card borders
  static const Color borderSubtleSlate = Color(0xFFE2E8F0); // Data table rows & section dividers

  static const Color borderProminentDark = Color(0xFF334155); // Dark input outlines & focused cards
  static const Color borderSubtleDark = Color(0xFF1E293B); // Dark row lines & panel dividers

  /// 7. SYSTEM STATUS (Global Safety & Data Table Indicators)
  /// Hue: Emerald Green, Alert Red, Amber, Royal Blue
  static const Color statusGreenSuccess = Color(0xFF10B981); // Emerald Green
  static const Color statusAmberWarning = Color(0xFFF59E0B); // Amber
  static const Color statusRedError = Color(0xFFDC2626); // Strict Alert Red
  static const Color statusBlueInfo = Color(0xFF2563EB); // Informational Blue
}
