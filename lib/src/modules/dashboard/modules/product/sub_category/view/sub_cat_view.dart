import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/controller/sub_cat_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshSubCategories,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Sub-Categories',
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
                      Text('Loading Sub-Categories...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewSubCategoryDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Sub-Categories Available',
                      emptySubtitle: 'Sync with server or configure a new sub-category.',
                      emptyIcon: Icons.account_tree_outlined,
                      columns: const [
                        DataColumn(label: Text('CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('SUB CATEGORY NAME')),
                        DataColumn(label: Text('SC CODE')),
                        DataColumn(label: Text('EU CODE')),
                        DataColumn(label: Text('ENTRY DATE')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, subCategory) => _buildDataRow(context, subCategory),
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

  DataRow _buildDataRow(BuildContext context, ViewSubCategoryDatum subCategory) {
    final isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          SelectableText(subCategory.ogCode.isEmpty ? 'N/A' : subCategory.ogCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: subCategory.subCatWImg,
            mobileImageUrl: subCategory.subCatMImg,
            uploadType: 'subcategory',
            entityCode: subCategory.ogCode,
            entityTitle: subCategory.ogName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              final repo = Get.find<SubCategoryRepository>();
              final res = await repo.addSubCategoryDetails(subCatCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
              return res.success;
            },
            onSuccess: controller.refreshSubCategories,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: subCategory.ogName.trim().isEmpty ? 'N/A' : subCategory.ogName,
              child: Text(
                subCategory.ogName.trim().isEmpty ? 'N/A' : subCategory.ogName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SelectableText(
            _formatText(subCategory.ogScCode),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(Text(_formatText(subCategory.ogEucode))),
        DataCell(Text(_formatDate(subCategory.ogEdate))),
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
      title: '${subCategory.ogName.isNotEmpty ? subCategory.ogName.trim() : "Sub Category"} Details',
      subtitle: 'Configuration overview for code: ${subCategory.ogCode.isNotEmpty ? subCategory.ogCode : "N/A"}',
      headerIcon: Icons.account_tree_rounded,
      sections: [
        DetailSection(
          title: '1. Basic & Identification Information',
          items: [
            DetailItem(label: 'Sub Category Code', value: subCategory.ogCode, isCopyable: true),
            DetailItem(label: 'Sub Category Name', value: subCategory.ogName),
            DetailItem(label: 'Parent / SC Code', value: subCategory.ogScCode, isCopyable: true),
            DetailItem(label: 'Old Code', value: subCategory.ogOldCode),
            DetailItem(label: 'New Code', value: subCategory.ogNewCode),
          ],
        ),
        DetailSection(
          title: '2. Operational Flags & POS Settings',
          flags: [
            DetailFlag(label: 'On POS', value: subCategory.ogOnPos == true),
            DetailFlag(label: 'Negative Stock Billing', value: subCategory.ogNegativeStockBilling == true),
            DetailFlag(label: 'Locked', value: subCategory.ogLock == true),
          ],
          items: [
            DetailItem(label: 'POS Index', value: subCategory.ogPosIndex),
            DetailItem(label: 'POS Name', value: subCategory.ogPosName),
            DetailItem(label: 'Print SrNo', value: subCategory.ogPrintSrNo),
          ],
        ),
        DetailSection(
          title: '3. Audit & Timestamps',
          items: [
            DetailItem(label: 'EU Code (Created By)', value: subCategory.ogEucode),
            DetailItem(label: 'MU Code (Modified By)', value: subCategory.ogMucode),
            DetailItem(label: 'Entry Date', value: EntityDetailsDialogHelper.formatDate(subCategory.ogEdate)),
            DetailItem(label: 'Modified Date', value: EntityDetailsDialogHelper.formatDate(subCategory.ogMdate)),
          ],
        ),
      ],
    );
  }

  String _formatText(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '—';
    try {
      final DateTime parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date.toString().split(' ').first;
    }
  }
}
