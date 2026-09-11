import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/binding/image_upload_binding.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/widget/image_upload_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_search_field.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
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
                  child: DataTableWidget<ViewCategoryDatum>(
                    items: controller.pagedList.toList(),
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
              Text('Category Master', style: context.headingTextStyle.copyWith(fontSize: 18)),
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
                  tooltip: 'Refresh Categories',
                  onPressed: controller.refreshCategories,
                );
              }),
            ],
          ),
          AppSearchField(hintText: 'Search', onChanged: controller.onSearchChanged, onClear: controller.clearSearch),
          /*const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Action reserved for category creation modal
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('Add Category'),
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
            /* const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Action reserved for category creation modal
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Category'),
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

  DataRow _buildDataRow(BuildContext context, ViewCategoryDatum category) {
    final isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          SelectableText(category.igCode.isEmpty ? 'N/A' : category.igCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        DataCell(_buildImagesCell(context, category)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: category.igName.trim().isEmpty ? 'N/A' : category.igName,
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
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Category Details',
            splashRadius: 18,
            onPressed: () => _showCategoryDetails(context, category),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesCell(BuildContext context, ViewCategoryDatum category) {
    final bool hasWebImg = category.catWImg.trim().isNotEmpty;
    final bool hasMobileImg = category.catMImg.trim().isNotEmpty;
    final isDark = context.isDark;

    if (!hasWebImg && !hasMobileImg) {
      return InkWell(
        onTap: () => _openImageUploadModal(context, category),
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
      onTap: () => _openImageUploadModal(context, category),
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
                imageUrl: category.catWImg,
                width: 40,
                height: 24,
                placeholderIcon: Icons.desktop_mac_rounded,
                tooltipLabel: 'Web Banner',
              ),
              const SizedBox(width: 6),
              _buildMiniThumbnail(
                imageUrl: category.catMImg,
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

  void _openImageUploadModal(BuildContext context, ViewCategoryDatum category) {
    ImageUploadBinding().dependencies();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24), vertical: context.responsiveSize(16, 24)),
        child: ImageUploadView(
          uploadType: 'category',
          entityCode: category.igCode,
          entityTitle: category.igName,
          initialWebImageUrl: category.catWImg,
          initialMobileImageUrl: category.catMImg,
          onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
            final repo = Get.find<CategoryRepository>();
            final res = await repo.addCategoryDetails(catCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            return res.success;
          },
          onSuccess: () {
            if (Get.isRegistered<CategoryController>()) {
              Get.find<CategoryController>().refreshCategories();
            }
          },
          onDismiss: () => Get.back(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildStatusBadge({required dynamic value, required String activeLabel, required String inactiveLabel}) {
    final bool isActive = value == true || value == 1 || value == '1' || value == 'Y' || value == 'true';
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
          items: [
            DetailItem(label: 'EU Code', value: category.igEucode),
            DetailItem(label: 'MU Code', value: category.igMucode),
            DetailItem(label: 'Entry Date', value: EntityDetailsDialogHelper.formatDate(category.igEdate)),
            DetailItem(label: 'Modified Date', value: EntityDetailsDialogHelper.formatDate(category.igMdate)),
            DetailItem(label: 'Sync Date', value: category.igSyncDate),
          ],
        ),
        DetailSection(
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
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igStateTaxSlabLessThanOrEqualTo),
            DetailItem(label: 'Tax Slab 1', value: category.igStateTaxSlab1),
            DetailItem(label: 'Tax Slab 2', value: category.igStateTaxSlab2),
            DetailItem(label: 'Tax Slab 3', value: category.igStateTaxSlab3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igStateTaxSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igExStateTaxSlabLessThanOrEqualTo),
            DetailItem(label: 'Ex-Tax Slab 1', value: category.igExStateTaxSlab1),
            DetailItem(label: 'Ex-Tax Slab 2', value: category.igExStateTaxSlab2),
            DetailItem(label: 'Ex-Tax Slab 3', value: category.igExStateTaxSlab3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igExStateTaxSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igRateDiffDaysLessThanOrEqualTo),
            DetailItem(label: 'Days Slab F1', value: category.igRateDiffDaysSlabF1),
            DetailItem(label: 'Days Slab U1', value: category.igRateDiffDaysSlabU1),
            DetailItem(label: 'Days Slab F2', value: category.igRateDiffDaysSlabF2),
            DetailItem(label: 'Days Slab U2', value: category.igRateDiffDaysSlabU2),
            DetailItem(label: 'Days Slab F3', value: category.igRateDiffDaysSlabF3),
            DetailItem(label: 'Days Slab U3', value: category.igRateDiffDaysSlabU3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igRateDiffDaysGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igRateDiffRateLessThanOrEqualTo),
            DetailItem(label: 'Rate Slab 1', value: category.igRateDiffRateSlab1),
            DetailItem(label: 'Rate Slab 2', value: category.igRateDiffRateSlab2),
            DetailItem(label: 'Rate Slab 3', value: category.igRateDiffRateSlab3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igRateDiffRateGreaterThanOrEqualTo),
          ],
        ),
      ],
    );
  }
}
