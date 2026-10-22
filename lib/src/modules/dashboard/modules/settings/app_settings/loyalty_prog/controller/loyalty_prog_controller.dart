import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/save_points_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/view_loyalty_rules_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/repository/loyalty_prog_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoyaltyProgController extends BaseServerTableController<LoyaltyRuleDatum> {
  final LoyaltyRepository _repository;
  LoyaltyProgController({required this._repository});

  bool _isActionLocked = false;

  // LOYALTY RULES STATE
  final RxBool isFormOpen = false.obs;
  final Rxn<int> editingRuleId = Rxn<int>();
  final GlobalKey<FormState> loyaltyFormKey = GlobalKey<FormState>();

  late final TextEditingController ruleNameController;
  late final TextEditingController minOrderAmtController;
  late final TextEditingController maxOrderAmtController;
  late final TextEditingController pointsValueController;
  late final TextEditingController expiryDateController;

  final RxInt status = 1.obs;
  final RxBool isSubmitting = false.obs;
  final RxMap<int, bool> togglingStatusMap = <int, bool>{}.obs;

  // Catalog Dropdown & Multi-Select
  final RxBool isLoadingItems = false.obs;
  final RxList<LoyaltyBrand> availableBrands = <LoyaltyBrand>[].obs;
  final RxList<LoyaltyCategory> availableCategories = <LoyaltyCategory>[].obs;
  final RxSet<String> selectedBrandCodes = <String>{}.obs;
  final RxSet<String> selectedCategoryCodes = <String>{}.obs;
  final RxBool isAllBrandsSelected = false.obs;
  final RxBool isAllCategoriesSelected = false.obs;

  // GLOBAL POINTS SETTINGS STATE
  final GlobalKey<FormState> pointsSettingsFormKey = GlobalKey<FormState>();
  final Rxn<int> pointsSettingsId = Rxn<int>();

  late final TextEditingController rupeesPerPointCtrl;
  late final TextEditingController pointsPerRupeeCtrl;
  late final TextEditingController newCustRewardCtrl;
  late final TextEditingController custReffRewardCtrl;

  final RxString loyaltyConflictPriority = 'category'.obs;
  final RxBool isSubmittingPointsSettings = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize Loyalty Rule Controllers
    ruleNameController = TextEditingController();
    minOrderAmtController = TextEditingController();
    maxOrderAmtController = TextEditingController();
    pointsValueController = TextEditingController();
    expiryDateController = TextEditingController();

    // Initialize Points Settings Controllers
    rupeesPerPointCtrl = TextEditingController(text: '0.50');
    pointsPerRupeeCtrl = TextEditingController(text: '2.00');
    newCustRewardCtrl = TextEditingController(text: '100');
    custReffRewardCtrl = TextEditingController(text: '50');

    fetchServerData();
    fetchDropdownItems();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final ViewLoyaltyRulesModel response = await _repository.getLoyaltyRules(
          search: searchQuery.value,
          page: currentPage.value,
          limit: itemsPerPage.value,
        );

        if (isClosed) return;

        if (response.success) {
          final List<LoyaltyRuleDatum> rulesList = response.data;
          final int totalRecords = response.pagination?.totalRecords ?? rulesList.length;
          final int? totalPages = response.pagination?.totalPages;
          setServerData(data: rulesList, totalCount: totalRecords, pageCount: totalPages);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch loyalty rules.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData');
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching rules.');
        }
      }
    });
  }

  Future<void> refreshRules() async {
    await fetchDropdownItems();
    await fetchServerData();
  }

  Future<void> fetchDropdownItems({int? ruleId}) async {
    try {
      isLoadingItems.value = true;
      final AvailableItemsModel response = await _repository.getAvailableItems(limit: 1000, ruleId: ruleId);

      if (isClosed) return;

      if (response.success) {
        availableBrands.assignAll(response.brands);
        availableCategories.assignAll(response.categories);
        _updateSelectAllStates();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to load options.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchDropdownItems');
    } finally {
      if (!isClosed) isLoadingItems.value = false;
    }
  }

  void toggleBrandSelection(String brandCode) {
    if (selectedBrandCodes.contains(brandCode)) {
      selectedBrandCodes.remove(brandCode);
    } else {
      selectedBrandCodes.add(brandCode);
    }
    _updateSelectAllStates();
  }

  void toggleCategorySelection(String categoryCode) {
    if (selectedCategoryCodes.contains(categoryCode)) {
      selectedCategoryCodes.remove(categoryCode);
    } else {
      selectedCategoryCodes.add(categoryCode);
    }
    _updateSelectAllStates();
  }

  void toggleSelectAllBrands(bool? selectAll) {
    final bool isChecked = selectAll ?? false;
    isAllBrandsSelected.value = isChecked;
    if (isChecked) {
      selectedBrandCodes.assignAll(availableBrands.map((LoyaltyBrand b) => b.brandCode).where((String c) => c.isNotEmpty));
    } else {
      selectedBrandCodes.clear();
    }
  }

  void toggleSelectAllCategories(bool? selectAll) {
    final bool isChecked = selectAll ?? false;
    isAllCategoriesSelected.value = isChecked;
    if (isChecked) {
      selectedCategoryCodes.assignAll(availableCategories.map((LoyaltyCategory c) => c.categoryCode).where((String c) => c.isNotEmpty));
    } else {
      selectedCategoryCodes.clear();
    }
  }

  void _updateSelectAllStates() {
    isAllBrandsSelected.value = availableBrands.isNotEmpty && selectedBrandCodes.length == availableBrands.length;
    isAllCategoriesSelected.value = availableCategories.isNotEmpty && selectedCategoryCodes.length == availableCategories.length;
  }

  void openCreateForm() {
    _clearForm();
    isFormOpen.value = true;
    fetchDropdownItems();
  }

  Future<void> openEditForm(LoyaltyRuleDatum rule) async {
    _clearForm();
    isFormOpen.value = true;
    editingRuleId.value = rule.id;
    ruleNameController.text = rule.ruleName;
    minOrderAmtController.text = rule.minOrderAmt.toStringAsFixed(0);
    maxOrderAmtController.text = (rule.maxOrderAmt != null && rule.maxOrderAmt! > 0) ? rule.maxOrderAmt!.toStringAsFixed(0) : '';
    pointsValueController.text = rule.pointsValue.toStringAsFixed(2);
    status.value = rule.status;

    if (rule.expiryDate != null) {
      expiryDateController.text = DateFormat('yyyy-MM-dd').format(rule.expiryDate!.toLocal());
    }

    selectedBrandCodes.assignAll(rule.brands.map((LoyaltyBrand b) => b.brandCode).where((String c) => c.isNotEmpty));
    selectedCategoryCodes.assignAll(rule.categories.map((LoyaltyCategory c) => c.categoryCode).where((String c) => c.isNotEmpty));
    await fetchDropdownItems(ruleId: rule.id);
    _updateSelectAllStates();
  }

  void closeForm() {
    _clearForm();
    isFormOpen.value = false;
  }

  void _clearForm() {
    editingRuleId.value = null;
    ruleNameController.clear();
    minOrderAmtController.clear();
    maxOrderAmtController.clear();
    pointsValueController.clear();
    expiryDateController.clear();
    status.value = 1;
    selectedBrandCodes.clear();
    selectedCategoryCodes.clear();
    isAllBrandsSelected.value = false;
    isAllCategoriesSelected.value = false;
    isSubmitting.value = false;
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final DateTime initial = DateTime.now();
    final DateTime? picked = await showDatePicker(context: context, initialDate: initial, firstDate: initial, lastDate: DateTime(2040));
    if (picked != null) {
      expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> submitLoyaltyRule() async {
    if (_isActionLocked || isSubmitting.value) return;
    if (!loyaltyFormKey.currentState!.validate()) return;

    if (selectedBrandCodes.isEmpty) {
      errorMessage(message: 'Please select at least one brand.');
      return;
    }
    if (selectedCategoryCodes.isEmpty) {
      errorMessage(message: 'Please select at least one category.');
      return;
    }

    final double minAmt = double.tryParse(minOrderAmtController.text.trim()) ?? 0.0;
    final String rawMax = maxOrderAmtController.text.trim();
    final double? maxAmt = rawMax.isNotEmpty ? double.tryParse(rawMax) : null;
    final double ptsVal = double.tryParse(pointsValueController.text.trim()) ?? 0.0;

    _isActionLocked = true;
    isSubmitting.value = true;

    try {
      final SaveLoyaltyRuleModel response = await _repository.saveLoyaltyRule(
        id: editingRuleId.value,
        ruleName: ruleNameController.text.trim(),
        brandCodes: selectedBrandCodes.toList(growable: false),
        categoryCodes: selectedCategoryCodes.toList(growable: false),
        minOrderAmt: minAmt,
        maxOrderAmt: maxAmt,
        pointsValue: ptsVal,
        status: status.value,
        expiryDate: expiryDateController.text.trim(),
      );

      if (isClosed) return;

      if (response.success) {
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Rule saved successfully.');
        closeForm();
        await fetchServerData();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save rule.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitLoyaltyRule');
      if (!isClosed) errorMessage(message: 'An error occurred while saving the rule.');
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmitting.value = false;
    }
  }

  Future<void> toggleRuleStatus(LoyaltyRuleDatum rule, bool newStatus) async {
    if (_isActionLocked || togglingStatusMap[rule.id] == true) return;
    togglingStatusMap[rule.id] = true;
    _isActionLocked = true;

    try {
      final int targetStatus = newStatus ? 1 : 0;
      final SaveLoyaltyRuleModel response = await _repository.saveLoyaltyRule(
        id: rule.id,
        ruleName: rule.ruleName,
        brandCodes: rule.brands.map((LoyaltyBrand b) => b.brandCode).where((String c) => c.isNotEmpty).toList(growable: false),
        categoryCodes: rule.categories.map((LoyaltyCategory c) => c.categoryCode).where((String c) => c.isNotEmpty).toList(growable: false),
        minOrderAmt: rule.minOrderAmt,
        maxOrderAmt: rule.maxOrderAmt,
        pointsValue: rule.pointsValue,
        status: targetStatus,
        expiryDate: rule.expiryDate != null ? DateFormat('yyyy-MM-dd').format(rule.expiryDate!) : null,
      );

      if (isClosed) return;

      if (response.success) {
        successMessage(title: 'Status Updated', message: 'Rule is now ${newStatus ? 'Active' : 'Inactive'}.');
        await fetchServerData();
      } else {
        errorMessage(message: 'Failed to update rule status.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'toggleRuleStatus');
      if (!isClosed) errorMessage(message: 'Error updating rule status.');
    } finally {
      _isActionLocked = false;
      if (!isClosed) togglingStatusMap[rule.id] = false;
    }
  }

  // POINTS SETTINGS
  void populatePointsSettings(PointsSettingsData data) {
    pointsSettingsId.value = data.id;
    rupeesPerPointCtrl.text = data.rupeesPerPoint.toStringAsFixed(2);
    pointsPerRupeeCtrl.text = data.pointsPerRupee.toStringAsFixed(2);
    loyaltyConflictPriority.value = data.loyaltyConflictPriority.isNotEmpty ? data.loyaltyConflictPriority : 'category';
    newCustRewardCtrl.text = data.newCustReward.toString();
    custReffRewardCtrl.text = data.custReffReward.toString();
  }

  Future<bool> submitPointsSettings() async {
    if (_isActionLocked || isSubmittingPointsSettings.value) return false;
    if (!pointsSettingsFormKey.currentState!.validate()) return false;

    final double? rupeesPerPt = double.tryParse(rupeesPerPointCtrl.text.trim());
    final double? ptsPerRupee = double.tryParse(pointsPerRupeeCtrl.text.trim());
    final num? newReward = num.tryParse(newCustRewardCtrl.text.trim());
    final num? reffReward = num.tryParse(custReffRewardCtrl.text.trim());

    if (rupeesPerPt == null || ptsPerRupee == null || newReward == null || reffReward == null) {
      errorMessage(message: 'Please provide valid numeric values for all points settings.');
      return false;
    }

    _isActionLocked = true;
    isSubmittingPointsSettings.value = true;

    try {
      final SavePointsSettingsModel response = await _repository.savePointsSettings(
        id: pointsSettingsId.value,
        rupeesPerPoint: rupeesPerPt,
        pointsPerRupee: ptsPerRupee,
        loyaltyConflictPriority: loyaltyConflictPriority.value,
        newCustReward: newReward,
        custReffReward: reffReward,
      );

      if (isClosed) return false;

      if (response.success) {
        if (response.data?.id != null) {
          pointsSettingsId.value = response.data!.id;
        }
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Points settings saved successfully.');
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save points settings.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitPointsSettings');
      if (!isClosed) errorMessage(message: 'Error saving points settings.');
      return false;
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmittingPointsSettings.value = false;
    }
  }

  Future<bool> deleteRule(int ruleId) async {
    if (ruleId <= 0) {
      errorMessage(message: 'Invalid customer ID.');
      return false;
    }

    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _repository.deleteRule(ruleId: ruleId);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Customer deleted successfully.');
          await refreshRules();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete customer.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteLoyaltyRule');
        if (!isClosed) {
          errorMessage(message: 'An error occurred while deleting the customer.');
        }
      }
    });

    _isActionLocked = false;
    return isSuccess;
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'loyalty_program');
        scope.setTag('controller', 'LoyaltyProgController');
        scope.setContexts('loyalty_action', <String, dynamic>{
          'action': action,
          'currentPage': currentPage.value,
          'pointsSettingsId': pointsSettingsId.value,
        });
      },
    );
  }

  @override
  void onClose() {
    ruleNameController.dispose();
    minOrderAmtController.dispose();
    maxOrderAmtController.dispose();
    pointsValueController.dispose();
    expiryDateController.dispose();
    rupeesPerPointCtrl.dispose();
    pointsPerRupeeCtrl.dispose();
    newCustRewardCtrl.dispose();
    custReffRewardCtrl.dispose();

    availableBrands.clear();
    availableCategories.clear();
    selectedBrandCodes.clear();
    selectedCategoryCodes.clear();
    togglingStatusMap.clear();

    super.onClose();
  }
}
