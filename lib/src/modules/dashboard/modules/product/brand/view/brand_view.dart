/*
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/controller/brand_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BrandView extends GetView<BrandController> {
  const BrandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search category code, name...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshBrands,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Brands',
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
                      Text('Loading Brands...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewBrandDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Brands Found',
                      emptySubtitle: 'Sync with server or add a new category.',
                      emptyIcon: Icons.category_outlined,
                      columns: const [
                        DataColumn(label: Text('CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('BRAND NAME')),
                        DataColumn(label: Text('FEATURED')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('VIEW ITEMS')),
                      ],
                      rowBuilder: (context, brand) => _buildDataRow(context, brand),
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

  DataRow _buildDataRow(BuildContext context, ViewBrandDatum brand) {
    return DataRow(
      cells: [
        DataCell(
          SelectableText(brand.mcCompCode.isEmpty ? 'N/A' : brand.mcCompCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: brand.wImg ?? "",
            mobileImageUrl: brand.mImg ?? "",
            uploadType: 'brand',
            entityCode: brand.mcCompCode,
            entityTitle: brand.mcCompName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              return await controller.updateBrand(mcCompCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshBrands,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: brand.mcCompName.trim().isEmpty ? 'N/A' : brand.mcCompName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                brand.mcCompName.trim().isEmpty ? 'N/A' : brand.mcCompName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: brand.featuredBrand == 1,
            activeLabel: 'Yes',
            inactiveLabel: 'No',
            activeColor: AppColors.accentAzureBlue,
            inactiveColor: Colors.grey,
            onToggle: (bool val) => controller.toggleBrandFeatured(brand, val),
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            statusValue: brand.status,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleBrandStatus(brand, val),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: context.isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'VIEW ITEMS',
            splashRadius: 18,
            onPressed: () {},
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
*/

/*import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/controller/brand_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandView extends GetView<BrandController> {
  const BrandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search brand code, name...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshBrands,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Brands',
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
                      Text('Loading Brands...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewBrandDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Brands Found',
                      emptySubtitle: 'Sync with server or add a new brand.',
                      emptyIcon: Icons.branding_watermark_outlined,
                      columns: const [
                        DataColumn(label: Text('CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('BRAND NAME')),
                        DataColumn(label: Text('FEATURED')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('VIEW ITEMS')),
                      ],
                      rowBuilder: (context, brand) => _buildDataRow(context, brand),
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

  DataRow _buildDataRow(BuildContext context, ViewBrandDatum brand) {
    return DataRow(
      cells: [
        DataCell(
          SelectableText(brand.mcCompCode.isEmpty ? 'N/A' : brand.mcCompCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: brand.wImg ?? '',
            mobileImageUrl: brand.mImg ?? '',
            uploadType: 'brand',
            entityCode: brand.mcCompCode,
            entityTitle: brand.mcCompName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              return await controller.updateBrand(mcCompCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshBrands,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: brand.mcCompName.trim().isEmpty ? 'N/A' : brand.mcCompName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                brand.mcCompName.trim().isEmpty ? 'N/A' : brand.mcCompName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: brand.featuredBrand == 1,
            activeLabel: 'Yes',
            inactiveLabel: 'No',
            activeColor: AppColors.accentAzureBlue,
            inactiveColor: Colors.grey,
            onToggle: (bool val) => controller.toggleBrandFeatured(brand, val),
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            statusValue: brand.status,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleBrandStatus(brand, val),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: context.isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'VIEW ITEMS',
            splashRadius: 18,
            onPressed: () => controller.fetchBrandItems(brand.mcCompCode),
          ),
        ),
      ],
    );
  }
}*/

import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/controller/brand_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BrandView extends GetView<BrandController> {
  const BrandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search brand code, name...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshBrands,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Brands',
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
                      Text('Loading Brands...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewBrandDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Brands Found',
                      emptySubtitle: 'Sync with server or add a new brand.',
                      emptyIcon: Icons.branding_watermark_outlined,
                      columns: const [
                        DataColumn(label: Text('CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('BRAND NAME')),
                        DataColumn(label: Text('FEATURED')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('VIEW ITEMS')),
                      ],
                      rowBuilder: (context, brand) => _buildDataRow(context, brand),
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

  DataRow _buildDataRow(BuildContext context, ViewBrandDatum brand) {
    return DataRow(
      cells: [
        DataCell(
          SelectableText(brand.mcCompCode.isEmpty ? 'N/A' : brand.mcCompCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: brand.wImg ?? '',
            mobileImageUrl: brand.mImg ?? '',
            uploadType: 'brand',
            entityCode: brand.mcCompCode,
            entityTitle: brand.mcCompName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              return await controller.updateBrand(mcCompCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshBrands,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: brand.mcCompName.trim().isEmpty ? 'N/A' : brand.mcCompName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                brand.mcCompName.trim().isEmpty ? 'N/A' : brand.mcCompName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: brand.featuredBrand == 1,
            activeLabel: 'Yes',
            inactiveLabel: 'No',
            activeColor: AppColors.accentAzureBlue,
            inactiveColor: Colors.grey,
            onToggle: (bool val) => controller.toggleBrandFeatured(brand, val),
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            statusValue: brand.status,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleBrandStatus(brand, val),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: context.isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Brand Items',
            splashRadius: 18,
            onPressed: () => _openBrandItemsDialog(context, brand),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BRAND ITEMS DIALOG
  // ===========================================================================
  void _openBrandItemsDialog(BuildContext context, ViewBrandDatum brand) {
    controller.openBrandItemsModal(brand.mcCompCode);
    final isDark = context.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 32), vertical: context.responsiveSize(16, 24)),
        child: Container(
          width: 1050,
          height: 720,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.branding_watermark_rounded, size: 22, color: AppColors.primaryRed),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              brand.mcCompName.trim().isNotEmpty ? brand.mcCompName.trim() : 'Brand Catalog',
                              style: context.titleStyleActive.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${brand.mcCompCode} • Catalog inventory associated with this brand',
                              style: context.subTitleStyle.copyWith(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '${controller.filteredBrandItems.length} Items',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.close_rounded, size: 20), splashRadius: 18, onPressed: () => Get.back()),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),

              // 2. Search Toolbar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.brandItemSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search brand items by name, code, EAN, category...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              controller.brandItemSearchController.clear();
                              controller.filterBrandItems('');
                            },
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onChanged: controller.filterBrandItems,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => controller.fetchBrandItems(brand.mcCompCode),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
                    ),
                  ],
                ),
              ),

              // 3. Items Table / Content Body
              Expanded(
                child: Obx(() {
                  if (controller.isItemsLoading.value) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                          SizedBox(height: 16),
                          Text('Loading Brand Items...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }

                  if (controller.allBrandItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                          const SizedBox(height: 12),
                          const Text('No Items Found for This Brand', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'No catalog items are mapped with brand code: ${brand.mcCompCode}',
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredBrandItems.isEmpty) {
                    return const Center(child: Text('No brand items match your search filter.'));
                  }

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 22,
                          dataRowMaxHeight: 56,
                          headingRowHeight: 44,
                          headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('IMAGE', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('ITEM NAME', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('SUB-CATEGORY', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('MRP', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('SALE RATE', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('STOCK', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                          rows: controller.filteredBrandItems.map((item) {
                            return _buildModalDataRow(context, item, brand);
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // 4. Footer Actions
              Divider(height: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        'Showing ${controller.filteredBrandItems.length} of ${controller.allBrandItems.length} items',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: AppColors.onPrimaryWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  DataRow _buildModalDataRow(BuildContext context, Item item, ViewBrandDatum brand) {
    final isDark = context.isDark;
    final String? imgUrl = (item.iImgM != null && item.iImgM!.isNotEmpty) ? item.iImgM : item.iImgW;

    return DataRow(
      cells: [
        DataCell(SelectableText(item.iCode.isEmpty ? 'N/A' : item.iCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataCell(
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            clipBehavior: Clip.antiAlias,
            child: (imgUrl != null && imgUrl.isNotEmpty)
                ? Image.network(
                    imgUrl.startsWith('http') ? imgUrl : '${ApiConstants.baseUrl}${imgUrl.startsWith('/') ? '' : '/'}$imgUrl',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, size: 18, color: Colors.grey),
                  )
                : const Icon(Icons.inventory_2_rounded, size: 18, color: Colors.grey),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: item.iName.trim().isEmpty ? 'N/A' : item.iName,
              child: Text(
                item.iName.trim().isEmpty ? 'N/A' : item.iName,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            item.categoryDisplayName.isEmpty ? '—' : item.categoryDisplayName,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Text(
            item.subCategoryDisplayName.isEmpty ? '—' : item.subCategoryDisplayName,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
          ),
        ),
        DataCell(Text('₹ ${item.sbMRate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          Text(
            '₹ ${item.sbRateA.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Text(
            '${item.sbSaleableStock}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: item.sbSaleableStock > 0 ? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate) : AppColors.statusRedError,
            ),
          ),
        ),
        DataCell(StatusBadge(statusValue: item.status, activeLabel: 'Active', inactiveLabel: 'Inactive')),
        DataCell(
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 18),
            color: AppColors.primaryRed,
            tooltip: 'View Full Item Details',
            splashRadius: 18,
            onPressed: () => _showItemDetails(context, item, brand),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // DEEP ENTITY INSPECTOR DIALOG
  // ===========================================================================
  void _showItemDetails(BuildContext context, Item item, ViewBrandDatum brand) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: item.iName.isNotEmpty ? item.iName.trim() : 'Item Details',
      subtitle: 'Inventory details for item code: ${item.iCode}',
      headerIcon: Icons.inventory_2_rounded,
      sections: [
        DetailSection(
          title: '1. Identification & Nomenclature',
          items: [
            DetailItem(label: 'Item Code (I_Code)', value: item.iCode, isCopyable: true),
            DetailItem(label: 'Item Name', value: item.iName),
            DetailItem(label: 'EAN / Barcode', value: item.eanCode, isCopyable: true),
            DetailItem(label: 'Firm Code', value: item.iFirmCode, isCopyable: true),
            DetailItem(
              label: 'Brand',
              value: item.brandName.isNotEmpty ? item.brandName : (brand.mcCompName.isNotEmpty ? brand.mcCompName : brand.mcCompCode),
            ),
            DetailItem(label: 'EU Code', value: item.iEuCode),
          ],
        ),
        DetailSection(
          title: '2. Group & Taxonomy Associations',
          items: [
            DetailItem(label: 'Category (ItemGroup)', value: item.categoryDisplayName),
            DetailItem(label: 'Category Code (I_ItemGroup)', value: item.iItemGroup, isCopyable: true),
            DetailItem(label: 'Sub-Category (OtherGroup)', value: item.subCategoryDisplayName),
            DetailItem(label: 'Sub-Category Code (I_OtherGroup)', value: item.iOtherGroup, isCopyable: true),
            DetailItem(label: 'Mfg Company Code', value: item.iMfgComp),
          ],
        ),
        DetailSection(
          title: '3. Pricing & Stock Inventory',
          flags: [
            DetailFlag(label: 'Active Status', value: item.isActive),
            DetailFlag(label: 'In Stock', value: item.sbSaleableStock > 0),
          ],
          items: [
            DetailItem(label: 'MRP Rate', value: '₹ ${item.sbMRate.toStringAsFixed(2)}'),
            DetailItem(label: 'Sale Rate (Rate A)', value: '₹ ${item.sbRateA.toStringAsFixed(2)}'),
            DetailItem(label: 'Saleable Stock Units', value: '${item.sbSaleableStock}'),
          ],
        ),
        DetailSection(
          title: '4. Audit Logs & Timestamps',
          items: [
            DetailItem(label: 'Inserted Timestamp', value: _formatDate(item.insertedOn)),
            DetailItem(label: 'Created Timestamp', value: _formatDate(item.createdAt)),
            DetailItem(label: 'Updated Timestamp', value: _formatDate(item.updatedAt)),
          ],
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '—';
    try {
      final DateTime parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
    } catch (_) {
      return date.toString().split(' ').first;
    }
  }
}
