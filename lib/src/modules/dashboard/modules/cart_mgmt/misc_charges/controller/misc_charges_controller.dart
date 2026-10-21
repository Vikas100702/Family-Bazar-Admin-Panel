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

  bool _isActionLocked = false;

  // FORM MANAGEMENT & REACTIVE STATE
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
          final int total = response.pagination?.total ?? response.data.length;
          final int? totalPages = response.pagination?.totalPages;
          setServerData(data: response.data, totalCount: total, pageCount: totalPages);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch misc charges.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching charges.');
        }
      }
    });
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
    if (togglingStatusMap[item.id] == true || _isActionLocked) return;

    togglingStatusMap[item.id] = true;
    _isActionLocked = true;

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
      _logException(e, stackTrace, 'toggleChargeStatus', <String, dynamic>{'id': item.id, 'targetStatus': newStatus});
      if (!isClosed) {
        errorMessage(message: 'Error updating charge status.');
      }
    } finally {
      _isActionLocked = false;
      if (!isClosed) {
        togglingStatusMap[item.id] = false;
      }
    }
  }

  Future<bool> submitCharges() async {
    if (isSubmitting.value || _isActionLocked) return false;

    if (addEditFormKey.currentState == null || !addEditFormKey.currentState!.validate()) {
      return false;
    }

    final double handlingFee = double.tryParse(handlingFeeController.text.trim()) ?? 0.0;
    final double smallCartCharge = double.tryParse(smallCartChargeController.text.trim()) ?? 0.0;
    final double smallCartMinAmount = double.tryParse(smallCartMinAmountController.text.trim()) ?? 0.0;

    if (handlingFee < 0 || smallCartCharge < 0 || smallCartMinAmount < 0) {
      errorMessage(message: 'Charges and threshold amounts cannot be negative.');
      return false;
    }

    _isActionLocked = true;
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
      _logException(e, stackTrace, 'submitCharges', <String, dynamic>{'editing_id': editingChargeId.value});
      if (!isClosed) {
        errorMessage(message: 'An error occurred while saving charges.');
      }
      return false;
    } finally {
      _isActionLocked = false;
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

    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _miscChargesRepository.deleteCharges(chargeId: charge.id);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Charge deleted successfully.');
          await refreshMiscCharges();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete charge.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteCharge', <String, dynamic>{'charge_id': charge.id});
        errorMessage(message: 'An error occurred while deleting the charge.');
      }
    });

    _isActionLocked = false;
    return isSuccess;
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('controller', 'MiscChargesController');
        scope.setTag('module', 'misc_charges');
        scope.setContexts('misc_charges_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    handlingFeeController.dispose();
    smallCartChargeController.dispose();
    smallCartMinAmountController.dispose();
    togglingStatusMap.clear();
    super.onClose();
  }
}
