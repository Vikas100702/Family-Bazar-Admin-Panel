import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class DataTableWidget<T> extends StatelessWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final DataRow Function(BuildContext context, T item) rowBuilder;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;
  final String emptyTitle;
  final IconData emptyIcon;
  final double dataRowMaxHeight;
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
    this.emptyIcon = Icons.inbox_outlined,
    this.dataRowMaxHeight = 64.0,
    this.columnSpacing,
    this.horizontalMargin = 24.0,
    this.dividerThickness = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: items.isEmpty ? _buildEmptyState(context) : _buildTable(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emptyIcon, size: 48, color: AppColors.textHintLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(emptyTitle, style: context.titleStyleActive.copyWith(fontSize: 16, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Scrollbar(
                controller: verticalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.primaryBrandOrange.withValues(alpha: 0.04);
                      }
                      return null;
                    }),
                    headingTextStyle: context.titleStyleActive.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                    columnSpacing: columnSpacing ?? context.responsiveSize(16, 24),
                    horizontalMargin: horizontalMargin,
                    dataRowMaxHeight: dataRowMaxHeight,
                    dividerThickness: dividerThickness,
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
