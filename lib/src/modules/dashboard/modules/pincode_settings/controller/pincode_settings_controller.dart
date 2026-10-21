import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PincodeSettingsController extends BaseServerTableController<Datum> {
  final PincodeSettingsRepository _repository;
  final FirmRepository _firmRepository;
  final StorageService _storageService;

  PincodeSettingsController({required this._repository, required this._firmRepository, required this._storageService});

  bool _isActionLocked = false;

  // FIRM SELECTION & DROP-DOWN REACTIVE STATE
  final RxList<ViewFirmDatum> firmDropdownList = <ViewFirmDatum>[].obs;
  final Rxn<ViewFirmDatum> selectedFirm = Rxn<ViewFirmDatum>();
  final RxBool isLoadingFirms = false.obs;

  // FORM MANAGEMENT & TEXT CONTROLLERS
  final GlobalKey<FormState> pincodeFormKey = GlobalKey<FormState>();
  late final TextEditingController firmCodeController;
  late final TextEditingController firmNameController;
  late final TextEditingController pinCodeController;

  // Slot Selection State (1 -> Schedule Slot, 2 -> Regular Slot)
  final RxInt selectedSlot = 1.obs;

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
    fetchServerData();
    fetchFirmsForDropdown();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final PincodeModel response = await _repository.getPincodes(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );

        if (isClosed) return;

        if (response.status) {
          setServerData(
            data: response.data,
            totalCount: response.pagination?.totalRecords ?? response.data.length,
            pageCount: response.pagination?.totalPages,
          );
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the pincode list.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching pincodes.');
        }
      }
    });
  }

  Future<void> fetchFirmsForDropdown() async {
    try {
      isLoadingFirms.value = true;
      final ViewFirmModel response = await _firmRepository.viewFirms();

      if (isClosed) return;

      if (response.success) {
        firmDropdownList.assignAll(response.data);
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch firms list.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchFirmsForDropdown');
      if (!isClosed) {
        errorMessage(message: 'Error fetching firm details for dropdown.');
      }
    } finally {
      if (!isClosed) isLoadingFirms.value = false;
    }
  }

  void onFirmSelected(ViewFirmDatum? firm) {
    selectedFirm.value = firm;
    if (firm != null) {
      firmCodeController.text = firm.fFirmCode;
      firmNameController.text = firm.fFirmName;
    } else {
      firmCodeController.clear();
      firmNameController.clear();
    }
  }

  void selectSlot(int slotType) {
    selectedSlot.value = slotType;
  }

  Future<void> refreshPincodes() async {
    await fetchFirmsForDropdown();
    await fetchServerData();
  }

  // MUTATIONS (SUBMIT & UN-MAP) WITH CONCURRENCY LOCKS
  Future<void> submitPincode({bool isEdit = false, int? id}) async {
    if (isSubmitting.value || _isActionLocked) return;

    if (pincodeFormKey.currentState == null || !pincodeFormKey.currentState!.validate()) {
      return;
    }

    _isActionLocked = true;
    isSubmitting.value = true;

    try {
      final AddPincodeModel response = await _repository.addPincode(
        userName: _storageService.getString('username') ?? 'Super Admin',
        firmCode: firmCodeController.text.trim(),
        firmName: firmNameController.text.trim(),
        pincode: pinCodeController.text.trim(),
        id: id,
        isScheduleSlot: selectedSlot.value == 1 ? 1 : 0,
        isRegularSlot: selectedSlot.value == 2 ? 1 : 0,
      );

      if (isClosed) return;

      if (response.status == -1) {
        addPincodeStatus.value = -1;
        addPincodeErrorMessage.value = response.message.isNotEmpty ? response.message : 'Pincode is already assigned to another firm.';
        pincodeFormKey.currentState?.validate();
      } else if (response.status == 1 || response.success) {
        addPincodeStatus.value = 0;
        successMessage(title: 'Success', message: response.message);
        Get.back();
        fetchServerData();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save pincode.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitPincode', <String, dynamic>{'isEdit': isEdit, 'id': id});
      if (!isClosed) {
        errorMessage(message: 'An error occurred while saving the pincode mapping.');
      }
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmitting.value = false;
    }
  }

  Future<void> confirmAndUnmapPincode() async {
    if (isSubmitting.value || _isActionLocked) return;

    _isActionLocked = true;
    isSubmitting.value = true;

    try {
      final UnmapAndAssignPincodeModel response = await _repository.unmapAndAssignPincode(
        userName: _storageService.getString('username') ?? 'Super Admin',
        firmCode: firmCodeController.text.trim(),
        firmName: firmNameController.text.trim(),
        pincode: pinCodeController.text.trim(),
        isScheduleSlot: selectedSlot.value == 1 ? 1 : 0,
        isRegularSlot: selectedSlot.value == 2 ? 1 : 0,
      );

      if (isClosed) return;

      if (response.status == 1 || response.success) {
        addPincodeStatus.value = 0;
        successMessage(title: 'Success', message: response.message);
        fetchServerData();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to unmap & reassign pincode.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'confirmAndUnmapPincode');
      if (!isClosed) {
        errorMessage(message: 'An error occurred during unmap and assign execution.');
      }
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmitting.value = false;
    }
  }

  void clearForm() {
    firmCodeController.clear();
    firmNameController.clear();
    pinCodeController.clear();
    selectedFirm.value = null;
    selectedSlot.value = 1;
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
        selectedFirm.value = firmDropdownList.firstWhere((ViewFirmDatum f) => f.fFirmCode == pincode.pFirmCode || f.fFirmName == pincode.pFirmName);
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

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('controller', 'PincodeSettingsController');
        scope.setTag('module', 'pincode_settings');
        scope.setContexts('pincode_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    firmCodeController.dispose();
    firmNameController.dispose();
    pinCodeController.dispose();
    firmDropdownList.clear();
    super.onClose();
  }
}
