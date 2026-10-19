import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/controller/sub_cat_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubCategoryView extends GetView<SubCategoryController> {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search sub category code, name, EU code...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshData,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Sub-Categories',
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<ViewSubCategoryDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Sub-Categories...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Sub-Categories Available',
              emptySubtitle: 'Sync with server or configure a new sub-category.',
              emptyIcon: Icons.account_tree_outlined,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('CODE')),
                DataColumn(label: Text('IMAGES')),
                DataColumn(label: Text('SUB CATEGORY NAME')),
                DataColumn(label: Text('EU CODE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, subCategory) => _buildDataRow(context, subCategory),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewSubCategoryDatum subCategory) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: subCategory.ogCode,
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: subCategory.imImageWeb,
            mobileImageUrl: subCategory.imImageMob,
            uploadType: 'subcategory',
            entityCode: subCategory.ogCode,
            entityTitle: subCategory.ogName,
            onLinkEntity: ({required String entityCode, required String webImageUrl, required String mobileImageUrl}) async {
              return await controller.updateSubCategory(ogCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshData,
          ),
        ),
        DataCell(
          AppTableCellText(
            text: subCategory.ogName,
            maxWidth: 220,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(AppTableCellText(text: subCategory.ogEucode, maxWidth: 140)),
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: subCategory.isStatusActive,
            statusValue: subCategory.ogStatus,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleSubCategoryStatus(subCategory, val),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View SubCategory Configurations',
            splashRadius: 18,
            onPressed: () => _showSubCategoryDetails(context, subCategory),
          ),
        ),
      ],
    );
  }

  void _showSubCategoryDetails(BuildContext context, ViewSubCategoryDatum subCategory) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: subCategory.ogName.isNotEmpty ? subCategory.ogName.trim() : 'Sub Category',
      subtitle: 'Code: ${subCategory.ogCode.isNotEmpty ? subCategory.ogCode : "—"}',
      headerIcon: Icons.account_tree_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          items: [
            DetailItem(label: 'Sub Category Code', value: subCategory.ogCode, isCopyable: true),
            DetailItem(label: 'Sub Category Name', value: subCategory.ogName),
          ],
        ),
        DetailSection(
          title: 'System Information',
          flags: [DetailFlag(label: 'Active Status', value: subCategory.isStatusActive)],
          items: [
            DetailItem(label: 'SC Code', value: subCategory.ogScCode, isCopyable: true),
            DetailItem(label: 'EU Code', value: subCategory.ogEucode),
            DetailItem(label: 'MU Code', value: subCategory.ogMucode),
          ],
        ),
        DetailSection(
          title: 'History Details',
          items: [
            DetailItem(label: 'Created By', value: subCategory.ogCreatedBy),
            DetailItem(label: 'Created At', value: EntityDetailsDialogHelper.formatDate(subCategory.ogCreatedTimeStamp)),
            DetailItem(label: 'Modified By', value: subCategory.ogModifyBy),
            DetailItem(label: 'Modified At', value: EntityDetailsDialogHelper.formatDate(subCategory.ogModifyTimeStamp)),
          ],
        ),
      ],
    );
  }
}
