import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/controller/delivery_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_management_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DeliveryRuleStudioView extends GetView<DeliveryController> {
  const DeliveryRuleStudioView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: context.responsiveRadius(12, 16),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStudioHeader(context, isDark),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsiveSize(20, 28)),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    stepNumber: '1',
                    title: 'Rule Metadata & Serviceable Coverage',
                    subtitle: 'Configure rule calculation type, and postal delivery zones.',
                    child: _buildRuleParametersForm(context, isDark),
                  ),
                  SizedBox(height: context.responsiveHeight(20, 24)),
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    stepNumber: '2',
                    title: 'Delivery Slabs & Fee Matrix',
                    subtitle: 'Define distance and cart subtotal charge tiers for this rule.',
                    actionWidget: TextButton.icon(
                      onPressed: () => controller.openInlineSlabForm(),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Slab Tier'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    child: _buildOrderSlabsSection(context, isDark),
                  ),
                  SizedBox(height: context.responsiveHeight(24, 30)),
                  _buildBottomSubmissionBar(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(20, 28), vertical: context.responsiveHeight(14, 18)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.closeRuleStudio,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                tooltip: 'Back to Delivery Rules',
                splashRadius: 20,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune_rounded, color: AppColors.primaryRed, size: 20),
              ),
              const SizedBox(width: 12),
              Obx(() {
                final bool isEdit = controller.isStudioEditing.value;
                final int? id = controller.studioRuleId.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Delivery Rule Studio #${id ?? ""}' : 'Create Delivery Rule Studio',
                      style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isEdit
                          ? 'Update zones and pricing slabs for active fulfillment'
                          : 'Configure rule parameters, postal areas, and fee matrix in one transaction',
                      style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                    ),
                  ],
                );
              }),
            ],
          ),
          OutlinedButton.icon(
            onPressed: controller.closeRuleStudio,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Exit Studio'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required bool isDark,
    required String stepNumber,
    required String title,
    required String subtitle,
    required Widget child,
    Widget? actionWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
        borderRadius: context.responsiveRadius(10, 12),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      padding: EdgeInsets.all(context.responsiveSize(16, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryRed,
                      child: Text(
                        stepNumber,
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: context.responsiveSize(14, 15),
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                            ),
                          ),
                          Text(subtitle, style: context.captionStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRuleParametersForm(BuildContext context, bool isDark) {
    return Form(
      key: controller.deliveryRuleFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        context: context,
                        label: 'Rule Name *',
                        hint: 'e.g. Festive Delivery Rule',
                        controller: controller.ruleNameController,
                        isDark: isDark,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Rule Name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: _buildRuleTypeDropdown(context, isDark)),
                    const SizedBox(width: 14),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 1,
                      child: _buildStatusToggle(label: 'Status', isDark: isDark, statusRx: controller.status),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildTextField(
                    context: context,
                    label: 'Rule Name *',
                    hint: 'e.g. Festive Delivery Rule',
                    controller: controller.ruleNameController,
                    isDark: isDark,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Rule Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: _buildRuleTypeDropdown(context, isDark))]),
                  const SizedBox(height: 12),
                  _buildStatusToggle(label: 'Status', isDark: isDark, statusRx: controller.status),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            context: context,
            label: 'Description (Optional)',
            hint: 'Internal fulfillment comments and guidelines',
            controller: controller.descriptionController,
            isDark: isDark,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildPincodeInlineSelector(context, isDark),
        ],
      ),
    );
  }

  Widget _buildRuleTypeDropdown(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rule Calculation Basis *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Obx(() {
              if (controller.isStudioEditing.value) {
                return const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Tooltip(
                    message: 'Calculation type cannot be modified after creation.',
                    child: Icon(Icons.lock_rounded, size: 13, color: Colors.grey),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() {
          final bool isEdit = controller.isStudioEditing.value;
          final String currentVal = controller.selectedRuleType.value;

          return DropdownButtonFormField<String>(
            isExpanded: true,
            value: currentVal,
            dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isEdit
                  ? (isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)
                  : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isEdit
                  ? (isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray.withValues(alpha: 0.6))
                  : (isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isEdit
                      ? (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate)
                      : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              helperText: isEdit ? 'Locked during edit mode' : null,
              helperStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            items: const [
              DropdownMenuItem(
                value: 'amount',
                child: Text('Order Value Only (Amount)', overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
              DropdownMenuItem(
                value: 'distance',
                child: Text('Distance Only (KM)', overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
              DropdownMenuItem(
                value: 'distance_amount',
                child: Text('Combined (Distance + Amount)', overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ],
            // Passing null to onChanged automatically disables the dropdown
            onChanged: isEdit
                ? null
                : (val) {
                    if (val != null) {
                      controller.setRuleType(val);
                    }
                  },
          );
        }),
      ],
    );
  }

  Widget _buildStatusToggle({required String label, required bool isDark, required RxInt statusRx}) {
    return Obx(() {
      final bool isActive = statusRx.value == 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive ? AppColors.statusGreenSuccess : AppColors.borderSubtleSlate),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [StatusBadge(isEditable: true, isActive: isActive, onToggle: (val) => statusRx.value = val ? 1 : 0)],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPincodeInlineSelector(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Serviceable Postal Areas *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${controller.selectedPincodeIds.length} of ${controller.allPincodes.length} Selected',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.pincodeSearchController,
                  onChanged: controller.onPincodeSearch,
                  decoration: InputDecoration(
                    hintText: 'Search pincode or operating firm...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 16),
                    filled: true,
                    fillColor: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: controller.isAllPincodesSelected.value,
                      activeColor: AppColors.primaryRed,
                      onChanged: (val) => controller.toggleSelectAll(val),
                    ),
                    const Text('Select All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingPincodes.value) {
              return const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed)),
              );
            }

            final List<DeliveryRulePincodeItem> list = controller.filteredPincodes;
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No postal codes found.', style: TextStyle(fontSize: 12))),
              );
            }

            return Container(
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.5),
                itemBuilder: (context, index) {
                  final DeliveryRulePincodeItem item = list[index];
                  return Obx(() {
                    final bool isSelected = controller.selectedPincodeIds.contains(item.id);
                    return CheckboxListTile(
                      dense: true,
                      value: isSelected,
                      activeColor: AppColors.primaryRed,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(item.pincode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(item.firmName.isNotEmpty ? item.firmName : 'General Zone', style: const TextStyle(fontSize: 11)),
                      onChanged: (_) => controller.togglePincodeSelection(item.id),
                    );
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderSlabsSection(BuildContext context, bool isDark) {
    return Obx(() {
      final List<DeliveryRuleSlabItem> slabs = controller.studioSlabs;
      final bool isFormOpen = controller.isInlineSlabFormOpen.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFormOpen) ...[_buildInlineSlabEditor(context, isDark), const SizedBox(height: 16)],
          if (slabs.isEmpty && !isFormOpen)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('No delivery fee slabs added yet', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Add at least one threshold tier to save this rule.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => controller.openInlineSlabForm(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Fee Slab Tier'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slabs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final DeliveryRuleSlabItem slab = slabs[index];
                final String type = controller.selectedRuleType.value.toLowerCase().trim();
                final bool showDistance = type == 'distance' || type == 'distance_amount';
                final bool showAmount = type == 'amount' || type == 'distance_amount';

                final String distStr = '${slab.minDistanceKm.toStringAsFixed(0)} - ${slab.maxDistanceKm.toStringAsFixed(0)} KM';
                final String cartStr =
                    '₹ ${slab.minOrderAmount.toStringAsFixed(0)} - ${slab.maxOrderAmount != null && slab.maxOrderAmount! > 0 ? "₹ ${slab.maxOrderAmount!.toStringAsFixed(0)}" : "Open"}';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accentAzureBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          'P${slab.priority}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentAzureBlue),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (showAmount) Text('Order Subtotal: $cartStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            if (showDistance) Text('Distance: $distStr', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            Text(
                              'Base Charge: ₹ ${slab.baseCharge.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.primaryRed, fontWeight: FontWeight.bold),
                            ),
                            if (showDistance && slab.perKmCharge > 0)
                              Text(
                                'Per KM: ₹ ${slab.perKmCharge.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.statusBlueInfo),
                              ),
                          ],
                        ),
                      ),
                      StatusBadge(isEditable: false, isActive: slab.status == 1, activeLabel: 'Active', inactiveLabel: 'Inactive'),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        tooltip: 'Edit Slab',
                        onPressed: () => controller.openInlineSlabForm(slab: slab, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        color: AppColors.primaryRed,
                        tooltip: 'Remove Slab',
                        onPressed: () => controller.removeSlab(index),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    });
  }

  Widget _buildInlineSlabEditor(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.5), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.distanceSlabFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    controller.editingSlabIndex.value != null ? 'Edit Slab Tier' : 'Add New Slab Tier',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryRed),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, size: 16), onPressed: controller.closeInlineSlabForm),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final String type = controller.selectedRuleType.value.toLowerCase().trim();
              final bool showDistance = type == 'distance' || type == 'distance_amount';
              final bool showAmount = type == 'amount' || type == 'distance_amount';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. CONDITIONAL DISTANCE SLOTS
                  if (showDistance) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Min Distance (KM) *',
                            hint: '0',
                            controller: controller.minDistanceKmController,
                            isDark: isDark,
                            isNumber: true,
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Max Distance (KM) *',
                            hint: '5',
                            controller: controller.maxDistanceKmController,
                            isDark: isDark,
                            isNumber: true,
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Per KM Surcharge (₹)',
                            hint: '0',
                            controller: controller.perKmChargeController,
                            isDark: isDark,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  // 2. CONDITIONAL AMOUNT SLOTS
                  if (showAmount) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Min Order Subtotal (₹) *',
                            hint: '0',
                            controller: controller.minOrderAmountController,
                            isDark: isDark,
                            isNumber: true,
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Max Order Subtotal (₹)',
                            hint: '499 (Leave blank for open-ended)',
                            controller: controller.maxOrderAmountController,
                            isDark: isDark,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  // 3. BASE CHARGE, PRIORITY & SLAB STATUS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          label: 'Base Delivery Fee (₹) *',
                          hint: '40',
                          controller: controller.baseChargeController,
                          isDark: isDark,
                          isNumber: true,
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          label: 'Slab Priority *',
                          hint: '1',
                          controller: controller.slabPriorityController,
                          isDark: isDark,
                          isNumber: true,
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatusToggle(label: 'Slab Status', isDark: isDark, statusRx: controller.slabStatus),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: controller.closeInlineSlabForm, child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.saveInlineSlab,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                  child: const Text('Keep Slab'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSubmissionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(onPressed: controller.closeRuleStudio, child: const Text('Discard Changes')),
          Obx(() {
            final bool isSubmitting = controller.isSubmitting.value;
            final bool isEdit = controller.isStudioEditing.value;

            return ElevatedButton.icon(
              onPressed: isSubmitting ? null : controller.submitEntireStudioRule,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                isSubmitting ? 'Saving Configuration...' : (isEdit ? 'Update Entire Delivery Rule' : 'Save & Publish Delivery Rule'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
