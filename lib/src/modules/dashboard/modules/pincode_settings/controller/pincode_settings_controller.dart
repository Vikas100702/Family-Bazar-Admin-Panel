// import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
// import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
// import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart' as firm_model;
// import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
// import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
// import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class PincodeSettingsController extends BaseController {
//   final PincodeSettingsRepository _repository;
//   final FirmRepository _firmRepository;
//   final StorageService _storageService;
//
//   PincodeSettingsController({required this._repository, required this._firmRepository, required this._storageService});
//
//   final RxList<Datum> pincodeList = <Datum>[].obs;
//   final RxList<firm_model.Datum> firmDropdownList = <firm_model.Datum>[].obs;
//   final Rxn<firm_model.Datum> selectedFirm = Rxn<firm_model.Datum>();
//   final RxBool isLoadingFirms = false.obs;
//
//   final GlobalKey<FormState> pincodeFormKey = GlobalKey<FormState>();
//   late final TextEditingController firmCodeController;
//   late final TextEditingController firmNameController;
//   late final TextEditingController pinCodeController;
//
//   // Web Scroll Controllers bound to the view's Scrollbar widgets
//   late final ScrollController horizontalScrollController;
//   late final ScrollController verticalScrollController;
//
//   // Conflict & Loading Tracking
//   final RxInt addPincodeStatus = 0.obs;
//   final RxString addPincodeErrorMessage = ''.obs;
//   final RxBool isSubmitting = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     firmCodeController = TextEditingController();
//     firmNameController = TextEditingController();
//     pinCodeController = TextEditingController();
//
//     horizontalScrollController = ScrollController();
//     verticalScrollController = ScrollController();
//
//     fetchPincodes();
//     fetchFirmsForDropdown();
//   }
//
//   /// 1. READ: Fetch all mapped pincodes
//   Future<void> fetchPincodes() async {
//     await runWithLoading(() async {
//       final response = await _repository.getPincodes();
//       if (isClosed) return;
//       pincodeList.assignAll(response.data);
//     }, message: 'Fetching pincodes...');
//   }
//
//   /// 2. READ FIRMS: Fetch firm list from viewFirm
//   Future<void> fetchFirmsForDropdown() async {
//     try {
//       isLoadingFirms.value = true;
//       final response = await _firmRepository.viewFirms();
//       if (isClosed) return;
//
//       if (response.success) {
//         firmDropdownList.assignAll(response.data);
//       } else {
//         errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch firms list.');
//       }
//     } catch (e) {
//       if (!isClosed) {
//         errorMessage(message: 'Error fetching firm list for dropdown.');
//       }
//     } finally {
//       if (!isClosed) {
//         isLoadingFirms.value = false;
//       }
//     }
//   }
//
//   /// Triggers when user selects a firm from the Dropdown
//   void onFirmSelected(firm_model.Datum? firm) {
//     selectedFirm.value = firm;
//     if (firm != null) {
//       firmCodeController.text = firm.fFirmCode;
//       firmNameController.text = firm.fFirmName;
//     } else {
//       firmCodeController.clear();
//       firmNameController.clear();
//     }
//   }
//
//   /// REFRESH: Reloads both pincodes and firm dropdown list
//   Future<void> refreshPincodes() async {
//     await fetchFirmsForDropdown();
//     await fetchPincodes();
//   }
//
//   /// CREATE / UPDATE: Submits pincode mapping
//   Future<void> submitPincode({bool isEdit = false, int? id}) async {
//     if (!pincodeFormKey.currentState!.validate()) return;
//
//     await runWithLoading(() async {
//       final payload = {
//         "user_name": _storageService.getString("username") ?? "Super Admin",
//         "P_FirmCode": firmCodeController.text.trim(),
//         "P_FirmName": firmNameController.text.trim(),
//         "P_PinCode": pinCodeController.text.trim(),
//         "id": ?id,
//       };
//
//       final response = await _repository.addPincode(payload);
//       if (isClosed) return;
//
//       if (response.status == 1 || response.success) {
//         successMessage(title: "Success", message: response.message);
//         Get.back(); // Close Dialog
//         fetchPincodes();
//       } else if (response.status == -1) {
//         // already mapped to another firm
//         addPincodeStatus.value = -1;
//         addPincodeErrorMessage.value = response.message;
//       } else {
//         errorMessage(message: response.message);
//       }
//     }, message: 'Saving pincode mapping...');
//   }
//
//   /// UNMAP & ASSIGN: Reassigns conflicting pincode to the current firm
//   Future<void> confirmAndUnmapPincode() async {
//     await runWithLoading(() async {
//       final payload = {
//         "user_name": _storageService.getString("username") ?? "Super Admin",
//         "P_FirmCode": firmCodeController.text.trim(),
//         "P_FirmName": firmNameController.text.trim(),
//         "P_PinCode": pinCodeController.text.trim(),
//       };
//
//       final response = await _repository.unmapAndAssignPincode(payload);
//       if (isClosed) return;
//
//       if (response.status == 1 || response.success) {
//         successMessage(title: "Reassigned", message: response.message);
//         Get.back(); // Close Dialog
//         fetchPincodes();
//       } else {
//         errorMessage(message: response.message);
//       }
//     }, message: 'Reassigning pincode...');
//   }
//
//   /// Form state resets and population
//   void clearForm() {
//     firmCodeController.clear();
//     firmNameController.clear();
//     pinCodeController.clear();
//     selectedFirm.value = null;
//     addPincodeStatus.value = 0;
//     addPincodeErrorMessage.value = '';
//   }
//
//   void preFillForm(Datum pincode) {
//     firmCodeController.text = pincode.pFirmCode;
//     firmNameController.text = pincode.pFirmName;
//     pinCodeController.text = pincode.pPinCode;
//
//     // Auto-select matching firm in dropdown list if available
//     if (firmDropdownList.isNotEmpty) {
//       try {
//         selectedFirm.value = firmDropdownList.firstWhere((f) => f.fFirmCode == pincode.pFirmCode || f.fFirmName == pincode.pFirmName);
//       } catch (_) {
//         selectedFirm.value = null;
//       }
//     } else {
//       selectedFirm.value = null;
//     }
//
//     addPincodeStatus.value = 0;
//     addPincodeErrorMessage.value = '';
//   }
//
//   void onPincodeChanged(String value) {
//     if (addPincodeStatus.value == -1) {
//       addPincodeStatus.value = 0;
//       addPincodeErrorMessage.value = '';
//       pincodeFormKey.currentState?.validate();
//     }
//   }
//
//   @override
//   void onClose() {
//     // Flush all controllers to prevent web heap leaks
//     firmCodeController.dispose();
//     firmNameController.dispose();
//     pinCodeController.dispose();
//     horizontalScrollController.dispose();
//     verticalScrollController.dispose();
//     super.onClose();
//   }
// }

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart' as firm_model;
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PincodeSettingsController extends BaseController {
  final PincodeSettingsRepository _repository;
  final FirmRepository _firmRepository;
  final StorageService _storageService;

  PincodeSettingsController({
    required PincodeSettingsRepository repository,
    required FirmRepository firmRepository,
    required StorageService storageService,
  }) : _repository = repository,
       _firmRepository = firmRepository,
       _storageService = storageService;

  final RxList<Datum> pincodeList = <Datum>[].obs;
  final RxList<firm_model.Datum> firmDropdownList = <firm_model.Datum>[].obs;
  final Rxn<firm_model.Datum> selectedFirm = Rxn<firm_model.Datum>();
  final RxBool isLoadingFirms = false.obs;

  final GlobalKey<FormState> pincodeFormKey = GlobalKey<FormState>();
  late final TextEditingController firmCodeController;
  late final TextEditingController firmNameController;
  late final TextEditingController pinCodeController;

  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  final RxInt addPincodeStatus = 0.obs;
  final RxString addPincodeErrorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    firmCodeController = TextEditingController();
    firmNameController = TextEditingController();
    pinCodeController = TextEditingController();

    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();

    fetchPincodes();
    fetchFirmsForDropdown();
  }

  Future<void> fetchPincodes() async {
    await runWithLoading(() async {
      final response = await _repository.getPincodes();
      if (isClosed) return;
      pincodeList.assignAll(response.data);
    }, message: 'Fetching pincodes...');
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
    } catch (e) {
      if (!isClosed) errorMessage(message: 'Error fetching firm list.');
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

  /// 1. CHECK & ADD PINCODE (API Status Check)
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

      // Status -1 ko PEHLE check karein taaki response.success true hone par dialog close na ho
      if (response.status == -1) {
        addPincodeStatus.value = -1;
        addPincodeErrorMessage.value = response.message.isNotEmpty ? response.message : 'Pincode is already assigned to another firm.';
        pincodeFormKey.currentState?.validate(); // Pincode field ke niche red error dikhane ke liye
      } else if (response.status == 1 || response.success) {
        addPincodeStatus.value = 0;
        successMessage(title: "Success", message: response.message);
        Get.back(); // Dialog close karo
        fetchPincodes(); // Table refresh karo
      } else {
        errorMessage(message: response.message);
      }
    } catch (e) {
      errorMessage(message: e.toString());
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  /// 2. UNMAP & REASSIGN PINCODE
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
        fetchPincodes(); // Refresh Table
      } else {
        errorMessage(message: response.message);
      }
    } catch (e) {
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

  /// Resets status when user edits pincode
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
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.onClose();
  }
}
