import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class CustomPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int? totalRecords;
  final int itemsPerPage;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;

  const CustomPaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalRecords,
    this.itemsPerPage = 20,
    this.pageSizeOptions = const [10, 20, 50, 100],
    required this.onPageChanged,
    this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1 && (totalRecords == null || totalRecords == 0)) {
      return const SizedBox.shrink();
    }

    final int safeTotalPages = totalPages > 0 ? totalPages : 1;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.responsiveSize(10, 14), horizontal: context.responsiveSize(16, 24)),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 780;

          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 16,
            children: [
              // Left Section: Record Count & Rows Per Page Dropdown
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (totalRecords != null) ...[
                    Text(
                      'Total Records: $totalRecords',
                      style: context.subTitleStyle.copyWith(
                        fontSize: context.responsiveSize(12, 13),
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Rows Per Page Selector
                  if (onPageSizeChanged != null) ...[
                    Text(
                      'Rows per page:',
                      style: context.subTitleStyle.copyWith(fontSize: context.responsiveSize(12, 13), color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: pageSizeOptions.contains(itemsPerPage) ? itemsPerPage : pageSizeOptions.first,
                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                          isDense: true,
                          style: context.subTitleStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.isDark ? Colors.white : Colors.black87,
                          ),
                          items: pageSizeOptions.map((size) {
                            return DropdownMenuItem<int>(value: size, child: Text('$size'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) onPageSizeChanged!(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Right Section: Navigation Controls & Page Numbers
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First Page Button (<<)
                  _buildNavButton(
                    context,
                    icon: Icons.first_page_rounded,
                    tooltip: 'First Page',
                    isEnabled: currentPage > 1,
                    onTap: () => onPageChanged(1),
                  ),
                  const SizedBox(width: 4),

                  // Previous Page Button (<)
                  _buildNavButton(
                    context,
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Previous Page',
                    isEnabled: currentPage > 1,
                    onTap: () => onPageChanged(currentPage - 1),
                  ),
                  const SizedBox(width: 8),

                  // Numbered Page Buttons with Ellipsis (Compact screen shows dropdown)
                  if (!isCompact) ...[
                    ..._buildPagePills(context, safeTotalPages),
                    const SizedBox(width: 8),
                  ] else ...[
                    _buildPageDropdownSelector(context, safeTotalPages),
                    const SizedBox(width: 8),
                  ],

                  // Next Page Button (>)
                  _buildNavButton(
                    context,
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Next Page',
                    isEnabled: currentPage < safeTotalPages,
                    onTap: () => onPageChanged(currentPage + 1),
                  ),
                  const SizedBox(width: 4),

                  // Last Page Button (>>)
                  _buildNavButton(
                    context,
                    icon: Icons.last_page_rounded,
                    tooltip: 'Last Page',
                    isEnabled: currentPage < safeTotalPages,
                    onTap: () => onPageChanged(safeTotalPages),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Smart Window Numbered Buttons (e.g. 1 2 3 ... 84)
  List<Widget> _buildPagePills(BuildContext context, int total) {
    final List<Widget> pills = [];
    final List<int?> pageIndices = _generatePageIndices(total);

    for (int i = 0; i < pageIndices.length; i++) {
      final pageNum = pageIndices[i];

      if (pageNum == null) {
        pills.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: context.subTitleStyle.copyWith(fontWeight: FontWeight.bold, color: AppColors.textHintLight),
            ),
          ),
        );
      } else {
        final bool isSelected = pageNum == currentPage;
        pills.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => onPageChanged(pageNum),
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBrandOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? AppColors.primaryBrandOrange : AppColors.borderLight),
                ),
                child: Text(
                  '$pageNum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : (context.isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return pills;
  }

  // Generates sliding window pagination indices
  List<int?> _generatePageIndices(int total) {
    if (total <= 7) {
      return List.generate(total, (i) => i + 1);
    }

    if (currentPage <= 4) {
      return [1, 2, 3, 4, 5, null, total];
    } else if (currentPage >= total - 3) {
      return [1, null, total - 4, total - 3, total - 2, total - 1, total];
    } else {
      return [1, null, currentPage - 1, currentPage, currentPage + 1, null, total];
    }
  }

  // Dropdown selector for jumping to a page
  Widget _buildPageDropdownSelector(BuildContext context, int total) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentPage.clamp(1, total),
          isDense: true,
          style: context.subTitleStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: context.isDark ? Colors.white : Colors.black87),
          items: List.generate(total, (index) => index + 1).map((page) {
            return DropdownMenuItem<int>(value: page, child: Text('Page $page of $total'));
          }).toList(),
          onChanged: (page) {
            if (page != null) onPageChanged(page);
          },
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isEnabled ? tooltip : '',
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isEnabled
                  ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isEnabled ? AppColors.borderLight : Colors.transparent),
            ),
            child: Icon(icon, size: 18, color: isEnabled ? AppColors.primaryBrandOrange : AppColors.textHintLight),
          ),
        ),
      ),
    );
  }
}
