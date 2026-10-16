import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/controller/app_banners_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/model/app_banners_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBannersView extends GetView<AppBannersController> {
  const AppBannersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search banner ID, type (e.g. home_slider)...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearFilters,
          onRefresh: controller.refreshBanners,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Banners',
          extraActions: [
            ElevatedButton.icon(
              onPressed: () {
                controller.resetForm();
                _openSaveBannerDialog(context);
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Banner', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.onPrimaryWhite,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
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
                      Text('Loading Banners...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<AppBannerDatum>(
                      items: controller.pagedList.toList(),
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Banners Found',
                      emptySubtitle: 'Click "Add Banner" to create home sliders or promo banners.',
                      emptyIcon: Icons.view_carousel_rounded,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('START DATE')),
                        DataColumn(label: Text('END DATE')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('CREATED AT')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, banner) => _buildDataRow(context, banner),
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

  DataRow _buildDataRow(BuildContext context, AppBannerDatum banner) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText('#${banner.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        // In-Table Image Cell with Direct Upload / Replace Trigger (Items View Pattern)
        DataCell(_buildBannerImageCell(context, banner)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            child: Text(banner.bnrType.isNotEmpty ? banner.bnrType : 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        DataCell(Text(banner.startAt?.isNotEmpty == true ? banner.startAt! : '—', style: const TextStyle(fontSize: 12))),
        DataCell(Text(banner.endAt?.isNotEmpty == true ? banner.endAt! : '—', style: const TextStyle(fontSize: 12))),
        // Inline Status Toggle (Direct mutation via single saveBanner API)
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: banner.status == 1,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleBannerStatus(banner, val),
          ),
        ),
        DataCell(Text(banner.created.isNotEmpty ? banner.created : '—', style: const TextStyle(fontSize: 11))),
        // Approach B: Streamlined 2 Buttons (View Details & Delete Banner)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View / Edit Banner Details',
                splashRadius: 18,
                onPressed: () => _showDualModeBannerDetailsDialog(context, banner),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.primaryRedLight : AppColors.primaryRedDark,
                tooltip: 'Delete Banner',
                splashRadius: 18,
                onPressed: () => DialogHelper.showDeleteDialog(
                  title: 'Delete Banner',
                  itemName: 'Banner #${banner.id} (${banner.bnrType})',
                  message: 'Are you sure you want to delete this banner permanently?',
                  onConfirm: () => controller.deleteBanner(banner),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// In-Table Image Cell matching the Items View style:
  /// - If empty: renders Red outlined "Upload" button
  /// - If present: renders thumbnail with edit icon; click replaces image directly
  Widget _buildBannerImageCell(BuildContext context, AppBannerDatum banner) {
    final bool hasImage = banner.bnrImg.trim().isNotEmpty;
    final bool isDark = context.isDark;

    if (!hasImage) {
      return InkWell(
        onTap: () => controller.uploadBannerImageFromTable(banner),
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

    final String fullUrl = banner.bnrImg.startsWith('http') ? banner.bnrImg : '${ApiConstants.baseUrl}/${banner.bnrImg}';

    return InkWell(
      onTap: () => controller.uploadBannerImageFromTable(banner),
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Tooltip(
        message: 'Click to replace banner image',
        waitDuration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: fullUrl,
                  width: 50,
                  height: 26,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                    width: 14,
                    height: 14,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryRed)),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded, size: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.edit_outlined, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
            ],
          ),
        ),
      ),
    );
  }

  /// Approach B: Dual-Mode Inspector & Editor Dialog
  void _showDualModeBannerDetailsDialog(BuildContext context, AppBannerDatum banner) {
    controller.prefillForEdit(banner);
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 620.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 620, maxHeight: context.screenHeight * 0.90),
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Obx(() {
            final bool isEditing = controller.isDetailsEditing.value;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.view_carousel_rounded, size: 20, color: AppColors.primaryRed),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEditing ? 'Edit Banner #${banner.id}' : 'Banner Details #${banner.id}',
                            style: context.titleStyleActive.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (!isEditing)
                            OutlinedButton.icon(
                              onPressed: () => controller.enableDetailsEditMode(banner),
                              icon: const Icon(Icons.edit_outlined, size: 15),
                              label: const Text('Edit Banner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.statusBlueInfo,
                                side: const BorderSide(color: AppColors.statusBlueInfo),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              controller.cancelDetailsEditMode();
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 22, thickness: 1),
                  if (!isEditing) _buildInspectionView(context, isDark, banner) else _buildInlineFormEditor(context, isDark),
                ],
              ),
            );
          }),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildInspectionView(BuildContext context, bool isDark, AppBannerDatum banner) {
    final String fullUrl = banner.bnrImg.startsWith('http') ? banner.bnrImg : '${ApiConstants.baseUrl}/${banner.bnrImg}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          clipBehavior: Clip.antiAlias,
          child: banner.bnrImg.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: fullUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed)),
                  ),
                  errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey)),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported_outlined, size: 36, color: Colors.grey),
                      SizedBox(height: 6),
                      Text('No Banner Image Attached', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        _buildInfoGrid(context, isDark, banner),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context, bool isDark, AppBannerDatum banner) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailCard(isDark, 'BANNER ID', '#${banner.id}')),
            const SizedBox(width: 10),
            Expanded(child: _buildDetailCard(isDark, 'BANNER TYPE', banner.bnrType)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDetailCard(isDark, 'START DATE', banner.startAt?.isNotEmpty == true ? banner.startAt! : 'No Limit')),
            const SizedBox(width: 10),
            Expanded(child: _buildDetailCard(isDark, 'END DATE', banner.endAt?.isNotEmpty == true ? banner.endAt! : 'No Limit')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDetailCard(isDark, 'CREATED AT', banner.created.isNotEmpty ? banner.created : '—')),
            const SizedBox(width: 10),
            Expanded(child: _buildDetailCard(isDark, 'UPDATED AT', banner.updated.isNotEmpty ? banner.updated : '—')),
          ],
        ),
        const SizedBox(height: 10),
        _buildDetailCard(isDark, 'STATUS', banner.status == 1 ? 'Active' : 'Inactive'),
      ],
    );
  }

  Widget _buildDetailCard(bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInlineFormEditor(BuildContext context, bool isDark) {
    return Form(
      key: controller.bannerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBannerTypeInput(context, isDark),
          const SizedBox(height: 16),
          _buildImagePickerSlot(context, isDark),
          const SizedBox(height: 16),
          _buildDatesRow(context, isDark),
          const SizedBox(height: 16),
          _buildStatusToggle(context, isDark),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: controller.cancelDetailsEditMode, child: const Text('Cancel Edit')),
              const SizedBox(width: 12),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          final bool success = await controller.submitBanner();
                          if (success) {
                            controller.cancelDetailsEditMode();
                            Get.back();
                          }
                        },
                  icon: controller.isSubmitting.value
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Add New Banner Dialog
  void _openSaveBannerDialog(BuildContext context) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 540.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 540, maxHeight: context.screenHeight * 0.88),
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: controller.bannerFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Banner', style: context.titleStyleActive.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildBannerTypeInput(context, isDark),
                  const SizedBox(height: 16),
                  _buildImagePickerSlot(context, isDark),
                  const SizedBox(height: 16),
                  _buildDatesRow(context, isDark),
                  const SizedBox(height: 16),
                  _buildStatusToggle(context, isDark),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final bool success = await controller.submitBanner();
                                  if (success) Get.back();
                                },
                          icon: controller.isSubmitting.value
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: const Text('Save Banner', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildBannerTypeInput(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banner Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return controller.bannerTypeSuggestions;
            }
            return controller.bannerTypeSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          initialValue: TextEditingValue(text: controller.bnrTypeController.text),
          onSelected: (selection) => controller.bnrTypeController.text = selection,
          fieldViewBuilder: (ctx, textEditingController, focusNode, onFieldSubmitted) {
            textEditingController.addListener(() {
              controller.bnrTypeController.text = textEditingController.text;
            });
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: _inputDecoration(isDark, 'e.g. home_slider, category_banner'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Banner type is required' : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildImagePickerSlot(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banner Image *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        Obx(() {
          final bytes = controller.selectedImageBytes.value;
          final existing = controller.existingImageUrl.value;

          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            child: Stack(
              children: [
                if (bytes != null)
                  Center(
                    child: Image.memory(bytes, fit: BoxFit.contain, width: double.infinity, height: 120),
                  )
                else if (existing != null && existing.isNotEmpty)
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: existing.startsWith('http') ? existing : '${ApiConstants.baseUrl}/$existing',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 120,
                    ),
                  )
                else
                  Center(
                    child: InkWell(
                      onTap: controller.pickImageWeb,
                      borderRadius: BorderRadius.circular(8),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primaryRed),
                          SizedBox(height: 6),
                          Text('Click to select banner image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                if (bytes != null || (existing != null && existing.isNotEmpty))
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.refresh_rounded, size: 18), tooltip: 'Change Image', onPressed: controller.pickImageWeb),
                        if (bytes != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                            tooltip: 'Clear Selected Image',
                            onPressed: controller.clearSelectedImage,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDatesRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start Date (YYYY-MM-DD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.startAtController,
                readOnly: true,
                onTap: () => controller.pickDate(context: context, isStart: true),
                decoration: _inputDecoration(isDark, 'YYYY-MM-DD').copyWith(
                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    tooltip: 'Clear Start Date',
                    onPressed: () => controller.clearDateField(isStart: true),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('End Date (YYYY-MM-DD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.endAtController,
                readOnly: true,
                onTap: () => controller.pickDate(context: context, isStart: false),
                decoration: _inputDecoration(isDark, 'YYYY-MM-DD').copyWith(
                  prefixIcon: const Icon(Icons.event_available_rounded, size: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    tooltip: 'Clear End Date',
                    onPressed: () => controller.clearDateField(isStart: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle(BuildContext context, bool isDark) {
    return Obx(() {
      final bool isActive = controller.bannerStatus.value == 1;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          StatusBadge(
            isEditable: true,
            isActive: isActive,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (val) => controller.bannerStatus.value = val ? 1 : 0,
          ),
        ],
      );
    });
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
