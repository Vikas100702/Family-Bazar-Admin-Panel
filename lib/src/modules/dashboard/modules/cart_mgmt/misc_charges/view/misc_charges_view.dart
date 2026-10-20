import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/controller/misc_charges_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/model/misc_charges_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MiscChargesView extends GetView<MiscChargesController> {
  const MiscChargesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search config ID, handling fee, threshold...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshMiscCharges,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Charges',
          extraActions: [
            ElevatedButton.icon(
              onPressed: () {
                controller.openCreateDialog();
                _showChargeFormDialog(context, isEdit: false);
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Misc Charge', style: TextStyle(fontWeight: FontWeight.w600)),
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
            () => PaginatedTableContainer<MiscChargeItem>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Misc Cart Charges...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Misc Charges Found',
              emptySubtitle: 'Click "Add Misc Charge" above to configure cart fee policies.',
              emptyIcon: Icons.receipt_long_rounded,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('CONFIG ID')),
                DataColumn(label: Text('HANDLING FEE')),
                DataColumn(label: Text('SMALL CART FEE')),
                DataColumn(label: Text('MIN CART THRESHOLD')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('CREATED AT')),
                DataColumn(label: Text('UPDATED AT')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, charge) => _buildDataRow(context, charge),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, MiscChargeItem charge) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: charge.id > 0 ? '#${charge.id}' : '—',
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        DataCell(Text(charge.handlingFee.toCurrency(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(
          Text(
            charge.smallCartCharge.toCurrency(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryRed),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentAzureBlue.withValues(alpha: 0.1), borderRadius: context.responsiveRadius(4, 6)),
            child: Text(
              'Under ${charge.smallCartMinAmount.toCurrency()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentAzureBlue),
            ),
          ),
        ),
        DataCell(
          StatusBadge(
            statusValue: charge.status,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            isEditable: true,
            onToggle: (bool val) => controller.toggleChargeStatus(charge, val),
          ),
        ),
        DataCell(Text(EntityDetailsDialogHelper.formatDate(charge.createdAt), style: const TextStyle(fontSize: 12))),
        DataCell(Text(EntityDetailsDialogHelper.formatDate(charge.updatedAt), style: const TextStyle(fontSize: 12))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View Charge Details',
                splashRadius: 18,
                onPressed: () => _showChargeDetails(context, charge),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.statusBlueInfo,
                tooltip: 'Edit Charge Parameters',
                splashRadius: 18,
                onPressed: () {
                  controller.openEditDialog(charge);
                  _showChargeFormDialog(context, isEdit: true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.primaryRedLight : AppColors.primaryRedDark,
                tooltip: 'Delete Charge Config',
                splashRadius: 18,
                onPressed: () => DialogHelper.showDeleteDialog(
                  title: 'Delete Charge Configuration',
                  itemName: '#${charge.id} (Handling: ₹${charge.handlingFee.toStringAsFixed(2)})',
                  message: 'Are you sure you want to delete miscellaneous charge config #${charge.id}?',
                  onConfirm: () => controller.deleteCharge(charge),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChargeDetails(BuildContext context, MiscChargeItem charge) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: 'Cart Charge Details',
      subtitle: 'Surcharge & Threshold Policy #${charge.id}',
      headerIcon: Icons.receipt_long_rounded,
      sections: [
        DetailSection(
          title: '1. Identification & Rates',
          items: [
            DetailItem(label: 'Config ID', value: charge.id.toString(), isCopyable: true),
            DetailItem(label: 'Handling Fee', value: '₹${charge.handlingFee.toStringAsFixed(2)}'),
            DetailItem(label: 'Small Cart Surcharge', value: '₹${charge.smallCartCharge.toStringAsFixed(2)}'),
            DetailItem(label: 'Min Cart Threshold', value: '₹${charge.smallCartMinAmount.toStringAsFixed(2)}'),
            DetailItem(label: 'Policy Status', value: charge.isActive ? 'Active (Operational)' : 'Inactive (Disabled)'),
          ],
        ),
        DetailSection(
          title: '2. Audit & Timestamps',
          items: [
            DetailItem(label: 'Created At', value: EntityDetailsDialogHelper.formatDate(charge.createdAt)),
            DetailItem(label: 'Updated At', value: EntityDetailsDialogHelper.formatDate(charge.updatedAt)),
          ],
        ),
      ],
    );
  }

  void _showChargeFormDialog(BuildContext context, {required bool isEdit}) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 520.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 520, maxHeight: context.screenHeight * 0.90),
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: context.responsiveRadius(12, 14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Obx(() {
            final bool isSubmitting = controller.isSubmitting.value;

            return PopScope(
              canPop: !isSubmitting,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Form(
                  key: controller.addEditFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isEdit ? 'Edit Misc Charges' : 'Add Misc Cart Charges', style: context.titleStyleActive.copyWith(fontSize: 18)),
                          IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: isSubmitting ? null : () => Get.back()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set handling fees, small cart charges, and minimum checkout thresholds.',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                      ),
                      const SizedBox(height: 20),
                      _buildNumberField(
                        context: context,
                        label: 'Handling Fee (₹) *',
                        controller: controller.handlingFeeController,
                        hint: 'e.g. 10.00',
                        enabled: !isSubmitting,
                      ),
                      SizedBox(height: context.responsiveHeight(14, 16)),
                      _buildNumberField(
                        context: context,
                        label: 'Small Cart Surcharge (₹) *',
                        controller: controller.smallCartChargeController,
                        hint: 'e.g. 20.00',
                        enabled: !isSubmitting,
                      ),
                      SizedBox(height: context.responsiveHeight(14, 16)),
                      _buildNumberField(
                        context: context,
                        label: 'Small Cart Threshold Amount (₹) *',
                        controller: controller.smallCartMinAmountController,
                        hint: 'Apply surcharge if cart total is below this',
                        enabled: !isSubmitting,
                      ),
                      if (isEdit) ...[
                        SizedBox(height: context.responsiveHeight(14, 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                            borderRadius: context.responsiveRadius(6, 8),
                            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Configuration Status',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                                    ),
                                  ),
                                  Text(
                                    controller.status.value == 1 ? 'Active (Applied during checkout)' : 'Inactive (Temporarily ignored)',
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                                  ),
                                ],
                              ),
                              StatusBadge(
                                isEditable: true,
                                isActive: controller.status.value == 1,
                                activeLabel: 'Active',
                                inactiveLabel: 'Inactive',
                                onToggle: (bool val) {
                                  controller.status.value = val ? 1 : 0;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: isSubmitting ? null : () => Get.back(), child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final bool success = await controller.submitCharges();
                                    if (success) Get.back();
                                  },
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  )
                                : const Icon(Icons.check_circle_rounded, size: 18),
                            label: Text(
                              isSubmitting ? 'Saving...' : (isEdit ? 'Update Charges' : 'Save Charges'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.onPrimaryWhite,
                              padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(18, 22), vertical: context.responsiveHeight(10, 12)),
                              shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.titleStyleRegular.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            final double? numVal = double.tryParse(value.trim());
            if (numVal == null || numVal < 0) {
              return 'Enter a valid positive number';
            }
            return null;
          },
          decoration: InputDecoration(hintText: hint, prefixText: '₹ ', isDense: true),
        ),
      ],
    );
  }
}
