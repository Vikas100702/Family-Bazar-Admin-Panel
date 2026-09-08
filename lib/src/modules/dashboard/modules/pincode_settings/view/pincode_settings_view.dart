import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
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
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.responsiveSize(16, 24),
            context.responsiveSize(16, 24),
            context.responsiveSize(16, 24),
            context.responsiveSize(12, 16),
          ),
          child: _buildHeader(context),
        ),

        // Generic Responsive Data Table
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24)),
            child: Obx(
              () => DataTableWidget<Datum>(
                items: controller.pagedList.toList(),
                horizontalScrollController: controller.horizontalScrollController,
                verticalScrollController: controller.verticalScrollController,
                emptyTitle: 'No Pincode Configurations Available',
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
        ),

        // Pagination
        Padding(
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          child: Obx(
            () => CustomPaginationWidget(
              currentPage: controller.currentPage.value,
              totalPages: controller.totalPages.value,
              totalRecords: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              pageSizeOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onPageSizeChanged: controller.changePageSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pincode Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(20, 24)),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () => controller.refreshPincodes(),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_location_alt_rounded, size: 20),
              label: const Text('Map Pincode', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () {
                controller.clearForm();
                _showPincodeDialog(context, isEdit: false);
              },
            ),
          ],
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, Datum pincode) {
    return DataRow(
      cells: [
        DataCell(Text(pincode.id.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(_formatText(pincode.pFirmCode))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(pincode.pFirmName),
              child: Text(_formatText(pincode.pFirmName), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        DataCell(Text(_formatText(pincode.pPinCode), style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(_formatText(pincode.userName))),
        DataCell(_buildStatusBadge(pincode.status == 1)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
            tooltip: 'Edit Pincode Mapping',
            splashRadius: 24,
            mouseCursor: SystemMouseCursors.click,
            onPressed: () {
              controller.preFillForm(pincode);
              _showPincodeDialog(context, isEdit: true, id: pincode.id);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final Color color = isActive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

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
                      isEdit ? 'Edit Pincode Mapping' : 'Add New Pincode Mapping',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(16, 18)),
                    ),
                    const SizedBox(height: 20),

                    // Firm Name Selection Dropdown
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

                    // Read-only Firm Code
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

                    // Pincode Input
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
                        if (controller.addPincodeStatus.value == -1) {
                          return controller.addPincodeErrorMessage.value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Controls
                    if (controller.isSubmitting.value)
                      const Center(child: CircularProgressIndicator())
                    else if (controller.addPincodeStatus.value == -1) ...[
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
                            onPressed: () => _showUnmapConfirmationDialog(context),
                            child: const Text('Unmap & Reassign'),
                          ),
                        ],
                      ),
                    ] else ...[
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
                            child: const Text('Check & Save'),
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
            onPressed: () => Get.back(),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrandOrange, foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              Get.back();
              controller.confirmAndUnmapPincode();
            },
            child: const Text('Yes'),
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
