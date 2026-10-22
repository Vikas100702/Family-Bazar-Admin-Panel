import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
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
          onSearchClear: () => controller.clearSearch(),
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
    final bool isDark = context.isDark;
    final String fullImgUrl = banner.bnrImg.isNotEmpty
        ? (banner.bnrImg.startsWith('http') ? banner.bnrImg : '${ApiConstants.baseUrl}${banner.bnrImg.startsWith('/') ? '' : '/'}${banner.bnrImg}')
        : '';

    EntityDetailsDialogHelper.show(
      context: context,
      title: 'Banner #${banner.id}',
      subtitle: 'Type: ${banner.bnrType.withDashFallback}',
      headerIcon: Icons.view_carousel_rounded,
      sections: [
        DetailSection(
          title: 'Banner Preview',
          customContent: Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            clipBehavior: Clip.antiAlias,
            child: fullImgUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: fullImgUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                    ),
                    errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey)),
                  )
                : const Center(
                    child: Text('No Banner Image Attached', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
          ),
          flags: [DetailFlag(label: 'Active Status', value: banner.status == 1)],
          items: [
            DetailItem(label: 'Banner ID', value: '#${banner.id}', isCopyable: true),
            DetailItem(label: 'Banner Type', value: banner.bnrType, isCopyable: true),
          ],
        ),
        DetailSection(
          title: 'Scheduling & Display Rules',
          items: [
            DetailItem(label: 'Start Date', value: banner.startDate.withDashFallback),
            DetailItem(label: 'End Date', value: banner.endDate.withDashFallback),
          ],
        ),
        DetailSection(
          title: 'Audit & System Info',
          items: [
            DetailItem(label: 'Created At', value: banner.created.withDashFallback),
            DetailItem(label: 'Updated At', value: banner.updated.withDashFallback),
          ],
        ),
      ],
    );
  }

  void _openSaveBannerDialog(BuildContext context, {bool isEditing = false}) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 720.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 24), vertical: context.responsiveHeight(16, 24)),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 720, maxHeight: context.screenHeight * 0.90),
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

                  // 1. Banner Type (Existing Input Intact)
                  _buildBannerTypeInput(context),
                  const SizedBox(height: 16),

                  // 2. Applicable Target (Single Row: All Button + Dropdown 1 + Searchable Dropdown 2)
                  _buildTargetRow(context, isDark),
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

  // =========================================================================
  // TARGET ROW (OPTIONAL + SINGLE SELECT + TOGGLE/CLEAR SUPPORT)
  // =========================================================================
  Widget _buildTargetRow(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Applicable Target', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(width: 6),
                Text('(Optional)', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)),
              ],
            ),
            Obx(() {
              final bool hasSelection =
                  controller.isAllSelected.value || controller.selectedTargetType.value != null || controller.selectedTargetItemCode.value != null;

              if (!hasSelection) return const SizedBox.shrink();

              return InkWell(
                onTap: controller.clearAllTargetSelections,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear_rounded, size: 14, color: AppColors.statusRedError),
                      SizedBox(width: 4),
                      Text(
                        'Clear Selection',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.statusRedError),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. ALL BUTTON (Toggleable)
            Obx(() {
              final bool isAll = controller.isAllSelected.value;
              return InkWell(
                onTap: controller.toggleAllTarget,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isAll ? AppColors.primaryRed : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isAll ? AppColors.primaryRed : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAll ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: isAll ? Colors.white : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isAll ? Colors.white : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(width: 10),

            // 2. DROPDOWN TYPE (Category, Subcategory, Brands, Group)
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 40,
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: controller.selectedTargetType.value,
                    hint: const Text('Select Type', style: TextStyle(fontSize: 12)),
                    isDense: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    items: controller.targetTypeOptions.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 12.5)),
                      );
                    }).toList(),
                    onChanged: (val) => controller.onTargetTypeChanged(val),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),

            // 3. SEARCHABLE ITEMS DROPDOWN
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 40,
                child: Obx(() {
                  if (controller.isAllSelected.value) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.canvasDarkSlate.withValues(alpha: 0.5) : AppColors.surfaceSubtleGray,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                      ),
                      child: const Text('All Selected', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    );
                  }

                  if (controller.selectedTargetType.value == null) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.canvasDarkSlate.withValues(alpha: 0.5) : AppColors.surfaceSubtleGray,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                      ),
                      child: const Text('Select Type First', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    );
                  }

                  if (controller.isLoadingItems.value) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                      ),
                      child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                    );
                  }

                  return Autocomplete<Map<String, String>>(
                    displayStringForOption: (item) => '${item['name']} (${item['code']})',
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return controller.currentTargetItems;
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return controller.currentTargetItems.where(
                        (item) => (item['name'] ?? '').toLowerCase().contains(query) || (item['code'] ?? '').toLowerCase().contains(query),
                      );
                    },
                    onSelected: (Map<String, String> selection) {
                      controller.onTargetItemSelected(selection['code'] ?? '', selection['name'] ?? '');
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      if (textController.text.isEmpty && controller.selectedTargetItemName.value != null) {
                        textController.text = '${controller.selectedTargetItemName.value} (${controller.selectedTargetItemCode.value})';
                      }
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          hintText: 'Search ${controller.selectedTargetType.value}...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 16),
                          suffixIcon: controller.selectedTargetItemCode.value != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 14),
                                  onPressed: () {
                                    textController.clear();
                                    controller.selectedTargetItemCode.value = null;
                                    controller.selectedTargetItemName.value = null;
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
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
                onTap: () => _pickDate(context, isStart: true),
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
                onTap: () => _pickDate(context, isStart: false),
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

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(2020), lastDate: DateTime(2040));
    if (picked == null || !context.mounted) return;
    controller.setDate(formattedDate: picked.toApiDateString(), isStart: isStart);
  }
}
