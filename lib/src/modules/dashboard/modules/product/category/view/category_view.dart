import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/controller/category_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/view/category_details_helper_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsiveSize(16, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: context.responsiveSize(16, 24)),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Obx(() => _buildResponsiveTable(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(20, 24)),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh Category',
          splashRadius: 24,
          onPressed: () => controller.refreshCategories(),
        ),
      ],
    );
  }

  Widget _buildResponsiveTable(BuildContext context) {
    if (controller.categoryList.isEmpty) {
      return Center(
        child: Text('No Category Available.', style: context.subTitleStyle.copyWith(fontSize: 16, color: AppColors.textHintLight)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: controller.horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: controller.horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Scrollbar(
                controller: controller.verticalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller.verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    ),
                    headingTextStyle: context.titleStyleActive.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    columnSpacing: context.responsiveSize(20, 32),
                    dataRowMaxHeight: 60.0,
                    columns: const [
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('EU Code')),
                      DataColumn(label: Text('E Date')),
                      DataColumn(label: Text('POS')),
                      DataColumn(label: Text('CNegative Stock Billing')),
                      DataColumn(label: Text('CM Code')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: controller.categoryList.map((category) => _buildDataRow(context, category)).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewCategoryDatum category) {
    return DataRow(
      cells: [
        DataCell(Text(category.igCode.isNotEmpty ? category.igCode : 'N/A')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(category.igName.isNotEmpty ? category.igName : 'N/A', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(Text(category.igType.isNotEmpty ? category.igType : 'N/A')),
        DataCell(Text(category.igEucode.isNotEmpty ? category.igEucode : 'N/A')),
        DataCell(Text(category.igEdate.toString().isNotEmpty ? category.igEdate.toString() : 'N/A')),
        DataCell(Text(category.igOnPos.toString().isNotEmpty ? category.igOnPos.toString() : 'N/A')),
        DataCell(Text(category.igNegativeStockBilling.toString().isNotEmpty ? category.igNegativeStockBilling.toString() : 'N/A')),
        DataCell(Text(category.igCmCode.toString().isNotEmpty ? category.igCmCode.toString() : 'N/A')),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_rounded, color: AppColors.primaryBrandOrange, size: 20),
            tooltip: 'View Details',
            splashRadius: 24,
            onPressed: () {
              CategoryDetailsDialogHelper.showCategoryDetailsDialog(context, category);
            },
          ),
        ),
      ],
    );
  }
}
