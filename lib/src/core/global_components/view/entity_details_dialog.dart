import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Key-Value attribute item model
class DetailItem {
  final String label;
  final dynamic value;
  final bool isCopyable;
  final IconData icon;

  const DetailItem({required this.label, required this.value, this.isCopyable = false, this.icon = Icons.info_outline_rounded});
}

/// Operational / Status flag model
class DetailFlag {
  final String label;
  final bool value;

  const DetailFlag({required this.label, required this.value});
}

/// Grouped section container model
class DetailSection {
  final String title;
  final List<DetailItem>? items;
  final List<DetailFlag>? flags;
  final Widget? customContent;

  const DetailSection({required this.title, this.items, this.flags, this.customContent});
}

/// Enterprise-grade generic dialog helper for any administrative entity
class EntityDetailsDialogHelper {
  /// Opens a responsive, view-only entity details dialog
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData headerIcon = Icons.info_outline_rounded,
    required List<DetailSection> sections,
  }) {
    final mediaQuery = MediaQuery.sizeOf(context);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.responsiveSize(12, 16))),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          width: context.isDesktop ? 940 : mediaQuery.width * 0.95,
          constraints: BoxConstraints(maxHeight: mediaQuery.height * 0.90, maxWidth: 940),
          padding: EdgeInsets.all(context.responsiveSize(20, 28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, title, subtitle, headerIcon),
              const Divider(height: 28, thickness: 1),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections.map((section) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, section.title),
                              const SizedBox(height: 12),
                              if (section.flags != null && section.flags!.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: section.flags!.map((flag) => _buildFlagChip(context, flag.label, flag.value)).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (section.items != null && section.items!.isNotEmpty) _buildInfoGrid(context, section.items!),
                              if (section.customContent != null) ...[const SizedBox(height: 12), section.customContent!],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Footer Action
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrandOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.responsiveSize(6, 8))),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildHeader(BuildContext context, String title, String? subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryBrandOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primaryBrandOrange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.trim(),
                style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 19), fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle.trim(),
                  style: context.subTitleStyle.copyWith(fontSize: context.responsiveSize(12, 13), color: AppColors.textSecondaryLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.close_rounded), splashRadius: 24, tooltip: 'Close Dialog', onPressed: () => Get.back()),
      ],
    );
  }

  static Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Text(
        title,
        style: context.titleStyleActive.copyWith(
          fontSize: context.responsiveSize(14, 15),
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBrandOrange,
        ),
      ),
    );
  }

  static Widget _buildInfoGrid(BuildContext context, List<DetailItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 520;
        final double itemWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            return SizedBox(width: itemWidth, child: _buildInfoCard(context, item));
          }).toList(),
        );
      },
    );
  }

  static Widget _buildInfoCard(BuildContext context, DetailItem item) {
    final String displayValue = formatVal(item.value);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: context.subTitleStyle.copyWith(fontSize: 11, color: AppColors.textHintLight)),
                const SizedBox(height: 3),
                item.isCopyable
                    ? SelectableText(
                        displayValue,
                        style: context.subTitleStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      )
                    : Text(
                        displayValue,
                        style: context.subTitleStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFlagChip(BuildContext context, String label, bool value) {
    final Color chipColor = value ? Colors.green.shade800 : Colors.red.shade800;

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      avatar: Icon(value ? Icons.check_circle_rounded : Icons.cancel_rounded, color: chipColor, size: 15),
      backgroundColor: chipColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
    );
  }

  static String formatVal(dynamic val) {
    if (val == null) return 'N/A';
    final str = val.toString().trim();
    return str.isEmpty ? 'N/A' : str;
  }

  static String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed.toLocal());
    } catch (_) {
      return date.toString().trim().isEmpty ? 'N/A' : date.toString();
    }
  }
}
