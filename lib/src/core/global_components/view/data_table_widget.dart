import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/empty_state_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class DataTableWidget<T> extends StatelessWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final DataRow Function(BuildContext context, T item) rowBuilder;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;
  final String emptyTitle;
  final String? emptySubtitle;
  final IconData emptyIcon;
  final double dataRowMaxHeight;
  final double dataRowMinHeight;
  final double? columnSpacing;
  final double horizontalMargin;
  final double dividerThickness;

  const DataTableWidget({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.horizontalScrollController,
    required this.verticalScrollController,
    this.emptyTitle = 'No Records Available',
    this.emptySubtitle,
    this.emptyIcon = Icons.inbox_outlined,
    this.dataRowMaxHeight = 56.0,
    this.dataRowMinHeight = 48.0,
    this.columnSpacing,
    this.horizontalMargin = 20.0,
    this.dividerThickness = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: items.isEmpty ? _buildEmptyState(context) : _buildTableCanvas(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(isCard: false, title: emptyTitle, subtitle: emptySubtitle, icon: emptyIcon);
  }

  // BI-DIRECTIONAL SCROLLABLE TABLE CANVAS
  Widget _buildTableCanvas(BuildContext context) {
    final isDark = context.isDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: false,
          notificationPredicate: (notification) => notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // Forces the table to expand across the full desktop card canvas while preserving horizontal scroll capability on mobile screens
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Scrollbar(
                controller: verticalScrollController,
                thumbVisibility: true,
                trackVisibility: false,
                notificationPredicate: (notification) => notification.metrics.axis == Axis.vertical,
                child: SingleChildScrollView(
                  controller: verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowHeight: 46.0,
                    headingRowColor: WidgetStateProperty.all(isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray),
                    headingTextStyle: context.titleStyleActive.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                    ),
                    dataRowMinHeight: dataRowMinHeight,
                    dataRowMaxHeight: dataRowMaxHeight,
                    dataTextStyle: context.bodyTextStyle.copyWith(
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimaryWhite : AppColors.textSecondarySlate,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.primaryRed.withValues(alpha: 0.04);
                      }
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primaryRed.withValues(alpha: 0.08);
                      }
                      return Colors.transparent;
                    }),
                    columnSpacing: columnSpacing ?? context.responsiveSize(16, 24),
                    horizontalMargin: horizontalMargin,
                    dividerThickness: dividerThickness,
                    border: TableBorder(
                      horizontalInside: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: dividerThickness),
                    ),
                    columns: columns,
                    rows: items.map((item) => rowBuilder(context, item)).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
