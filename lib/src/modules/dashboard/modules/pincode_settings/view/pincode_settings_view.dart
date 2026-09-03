import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
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
    return Padding(
      padding: EdgeInsets.all(context.responsiveSize(16, 24)),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildHeader(context),
          SizedBox(height: context.responsiveSize(16, 24)),
          Expanded(
            child: Container(
              width: .infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Obx(() => _buildResponsiveTable(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;
        return isCompact
            ? Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Pincode Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(18, 22)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Refresh Pincodes', onPressed: () => controller.refreshPincodes()),
                      const Spacer(),
                      _buildAddButton(context),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pincode Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(20, 24)),
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Refresh Pincodes', onPressed: () => controller.refreshPincodes()),
                      const SizedBox(width: 8),
                      _buildAddButton(context),
                    ],
                  ),
                ],
              );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        controller.clearForm();
        _showPincodeDialog(context, isEdit: false);
      },
      icon: const Icon(Icons.add_location_alt_rounded, size: 18),
      label: const Text('Map New Pincode'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBrandOrange,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(14, 20), vertical: context.responsiveSize(12, 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildResponsiveTable(BuildContext context) {
    if (controller.pincodeList.isEmpty) {
      return Center(
        child: Text('No Pincode Configurations Available.', style: context.subTitleStyle.copyWith(fontSize: 16, color: AppColors.textHintLight)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: controller.horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: controller.horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Scrollbar(
                controller: controller.verticalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller.verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    ),
                    headingTextStyle: context.titleStyleActive.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    columnSpacing: context.responsiveSize(20, 32),
                    dataRowMaxHeight: 60.0,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Firm Code')),
                      DataColumn(label: Text('Firm Name')),
                      DataColumn(label: Text('Pincode')),
                      DataColumn(label: Text('Created By')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: controller.pincodeList.map((pincode) => _buildDataRow(context, pincode)).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(BuildContext context, Datum pincode) {
    final bool isActive = pincode.status == 1;

    return DataRow(
      cells: [
        DataCell(Text(pincode.id.toString())),
        DataCell(Text(pincode.pFirmCode.isNotEmpty ? pincode.pFirmCode : 'N/A')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(pincode.pFirmName.isNotEmpty ? pincode.pFirmName : 'N/A', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(Text(pincode.pPinCode.isNotEmpty ? pincode.pPinCode : 'N/A', style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(pincode.userName.isNotEmpty ? pincode.userName : 'N/A')),
        DataCell(
          Chip(
            label: Text(isActive ? 'Active' : 'Inactive', style: const TextStyle(fontSize: 11)),
            backgroundColor: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
            labelStyle: TextStyle(color: isActive ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.w600),
            side: BorderSide.none,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                tooltip: 'Edit Pincode',
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

  /// Pincode Form Dialog
  void _showPincodeDialog(BuildContext context, {required bool isEdit, int? id}) {
    final mediaQuery = MediaQuery.sizeOf(context);

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          width: context.isDesktop ? 460 : mediaQuery.width * 0.92,
          padding: EdgeInsets.all(context.responsiveSize(20, 24)),
          child: SingleChildScrollView(
            child: Obx(
              () => Form(
                key: controller.pincodeFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Pincode' : 'Add New Pincode',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(16, 18)),
                    ),
                    const SizedBox(height: 20),

                    // 1. FIRM NAME DROPDOWN
                    if (controller.isLoadingFirms.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      DropdownButtonFormField<firm_model.Datum>(
                        value: controller.selectedFirm.value,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Firm Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        hint: const Text('Select Firm'),
                        items: controller.firmDropdownList.map((firm_model.Datum firm) {
                          return DropdownMenuItem<firm_model.Datum>(
                            value: firm,
                            child: Text(firm.fFirmName, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (firm_model.Datum? newValue) => controller.onFirmSelected(newValue),
                        validator: (value) {
                          if (value == null && controller.firmNameController.text.trim().isEmpty) {
                            return 'Please select a Firm';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // 2. READ-ONLY FIRM CODE
                    TextFormField(
                      controller: controller.firmCodeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Firm Code',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).disabledColor.withValues(alpha: 0.08),
                        suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Firm Code is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. PINCODE FIELD
                    TextFormField(
                      controller: controller.pinCodeController,
                      decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: controller.onPincodeChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pincode is required';
                        }
                        if (value.trim().length < 6) {
                          return 'Enter a valid 6-digit pincode';
                        }
                        // Status -1 hone par field validator mein error show karega
                        if (controller.addPincodeStatus.value == -1) {
                          return controller.addPincodeErrorMessage.value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // DYNAMIC ACTION BUTTONS
                    if (controller.isSubmitting.value)
                      const Center(child: CircularProgressIndicator())
                    else if (controller.addPincodeStatus.value == -1) ...[
                      // Status -1 par: Cancel & Unmap buttons dikhenge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              controller.clearForm();
                              Get.back();
                            },
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrandOrange, foregroundColor: Colors.white),
                            onPressed: () {
                              _showUnmapConfirmationDialog(context);
                            },
                            child: const Text('Unmap & Reassign'),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Initial State: Check Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              controller.clearForm();
                              Get.back();
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrandOrange, foregroundColor: Colors.white),
                            onPressed: () => controller.submitPincode(isEdit: isEdit, id: id),
                            child: const Text('Check'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Confirmation Dialog for Unmap
  void _showUnmapConfirmationDialog(BuildContext context) {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Unmap & Reassign'),
        content: Text(
          'Are you sure you want to unmap Pincode ${controller.pinCodeController.text.trim()} and assign it to ${controller.firmNameController.text.trim()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Confirmation dialog band karega, main dialog open rahega
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrandOrange, foregroundColor: Colors.white),
            onPressed: () {
              Get.back(); // Confirmation dialog close
              Get.back(); // Main form dialog close
              controller.confirmAndUnmapPincode(); // Call unmap API
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
