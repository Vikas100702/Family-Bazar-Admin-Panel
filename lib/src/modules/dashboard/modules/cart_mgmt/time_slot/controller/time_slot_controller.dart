import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/model/time_slot_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/repository/time_slot_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TimeSlotController extends BaseServerTableController<TimeSlotItem> {
  final TimeSlotRepository _slotRepository;

  TimeSlotController({required TimeSlotRepository repository}) : _slotRepository = repository;

  // Master Cache for local fallback pagination & search
  final RxList<TimeSlotItem> _allSlotsCache = <TimeSlotItem>[].obs;

  // Form Management & Editing State
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
          _allSlotsCache.assignAll(response.data);

          if (response.pagination != null) {
            setServerData(data: response.data, totalCount: response.pagination!.total, pageCount: response.pagination!.totalPages);
          } else {
            _applyLocalSearchAndPagination();
          }
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch time slots.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', {'page': currentPage.value, 'limit': itemsPerPage.value, 'search': searchQuery.value});
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching time slots.');
        }
      }
    });
  }

  void _applyLocalSearchAndPagination() {
    List<TimeSlotItem> filtered = _allSlotsCache.toList();
    final String query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((slot) {
        final String idStr = slot.id.toString();
        final String start = slot.startTimeSlot.toLowerCase();
        final String end = slot.endTimeSlot.toLowerCase();
        return idStr.contains(query) || start.contains(query) || end.contains(query);
      }).toList();
    }

    final int total = filtered.length;
    final int limit = itemsPerPage.value;
    final int page = currentPage.value;
    final int startIndex = (page - 1) * limit;

    List<TimeSlotItem> pageSlice = <TimeSlotItem>[];
    if (startIndex < total) {
      final int endIndex = (startIndex + limit) > total ? total : (startIndex + limit);
      pageSlice = filtered.sublist(startIndex, endIndex);
    }

    setServerData(data: pageSlice, totalCount: total, pageCount: (total / limit).ceil() > 0 ? (total / limit).ceil() : 1);
  }

  @override
  void onSearchChanged(String query) {
    searchQuery.value = query.trim();
    currentPage.value = 1;
    fetchServerData();
  }

  @override
  void onSearchSubmitted(String query) {
    searchQuery.value = query.trim();
    currentPage.value = 1;
    fetchServerData();
  }

  @override
  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 1;
    fetchServerData();
  }

  @override
  void changePage(int newPage) {
    if (newPage < 1 || (totalPages.value > 0 && newPage > totalPages.value) || isLoading.value) {
      return;
    }
    currentPage.value = newPage;
    fetchServerData();
  }

  @override
  void changePageSize(int newSize) {
    if (newSize == itemsPerPage.value || isLoading.value) return;
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    fetchServerData();
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
    if (isSubmitting.value) return false;

    if (!addEditFormKey.currentState!.validate()) return false;

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
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

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
      _logException(e, stackTrace, 'submitSlot', {'editing_id': editingSlotId.value});
      if (!isClosed) {
        errorMessage(message: 'An error occurred while saving the time slot.');
      }
      return false;
    } finally {
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

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _slotRepository.deleteTimeSlot(slotId: slot.id.toString());

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Time slot deleted successfully.');
          await refreshTimeSlots();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete time slot.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteTimeSlot', {'slot_id': slot.id, 'start_time': slot.startTimeSlot, 'end_time': slot.endTimeSlot});
        errorMessage(message: 'An error occurred while deleting the time slot.');
      }
    });

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
    return '${hour.toString().padLeft(2, '0')}:$minute$period';
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'TimeSlotController');
        scope.setContexts('time_slot_action', {'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    startTimeDisplayController.dispose();
    endTimeDisplayController.dispose();
    _allSlotsCache.clear();
    super.onClose();
  }
}
