import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/controller/category_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('EU CODE')),
                        DataColumn(label: Text('ENTRY DATE')),
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
            webImageUrl: category.catWImg,
            mobileImageUrl: category.catMImg,
            uploadType: 'category',
            entityCode: category.igCode,
            entityTitle: category.igName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              final repo = Get.find<CategoryRepository>();
              final res = await repo.addCategoryDetails(catCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
              return res.success;
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
        DataCell(Text(category.igType.trim().isEmpty ? 'N/A' : category.igType)),
        DataCell(Text(category.igEucode.trim().isEmpty ? 'N/A' : category.igEucode)),
        DataCell(Text(_formatDate(category.igEdate))),
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

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '—';
    try {
      final DateTime parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date.toString().split(' ').first;
    }
  }

  void _showCategoryDetails(BuildContext context, ViewCategoryDatum category) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: category.igName.isNotEmpty ? category.igName.trim() : "Category",
      headerIcon: Icons.category_rounded,
      sections: [
        DetailSection(
          title: '1. Identification & Classification',
          items: [
            DetailItem(label: 'Category Code', value: category.igCode, isCopyable: true),
            DetailItem(label: 'Category Name', value: category.igName),
            DetailItem(label: 'CM Code', value: category.igCmCode, isCopyable: true),
            DetailItem(label: 'Type', value: category.igType),
            DetailItem(label: 'Old Code', value: category.igOldCode),
            DetailItem(label: 'New Code', value: category.igNewCode),
          ],
        ),
        DetailSection(
          title: '2. POS & Operational Settings',
          flags: [
            DetailFlag(label: 'On POS', value: category.igOnPos),
            DetailFlag(label: 'Negative Stock Billing', value: category.igNegativeStockBilling),
            DetailFlag(label: 'Locked', value: category.igLock),
            DetailFlag(label: 'Rate Wise Tax', value: category.igRateWiseTax),
          ],
          items: [
            DetailItem(label: 'POS Index', value: category.igPosINdex),
            DetailItem(label: 'POS Name', value: category.igPosName),
            DetailItem(label: 'Point Value Per', value: category.igPointValuePer),
            DetailItem(label: 'Print SrNo', value: category.igPrintSrNo),
            DetailItem(label: 'Rate Wise Tax Rate Type', value: category.igRateWiseTaxRateType),
          ],
        ),
        DetailSection(
          title: '3. Audit & Tracking Meta',
          items: [
            DetailItem(label: 'EU Code', value: category.igEucode),
            DetailItem(label: 'MU Code', value: category.igMucode),
            DetailItem(label: 'Entry Date', value: EntityDetailsDialogHelper.formatDate(category.igEdate)),
            DetailItem(label: 'Modified Date', value: EntityDetailsDialogHelper.formatDate(category.igMdate)),
            DetailItem(label: 'Sync Date', value: category.igSyncDate),
          ],
        ),
        DetailSection(
          title: '4. MRP & Rate Slabs',
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igMrpRateSlabLessThanOrEqualTo),
            DetailItem(label: 'Slab F1', value: category.igMrpRateSlabF1),
            DetailItem(label: 'Slab U1', value: category.igMrpRateSlabU1),
            DetailItem(label: 'Slab F2', value: category.igMrpRateSlabF2),
            DetailItem(label: 'Slab U2', value: category.igMrpRateSlabU2),
            DetailItem(label: 'Slab F3', value: category.igMrpRateSlabF3),
            DetailItem(label: 'Slab U3', value: category.igMrpRateSlabU3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igMrpRateSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          title: '5. Tax Slabs (State & Ex-State)',
          items: [
            DetailItem(label: 'State Tax Less Than Or Equal To', value: category.igStateTaxSlabLessThanOrEqualTo),
            DetailItem(label: 'State Tax Slab 1', value: category.igStateTaxSlab1),
            DetailItem(label: 'State Tax Slab 2', value: category.igStateTaxSlab2),
            DetailItem(label: 'State Tax Slab 3', value: category.igStateTaxSlab3),
            DetailItem(label: 'State Tax Greater Than Or Equal To', value: category.igStateTaxSlabGreaterThanOrEqualTo),
            DetailItem(label: 'Ex-State Tax Less Than Or Equal To', value: category.igExStateTaxSlabLessThanOrEqualTo),
            DetailItem(label: 'Ex-State Tax Slab 1', value: category.igExStateTaxSlab1),
            DetailItem(label: 'Ex-State Tax Slab 2', value: category.igExStateTaxSlab2),
            DetailItem(label: 'Ex-State Tax Slab 3', value: category.igExStateTaxSlab3),
            DetailItem(label: 'Ex-State Tax Greater Than Or Equal To', value: category.igExStateTaxSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          title: '6. Rate Difference Policy',
          items: [
            DetailItem(label: 'Days Less Than Or Equal To', value: category.igRateDiffDaysLessThanOrEqualTo),
            DetailItem(label: 'Days Slab F1', value: category.igRateDiffDaysSlabF1),
            DetailItem(label: 'Days Slab U1', value: category.igRateDiffDaysSlabU1),
            DetailItem(label: 'Days Slab F2', value: category.igRateDiffDaysSlabF2),
            DetailItem(label: 'Days Slab U2', value: category.igRateDiffDaysSlabU2),
            DetailItem(label: 'Days Slab F3', value: category.igRateDiffDaysSlabF3),
            DetailItem(label: 'Days Slab U3', value: category.igRateDiffDaysSlabU3),
            DetailItem(label: 'Days Greater Than Or Equal To', value: category.igRateDiffDaysGreaterThanOrEqualTo),
            DetailItem(label: 'Rate Diff Less Than Or Equal To', value: category.igRateDiffRateLessThanOrEqualTo),
            DetailItem(label: 'Rate Slab 1', value: category.igRateDiffRateSlab1),
            DetailItem(label: 'Rate Slab 2', value: category.igRateDiffRateSlab2),
            DetailItem(label: 'Rate Slab 3', value: category.igRateDiffRateSlab3),
            DetailItem(label: 'Rate Diff Greater Than Or Equal To', value: category.igRateDiffRateGreaterThanOrEqualTo),
          ],
        ),
      ],
    );
  }
}
