import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/model/misc_charges_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/repository/misc_charges_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MiscChargesController extends BaseServerTableController<MiscChargeItem> {
  final MiscChargesRepository _miscChargesRepository;
  MiscChargesController({required this._miscChargesRepository});

  final RxList<MiscChargeItem> _allChargesCache = <MiscChargeItem>[].obs;

  // Form Management & Editing State
  final GlobalKey<FormState> addEditFormKey = GlobalKey<FormState>();
  final Rxn<int> editingChargeId = Rxn<int>();
  final Rxn<MiscChargeItem> activeViewingCharge = Rxn<MiscChargeItem>();

  late final TextEditingController handlingFeeController;
  late final TextEditingController smallCartChargeController;
  late final TextEditingController smallCartMinAmountController;

  final RxInt status = 1.obs; // 1 = Active, 0 = Inactive
  final RxBool isSubmitting = false.obs;
  final RxMap<int, bool> togglingStatusMap = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    handlingFeeController = TextEditingController();
    smallCartChargeController = TextEditingController();
    smallCartMinAmountController = TextEditingController();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final MiscChargesResponseModel response = await _miscChargesRepository.getAllMiscCharges(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );

        if (isClosed) return;

        if (response.status || response.success) {
          _allChargesCache.assignAll(response.data);

          if (response.pagination != null) {
            setServerData(data: response.data, totalCount: response.pagination!.total, pageCount: response.pagination!.totalPages);
          } else {
            _applyLocalSearchAndPagination();
          }
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch misc charges.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', {'page': currentPage.value, 'limit': itemsPerPage.value, 'search': searchQuery.value});
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching charges.');
        }
      }
    });
  }

  void _applyLocalSearchAndPagination() {
    List<MiscChargeItem> filtered = _allChargesCache.toList();
    final String query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        final String idStr = item.id.toString();
        final String feeStr = item.handlingFee.toString();
        final String chargeStr = item.smallCartCharge.toString();
        final String minAmountStr = item.smallCartMinAmount.toString();
        return idStr.contains(query) || feeStr.contains(query) || chargeStr.contains(query) || minAmountStr.contains(query);
      }).toList();
    }

    final int total = filtered.length;
    final int limit = itemsPerPage.value;
    final int page = currentPage.value;
    final int startIndex = (page - 1) * limit;

    List<MiscChargeItem> pageSlice = <MiscChargeItem>[];
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

  Future<void> refreshMiscCharges() async => refreshData();

  void openCreateDialog() {
    editingChargeId.value = null;
    activeViewingCharge.value = null;
    handlingFeeController.clear();
    smallCartChargeController.clear();
    smallCartMinAmountController.clear();
    status.value = 1;
  }

  void openEditDialog(MiscChargeItem item) {
    editingChargeId.value = item.id;
    activeViewingCharge.value = item;
    handlingFeeController.text = item.handlingFee.toStringAsFixed(2);
    smallCartChargeController.text = item.smallCartCharge.toStringAsFixed(2);
    smallCartMinAmountController.text = item.smallCartMinAmount.toStringAsFixed(2);
    status.value = item.status;
  }

  Future<void> toggleChargeStatus(MiscChargeItem item, bool newStatus) async {
    if (togglingStatusMap[item.id] == true) return;
    togglingStatusMap[item.id] = true;

    try {
      final int updatedStatusInt = newStatus ? 1 : 0;
      final MiscChargesResponseModel response = await _miscChargesRepository.updateMiscCharges(
        id: item.id,
        handlingFee: item.handlingFee,
        smallCartCharge: item.smallCartCharge,
        smallCartMinAmount: item.smallCartMinAmount,
        status: updatedStatusInt,
      );

      if (isClosed) return;

      if (response.status || response.success) {
        successMessage(title: 'Status Updated', message: 'Charge status changed to ${newStatus ? "Active" : "Inactive"}.');
        await fetchServerData();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update charge status.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'toggleChargeStatus', {'id': item.id, 'targetStatus': newStatus});
      if (!isClosed) {
        errorMessage(message: 'Error updating charge status: $e');
      }
    } finally {
      if (!isClosed) {
        togglingStatusMap[item.id] = false;
      }
    }
  }

  Future<bool> submitCharges() async {
    if (isSubmitting.value) return false;

    if (!addEditFormKey.currentState!.validate()) return false;

    final double handlingFee = double.tryParse(handlingFeeController.text.trim()) ?? 0.0;
    final double smallCartCharge = double.tryParse(smallCartChargeController.text.trim()) ?? 0.0;
    final double smallCartMinAmount = double.tryParse(smallCartMinAmountController.text.trim()) ?? 0.0;

    isSubmitting.value = true;

    try {
      final int? editId = editingChargeId.value;
      final MiscChargesResponseModel response;

      if (editId != null && editId > 0) {
        response = await _miscChargesRepository.updateMiscCharges(
          id: editId,
          handlingFee: handlingFee,
          smallCartCharge: smallCartCharge,
          smallCartMinAmount: smallCartMinAmount,
          status: status.value,
        );
      } else {
        response = await _miscChargesRepository.addMiscCharges(
          handlingFee: handlingFee,
          smallCartCharge: smallCartCharge,
          smallCartMinAmount: smallCartMinAmount,
        );
      }

      if (isClosed) return false;

      if (response.status || response.success) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        final String actionVerb = editId != null ? 'updated' : 'added';
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Charges configuration $actionVerb successfully.');

        openCreateDialog();
        await fetchServerData();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save charges configuration.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitCharges', {'editing_id': editingChargeId.value});
      if (!isClosed) {
        errorMessage(message: 'An error occurred while saving charges.');
      }
      return false;
    } finally {
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }

  Future<bool> deleteCharge(MiscChargeItem charge) async {
    if (charge.id <= 0) {
      errorMessage(message: 'Invalid charge ID.');
      return false;
    }

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _miscChargesRepository.deleteCharges(chargeId: charge.id.toString());

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Charge deleted successfully.');
          await refreshMiscCharges();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete charge.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteCharge', {'charge_id': charge.id});
        errorMessage(message: 'An error occurred while deleting the charge.');
      }
    });

    return isSuccess;
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'MiscChargesController');
        scope.setContexts('misc_charges_action', {'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    handlingFeeController.dispose();
    smallCartChargeController.dispose();
    smallCartMinAmountController.dispose();
    _allChargesCache.clear();
    togglingStatusMap.clear();
    super.onClose();
  }
}
