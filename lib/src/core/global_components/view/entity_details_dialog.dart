import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// DATA CONTRACTS FOR ENTITY INSPECTION
class DetailItem {
  final String label;
  final dynamic value;
  final bool isCopyable;

  const DetailItem({required this.label, required this.value, this.isCopyable = false});

  String get displayValue {
    if (value == null) return 'N/A';
    final str = value.toString().trim();
    return str.isEmpty ? 'N/A' : str;
  }
}

class DetailFlag {
  final String label;
  final bool? value;

  const DetailFlag({required this.label, required this.value});

  bool get isTrue => value == true;
}

class DetailSection {
  final String title;
  final List<DetailItem> items;
  final List<DetailFlag> flags;

  const DetailSection({this.title = '', this.items = const [], this.flags = const []});
}

// DIALOG HELPER & LAUNCHER
abstract final class EntityDetailsDialogHelper {
  const EntityDetailsDialogHelper._();

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData headerIcon = Icons.info_outline_rounded,
    required List<DetailSection> sections,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => EntityDetailsDialog(title: title, subtitle: subtitle, headerIcon: headerIcon, sections: sections),
    );
  }
}

// RESPONSIVE ENTITY DETAILS DIALOG WIDGET
class EntityDetailsDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData headerIcon;
  final List<DetailSection> sections;

  const EntityDetailsDialog({super.key, required this.title, this.subtitle, required this.headerIcon, required this.sections});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    final double dialogWidth = isMobile ? context.screenWidth * 0.94 : (context.screenWidth < 1100 ? 680.0 : 840.0);

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 24), vertical: context.responsiveHeight(16, 24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: context.screenHeight * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Divider(height: 1, thickness: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 24), vertical: context.responsiveHeight(14, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: sections.map((section) => _buildSection(context, section)).toList(),
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // DIALOG HEADER
  Widget _buildHeader(BuildContext context) {
    final isDark = context.isDark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 24), vertical: context.responsiveHeight(14, 18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(headerIcon, size: 22, color: AppColors.primaryRed),
          ),
          SizedBox(width: context.responsiveWidth(12, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: context.titleStyleActive.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            splashRadius: 18,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // SECTION CONTAINER & CONTENT
  Widget _buildSection(BuildContext context, DetailSection section) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(context.responsiveSize(12, 16)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title.isNotEmpty)
            Text(
              section.title,
              style: context.titleStyleRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryRed),
            ),
          if (section.flags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: section.flags.map((flag) => _buildFlagChip(context, flag)).toList()),
          ],
          if (section.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = isMobile ? 1 : (constraints.maxWidth > 500 ? 2 : 1);
                return _buildAdaptiveGrid(context, section.items, crossAxisCount);
              },
            ),
          ],
        ],
      ),
    );
  }

  // ADAPTIVE ITEM GRID
  Widget _buildAdaptiveGrid(BuildContext context, List<DetailItem> items, int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = crossAxisCount == 1;
        final double itemWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(width: itemWidth, child: _buildItemTile(context, item));
          }).toList(),
        );
      },
    );
  }

  // DETAIL ITEM TILE
  Widget _buildItemTile(BuildContext context, DetailItem item) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label.toUpperCase(),
            style: context.captionStyle.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  item.displayValue,
                  style: context.bodyTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                  ),
                ),
              ),
              if (item.isCopyable && item.displayValue != 'N/A') ...[
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _copyToClipboard(context, item.label, item.displayValue),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.copy_rounded, size: 13, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // FLAG BADGE CHIP
  Widget _buildFlagChip(BuildContext context, DetailFlag flag) {
    final isTrue = flag.isTrue;
    final color = isTrue ? AppColors.statusGreenSuccess : AppColors.statusRedError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isTrue ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            flag.label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // DIALOG FOOTER
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 24), vertical: context.responsiveHeight(10, 14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.onPrimaryWhite,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String label, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied "$label" to clipboard'), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
    );
  }
}
