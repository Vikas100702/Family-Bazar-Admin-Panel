import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart' as firm_model;
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PincodeSettingsController extends BaseTableController<Datum> {
  final PincodeSettingsRepository _repository;
  final FirmRepository _firmRepository;
  final StorageService _storageService;

  PincodeSettingsController({required this._repository, required this._firmRepository, required this._storageService});

  // Firm selection & drop-down reactive state
  final RxList<firm_model.Datum> firmDropdownList = <firm_model.Datum>[].obs;
  final Rxn<firm_model.Datum> selectedFirm = Rxn<firm_model.Datum>();
  final RxBool isLoadingFirms = false.obs;

  // Form Management
  final GlobalKey<FormState> pincodeFormKey = GlobalKey<FormState>();
  late final TextEditingController firmCodeController;
  late final TextEditingController firmNameController;
  late final TextEditingController pinCodeController;

  // Conflict Tracking & Operation State
  final RxInt addPincodeStatus = 0.obs;
  final RxString addPincodeErrorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    firmCodeController = TextEditingController();
    firmNameController = TextEditingController();
    pinCodeController = TextEditingController();
    fetchPincodes();
    fetchFirmsForDropdown();
  }

  @override
  String searchTokenBuilder(Datum item) {
    return '${item.pPinCode} ${item.pFirmName} ${item.pFirmCode} ${item.userName}';
  }

  Future<void> fetchPincodes() async {
    await runWithLoading(() async {
      try {
        final response = await _repository.getPincodes();
        if (isClosed) return;

        if (response.status) {
          setMasterData(response.data);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the pincode list.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'PincodeSettingsController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching pincodes.');
      }
    });
  }

  Future<void> fetchFirmsForDropdown() async {
    try {
      isLoadingFirms.value = true;
      final response = await _firmRepository.viewFirms();
      if (isClosed) return;

      if (response.success) {
        firmDropdownList.assignAll(response.data);
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch firms list.');
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      if (!isClosed) errorMessage(message: 'Error fetching pincode details.');
    } finally {
      if (!isClosed) isLoadingFirms.value = false;
    }
  }

  void onFirmSelected(firm_model.Datum? firm) {
    selectedFirm.value = firm;
    if (firm != null) {
      firmCodeController.text = firm.fFirmCode;
      firmNameController.text = firm.fFirmName;
    } else {
      firmCodeController.clear();
      firmNameController.clear();
    }
  }

  Future<void> refreshPincodes() async {
    await fetchFirmsForDropdown();
    await fetchPincodes();
  }

  /// Submits pincode assignment with conflict verification
  Future<void> submitPincode({bool isEdit = false, int? id}) async {
    if (!pincodeFormKey.currentState!.validate()) return;
    isSubmitting.value = true;

    try {
      final payload = {
        "user_name": _storageService.getString("username") ?? "Super Admin",
        "P_FirmCode": firmCodeController.text.trim(),
        "P_FirmName": firmNameController.text.trim(),
        "P_PinCode": pinCodeController.text.trim(),
        if (id != null) "id": id,
      };

      final response = await _repository.addPincode(payload);
      if (isClosed) return;

      if (response.status == -1) {
        addPincodeStatus.value = -1;
        addPincodeErrorMessage.value = response.message.isNotEmpty ? response.message : 'Pincode is already assigned to another firm.';
        pincodeFormKey.currentState?.validate();
      } else if (response.status == 1 || response.success) {
        addPincodeStatus.value = 0;
        successMessage(title: "Success", message: response.message);
        Get.back();
        fetchPincodes();
      } else {
        errorMessage(message: response.message);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      errorMessage(message: e.toString());
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  /// Unmaps and reassigns an existing pincode mapping
  Future<void> confirmAndUnmapPincode() async {
    isSubmitting.value = true;
    try {
      final payload = {
        "user_name": _storageService.getString("username") ?? "Super Admin",
        "P_FirmCode": firmCodeController.text.trim(),
        "P_FirmName": firmNameController.text.trim(),
        "P_PinCode": pinCodeController.text.trim(),
      };

      final response = await _repository.unmapAndAssignPincode(payload);
      if (isClosed) return;

      if (response.status == 1 || response.success) {
        addPincodeStatus.value = 0;
        successMessage(title: "Success", message: response.message);
        fetchPincodes();
      } else {
        errorMessage(message: response.message);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      errorMessage(message: e.toString());
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  void clearForm() {
    firmCodeController.clear();
    firmNameController.clear();
    pinCodeController.clear();
    selectedFirm.value = null;
    addPincodeStatus.value = 0;
    addPincodeErrorMessage.value = '';
    isSubmitting.value = false;
  }

  void preFillForm(Datum pincode) {
    firmCodeController.text = pincode.pFirmCode;
    firmNameController.text = pincode.pFirmName;
    pinCodeController.text = pincode.pPinCode;

    if (firmDropdownList.isNotEmpty) {
      try {
        selectedFirm.value = firmDropdownList.firstWhere((f) => f.fFirmCode == pincode.pFirmCode || f.fFirmName == pincode.pFirmName);
      } catch (_) {
        selectedFirm.value = null;
      }
    } else {
      selectedFirm.value = null;
    }

    addPincodeStatus.value = 0;
    addPincodeErrorMessage.value = '';
    isSubmitting.value = false;
  }

  void onPincodeChanged(String value) {
    if (addPincodeStatus.value == -1) {
      addPincodeStatus.value = 0;
      addPincodeErrorMessage.value = '';
      pincodeFormKey.currentState?.validate();
    }
  }

  @override
  void onClose() {
    firmCodeController.dispose();
    firmNameController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }
}
