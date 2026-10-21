import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

/// Reusable table cell text component with enterprise typography,
/// responsive constraints, tooltip on overflow, and optional clipboard selection.
class AppTableCellText extends StatelessWidget {
  final String? text;
  final double maxWidth;
  final int maxLines;
  final TextStyle? style;
  final bool isSelectable;
  final bool showTooltip;
  final String fallbackText;

  const AppTableCellText({
    super.key,
    required this.text,
    this.maxWidth = 200.0,
    this.maxLines = 1,
    this.style,
    this.isSelectable = false,
    this.showTooltip = true,
    this.fallbackText = '—',
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    final String cleanText = (text == null || text!.trim().isEmpty) ? fallbackText : text!.trim();
    final bool hasValidContent = cleanText != fallbackText;

    final TextStyle defaultStyle = context.bodyTextStyle.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
    );

    final TextStyle effectiveStyle = style ?? defaultStyle;

    final Widget textWidget = isSelectable && hasValidContent
        ? SelectableText(cleanText, style: effectiveStyle, maxLines: maxLines)
        : Text(cleanText, style: effectiveStyle, maxLines: maxLines, overflow: TextOverflow.ellipsis);

    final Widget constrainedBox = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: textWidget,
    );

    if (showTooltip && hasValidContent) {
      return Tooltip(message: cleanText, waitDuration: const Duration(milliseconds: 400), child: constrainedBox);
    }

    return constrainedBox;
  }
}
