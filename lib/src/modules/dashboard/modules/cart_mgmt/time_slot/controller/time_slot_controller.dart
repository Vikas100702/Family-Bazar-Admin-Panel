import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/model/time_slot_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/repository/time_slot_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TimeSlotController extends BaseServerTableController<TimeSlotItem> {
  final TimeSlotRepository _slotRepository;
  TimeSlotController({required this._slotRepository});

  bool _isActionLocked = false;

  // FORM MANAGEMENT & EDITING STATE
  final GlobalKey<FormState> addEditFormKey = GlobalKey<FormState>();
  final Rxn<int> editingSlotId = Rxn<int>();
  final Rxn<TimeSlotItem> activeViewingSlot = Rxn<TimeSlotItem>();

  final Rxn<TimeOfDay> selectedStartTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> selectedEndTime = Rxn<TimeOfDay>();

  late final TextEditingController startTimeDisplayController;
  late final TextEditingController endTimeDisplayController;

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimeDisplayController = TextEditingController();
    endTimeDisplayController = TextEditingController();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final TimeSlotResponseModel response = await _slotRepository.getTimeSlots(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );

        if (isClosed) return;

        if (response.status) {
          final int total = response.pagination?.total ?? response.data.length;
          final int? totalPages = response.pagination?.totalPages;
          setServerData(data: response.data, totalCount: total, pageCount: totalPages);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch time slots.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching time slots.');
        }
      }
    });
  }

  Future<void> refreshTimeSlots() async => refreshData();

  void openCreateDialog() {
    editingSlotId.value = null;
    activeViewingSlot.value = null;
    selectedStartTime.value = null;
    selectedEndTime.value = null;
    startTimeDisplayController.clear();
    endTimeDisplayController.clear();
  }

  void openEditDialog(TimeSlotItem item) {
    editingSlotId.value = item.id;
    activeViewingSlot.value = item;

    final TimeOfDay? start = _parseTimeString(item.startTimeSlot);
    final TimeOfDay? end = _parseTimeString(item.endTimeSlot);

    selectedStartTime.value = start;
    selectedEndTime.value = end;

    startTimeDisplayController.text = start != null ? _formatTimeOfDayForDisplay(start) : item.startTimeSlot;
    endTimeDisplayController.text = end != null ? _formatTimeOfDayForDisplay(end) : item.endTimeSlot;
  }

  void setStartTime(TimeOfDay time) {
    selectedStartTime.value = time;
    startTimeDisplayController.text = _formatTimeOfDayForDisplay(time);
  }

  void setEndTime(TimeOfDay time) {
    selectedEndTime.value = time;
    endTimeDisplayController.text = _formatTimeOfDayForDisplay(time);
  }

  Future<bool> submitSlot() async {
    if (isSubmitting.value || _isActionLocked) return false;

    if (addEditFormKey.currentState == null || !addEditFormKey.currentState!.validate()) {
      return false;
    }

    final TimeOfDay? start = selectedStartTime.value;
    final TimeOfDay? end = selectedEndTime.value;

    if (start == null || end == null) {
      errorMessage(message: 'Both start time and end time must be selected.');
      return false;
    }

    final int startMinutes = start.hour * 60 + start.minute;
    final int endMinutes = end.hour * 60 + end.minute;

    if (endMinutes <= startMinutes) {
      errorMessage(message: 'End time must be later than start time.');
      return false;
    }

    _isActionLocked = true;
    isSubmitting.value = true;

    try {
      final String startSlotApi = _formatTimeOfDayForApi(start);
      final String endSlotApi = _formatTimeOfDayForApi(end);

      final TimeSlotResponseModel response = await _slotRepository.addOrUpdateSlot(
        id: editingSlotId.value,
        startTimeSlot: startSlotApi,
        endTimeSlot: endSlotApi,
      );

      if (isClosed) return false;

      if (response.status) {
        final String actionVerb = editingSlotId.value != null ? 'updated' : 'added';
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Time slot $actionVerb successfully.');
        openCreateDialog();
        await fetchServerData();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to configure time slot.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitSlot', <String, dynamic>{'editing_id': editingSlotId.value});
      if (!isClosed) {
        errorMessage(message: 'An error occurred while saving the time slot.');
      }
      return false;
    } finally {
      _isActionLocked = false;
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }

  Future<bool> deleteTimeSlot(TimeSlotItem slot) async {
    if (slot.id <= 0) {
      errorMessage(message: 'Invalid time slot ID.');
      return false;
    }

    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _slotRepository.deleteTimeSlot(slotId: slot.id);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Time slot deleted successfully.');
          await refreshTimeSlots();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete time slot.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteTimeSlot', <String, dynamic>{
          'slot_id': slot.id,
          'start_time': slot.startTimeSlot,
          'end_time': slot.endTimeSlot,
        });
        errorMessage(message: 'An error occurred while deleting the time slot.');
      }
    });

    _isActionLocked = false;
    return isSuccess;
  }

  TimeOfDay? _parseTimeString(String rawTime) {
    if (rawTime.trim().isEmpty) return null;
    final List<String> parts = rawTime.split(':');
    if (parts.length >= 2) {
      final int? hour = int.tryParse(parts[0]);
      final int? minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  String _formatTimeOfDayForApi(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _formatTimeOfDayForDisplay(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('controller', 'TimeSlotController');
        scope.setTag('module', 'time_slot');
        scope.setContexts('time_slot_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    startTimeDisplayController.dispose();
    endTimeDisplayController.dispose();
    super.onClose();
  }
}
