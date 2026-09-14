import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart' as firm_model;
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/controller/pincode_settings_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PincodeSettingsView extends GetView<PincodeSettingsController> {
  const PincodeSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search pincode, firm, user...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshPincodes,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Pincodes',
          extraActions: [
            ElevatedButton.icon(
              onPressed: () {
                controller.clearForm();
                _showPincodeDialog(context, isEdit: false);
              },
              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
              label: const Text('Map New Pincode'),
              style: ElevatedButton.styleFrom(
                enabledMouseCursor: SystemMouseCursors.click,
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.onPrimaryWhite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                      Text('Loading Pincode Configurations...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<Datum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Pincode Configurations Available',
                      emptySubtitle: 'Map a new delivery pincode or refresh from server.',
                      emptyIcon: Icons.location_off_outlined,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('FIRM CODE')),
                        DataColumn(label: Text('FIRM NAME')),
                        DataColumn(label: Text('PINCODE')),
                        DataColumn(label: Text('CREATED BY')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, pincode) => _buildDataRow(context, pincode),
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

  DataRow _buildDataRow(BuildContext context, Datum pincode) {
    final isDark = context.isDark;
    final bool isActive = pincode.status == 1;

    return DataRow(
      cells: [
        DataCell(SelectableText(pincode.id.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(SelectableText(_formatText(pincode.pFirmCode), style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: _formatText(pincode.pFirmName),
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                _formatText(pincode.pFirmName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        DataCell(
          SelectableText(
            _formatText(pincode.pPinCode),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(Text(_formatText(pincode.userName))),
        DataCell(StatusBadge(statusValue: pincode.status, activeLabel: 'Active', inactiveLabel: 'Inactive')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View Mapping Details',
                splashRadius: 18,
                onPressed: () => _showPincodeDetails(context, pincode),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.statusBlueInfo,
                tooltip: 'Edit Pincode Mapping',
                splashRadius: 18,
                onPressed: () {
                  controller.preFillForm(pincode);
                  _showPincodeDialog(context, isEdit: true, id: pincode.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPincodeDetails(BuildContext context, Datum pincode) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: 'Pincode Mapping Details',
      subtitle: 'Pincode: ${pincode.pPinCode}',
      headerIcon: Icons.pin_drop_rounded,
      sections: [
        DetailSection(
          title: '1. Jurisdiction & Entity Mapping',
          items: [
            DetailItem(label: 'Pincode', value: pincode.pPinCode, isCopyable: true),
            DetailItem(label: 'Firm Code', value: pincode.pFirmCode, isCopyable: true),
            DetailItem(label: 'Firm Name', value: pincode.pFirmName),
          ],
        ),
        DetailSection(
          title: '2. Audit & Access Controls',
          flags: [DetailFlag(label: 'Route Active', value: pincode.status == 1)],
          items: [DetailItem(label: 'Assigned By', value: pincode.userName)],
        ),
      ],
    );
  }

  void _showPincodeDialog(BuildContext context, {required bool isEdit, int? id}) {
    final isDark = context.isDark;
    final mediaQuery = MediaQuery.sizeOf(context);
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
        ),
        backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        child: Container(
          width: context.isDesktop ? 480 : mediaQuery.width * 0.92,
          padding: EdgeInsets.all(context.responsiveSize(20, 24)),
          child: SingleChildScrollView(
            child: Obx(() {
              final firm_model.Datum? currentFirm = controller.selectedFirm.value;
              final firm_model.Datum? matchedFirm =
                  currentFirm != null && controller.firmDropdownList.any((f) => f.fFirmCode == currentFirm.fFirmCode)
                  ? controller.firmDropdownList.firstWhere((f) => f.fFirmCode == currentFirm.fFirmCode)
                  : null;

              return Form(
                key: controller.pincodeFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEdit ? 'Edit Pincode Mapping' : 'Map New Pincode', style: context.titleStyleActive.copyWith(fontSize: 17)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          mouseCursor: SystemMouseCursors.click,
                          splashRadius: 18,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
                          onPressed: () {
                            controller.clearForm();
                            Get.back();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Firm Assignment', style: context.titleStyleRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (controller.isLoadingFirms.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                        ),
                      )
                    else
                      DropdownButtonFormField<firm_model.Datum>(
                        value: matchedFirm,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                        decoration: const InputDecoration(
                          hintText: 'Select Firm to assign',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        items: controller.firmDropdownList.map((firm_model.Datum firm) {
                          return DropdownMenuItem<firm_model.Datum>(
                            value: firm,
                            child: Text(firm.fFirmName, overflow: TextOverflow.ellipsis, style: context.bodyTextStyle.copyWith(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (firm_model.Datum? newValue) => controller.onFirmSelected(newValue),
                        validator: (value) {
                          if (value == null && controller.firmNameController.text.trim().isEmpty) {
                            return 'Please select an enterprise firm';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    Text('Firm Code', style: context.titleStyleRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.firmCodeController,
                      readOnly: true,
                      style: context.bodyTextStyle.copyWith(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Auto-populated firm code',
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                        suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Firm Code is required' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Delivery Pincode', style: context.titleStyleRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.pinCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: context.bodyTextStyle.copyWith(fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Enter 6-digit postal zip code', counterText: ''),
                      onChanged: controller.onPincodeChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pincode is required';
                        }
                        if (value.trim().length < 6) {
                          return 'Enter a valid 6-digit pincode';
                        }
                        if (controller.addPincodeStatus.value == -1) {
                          return controller.addPincodeErrorMessage.value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (controller.isSubmitting.value)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                        ),
                      )
                    else if (controller.addPincodeStatus.value == -1) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.statusAmberWarning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.statusAmberWarning.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.statusAmberWarning, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.addPincodeErrorMessage.value,
                                    style: const TextStyle(color: AppColors.statusAmberWarning, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  enabledMouseCursor: SystemMouseCursors.click,
                                  backgroundColor: AppColors.primaryRed,
                                  foregroundColor: AppColors.onPrimaryWhite,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () => _showUnmapConfirmationDialog(context),
                                child: const Text('Unmap & Re-assign Pincode'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
                            onPressed: () {
                              controller.clearForm();
                              Get.back();
                            },
                            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate)),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
                            onPressed: () {
                              controller.clearForm();
                              Get.back();
                            },
                            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              enabledMouseCursor: SystemMouseCursors.click,
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.onPrimaryWhite,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () => controller.submitPincode(isEdit: isEdit, id: id),
                            child: Text(isEdit ? 'Update Mapping' : 'Check & Save'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showUnmapConfirmationDialog(BuildContext context) {
    final isDark = context.isDark;
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
        ),
        backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        title: Text('Confirm Unmap & Reassign', style: context.titleStyleActive.copyWith(fontSize: 16)),
        content: Text(
          'Are you sure you want to unmap Pincode ${controller.pinCodeController.text.trim()} and assign it to ${controller.firmNameController.text.trim()}?',
          style: context.bodyTextStyle.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
            onPressed: () => Get.back(),
            child: Text('No', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              enabledMouseCursor: SystemMouseCursors.click,
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.onPrimaryWhite,
            ),
            onPressed: () {
              Get.back();
              Get.back();
              controller.confirmAndUnmapPincode();
            },
            child: const Text('Yes, Re-assign'),
          ),
        ],
      ),
    );
  }

  String _formatText(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString().trim();
  }
}
