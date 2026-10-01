import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/controller/category_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search category code, name, EU code...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshCategories,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Categories',
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.pagedList.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: context.defaultDecoration,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                      SizedBox(height: 16),
                      Text('Loading Product Categories...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: DataTableWidget<ViewCategoryDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Product Categories Found',
                      emptySubtitle: 'Sync with server or add a new category.',
                      emptyIcon: Icons.category_outlined,
                      columns: const [
                        DataColumn(label: Text('CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('CATEGORY NAME')),
                        DataColumn(label: Text('EU CODE')),
                        DataColumn(label: Text('STAUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, category) => _buildDataRow(context, category),
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveHeight(12, 16)),
                CustomPaginationWidget(
                  currentPage: controller.currentPage.value,
                  totalItems: controller.totalRecords.value,
                  itemsPerPage: controller.itemsPerPage.value,
                  itemsPerPageOptions: controller.pageSizeOptions,
                  isLoading: controller.isLoading.value,
                  onPageChanged: controller.changePage,
                  onItemsPerPageChanged: controller.changePageSize,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewCategoryDatum category) {
    final isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          SelectableText(category.igCode.isEmpty ? 'N/A' : category.igCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: category.imImageWeb,
            mobileImageUrl: category.imImageMob,
            uploadType: 'category',
            entityCode: category.igCode,
            entityTitle: category.igName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              return await controller.updateCategory(igCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshCategories,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: category.igName.trim().isEmpty ? 'N/A' : category.igName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                category.igName.trim().isEmpty ? 'N/A' : category.igName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(Text(category.igEucode.trim().isEmpty ? 'N/A' : category.igEucode)),
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: category.isStatusActive,
            statusValue: category.igStatus,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleCategoryStatus(category, val),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Category Details',
            splashRadius: 18,
            onPressed: () => _showCategoryDetails(context, category),
          ),
        ),
      ],
    );
  }

  void _showCategoryDetails(BuildContext context, ViewCategoryDatum category) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: category.igName.isNotEmpty ? category.igName.trim() : "Category",
      headerIcon: Icons.category_rounded,
      sections: [
        DetailSection(
          title: '',
          items: [
            DetailItem(label: 'Category Code', value: category.igCode, isCopyable: true),
            DetailItem(label: 'Category Name', value: category.igName),
            DetailItem(label: 'CM Code', value: category.igCmCode, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '',
          items: [
            DetailItem(label: 'EU Code', value: category.igEucode),
            DetailItem(label: 'MU Code', value: category.igMucode),
          ],
        ),
      ],
    );
  }
}
