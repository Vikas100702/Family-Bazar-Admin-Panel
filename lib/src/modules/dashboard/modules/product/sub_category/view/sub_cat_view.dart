import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/binding/image_upload_binding.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/widget/image_upload_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_search_field.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
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
                  child: DataTableWidget<ViewSubCategoryDatum>(
                    items: controller.pagedList.toList(),
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
              Text('Sub-Category Master', style: context.headingTextStyle.copyWith(fontSize: 18)),
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
                  color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                  tooltip: 'Refresh Sub-Categories',
                  onPressed: controller.refreshCategories,
                );
              }),
            ],
          ),
          /*const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Action reserved for sub-category creation dialog
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('Add Sub-Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.onPrimaryWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),*/
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
                onPressed: controller.refreshCategories,
                icon: isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(isRefreshing ? 'Refreshing...' : 'Refresh'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              );
            }),
            /*const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Action reserved for sub-category creation dialog
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Sub-Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.onPrimaryWhite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),*/
          ],
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
        DataCell(_buildImagesCell(context, subCategory)),
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
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View SubCategory Configurations',
            splashRadius: 18,
            onPressed: () => _showSubCategoryDetails(context, subCategory),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesCell(BuildContext context, ViewSubCategoryDatum subCategory) {
    final bool hasWebImg = subCategory.subCatWImg.trim().isNotEmpty;
    final bool hasMobileImg = subCategory.subCatMImg.trim().isNotEmpty;
    final isDark = context.isDark;

    if (!hasWebImg && !hasMobileImg) {
      return InkWell(
        onTap: () => _openImageUploadModal(context, subCategory),
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
      onTap: () => _openImageUploadModal(context, subCategory),
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
                imageUrl: subCategory.subCatWImg,
                width: 40,
                height: 24,
                placeholderIcon: Icons.desktop_mac_rounded,
                tooltipLabel: 'Web Banner',
              ),
              const SizedBox(width: 6),
              _buildMiniThumbnail(
                imageUrl: subCategory.subCatMImg,
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

  void _openImageUploadModal(BuildContext context, ViewSubCategoryDatum subCategory) {
    ImageUploadBinding().dependencies();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24), vertical: context.responsiveSize(16, 24)),
        child: ImageUploadView(
          uploadType: 'subcategory',
          entityCode: subCategory.ogCode,
          entityTitle: subCategory.ogName,
          initialWebImageUrl: subCategory.subCatWImg,
          initialMobileImageUrl: subCategory.subCatMImg,
          onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
            final repo = Get.find<SubCategoryRepository>();
            final res = await repo.addSubCategoryDetails(subCatCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            return res.success;
          },
          onSuccess: () {
            if (Get.isRegistered<SubCategoryController>()) {
              Get.find<SubCategoryController>().refreshCategories();
            }
          },
          onDismiss: () => Get.back(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildStatusBadge({required bool isActive, required String activeLabel, required String inactiveLabel}) {
    final color = isActive ? AppColors.statusGreenSuccess : AppColors.statusRedError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isActive ? activeLabel : inactiveLabel,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
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
