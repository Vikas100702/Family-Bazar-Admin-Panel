import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_single_image_picker_field.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_single_image_table_cell.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
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
                padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(14, 16), vertical: context.responsiveHeight(12, 14)),
                shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<AppBannerDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Banners...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Banners Found',
              emptySubtitle: 'Click "Add Banner" to configure home sliders or promo banners.',
              emptyIcon: Icons.view_carousel_rounded,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('IMAGE')),
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
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, AppBannerDatum banner) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: '#${banner.id}',
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        DataCell(
          AppSingleImageTableCell(
            imageUrl: banner.bnrImg,
            tooltipMessage: 'Click to replace banner image',
            onTap: () => controller.uploadBannerImageFromTable(banner),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: context.responsiveRadius(4, 6),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            child: Text(banner.bnrType.withDashFallback, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        DataCell(AppTableCellText(text: banner.startDate.withDashFallback, style: const TextStyle(fontSize: 12))),
        DataCell(AppTableCellText(text: banner.endDate.withDashFallback, style: const TextStyle(fontSize: 12))),
        DataCell(
          StatusBadge(
            isEditable: true,
            isActive: banner.status == 1,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleBannerStatus(banner, val),
          ),
        ),
        DataCell(AppTableCellText(text: banner.created.withDashFallback, style: context.captionStyle)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View Banner Details',
                splashRadius: 18,
                onPressed: () => _showBannerDetails(context, banner),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo,
                tooltip: 'Edit Banner',
                splashRadius: 18,
                onPressed: () {
                  controller.prefillForEdit(banner);
                  _openSaveBannerDialog(context, isEditing: true);
                },
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

  void _showBannerDetails(BuildContext context, AppBannerDatum banner) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: 'Banner #${banner.id}',
      subtitle: 'Type: ${banner.bnrType.withDashFallback}',
      headerIcon: Icons.view_carousel_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          flags: [DetailFlag(label: 'Active Status', value: banner.status == 1)],
          items: [
            DetailItem(label: 'Banner ID', value: '#${banner.id}', isCopyable: true),
            DetailItem(label: 'Banner Type', value: banner.bnrType, isCopyable: true),
            DetailItem(label: 'Image URL', value: banner.bnrImg.isNotEmpty ? banner.bnrImg : 'None Attached', isCopyable: banner.bnrImg.isNotEmpty),
          ],
        ),
        DetailSection(
          title: 'Scheduling & Display Rules',
          items: [
            DetailItem(label: 'Start Date', value: banner.startDate!.withDashFallback),
            DetailItem(label: 'End Date', value: banner.endDate!.withDashFallback),
          ],
        ),
        DetailSection(
          title: 'Scheduling & Display Rules',
          items: [
            DetailItem(label: 'Start Date', value: banner.startDate.withDashFallback),
            DetailItem(label: 'End Date', value: banner.endDate.withDashFallback),
          ],
        ),
      ],
    );
  }

  void _openSaveBannerDialog(BuildContext context, {bool isEditing = false}) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 540.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 24), vertical: context.responsiveHeight(16, 24)),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 540, maxHeight: context.screenHeight * 0.90),
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: context.responsiveRadius(12, 14),
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
                      Text(
                        isEditing ? 'Edit Banner #${controller.editingBannerId.value}' : 'Add New Banner',
                        style: context.titleStyleActive.copyWith(fontSize: 17),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          controller.resetForm();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildBannerTypeInput(context),
                  const SizedBox(height: 16),
                  Obx(
                    () => AppSingleImagePickerField(
                      label: 'Banner Image',
                      isRequired: controller.editingBannerId.value == null,
                      selectedBytes: controller.selectedImageBytes.value,
                      existingImageUrl: controller.existingImageUrl.value,
                      onPickImage: controller.pickImageWeb,
                      onClearImage: controller.clearSelectedImage,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDatesRow(context),
                  const SizedBox(height: 16),
                  _buildStatusToggle(context, isDark),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.resetForm();
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
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
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: Text(isEditing ? 'Save Changes' : 'Save Banner', style: const TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(18, 22), vertical: context.responsiveHeight(10, 12)),
                            shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
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

  Widget _buildBannerTypeInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banner Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return controller.bannerTypeSuggestions;
            }
            return controller.bannerTypeSuggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          initialValue: TextEditingValue(text: controller.bnrTypeController.text),
          onSelected: (String selection) {
            controller.bnrTypeController.text = selection;
          },
          fieldViewBuilder: (ctx, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(hintText: 'e.g. home_slider, category_banner'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Banner type is required' : null,
              onChanged: (val) {
                controller.bnrTypeController.text = val;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatesRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start Date (YYYY-MM-DD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.startDateController,
                readOnly: true,
                onTap: () => controller.pickDate(context: context, isStart: true),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
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
                controller: controller.endDateController,
                readOnly: true,
                onTap: () => controller.pickDate(context: context, isStart: false),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
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
            onToggle: (bool val) => controller.bannerStatus.value = val ? 1 : 0,
          ),
        ],
      );
    });
  }
}
