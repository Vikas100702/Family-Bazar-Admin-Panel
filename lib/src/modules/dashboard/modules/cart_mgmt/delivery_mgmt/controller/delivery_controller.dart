import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_rule_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/view_delivery_rules_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/repository/delivery_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DeliveryController extends BaseServerTableController<Rule> {
  final DeliveryRepository _repository;
  final PincodeSettingsRepository _pincodeRepository;

  DeliveryController({required this._repository, required this._pincodeRepository});

  // Studio View Navigation State
  final RxBool isStudioMode = false.obs;
  final Rxn<int> studioRuleId = Rxn<int>();
  final RxBool isStudioEditing = false.obs;
  final RxBool isInlineSlabFormOpen = false.obs;

  // Pin Code Selection & Multi-Select Reactive State
  final RxList<Datum> pincodeDropdownList = <Datum>[].obs;
  final RxList<Datum> filteredPincodeList = <Datum>[].obs;
  final RxList<int> selectedPincodeIds = <int>[].obs;
  final RxBool isAllPincodesSelected = false.obs;
  final RxBool isLoadingPincodes = false.obs;
  final RxString pincodeSearchQuery = ''.obs;

  // Delivery Rule Form Management (Add & Edit)
  final GlobalKey<FormState> deliveryRuleFormKey = GlobalKey<FormState>();
  late final TextEditingController ruleNameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priorityController;
  final RxInt status = 1.obs;
  final RxBool isSubmitting = false.obs;
  final RxMap<int, bool> togglingStatusMap = <int, bool>{}.obs;
  final RxMap<int, bool> togglingSlabStatusMap = <int, bool>{}.obs;

  // Detailed Rule Data (Pin codes & Slabs for View/Edit)
  final Rxn<DeliveryRuleDetailsData> activeRuleDetails = Rxn<DeliveryRuleDetailsData>();
  final RxBool isLoadingRuleDetails = false.obs;

  // Distance Slab Management State & Controllers
  final GlobalKey<FormState> distanceSlabFormKey = GlobalKey<FormState>();
  final Rxn<int> editingSlabId = Rxn<int>();
  final RxString selectedSlabType = 'amount'.obs;

  late final TextEditingController minDistanceKmController;
  late final TextEditingController maxDistanceKmController;
  late final TextEditingController minOrderAmountController;
  late final TextEditingController maxOrderAmountController;
  late final TextEditingController baseChargeController;
  late final TextEditingController perKmChargeController;
  late final TextEditingController slabPriorityController;
  final RxInt slabStatus = 1.obs;
  final RxBool isSubmittingSlab = false.obs;

  @override
  void onInit() {
    super.onInit();
    ruleNameController = TextEditingController();
    descriptionController = TextEditingController();
    priorityController = TextEditingController(text: '1');

    minDistanceKmController = TextEditingController();
    maxDistanceKmController = TextEditingController();
    minOrderAmountController = TextEditingController();
    maxOrderAmountController = TextEditingController();
    baseChargeController = TextEditingController();
    perKmChargeController = TextEditingController(text: '0');
    slabPriorityController = TextEditingController(text: '1');

    fetchServerData();
    fetchPincodesForDropdown();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final response = await _repository.viewDeliveryRulesList(page: currentPage.value, limit: itemsPerPage.value, searchValue: searchQuery.value);
        if (isClosed) return;

        if (response.status) {
          final List<Rule> rulesList = response.data?.rules ?? <Rule>[];
          final int totalRecords = response.data?.pagination?.total ?? rulesList.length;
          final int? totalPages = response.data?.pagination?.totalPages;
          setServerData(data: rulesList, totalCount: totalRecords, pageCount: totalPages);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch delivery rules.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'DeliveryController');
            scope.setTag('action', 'fetchServerData');
          },
        );
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching delivery rules.');
        }
      }
    });
  }

  Future<void> fetchPincodesForDropdown() async {
    try {
      isLoadingPincodes.value = true;
      final response = await _pincodeRepository.getPincodes(page: 1, limit: 1000);
      if (isClosed) return;

      if (response.status) {
        pincodeDropdownList.assignAll(response.data);
        filteredPincodeList.assignAll(response.data);
        _updateSelectAllStatus();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch pincodes list.');
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DeliveryController');
          scope.setTag('action', 'fetchPincodesForDropdown');
        },
      );
      if (!isClosed) errorMessage(message: 'Error fetching pincodes for dropdown.');
    } finally {
      if (!isClosed) isLoadingPincodes.value = false;
    }
  }

  List<String> getPincodeLabelsForRule(Rule rule) {
    if (rule.pincodes.isNotEmpty) {
      return rule.pincodes;
    }

    if (rule.pincodeIds.isNotEmpty && pincodeDropdownList.isNotEmpty) {
      final Set<int> targetIds = rule.pincodeIds.toSet();
      return pincodeDropdownList.where((p) => targetIds.contains(p.id)).map((p) => '${p.pPinCode} (${p.pFirmName})').toList();
    }

    if (rule.pincodeIds.isNotEmpty) {
      return rule.pincodeIds.map((id) => 'Pincode ID: #$id').toList();
    }

    return const <String>['No pincodes assigned'];
  }

  Future<DeliveryRuleDetailsData?> loadRuleDetails(int ruleId) async {
    try {
      isLoadingRuleDetails.value = true;
      final response = await _repository.getDeliveryRuleDetails(ruleId);
      if (isClosed) return null;

      if (response.status && response.data != null) {
        activeRuleDetails.value = response.data;
        return response.data;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to load rule details.');
        return null;
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DeliveryController');
          scope.setTag('action', 'loadRuleDetails');
          scope.setContexts('rule_meta', {'rule_id': ruleId});
        },
      );
      if (!isClosed) {
        errorMessage(message: 'Failed to fetch rule details: $e');
      }
      return null;
    } finally {
      if (!isClosed) {
        isLoadingRuleDetails.value = false;
      }
    }
  }

  void openCreateRuleStudio() {
    clearForm();
    studioRuleId.value = null;
    isStudioEditing.value = false;
    activeRuleDetails.value = null;
    isInlineSlabFormOpen.value = false;
    isStudioMode.value = true;
  }

  Future<void> openEditRuleStudio(Rule rule) async {
    clearForm();
    studioRuleId.value = rule.id;
    isStudioEditing.value = true;
    isInlineSlabFormOpen.value = false;
    isStudioMode.value = true;

    ruleNameController.text = rule.ruleName;
    descriptionController.text = rule.description;
    priorityController.text = rule.priority.toString();
    status.value = rule.status;

    await loadRuleDetails(rule.id);
    if (activeRuleDetails.value != null && activeRuleDetails.value!.pincodeIds.isNotEmpty) {
      selectedPincodeIds.assignAll(activeRuleDetails.value!.pincodeIds);
    } else if (rule.pincodeIds.isNotEmpty) {
      selectedPincodeIds.assignAll(rule.pincodeIds);
    }
    _updateSelectAllStatus();
  }

  void closeRuleStudio() {
    clearForm();
    isStudioMode.value = false;
    studioRuleId.value = null;
    isStudioEditing.value = false;
    activeRuleDetails.value = null;
    isInlineSlabFormOpen.value = false;
    fetchServerData();
  }

  void togglePincodeSelection(int pincodeId) {
    if (selectedPincodeIds.contains(pincodeId)) {
      selectedPincodeIds.remove(pincodeId);
    } else {
      selectedPincodeIds.add(pincodeId);
    }
    _updateSelectAllStatus();
  }

  void toggleSelectAll(bool? selectAll) {
    final bool isChecked = selectAll ?? false;
    isAllPincodesSelected.value = isChecked;
    if (isChecked) {
      final List<int> allIds = pincodeDropdownList.map((item) => item.id).whereType<int>().toList();
      selectedPincodeIds.assignAll(allIds);
    } else {
      selectedPincodeIds.clear();
    }
  }

  void onPincodeSearch(String query) {
    pincodeSearchQuery.value = query;
    final String clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredPincodeList.assignAll(pincodeDropdownList);
    } else {
      filteredPincodeList.assignAll(
        pincodeDropdownList.where((p) => p.pPinCode.toLowerCase().contains(clean) || p.pFirmName.toLowerCase().contains(clean)),
      );
    }
  }

  void _updateSelectAllStatus() {
    if (pincodeDropdownList.isEmpty) {
      isAllPincodesSelected.value = false;
    } else {
      isAllPincodesSelected.value = selectedPincodeIds.length == pincodeDropdownList.length;
    }
  }

  Future<void> refreshDeliveryRules() async {
    await fetchPincodesForDropdown();
    await fetchServerData();
  }

  Future<void> toggleRuleStatus(Rule rule, bool newStatus) async {
    if (togglingStatusMap[rule.id] == true) return;
    togglingStatusMap[rule.id] = true;

    try {
      final int updatedStatusInt = newStatus ? 1 : 0;
      final List<int> effectivePincodes = rule.pincodeIds.isNotEmpty
          ? rule.pincodeIds
          : (pincodeDropdownList.isNotEmpty ? pincodeDropdownList.map((e) => e.id).whereType<int>().take(1).toList() : <int>[1]);

      final response = await _repository.addDeliveryRules(
        id: rule.id,
        ruleName: rule.ruleName,
        description: rule.description.isNotEmpty ? rule.description : null,
        priority: rule.priority,
        status: updatedStatusInt,
        pincodeIds: effectivePincodes,
      );

      if (isClosed) return;

      if (response.status) {
        successMessage(title: 'Status Updated', message: 'Rule status changed to ${newStatus ? 'Active' : 'Inactive'}.');
        await fetchServerData();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update rule status.');
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DeliveryController');
          scope.setTag('action', 'toggleRuleStatus');
          scope.setContexts('rule_payload', {'id': rule.id, 'targetStatus': newStatus});
        },
      );
      if (!isClosed) {
        errorMessage(message: 'Error updating rule status: $e');
      }
    } finally {
      togglingStatusMap[rule.id] = false;
    }
  }

  Future<void> toggleSlabStatus(RuleDistanceItem slab, bool newStatus) async {
    final int? currentRuleId = studioRuleId.value;
    if (currentRuleId == null || currentRuleId <= 0) return;
    if (togglingSlabStatusMap[slab.id] == true) return;

    togglingSlabStatusMap[slab.id] = true;
    try {
      final int updatedStatus = newStatus ? 1 : 0;
      final response = await _repository.saveDistanceSlab(
        id: slab.id,
        ruleId: currentRuleId,
        minDistanceKm: slab.minDistanceKm.toInt(),
        maxDistanceKm: slab.maxDistanceKm.toInt(),
        minOrderAmount: slab.minOrderAmount.toInt(),
        maxOrderAmount: slab.maxOrderAmount > 0 ? slab.maxOrderAmount.toInt() : null,
        baseCharge: slab.baseCharge.toInt(),
        perKmCharge: slab.perKmCharge.toInt(),
        priority: slab.priority,
        status: updatedStatus,
      );

      if (isClosed) return;

      if (response.status) {
        successMessage(title: 'Status Updated', message: 'Slab status updated to ${newStatus ? "Active" : "Inactive"}.');
        await loadRuleDetails(currentRuleId);
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update slab status.');
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DeliveryController');
          scope.setTag('action', 'toggleSlabStatus');
          scope.setContexts('slab_payload', {'id': slab.id, 'status': newStatus});
        },
      );
      if (!isClosed) {
        errorMessage(message: 'Error updating slab status: $e');
      }
    } finally {
      togglingSlabStatusMap[slab.id] = false;
    }
  }

  Future<bool> saveOrUpdateStudioRule() async {
    if (isSubmitting.value) return false;
    if (!deliveryRuleFormKey.currentState!.validate()) return false;

    if (selectedPincodeIds.isEmpty) {
      errorMessage(message: 'Please select at least one serviceable pincode.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final int parsedPriority = int.tryParse(priorityController.text.trim()) ?? 1;
      final int? currentId = studioRuleId.value;

      final response = await _repository.addDeliveryRules(
        id: currentId,
        ruleName: ruleNameController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        priority: parsedPriority,
        status: status.value,
        pincodeIds: selectedPincodeIds.toList(),
      );

      if (isClosed) return false;

      if (response.status) {
        final int resolvedId = response.data?.ruleId ?? currentId ?? 0;
        studioRuleId.value = resolvedId;
        isStudioEditing.value = true;

        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Delivery rule saved successfully.');

        if (resolvedId > 0) {
          await loadRuleDetails(resolvedId);
        }
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save delivery rule.');
        return false;
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DeliveryController');
          scope.setTag('action', 'saveOrUpdateStudioRule');
        },
      );
      if (!isClosed) errorMessage(message: e.toString());
      return false;
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  void clearForm() {
    ruleNameController.clear();
    descriptionController.clear();
    priorityController.text = '1';
    status.value = 1;
    selectedPincodeIds.clear();
    isAllPincodesSelected.value = false;
    pincodeSearchQuery.value = '';
    filteredPincodeList.assignAll(pincodeDropdownList);
    activeRuleDetails.value = null;
    editingSlabId.value = null;
    slabStatus.value = 1;
    isSubmitting.value = false;
    isSubmittingSlab.value = false;
  }

  // Distance Slab Operations & Type Setter
  void setSlabType(String type) {
    selectedSlabType.value = type;
  }

  void openInlineSlabForm({dynamic slab}) {
    selectedSlabType.value = 'amount';

    if (slab != null) {
      editingSlabId.value = slab.id as int;
      minDistanceKmController.text = slab.minDistanceKm.toString();
      maxDistanceKmController.text = slab.maxDistanceKm?.toString() ?? '0';
      minOrderAmountController.text = slab.minOrderAmount.toString();
      maxOrderAmountController.text = slab.maxOrderAmount != null && slab.maxOrderAmount > 0 ? slab.maxOrderAmount.toString() : '';
      baseChargeController.text = slab.baseCharge.toString();
      perKmChargeController.text = slab.perKmCharge?.toString() ?? '0';
      slabPriorityController.text = slab.priority.toString();
      slabStatus.value = slab.status as int;
    } else {
      editingSlabId.value = null;
      minDistanceKmController.clear();
      maxDistanceKmController.clear();
      minOrderAmountController.clear();
      maxOrderAmountController.clear();
      baseChargeController.clear();
      perKmChargeController.text = '0';
      slabPriorityController.text = '1';
      slabStatus.value = 1;
    }
    isInlineSlabFormOpen.value = true;
  }

  void closeInlineSlabForm() {
    editingSlabId.value = null;
    minOrderAmountController.clear();
    maxOrderAmountController.clear();
    baseChargeController.clear();
    slabStatus.value = 1;
    isInlineSlabFormOpen.value = false;
  }

  Future<void> submitStudioDistanceSlab() async {
    if (isSubmittingSlab.value) return;
    final int? currentRuleId = studioRuleId.value;

    if (currentRuleId == null || currentRuleId <= 0) {
      errorMessage(message: 'Please save the rule details first before configuring order slabs.');
      return;
    }

    if (!distanceSlabFormKey.currentState!.validate()) return;
    isSubmittingSlab.value = true;

    try {
      final String type = selectedSlabType.value.toLowerCase().trim();
      final bool isAmountType = type == 'amount';
      final bool isDistanceType = type == 'distance';

      final int minDistance = isAmountType ? 0 : (int.tryParse(minDistanceKmController.text.trim()) ?? 0);
      final int maxDistance = isAmountType ? 0 : (int.tryParse(maxDistanceKmController.text.trim()) ?? 0);
      final int perKm = isAmountType ? 0 : (int.tryParse(perKmChargeController.text.trim()) ?? 0);

      final int minAmount = isDistanceType ? 0 : (int.tryParse(minOrderAmountController.text.trim()) ?? 0);
      final String rawMaxAmount = maxOrderAmountController.text.trim();
      final int? maxAmount = isDistanceType ? 0 : (rawMaxAmount.isNotEmpty ? int.tryParse(rawMaxAmount) : null);

      final int baseCharge = int.tryParse(baseChargeController.text.trim()) ?? 0;
      final int priority = int.tryParse(slabPriorityController.text.trim()) ?? 1;

      final response = await _repository.saveDistanceSlab(
        id: editingSlabId.value,
        ruleId: currentRuleId,
        minDistanceKm: minDistance,
        maxDistanceKm: maxDistance,
        minOrderAmount: minAmount,
        maxOrderAmount: maxAmount,
        baseCharge: baseCharge,
        perKmCharge: perKm,
        priority: priority,
        status: slabStatus.value,
      );

      if (isClosed) return;

      final bool isSuccess = response.status == true || response.status.toString() == 'true' || response.status.toString() == '1';
      if (isSuccess) {
        closeInlineSlabForm();
        successMessage(
          title: 'Success',
          message: response.message.isNotEmpty
              ? response.message
              : (editingSlabId.value != null ? 'Distance slab updated successfully.' : 'Order slab added successfully.'),
        );
        await loadRuleDetails(currentRuleId);
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save distance slab rule.');
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DeliveryController');
          scope.setTag('action', 'submitStudioDistanceSlab');
          scope.setContexts('target_rule', {'ruleId': currentRuleId, 'slabId': editingSlabId.value});
        },
      );
      if (!isClosed) {
        errorMessage(message: 'Error saving slab: $e');
      }
    } finally {
      if (!isClosed) {
        isSubmittingSlab.value = false;
      }
    }
  }

  @override
  void onClose() {
    ruleNameController.dispose();
    descriptionController.dispose();
    priorityController.dispose();
    minDistanceKmController.dispose();
    maxDistanceKmController.dispose();
    minOrderAmountController.dispose();
    maxOrderAmountController.dispose();
    baseChargeController.dispose();
    perKmChargeController.dispose();
    slabPriorityController.dispose();
    super.onClose();
  }
}
