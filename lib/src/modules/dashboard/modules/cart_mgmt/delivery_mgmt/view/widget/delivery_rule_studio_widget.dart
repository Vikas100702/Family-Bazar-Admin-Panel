import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/controller/delivery_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_rule_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    stepNumber: '1',
                    title: 'Rule Parameters & Serviceable Pincodes',
                    subtitle: 'Define rule priority and postal zones where this delivery logic applies.',
                    child: _buildRuleParametersForm(context, isDark),
                  ),
                  SizedBox(height: context.responsiveHeight(20, 24)),
                  Obx(() {
                    final int? currentRuleId = controller.studioRuleId.value;
                    final bool isSaved = currentRuleId != null && currentRuleId > 0;

                    return _buildSectionCard(
                      context: context,
                      isDark: isDark,
                      stepNumber: '2',
                      title: 'Delivery Slabs & Fee Matrix',
                      subtitle: 'Configure order amount thresholds, distance bands, and delivery fees.',
                      actionWidget: isSaved
                          ? TextButton.icon(
                              onPressed: () => controller.openInlineSlabForm(),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Slab'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryRed,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                      child: isSaved ? _buildOrderSlabsSection(context, isDark) : _buildLockedSlabsPlaceholder(context, isDark),
                    );
                  }),
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
                tooltip: 'Back to Rules List',
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
                      isEdit ? 'Delivery Rule Studio: #${id ?? ""}' : 'Create Delivery Rule Studio',
                      style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isEdit
                          ? 'Modify rule metadata, mapped pincodes, and amount/distance slabs'
                          : 'Configure rule settings, postal areas, and delivery charge slabs',
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
              ?actionWidget,
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
              final bool isWide = constraints.maxWidth > 650;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        context: context,
                        label: 'Rule Name *',
                        hint: 'e.g. Standard Delivery Rule',
                        controller: controller.ruleNameController,
                        isDark: isDark,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Rule Name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        context: context,
                        label: 'Priority *',
                        hint: 'e.g. 1',
                        controller: controller.priorityController,
                        isDark: isDark,
                        isNumber: true,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                    hint: 'e.g. Standard Delivery Rule',
                    controller: controller.ruleNameController,
                    isDark: isDark,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Rule Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          label: 'Priority *',
                          hint: 'e.g. 1',
                          controller: controller.priorityController,
                          isDark: isDark,
                          isNumber: true,
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusToggle(label: 'Status', isDark: isDark, statusRx: controller.status),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            context: context,
            label: 'Description (Optional)',
            hint: 'Notes or pricing guidelines for this rule',
            controller: controller.descriptionController,
            isDark: isDark,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildPincodeInlineSelector(context, isDark),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              final bool isSubmitting = controller.isSubmitting.value;
              final bool isEdit = controller.isStudioEditing.value;

              return ElevatedButton.icon(
                onPressed: isSubmitting ? null : () => controller.saveOrUpdateStudioRule(),
                icon: isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isEdit ? Icons.save_rounded : Icons.check_circle_outline_rounded, size: 16),
                label: Text(
                  isSubmitting ? 'Saving Rule...' : (isEdit ? 'Update Rule & Pincodes' : 'Save Rule to Enable Slabs'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              );
            }),
          ),
        ],
      ),
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
              const Text('Serviceable Pincodes *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${controller.selectedPincodeIds.length} of ${controller.pincodeDropdownList.length} Selected',
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
                  onChanged: controller.onPincodeSearch,
                  decoration: InputDecoration(
                    hintText: 'Filter postal code or firm name...',
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
              return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            final List<Datum> list = controller.filteredPincodeList;
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No matching postal codes found.', style: TextStyle(fontSize: 12))),
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
                  final Datum item = list[index];
                  return Obx(() {
                    final bool isSelected = controller.selectedPincodeIds.contains(item.id);
                    return CheckboxListTile(
                      dense: true,
                      value: isSelected,
                      activeColor: AppColors.primaryRed,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(item.pPinCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(item.pFirmName, style: const TextStyle(fontSize: 11)),
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
      final DeliveryRuleDetailsData? details = controller.activeRuleDetails.value;
      final List<RuleDistanceItem> slabs = details?.distanceRules ?? [];
      final bool isFormOpen = controller.isInlineSlabFormOpen.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFormOpen) ...[_buildInlineSlabEditor(context, isDark), const SizedBox(height: 16)],
          if (controller.isLoadingRuleDetails.value)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (slabs.isEmpty && !isFormOpen)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('No slabs configured yet for this rule.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Add your first slab to define delivery fee thresholds.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => controller.openInlineSlabForm(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Delivery Slab'),
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
                final RuleDistanceItem slab = slabs[index];
                final bool hasDistance = slab.minDistanceKm > 0 || slab.maxDistanceKm > 0;
                final bool hasAmount = slab.minOrderAmount > 0 || slab.maxOrderAmount > 0;

                final String distanceRange = hasDistance
                    ? '${slab.minDistanceKm.toStringAsFixed(0)} - ${slab.maxDistanceKm.toStringAsFixed(0)} KM'
                    : 'N/A';
                final String amountRange = hasAmount
                    ? '₹${slab.minOrderAmount.toStringAsFixed(0)} - ${slab.maxOrderAmount > 0 ? "₹${slab.maxOrderAmount.toStringAsFixed(0)}" : "Open"}'
                    : 'N/A';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accentAzureBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          'P${slab.priority}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentAzureBlue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (hasAmount) Text('Cart: $amountRange', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            if (hasDistance) Text('Distance: $distanceRange', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            Text(
                              'Base Fee: ₹${slab.baseCharge.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.primaryRed, fontWeight: FontWeight.bold),
                            ),
                            if (slab.perKmCharge > 0)
                              Text(
                                'Per KM: ₹${slab.perKmCharge.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.statusBlueInfo),
                              ),
                          ],
                        ),
                      ),
                      Obx(() {
                        final bool isToggling = controller.togglingSlabStatusMap[slab.id] == true;
                        if (isToggling) {
                          return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed));
                        }
                        return StatusBadge(
                          isEditable: true,
                          isActive: slab.status == 1,
                          statusValue: slab.status,
                          onToggle: (bool val) => controller.toggleSlabStatus(slab, val),
                        );
                      }),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        tooltip: 'Edit Slab',
                        onPressed: () => controller.openInlineSlabForm(slab: slab),
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
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.4), width: 1.2),
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
                    controller.editingSlabId.value != null ? 'Edit Slab Configuration' : 'Add New Slab Configuration',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryRed),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, size: 16), onPressed: controller.closeInlineSlabForm),
              ],
            ),
            const SizedBox(height: 12),
            // Slab Type Dropdown with ALL 3 OPTIONS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calculation Slab Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 6),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    initialValue: controller.selectedSlabType.value,
                    dropdownColor: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceWhite,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'amount',
                        child: Text('Amount Only (Order Value Range)', style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: 'distance',
                        child: Text('Distance Only (KM Range)', style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: 'both',
                        child: Text('Both (Distance & Order Value)', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.setSlabType(val);
                      }
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),
            // CONDITIONAL FIELDS BASED ON SELECTED TYPE
            Obx(() {
              final String type = controller.selectedSlabType.value.toLowerCase().trim();
              final bool showAmount = type == 'amount' || type == 'both';
              final bool showDistance = type == 'distance' || type == 'both';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. DISTANCE SECTION (If Distance or Both)
                  if (showDistance) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Min Distance (KM) *',
                            hint: 'e.g. 0',
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
                            hint: 'e.g. 5',
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
                            label: 'Per KM Fee (₹)',
                            hint: 'e.g. 5',
                            controller: controller.perKmChargeController,
                            isDark: isDark,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 2. AMOUNT SECTION (If Amount or Both)
                  if (showAmount) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            label: 'Min Cart (₹) *',
                            hint: 'e.g. 0',
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
                            label: 'Max Cart (₹)',
                            hint: 'e.g. 499 (Optional)',
                            controller: controller.maxOrderAmountController,
                            isDark: isDark,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 3. COMMON CHARGES & STATUS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          label: 'Base Fee (₹) *',
                          hint: 'e.g. 40',
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
                          label: 'Priority *',
                          hint: 'e.g. 1',
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
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmittingSlab.value ? null : () => controller.submitStudioDistanceSlab(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                    child: controller.isSubmittingSlab.value
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Slab'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedSlabsPlaceholder(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate.withValues(alpha: 0.4) : AppColors.surfaceWhite.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'Save Step 1 (Rule Details) to unlock and configure order amount slabs.',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
