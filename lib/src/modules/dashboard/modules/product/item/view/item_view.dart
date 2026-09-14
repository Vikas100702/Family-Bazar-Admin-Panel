import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/binding/image_upload_binding.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/widget/image_upload_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_search_field.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/controller/items_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemsView extends GetView<ItemController> {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
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
                      Text('Loading Product Items...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewItemDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Product Items Available',
                      emptySubtitle: 'Sync with server or configure inventory catalog.',
                      emptyIcon: Icons.inventory_2_outlined,
                      columns: const [
                        DataColumn(label: Text('ITEM CODE')),
                        DataColumn(label: Text('FIRM CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('ITEM NAME')),
                        DataColumn(label: Text('CATEGORY')),
                        DataColumn(label: Text('SUB-CATEGORY')),
                        DataColumn(label: Text('ITEM MRP')),
                        DataColumn(label: Text('SALES PRICE')),
                        DataColumn(label: Text('AVAILABLE STOCK')),
                        DataColumn(label: Text('EU CODE')),
                        DataColumn(label: Text('EAN / BARCODE')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, item) => _buildDataRow(context, item),
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

  Widget _buildHeader(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final bool isRefreshing = controller.isLoading.value;
                return IconButton(
                  icon: isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                        )
                      : const Icon(Icons.refresh_rounded, size: 20),
                  mouseCursor: SystemMouseCursors.click,
                  color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                  tooltip: 'Refresh Items',
                  onPressed: isRefreshing ? null : controller.refreshCategories,
                );
              }),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSearchField(hintText: 'Search', onChanged: controller.onSearchChanged, onClear: controller.clearSearch),
            const SizedBox(width: 12),
            Obx(() {
              final bool isRefreshing = controller.isLoading.value;
              return OutlinedButton.icon(
                onPressed: isRefreshing ? null : controller.refreshCategories,
                icon: isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(isRefreshing ? 'Refreshing...' : 'Refresh'),
                style: OutlinedButton.styleFrom(
                  enabledMouseCursor: SystemMouseCursors.click,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewItemDatum item) {
    final isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText(_formatText(item.iCode), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(Text(_formatText(item.iFirmCode))),
        DataCell(_buildImagesCell(context, item)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(item.iName),
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                _formatText(item.iName),
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SelectableText(
            _formatText(item.itemGroup),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          SelectableText(
            _formatText(item.otherGroup),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
          ),
        ),
        DataCell(Text(_formatText(item.sbMRate.toString()))),
        DataCell(Text(_formatText(item.sbRateA.toString()))),
        DataCell(Text(_formatText(item.sbSaleableStock.toString()))),
        DataCell(Text(_formatText(item.iEuCode))),
        DataCell(SelectableText(_formatText(item.eanCode), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Item Details',
            splashRadius: 18,
            onPressed: () => _showItemDetails(context, item),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesCell(BuildContext context, ViewItemDatum item) {
    final bool hasWebImg = item.iImgW.trim().isNotEmpty;
    final bool hasMobileImg = item.iImgM.trim().isNotEmpty;
    final isDark = context.isDark;

    if (!hasWebImg && !hasMobileImg) {
      return InkWell(
        onTap: () => _openImageUploadModal(context, item),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 15, color: AppColors.primaryRed),
              SizedBox(width: 4),
              Text(
                'Upload',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryRed),
              ),
            ],
          ),
        ),
      );
    }
    return InkWell(
      onTap: () => _openImageUploadModal(context, item),
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Tooltip(
        message: 'Click to view / update category images',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniThumbnail(
                imageUrl: item.iImgW,
                width: 40,
                height: 24,
                placeholderIcon: Icons.desktop_mac_rounded,
                tooltipLabel: 'Web Banner',
              ),
              const SizedBox(width: 6),
              _buildMiniThumbnail(
                imageUrl: item.iImgM,
                width: 24,
                height: 24,
                placeholderIcon: Icons.phone_android_rounded,
                tooltipLabel: 'Mobile Icon',
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, size: 13, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniThumbnail({
    required String imageUrl,
    required double width,
    required double height,
    required IconData placeholderIcon,
    required String tooltipLabel,
  }) {
    final bool hasImage = imageUrl.trim().isNotEmpty;
    final String resolvedUrl = _resolveImageUrl(imageUrl);

    return Tooltip(
      message: tooltipLabel,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(placeholderIcon, size: 12, color: Colors.grey),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5))),
              )
            : Icon(placeholderIcon, size: 12, color: Colors.grey.shade400),
      ),
    );
  }

  static String _resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    const String baseDomain = ApiConstants.baseUrl;
    return '$baseDomain${path.startsWith('/') ? '' : '/'}$path';
  }

  void _openImageUploadModal(BuildContext context, ViewItemDatum item) {
    ImageUploadBinding().dependencies();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 24), vertical: context.responsiveHeight(16, 24)),
        child: ImageUploadView(
          uploadType: 'item',
          entityCode: item.iCode,
          entityTitle: item.iName,
          initialWebImageUrl: item.iImgW,
          initialMobileImageUrl: item.iImgM,
          onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
            final repo = Get.find<ItemRepository>();
            final res = await repo.addItemDetails(itemCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            return res.success;
          },
          onSuccess: () {
            if (Get.isRegistered<ItemController>()) {
              Get.find<ItemController>().refreshCategories();
            }
          },
          onDismiss: () => Get.back(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showItemDetails(BuildContext context, ViewItemDatum item) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: item.iName.isNotEmpty ? item.iName.trim() : "Item",
      headerIcon: Icons.inventory_2_rounded,
      sections: [
        DetailSection(
          title: '',
          items: [
            DetailItem(label: 'Item Code', value: item.iCode, isCopyable: true),
            DetailItem(label: 'Item Name', value: item.iName),
            DetailItem(label: 'EAN / Barcode', value: item.eanCode, isCopyable: true),
            DetailItem(label: 'Firm Code', value: item.iFirmCode, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '',
          items: [
            DetailItem(label: 'Category Code', value: item.iItemGroup, isCopyable: true),
            DetailItem(label: 'Sub-Category Code', value: item.iOtherGroup, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '',
          items: [DetailItem(label: 'EU Code', value: item.iEuCode)],
        ),
      ],
    );
  }

  String _formatText(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }
}

typedef ItemView = ItemsView;
