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
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
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
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshData,
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
          SelectableText(brand.mcCompCode.isEmpty ? '—' : brand.mcCompCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(
          TableImageCellWidget(
            webImageUrl: brand.imImageWeb,
            mobileImageUrl: brand.imImageMob,
            uploadType: 'brand',
            entityCode: brand.mcCompCode,
            entityTitle: brand.mcCompName,
            onLinkEntity: ({required String entityCode, required String webImageUrl, required String mobileImageUrl}) async {
              return await controller.updateBrand(mcCompCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            },
            onSuccess: controller.refreshData,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: brand.mcCompName.trim().isEmpty ? '—' : brand.mcCompName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                brand.mcCompName.trim().isEmpty ? '—' : brand.mcCompName,
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
            isActive: brand.isFeatured,
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
            isActive: brand.isStatusActive,
            statusValue: brand.mcStatus,
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

  void _openBrandItemsDialog(BuildContext context, ViewBrandDatum brand) {
    controller.openBrandItemsModal(brand.mcCompCode);
    final bool isDark = context.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 32), vertical: context.responsiveSize(16, 24)),
        child: Container(
          width: context.isDesktop ? 1050 : context.screenWidth * 0.96,
          constraints: BoxConstraints(maxWidth: 1050, maxHeight: context.screenHeight * 0.90),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: context.responsiveRadius(12, 14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: context.responsiveRadius(6, 8)),
                          child: const Icon(Icons.branding_watermark_rounded, size: 22, color: AppColors.primaryRed),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              brand.mcCompName.trim().isNotEmpty ? brand.mcCompName.trim() : 'Brand Catalog',
                              style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(14, 16)),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${brand.mcCompCode}',
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
                          border: OutlineInputBorder(borderRadius: context.responsiveRadius(6, 8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                        onChanged: controller.filterBrandItems,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => controller.fetchBrandItems(brand.mcCompCode),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                      ),
                    ),
                  ],
                ),
              ),
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
                        ],
                      ),
                    );
                  }

                  if (controller.filteredBrandItems.isEmpty) {
                    return const Center(child: Text('No brand items match your search filter.'));
                  }

                  return RepaintBoundary(
                    child: Scrollbar(
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
                            rows: controller.filteredBrandItems
                                .map((item) {
                                  return _buildModalDataRow(context, item, brand, isDark);
                                })
                                .toList(growable: false),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
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
                        shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(4, 6)),
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

  DataRow _buildModalDataRow(BuildContext context, ViewItemByTypeDatum item, ViewBrandDatum brand, bool isDark) {
    return DataRow(
      cells: [
        DataCell(SelectableText(item.iCode.isEmpty ? '—' : item.iCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataCell(
          TableImageCellWidget(
            webImageUrl: item.imImageWeb,
            mobileImageUrl: item.imImageMob,
            secondaryImageUrl: item.imSecondryImage,
            informationImageUrl: item.imImformation,
            uploadType: 'item',
            entityCode: item.iCode,
            entityTitle: item.iName,
            onLinkEntity: ({required String entityCode, required String webImageUrl, required String mobileImageUrl}) async {
              final ItemRepository repo = Get.find<ItemRepository>();
              final res = await repo.addItemDetails(itemCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
              return res.success;
            },
            onSuccess: controller.refreshData,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: item.iName.trim().isEmpty ? '—' : item.iName,
              child: Text(
                item.iName.trim().isEmpty ? '—' : item.iName,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            item.itemGroupName.isEmpty ? '—' : item.itemGroupName,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Text(
            (item.otherGroupName.toString()).trim().isEmpty ? '—' : item.otherGroupName.toString().trim(),
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
          ),
        ),
        DataCell(Text('₹${_formatPrice(item.sbMRate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          Text(
            '₹${_formatPrice(item.sbRateA)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Builder(
            builder: (_) {
              final double rawStock = double.tryParse(item.sbSaleableStock.toString()) ?? 0;
              final int stock = rawStock.toInt();
              return Text(
                '$stock',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: stock > 0 ? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate) : AppColors.statusRedError,
                ),
              );
            },
          ),
        ),
        DataCell(StatusBadge(statusValue: item.iStatus, activeLabel: 'Active', inactiveLabel: 'Inactive')),
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

  void _showItemDetails(BuildContext context, ViewItemByTypeDatum item, ViewBrandDatum brand) {
    final bool isActiveItem = item.iStatus == '1' || item.iStatus.toLowerCase() == 'active' || item.iStatus.toLowerCase() == 'true';
    final double rawStock = double.tryParse(item.sbSaleableStock.toString()) ?? 0;
    final int stockCount = rawStock.toInt();
    EntityDetailsDialogHelper.show(
      context: context,
      title: item.iName.isNotEmpty ? item.iName.trim() : 'Item Details',
      subtitle: 'Code: ${item.iCode}',
      headerIcon: Icons.inventory_2_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          items: [
            DetailItem(label: 'Item Code', value: item.iCode, isCopyable: true),
            DetailItem(label: 'Item Name', value: item.iName),
            DetailItem(label: 'EAN Code', value: item.iBarCode),
            DetailItem(label: 'Batch Number', value: item.batchNo),
            DetailItem(label: 'Brand Code', value: item.iMfgComp),
            DetailItem(
              label: 'Brand Name',
              value: item.brandName.isNotEmpty ? item.brandName : (brand.mcCompName.isNotEmpty ? brand.mcCompName : brand.mcCompCode),
            ),
          ],
        ),
        DetailSection(
          title: 'System Information',
          flags: [DetailFlag(label: 'Active Status', value: isActiveItem)],
          items: [
            DetailItem(label: 'Category Code', value: item.iItemGroup),
            DetailItem(label: 'Category Name', value: item.itemGroupName, isCopyable: true),
            DetailItem(label: 'Sub-Category Code', value: item.iOtherGroup, isCopyable: true),
            DetailItem(
              label: 'Sub-Category Name',
              value: (item.otherGroupName.toString()).trim().isNotEmpty ? item.otherGroupName.toString().trim() : '—',
            ),
            DetailItem(label: 'Firm Code', value: item.iFirmCode, isCopyable: true),
          ],
        ),
        DetailSection(
          title: 'Pricing & Stock Details',
          flags: [DetailFlag(label: 'In Stock', value: stockCount > 0)],
          items: [
            DetailItem(label: 'MRP Rate', value: '₹${_formatPrice(item.sbMRate)}'),
            DetailItem(label: 'Sale Rate', value: '₹${_formatPrice(item.sbRateA)}'),
            DetailItem(label: 'Saleable Stock Units', value: '$stockCount'),
          ],
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    final double? parsed = double.tryParse(price.toString().trim());
    return (parsed ?? 0.0).toStringAsFixed(2);
  }
}
