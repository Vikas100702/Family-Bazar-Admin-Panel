import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_management_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/repository/delivery_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DeliveryController extends BaseServerTableController<DeliveryRuleItem> {
  final DeliveryRepository _repository;
  DeliveryController({required this._repository});

  bool _isActionLocked = false;

  // STUDIO MODE & FLOW MANAGEMENT
  final RxBool isStudioMode = false.obs;
  final Rxn<int> studioRuleId = Rxn<int>();
  final RxBool isStudioEditing = false.obs;
  final RxBool isInlineSlabFormOpen = false.obs;

  // RULE METADATA FORM STATE
  final GlobalKey<FormState> deliveryRuleFormKey = GlobalKey<FormState>();
  late final TextEditingController ruleNameController;
  late final TextEditingController descriptionController;
  final RxString selectedRuleType = 'amount'.obs;
  final RxInt status = 1.obs;

  // PINCODE SELECTION & FILTERING
  final RxList<DeliveryRulePincodeItem> allPincodes = <DeliveryRulePincodeItem>[].obs;
  final RxList<DeliveryRulePincodeItem> filteredPincodes = <DeliveryRulePincodeItem>[].obs;
  final RxSet<int> selectedPincodeIds = <int>{}.obs;
  final RxBool isLoadingPincodes = false.obs;
  final RxBool isAllPincodesSelected = false.obs;
  late final TextEditingController pincodeSearchController;

  // DELIVERY SLABS MATRIX STATE
  final RxList<DeliveryRuleSlabItem> studioSlabs = <DeliveryRuleSlabItem>[].obs;
  final GlobalKey<FormState> distanceSlabFormKey = GlobalKey<FormState>();
  final Rxn<int> editingSlabIndex = Rxn<int>();
  late final TextEditingController minDistanceKmController;
  late final TextEditingController maxDistanceKmController;
  late final TextEditingController minOrderAmountController;
  late final TextEditingController maxOrderAmountController;
  late final TextEditingController baseChargeController;
  late final TextEditingController perKmChargeController;
  late final TextEditingController slabPriorityController;
  final RxInt slabStatus = 1.obs;

  // SUBMISSION & STATUS MUTATION MAPS
  final RxBool isSubmitting = false.obs;
  final RxMap<int, bool> togglingStatusMap = <int, bool>{}.obs;
  final Rxn<DeliveryRuleDataWrapper> activeViewingDetails = Rxn<DeliveryRuleDataWrapper>();
  final RxBool isLoadingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    ruleNameController = TextEditingController();
    descriptionController = TextEditingController();
    pincodeSearchController = TextEditingController();
    minDistanceKmController = TextEditingController();
    maxDistanceKmController = TextEditingController();
    minOrderAmountController = TextEditingController();
    maxOrderAmountController = TextEditingController();
    baseChargeController = TextEditingController();
    perKmChargeController = TextEditingController(text: '0');
    slabPriorityController = TextEditingController(text: '1');
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final DeliveryRulesResponseModel response = await _repository.getDeliveryRules(
          search: searchQuery.value,
          page: currentPage.value,
          limit: itemsPerPage.value,
        );

        if (isClosed) return;

        if (response.status && response.data != null) {
          final List<DeliveryRuleItem> rulesList = response.data!.rules;
          final int total = response.data!.pagination?.total ?? rulesList.length;
          final int? totalPages = response.data!.pagination?.totalPages;
          setServerData(data: rulesList, totalCount: total, pageCount: totalPages);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch delivery rules.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{'page': currentPage.value, 'search': searchQuery.value});
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching delivery rules.');
        }
      }
    });
  }

  Future<void> refreshDeliveryRules() async => refreshData();

  Future<DeliveryRuleDataWrapper?> loadRuleDetails(int ruleId) async {
    try {
      isLoadingDetails.value = true;
      final DeliveryRulesResponseModel response = await _repository.getDeliveryRules(id: ruleId);
      if (isClosed) return null;

      if (response.status && response.data != null) {
        activeViewingDetails.value = response.data;
        return response.data;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to retrieve rule details.');
        return null;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'loadRuleDetails', <String, dynamic>{'rule_id': ruleId});
      return null;
    } finally {
      if (!isClosed) isLoadingDetails.value = false;
    }
  }

  Future<void> loadPincodes({int? ruleId}) async {
    try {
      isLoadingPincodes.value = true;
      final DeliveryRulePincodeListResponse response = await _repository.getPincodeList(ruleId: ruleId);

      if (isClosed) return;

      if (response.status && response.data != null) {
        allPincodes.assignAll(response.data!.pincodes);
        filteredPincodes.assignAll(response.data!.pincodes);

        selectedPincodeIds.clear();
        for (final pin in response.data!.pincodes) {
          if (pin.isSelected) {
            selectedPincodeIds.add(pin.id);
          }
        }
        _updateSelectAllStatus();
      } else {
        errorMessage(message: 'Failed to fetch available pincodes.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'loadPincodes', <String, dynamic>{'rule_id': ruleId});
    } finally {
      if (!isClosed) isLoadingPincodes.value = false;
    }
  }

  void openCreateRuleStudio() {
    clearStudioState();
    studioRuleId.value = null;
    isStudioEditing.value = false;
    isStudioMode.value = true;
    loadPincodes();
  }

  Future<void> openEditRuleStudio(DeliveryRuleItem rule) async {
    clearStudioState();
    studioRuleId.value = rule.id;
    isStudioEditing.value = true;
    isStudioMode.value = true;
    ruleNameController.text = rule.ruleName;
    descriptionController.text = rule.description;
    selectedRuleType.value = rule.ruleType.isNotEmpty ? rule.ruleType : 'amount';
    status.value = rule.status;

    final DeliveryRuleDataWrapper? details = await loadRuleDetails(rule.id);
    if (isClosed) return;

    if (details != null) {
      studioSlabs.assignAll(details.deliveryRules);
    }
    await loadPincodes(ruleId: rule.id);
  }

  void closeRuleStudio() {
    clearStudioState();
    isStudioMode.value = false;
    fetchServerData();
  }

  void clearStudioState() {
    ruleNameController.clear();
    descriptionController.clear();
    selectedRuleType.value = 'amount';
    status.value = 1;
    selectedPincodeIds.clear();
    isAllPincodesSelected.value = false;
    pincodeSearchController.clear();
    studioSlabs.clear();
    closeInlineSlabForm();
  }

  void onPincodeSearch(String query) {
    final String clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredPincodes.assignAll(allPincodes);
    } else {
      filteredPincodes.assignAll(allPincodes.where((p) => p.pincode.toLowerCase().contains(clean) || p.firmName.toLowerCase().contains(clean)));
    }
  }

  void togglePincodeSelection(int id) {
    if (selectedPincodeIds.contains(id)) {
      selectedPincodeIds.remove(id);
    } else {
      selectedPincodeIds.add(id);
    }
    _updateSelectAllStatus();
  }

  void toggleSelectAll(bool? selectAll) {
    final bool isChecked = selectAll ?? false;
    isAllPincodesSelected.value = isChecked;
    if (isChecked) {
      selectedPincodeIds.assignAll(allPincodes.map((p) => p.id));
    } else {
      selectedPincodeIds.clear();
    }
  }

  void _updateSelectAllStatus() {
    if (allPincodes.isEmpty) {
      isAllPincodesSelected.value = false;
    } else {
      isAllPincodesSelected.value = selectedPincodeIds.length == allPincodes.length;
    }
  }

  void setRuleType(String type) {
    selectedRuleType.value = type;
  }

  void openInlineSlabForm({DeliveryRuleSlabItem? slab, int? index}) {
    editingSlabIndex.value = index;
    if (slab != null) {
      minDistanceKmController.text = slab.minDistanceKm.toStringAsFixed(0);
      maxDistanceKmController.text = slab.maxDistanceKm.toStringAsFixed(0);
      minOrderAmountController.text = slab.minOrderAmount.toStringAsFixed(0);
      maxOrderAmountController.text = (slab.maxOrderAmount != null && slab.maxOrderAmount! > 0) ? slab.maxOrderAmount!.toStringAsFixed(0) : '';
      baseChargeController.text = slab.baseCharge.toStringAsFixed(0);
      perKmChargeController.text = slab.perKmCharge.toStringAsFixed(0);
      slabPriorityController.text = slab.priority.toString();
      slabStatus.value = slab.status;
    } else {
      minDistanceKmController.clear();
      maxDistanceKmController.clear();
      minOrderAmountController.clear();
      maxOrderAmountController.clear();
      baseChargeController.clear();
      perKmChargeController.text = '0';
      slabPriorityController.text = (studioSlabs.length + 1).toString();
      slabStatus.value = 1;
    }
    isInlineSlabFormOpen.value = true;
  }

  void closeInlineSlabForm() {
    editingSlabIndex.value = null;
    minDistanceKmController.clear();
    maxDistanceKmController.clear();
    minOrderAmountController.clear();
    maxOrderAmountController.clear();
    baseChargeController.clear();
    perKmChargeController.text = '0';
    slabPriorityController.text = '1';
    isInlineSlabFormOpen.value = false;
  }

  void saveInlineSlab() {
    if (distanceSlabFormKey.currentState == null || !distanceSlabFormKey.currentState!.validate()) {
      return;
    }

    final String type = selectedRuleType.value.toLowerCase().trim();
    final bool isDistanceType = type == 'distance';
    final bool isAmountType = type == 'amount';

    final double minDistance = isAmountType ? 0.0 : (double.tryParse(minDistanceKmController.text.trim()) ?? 0.0);
    final double maxDistance = isAmountType ? 0.0 : (double.tryParse(maxDistanceKmController.text.trim()) ?? 0.0);
    final double perKm = isAmountType ? 0.0 : (double.tryParse(perKmChargeController.text.trim()) ?? 0.0);

    final double minAmount = isDistanceType ? 0.0 : (double.tryParse(minOrderAmountController.text.trim()) ?? 0.0);
    final String rawMax = maxOrderAmountController.text.trim();
    final double? maxAmount = isDistanceType ? 0.0 : (rawMax.isNotEmpty ? double.tryParse(rawMax) : null);

    if (!isAmountType && minDistance > maxDistance) {
      errorMessage(message: 'Min distance cannot exceed Max distance.');
      return;
    }

    if (!isDistanceType && maxAmount != null && maxAmount > 0 && minAmount > maxAmount) {
      errorMessage(message: 'Min order amount cannot exceed Max order amount.');
      return;
    }

    final double baseCharge = double.tryParse(baseChargeController.text.trim()) ?? 0.0;
    final int priority = int.tryParse(slabPriorityController.text.trim()) ?? 1;

    final DeliveryRuleSlabItem slabItem = DeliveryRuleSlabItem(
      minDistanceKm: minDistance,
      maxDistanceKm: maxDistance,
      minOrderAmount: minAmount,
      maxOrderAmount: maxAmount,
      baseCharge: baseCharge,
      perKmCharge: perKm,
      priority: priority,
      status: slabStatus.value,
    );

    if (editingSlabIndex.value != null && editingSlabIndex.value! >= 0 && editingSlabIndex.value! < studioSlabs.length) {
      studioSlabs[editingSlabIndex.value!] = slabItem;
    } else {
      studioSlabs.add(slabItem);
    }

    closeInlineSlabForm();
  }

  void removeSlab(int index) {
    if (index >= 0 && index < studioSlabs.length) {
      studioSlabs.removeAt(index);
    }
  }

  Future<bool> submitEntireStudioRule() async {
    if (isSubmitting.value || _isActionLocked) return false;

    if (deliveryRuleFormKey.currentState == null || !deliveryRuleFormKey.currentState!.validate()) {
      return false;
    }

    if (selectedPincodeIds.isEmpty) {
      errorMessage(message: 'Please select at least one serviceable pincode.');
      return false;
    }

    if (studioSlabs.isEmpty) {
      errorMessage(message: 'Please configure at least one delivery charge slab.');
      return false;
    }

    _isActionLocked = true;
    isSubmitting.value = true;

    try {
      final int? ruleId = studioRuleId.value;
      final SaveDeliveryRuleResponseModel response = await _repository.saveRule(
        id: ruleId,
        ruleName: ruleNameController.text.trim(),
        ruleType: selectedRuleType.value,
        description: descriptionController.text.trim(),
        status: status.value,
        pincodeIds: selectedPincodeIds.toList(growable: false),
        deliveryRules: studioSlabs.toList(growable: false),
      );

      if (isClosed) return false;

      if (response.status) {
        final String actionVerb = ruleId != null ? 'updated' : 'created';
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Delivery rule $actionVerb successfully.');
        closeRuleStudio();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save delivery rule.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitEntireStudioRule');
      if (!isClosed) {
        errorMessage(message: 'An error occurred while saving the delivery rule.');
      }
      return false;
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmitting.value = false;
    }
  }

  Future<void> toggleRuleStatus(DeliveryRuleItem rule, bool newStatus) async {
    if (togglingStatusMap[rule.id] == true || _isActionLocked) return;

    togglingStatusMap[rule.id] = true;
    _isActionLocked = true;

    try {
      final int targetStatus = newStatus ? 1 : 0;
      final DeliveryRuleDataWrapper? details = await loadRuleDetails(rule.id);
      if (isClosed) return;

      final List<int> currentPinIds = details?.pincodes.map((p) => p.pincodeId).toList(growable: false) ?? <int>[];
      final List<DeliveryRuleSlabItem> currentSlabs = details?.deliveryRules ?? <DeliveryRuleSlabItem>[];

      final SaveDeliveryRuleResponseModel response = await _repository.saveRule(
        id: rule.id,
        ruleName: rule.ruleName,
        ruleType: rule.ruleType,
        description: rule.description,
        status: targetStatus,
        pincodeIds: currentPinIds,
        deliveryRules: currentSlabs,
      );

      if (isClosed) return;

      if (response.status) {
        successMessage(title: 'Status Updated', message: 'Rule status changed to ${newStatus ? 'Active' : 'Inactive'}.');
        await fetchServerData();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update rule status.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'toggleRuleStatus', <String, dynamic>{'rule_id': rule.id});
      if (!isClosed) errorMessage(message: 'Error toggling rule status.');
    } finally {
      _isActionLocked = false;
      if (!isClosed) togglingStatusMap[rule.id] = false;
    }
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('controller', 'DeliveryController');
        scope.setTag('module', 'delivery_mgmt');
        scope.setContexts('delivery_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    ruleNameController.dispose();
    descriptionController.dispose();
    pincodeSearchController.dispose();
    minDistanceKmController.dispose();
    maxDistanceKmController.dispose();
    minOrderAmountController.dispose();
    maxOrderAmountController.dispose();
    baseChargeController.dispose();
    perKmChargeController.dispose();
    slabPriorityController.dispose();

    allPincodes.clear();
    filteredPincodes.clear();
    selectedPincodeIds.clear();
    studioSlabs.clear();
    togglingStatusMap.clear();

    super.onClose();
  }
}
