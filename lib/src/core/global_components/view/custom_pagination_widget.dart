import 'dart:math';

import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class CustomPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int> itemsPerPageOptions;
  final bool isLoading;

  const CustomPaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
    this.itemsPerPageOptions = const [10, 20, 50, 100],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    // mathematical calculations
    final safeItemsPerPage = max(1, itemsPerPage);
    final totalPages = max(1, (totalItems / safeItemsPerPage).ceil());
    final safeCurrentPage = currentPage.clamp(1, totalPages);
    final startItem = totalItems == 0 ? 0 : (safeCurrentPage - 1) * safeItemsPerPage + 1;
    final endItem = min(safeCurrentPage * safeItemsPerPage, totalItems);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 18), vertical: context.responsiveHeight(10, 12)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      child: isMobile
          ? _buildMobileLayout(context, startItem, endItem, totalPages, safeCurrentPage)
          : _buildDesktopLayout(context, startItem, endItem, totalPages, safeCurrentPage),
    );
  }

  // DESKTOP VIEWPORT LAYOUT
  Widget _buildDesktopLayout(BuildContext context, int startItem, int endItem, int totalPages, int safeCurrentPage) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        // Left: Range Indicator & Rows Per Page Selector
        Row(
          mainAxisSize: .min,
          children: [
            Text('Showing $startItem to $endItem of $totalItems entries', style: context.captionStyle.copyWith(fontWeight: FontWeight.w500)),
            if (onItemsPerPageChanged != null) ...[const SizedBox(width: 16), _buildRowsPerPageDropdown(context)],
          ],
        ),

        // Right: Navigation Buttons
        _buildNavigationControls(context, totalPages, safeCurrentPage),
      ],
    );
  }

  // MOBILE VIEWPORT LAYOUT (Wrapped Stacking)
  Widget _buildMobileLayout(BuildContext context, int startItem, int endItem, int totalPages, int safeCurrentPage) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: [
        Text('$startItem-$endItem of $totalItems entries', style: context.captionStyle.copyWith(fontSize: context.responsiveSize(12, 12))),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            if (onItemsPerPageChanged != null) _buildRowsPerPageDropdown(context) else const SizedBox.shrink(),
            _buildNavigationControls(context, totalPages, safeCurrentPage),
          ],
        ),
      ],
    );
  }

  // ROWS PER PAGE DROPDOWN SELECTOR
  Widget _buildRowsPerPageDropdown(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: itemsPerPageOptions.contains(itemsPerPage) ? itemsPerPage : itemsPerPageOptions.first,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
          style: context.captionStyle.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
          dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
          onChanged: isLoading || onItemsPerPageChanged == null
              ? null
              : (value) {
                  if (value != null) {
                    onItemsPerPageChanged!(value);
                  }
                },
          items: itemsPerPageOptions.map((int option) {
            return DropdownMenuItem<int>(value: option, child: Text('$option / page'));
          }).toList(),
        ),
      ),
    );
  }

  // 4. ACTION CONTROLS & PAGE BUTTONS

  Widget _buildNavigationControls(BuildContext context, int totalPages, int safeCurrentPage) {
    final canGoPrev = safeCurrentPage > 1 && !isLoading;
    final canGoNext = safeCurrentPage < totalPages && !isLoading;

    return Row(
      mainAxisSize: .min,
      children: [
        _buildNavButton(context: context, icon: Icons.first_page_rounded, tooltip: 'First Page', isEnabled: canGoPrev, onTap: () => onPageChanged(1)),
        const SizedBox(width: 4),

        // Previous Page Button
        _buildNavButton(
          context: context,
          icon: Icons.chevron_left_rounded,
          tooltip: 'Previous Page',
          isEnabled: canGoPrev,
          onTap: () => onPageChanged(safeCurrentPage - 1),
        ),
        const SizedBox(width: 6),

        // Current Page Indicator Box
        Container(
          constraints: const BoxConstraints(minWidth: 32),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text(
            '$safeCurrentPage / $totalPages',
            style: const TextStyle(color: AppColors.onPrimaryWhite, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 6),

        // Next Page Button
        _buildNavButton(
          context: context,
          icon: Icons.chevron_right_rounded,
          tooltip: 'Next Page',
          isEnabled: canGoNext,
          onTap: () => onPageChanged(safeCurrentPage + 1),
        ),
        const SizedBox(width: 4),

        // Last Page Button
        _buildNavButton(
          context: context,
          icon: Icons.last_page_rounded,
          tooltip: 'Last Page',
          isEnabled: canGoNext,
          onTap: () => onPageChanged(totalPages),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        mouseCursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppColors.primaryRed.withValues(alpha: 0.08),
        splashColor: AppColors.primaryRed.withValues(alpha: 0.16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate)
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
          ),
        ),
      ),
    );
  }
}
