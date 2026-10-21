import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

/// Enterprise-grade, generic table body container.
/// Eliminates redundant table layout scaffolding across all admin panel views:
/// - Reactive full-canvas loading card with branded progress indicator
/// - RepaintBoundary-isolated bidirectional data table
/// - Theme-adaptive empty state handling
/// - Standardized custom pagination toolbar
class PaginatedTableContainer<T> extends StatelessWidget {
  final bool isLoading; // Loading state indicator from controller
  final String loadingMessage; // Custom loading message shown during initial load
  final List<T> items; // List of items to display (active page slice)

  /// Dual scroll controllers for web bidirectional scrolling
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  /// Empty state configurations
  final String emptyTitle;
  final String? emptySubtitle;
  final IconData emptyIcon;

  /// Table structure configuration
  final List<DataColumn> columns;
  final DataRow Function(BuildContext context, T item) rowBuilder;
  final double dataRowMaxHeight;
  final double dataRowMinHeight;
  final double? columnSpacing;

  /// Pagination configurations
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const PaginatedTableContainer({
    super.key,
    required this.isLoading,
    this.loadingMessage = 'Loading Records...',
    required this.items,
    required this.horizontalScrollController,
    required this.verticalScrollController,
    required this.emptyTitle,
    this.emptySubtitle,
    this.emptyIcon = Icons.inbox_outlined,
    required this.columns,
    required this.rowBuilder,
    this.dataRowMaxHeight = 56.0,
    this.dataRowMinHeight = 48.0,
    this.columnSpacing,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    this.itemsPerPageOptions = const [10, 20, 50, 100],
    required this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return Center(
        child: Container(
          padding: const .all(24),
          decoration: context.defaultDecoration,
          child: Column(
            mainAxisSize: .min,
            children: [
              const CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
              const SizedBox(height: 16),
              Text(loadingMessage, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: RepaintBoundary(
            child: DataTableWidget<T>(
              items: items,
              horizontalScrollController: horizontalScrollController,
              verticalScrollController: verticalScrollController,
              emptyTitle: emptyTitle,
              emptySubtitle: emptySubtitle,
              emptyIcon: emptyIcon,
              dataRowMaxHeight: dataRowMaxHeight,
              dataRowMinHeight: dataRowMinHeight,
              columnSpacing: columnSpacing,
              columns: columns,
              rowBuilder: rowBuilder,
            ),
          ),
        ),
        SizedBox(height: context.responsiveHeight(12, 16)),
        CustomPaginationWidget(
          currentPage: currentPage,
          totalItems: totalItems,
          itemsPerPage: itemsPerPage,
          itemsPerPageOptions: itemsPerPageOptions,
          isLoading: isLoading,
          onPageChanged: onPageChanged,
          onItemsPerPageChanged: onItemsPerPageChanged,
        ),
      ],
    );
  }
}
