import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/controller/time_slot_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/model/time_slot_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeSlotView extends GetView<TimeSlotController> {
  const TimeSlotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search slot ID, operational window...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshTimeSlots,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Time Slots',
          extraActions: [
            ElevatedButton.icon(
              onPressed: () {
                controller.openCreateDialog();
                _showSlotFormDialog(context, isEdit: false);
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Time Slot', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      Text('Loading Time Slots...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<TimeSlotItem>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Time Slots Found',
                      emptySubtitle: 'Click "Add Time Slot" above to configure delivery fulfillment windows.',
                      emptyIcon: Icons.schedule_rounded,
                      columns: const [
                        DataColumn(label: Text('SLOT ID')),
                        DataColumn(label: Text('START TIME')),
                        DataColumn(label: Text('END TIME')),
                        DataColumn(label: Text('CREATED AT')),
                        DataColumn(label: Text('UPDATED AT')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, slot) => _buildDataRow(context, slot),
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

  // 1. DATA ROW BUILDER
  DataRow _buildDataRow(BuildContext context, TimeSlotItem slot) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText(slot.id > 0 ? '#${slot.id}' : '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline_rounded, size: 16, color: AppColors.statusGreenSuccess),
              const SizedBox(width: 6),
              Text(_formatDisplaySlot(slot.startTimeSlot), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.primaryRed),
              const SizedBox(width: 6),
              Text(_formatDisplaySlot(slot.endTimeSlot), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        DataCell(
          Text(
            slot.createdAt != null && slot.createdAt!.year >= 1970 ? slot.createdAt!.toLocal().toString().split('.').first : '—',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Text(
            slot.updatedAt != null && slot.updatedAt!.year >= 1970 ? slot.updatedAt!.toLocal().toString().split('.').first : '—',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.statusBlueInfo,
                tooltip: 'Edit Slot Window',
                splashRadius: 18,
                onPressed: () {
                  controller.openEditDialog(slot);
                  _showSlotFormDialog(context, isEdit: true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.primaryRedLight : AppColors.primaryRedDark,
                tooltip: 'Delete Slot',
                splashRadius: 18,
                onPressed: () => DialogHelper.showDeleteDialog(
                  title: 'Delete Time Slot',
                  itemName: '#${slot.id} (${_formatDisplaySlot(slot.startTimeSlot)} - ${_formatDisplaySlot(slot.endTimeSlot)})',
                  message: 'Are you sure you want to delete delivery slot #${slot.id}?',
                  onConfirm: () => controller.deleteTimeSlot(slot),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSlotFormDialog(BuildContext context, {required bool isEdit}) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 540.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 540, maxHeight: context.screenHeight * 0.90),
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
                          Text(isEdit ? 'Edit Delivery Time Slot' : 'Add Delivery Time Slot', style: context.titleStyleActive.copyWith(fontSize: 18)),
                          IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: isSubmitting ? null : () => Get.back()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set client operational order delivery fulfillment start and cut-off hours.',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                      ),
                      const SizedBox(height: 20),
                      _buildAdaptiveFieldsRow(
                        isMobile: isMobile,
                        first: _buildPickerField(
                          context: context,
                          label: 'Start Time *',
                          controller: controller.startTimeDisplayController,
                          hint: 'Choose start time',
                          enabled: !isSubmitting,
                          onTap: () => _pickTime(context, isStart: true),
                        ),
                        second: _buildPickerField(
                          context: context,
                          label: 'End Time *',
                          controller: controller.endTimeDisplayController,
                          hint: 'Choose end time',
                          enabled: !isSubmitting,
                          onTap: () => _pickTime(context, isStart: false),
                        ),
                      ),
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
                                    final bool success = await controller.submitSlot();
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
                              isSubmitting ? 'Saving...' : (isEdit ? 'Update Slot' : 'Save Slot'),
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

  Widget _buildPickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.titleStyleRegular.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: context.responsiveRadius(6, 8),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            enabled: false,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please pick a time';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              suffixIcon: Icon(Icons.access_time_rounded, size: 18, color: enabled ? AppColors.primaryRed : Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveFieldsRow({required bool isMobile, required Widget first, required Widget second}) {
    if (isMobile) {
      return Column(children: [first, const SizedBox(height: 14), second]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 14),
        Expanded(child: second),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final TimeOfDay initialTime = isStart
        ? (controller.selectedStartTime.value ?? const TimeOfDay(hour: 9, minute: 0))
        : (controller.selectedEndTime.value ?? const TimeOfDay(hour: 11, minute: 0));

    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime, initialEntryMode: TimePickerEntryMode.dial);

    if (picked != null) {
      if (isStart) {
        controller.setStartTime(picked);
      } else {
        controller.setEndTime(picked);
      }
    }
  }

  String _formatDisplaySlot(String timeStr) {
    if (timeStr.trim().isEmpty) return '—';
    final List<String> parts = timeStr.split(':');
    if (parts.length >= 2) {
      final int? hour = int.tryParse(parts[0]);
      final int? minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final String period = hour >= 12 ? 'PM' : 'AM';
        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    }
    return timeStr;
  }
}
