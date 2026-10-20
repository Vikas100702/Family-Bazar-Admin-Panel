import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
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
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshData,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Categories',
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<ViewCategoryDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Product Categories...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Product Categories Found',
              emptySubtitle: 'Sync with server or add a new category.',
              emptyIcon: Icons.category_outlined,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('CODE')),
                DataColumn(label: Text('IMAGES')),
                DataColumn(label: Text('CATEGORY NAME')),
                DataColumn(label: Text('EU CODE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, category) => _buildDataRow(context, category),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewCategoryDatum category) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: category.igCode.withDashFallback,
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: category.imImageWeb,
            mobileImageUrl: category.imImageMob,
            uploadType: 'category',
            entityCode: category.igCode,
            entityTitle: category.igName,
            onLinkEntity: ({required String entityCode, required String webImageUrl, required String mobileImageUrl}) async {
              return await controller.updateCategory(igCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshData,
          ),
        ),
        DataCell(
          AppTableCellText(
            text: category.igName.withDashFallback,
            maxWidth: 220,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(AppTableCellText(text: category.igEucode.withDashFallback, maxWidth: 140, style: context.captionStyle)),
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
      title: category.igName.isNotEmpty ? category.igName.trim() : 'Category Details',
      subtitle: 'Code: ${category.igCode}',
      headerIcon: Icons.category_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          items: [
            DetailItem(label: 'Category Code', value: category.igCode.withDashFallback, isCopyable: true),
            DetailItem(label: 'Category Name', value: category.igName.withDashFallback),
          ],
        ),
        DetailSection(
          title: 'System Information',
          flags: [DetailFlag(label: 'Active Status', value: category.isStatusActive)],
          items: [
            DetailItem(label: 'CM Code', value: category.igCmCode.withDashFallback, isCopyable: true),
            DetailItem(label: 'EU Code', value: category.igEucode.withDashFallback),
            DetailItem(label: 'MU Code', value: category.igMucode.withDashFallback),
          ],
        ),
        DetailSection(
          title: 'History Details',
          items: [
            DetailItem(label: 'Created By', value: category.igCreatedBy.withDashFallback),
            DetailItem(label: 'Created At', value: EntityDetailsDialogHelper.formatDate(category.igCreatedTimeStamp)),
            DetailItem(label: 'Modified By', value: category.igModifyBy.withDashFallback),
            DetailItem(label: 'Modified At', value: EntityDetailsDialogHelper.formatDate(category.igModifyTimeStamp)),
          ],
        ),
      ],
    );
  }
}
