import 'dart:async';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_filter_type_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_list_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/repository/coupon_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CouponController extends BaseServerTableController<ViewCouponListDatum> {
  final CouponRepository _couponRepository;
  late final DashboardGroupRepository _groupRepository;
  late final BrandRepository _brandRepository;

  CouponController({required this._couponRepository}) {
    final apiClient = Get.find<ApiClient>();
    _groupRepository = DashboardGroupRepository(apiClient: apiClient);
    _brandRepository = BrandRepository(apiClient: apiClient);
  }

  // Loading State
  final RxBool isSubmitting = false.obs;
  final RxBool isMetaLoading = false.obs;
  final RxBool isFilterTypeLoading = false.obs;

  // Form Key and Text Controllers
  final GlobalKey<FormState> addCouponFormKey = GlobalKey<FormState>();
  late final TextEditingController codeController;
  late final TextEditingController titleController;
  late final TextEditingController discountValueController;
  late final TextEditingController maxDiscountController;
  late final TextEditingController minOrderAmountController;
  late final TextEditingController usageLimitController;
  late final TextEditingController usagePerCustomerController;
  late final TextEditingController startAtController;
  late final TextEditingController endAtController;

  // DROPDOWN STATES
  final RxnString selectedDiscountType = RxnString();
  final RxList<Map<String, String>> discountTypeOptions = <Map<String, String>>[].obs;
  final RxnString selectedUserType = RxnString();
  final RxList<Map<String, String>> userTypeOptions = <Map<String, String>>[].obs;
  final RxnString selectedPaymentType = RxnString();
  final RxList<Map<String, String>> paymentTypeOptions = <Map<String, String>>[].obs;

  final RxInt couponStatus = 1.obs;
  final RxInt applicableAll = 1.obs; // APPLICABLE ALL, GROUPS & BRANDS SELECTION STATE

  // Dashboard Groups
  final RxList<ViewDashboardGroupDatum> allGroups = <ViewDashboardGroupDatum>[].obs;
  final RxList<ViewDashboardGroupDatum> filteredGroups = <ViewDashboardGroupDatum>[].obs;
  final RxList<String> selectedGroupCodes = <String>[].obs;
  late final TextEditingController groupSearchController;

  // Brands
  final RxList<ViewBrandDatum> allBrands = <ViewBrandDatum>[].obs;
  final RxList<ViewBrandDatum> filteredBrands = <ViewBrandDatum>[].obs;
  final RxList<String> selectedBrandCodes = <String>[].obs;
  late final TextEditingController brandSearchController;

  @override
  void onInit() {
    super.onInit();
    codeController = TextEditingController();
    titleController = TextEditingController();
    discountValueController = TextEditingController();
    maxDiscountController = TextEditingController();
    minOrderAmountController = TextEditingController();
    usageLimitController = TextEditingController();
    usagePerCustomerController = TextEditingController();
    startAtController = TextEditingController();
    endAtController = TextEditingController();

    groupSearchController = TextEditingController();
    brandSearchController = TextEditingController();

    fetchServerData();
    fetchMetadataAndFilterTypes();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final response = await _couponRepository.viewCouponList(page: currentPage.value, limit: itemsPerPage.value, searchValue: searchQuery.value);
        if (isClosed) return;

        if (response.status) {
          setServerData(
            data: response.data,
            totalCount: response.pagination?.total ?? response.data.length,
            pageCount: response.pagination?.totalPages,
          );
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch coupon list.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', {'page': currentPage.value, 'limit': itemsPerPage.value, 'search': searchQuery.value});
        errorMessage(message: 'An unexpected error occurred while fetching coupons.');
      }
    });
  }

  Future<void> refreshCoupons() async => refreshData();

  Future<void> fetchMetadataAndFilterTypes() async {
    try {
      isMetaLoading.value = true;
      isFilterTypeLoading.value = true;

      final results = await Future.wait([
        _groupRepository.viewGroups(),
        _brandRepository.viewBrands(page: 1, limit: 1000),
        _couponRepository.getCouponFilterType(),
      ]);

      if (isClosed) return;

      // Dashboard Groups mapping
      if (results[0] is ViewDashboardGroupModel) {
        final groupModel = results[0] as ViewDashboardGroupModel;
        allGroups.assignAll(groupModel.data);
        filteredGroups.assignAll(groupModel.data);
      }

      // Brands mapping
      if (results[1] is ViewBrandModel) {
        final brandModel = results[1] as ViewBrandModel;
        allBrands.assignAll(brandModel.data);
        filteredBrands.assignAll(brandModel.data);
      }

      // Dynamic Dropdowns population strictly from API
      if (results[2] is ViewCouponFilterTypeModel) {
        final filterModel = results[2] as ViewCouponFilterTypeModel;
        if (filterModel.status && filterModel.data != null) {
          final data = filterModel.data!;

          // Discount Types
          if (data.discountType.isNotEmpty) {
            discountTypeOptions.assignAll(data.discountType.map((t) => {'label': t.name.toUpperCase(), 'value': t.value}).toList());
            selectedDiscountType.value = discountTypeOptions.first['value'];
          }

          // User Types
          if (data.userType.isNotEmpty) {
            userTypeOptions.assignAll(data.userType.map((t) => {'label': t.name.toUpperCase(), 'value': t.value}).toList());
            selectedUserType.value = userTypeOptions.first['value'];
          }

          // Payment Types
          if (data.paymentType.isNotEmpty) {
            paymentTypeOptions.assignAll(data.paymentType.map((t) => {'label': t.name.toUpperCase(), 'value': t.value}).toList());
            selectedPaymentType.value = paymentTypeOptions.first['value'];
          }
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchMetadataAndFilterTypes');
    } finally {
      if (!isClosed) {
        isMetaLoading.value = false;
        isFilterTypeLoading.value = false;
      }
    }
  }

  void toggleApplicableAll(bool isChecked) {
    applicableAll.value = isChecked ? 1 : 0;
    if (isChecked) {
      selectedGroupCodes.clear();
      selectedBrandCodes.clear();
    }
  }

  void filterGroups(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredGroups.assignAll(allGroups);
    } else {
      filteredGroups.assignAll(
        allGroups
            .where((g) => g.dgName.toLowerCase().contains(clean) || g.dgCode.toLowerCase().contains(clean) || g.id.toString().contains(clean))
            .toList(),
      );
    }
  }

  void toggleGroupSelection(String groupCode) {
    if (applicableAll.value == 1) return;
    final trimmedGroupCode = groupCode.trim();
    if (trimmedGroupCode.isEmpty) return;

    if (selectedGroupCodes.contains(trimmedGroupCode)) {
      selectedGroupCodes.remove(trimmedGroupCode);
    } else {
      selectedGroupCodes.add(trimmedGroupCode);
    }
  }

  void filterBrands(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredBrands.assignAll(allBrands);
    } else {
      filteredBrands.assignAll(
        allBrands.where((b) => b.mcCompName.toLowerCase().contains(clean) || b.mcCompCode.toLowerCase().contains(clean)).toList(),
      );
    }
  }

  void toggleBrandSelection(String brandCode) {
    if (applicableAll.value == 1) return;
    final trimmedBrandCode = brandCode.trim();
    if (trimmedBrandCode.isEmpty) return;

    if (selectedBrandCodes.contains(trimmedBrandCode)) {
      selectedBrandCodes.remove(trimmedBrandCode);
    } else {
      selectedBrandCodes.add(brandCode);
    }
  }

  Future<void> pickDateTime({required BuildContext context, required bool isStart}) async {
    final DateTime initialDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? initialDate : initialDate.add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? const TimeOfDay(hour: 0, minute: 0) : const TimeOfDay(hour: 23, minute: 59),
    );

    if (pickedTime == null) return;

    final DateTime combined = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute, isStart ? 0 : 59);

    final String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);

    if (isStart) {
      startAtController.text = formatted;
    } else {
      endAtController.text = formatted;
    }
  }

  void resetForm() {
    codeController.clear();
    titleController.clear();
    discountValueController.clear();
    maxDiscountController.clear();
    minOrderAmountController.clear();
    usageLimitController.clear();
    usagePerCustomerController.clear();
    startAtController.clear();
    endAtController.clear();

    // Reset strictly to the first element from API
    selectedDiscountType.value = discountTypeOptions.isNotEmpty ? discountTypeOptions.first['value'] : null;
    selectedUserType.value = userTypeOptions.isNotEmpty ? userTypeOptions.first['value'] : null;
    selectedPaymentType.value = paymentTypeOptions.isNotEmpty ? paymentTypeOptions.first['value'] : null;
    couponStatus.value = 1;

    applicableAll.value = 1;
    selectedGroupCodes.clear();
    selectedBrandCodes.clear();

    groupSearchController.clear();
    brandSearchController.clear();
    filteredGroups.assignAll(allGroups);
    filteredBrands.assignAll(allBrands);
  }

  Future<bool> submitAddCoupon() async {
    if (!addCouponFormKey.currentState!.validate()) return false;

    if (selectedDiscountType.value == null || selectedUserType.value == null || selectedPaymentType.value == null) {
      errorMessage(message: 'Please select all required type options.');
      return false;
    }

    if (applicableAll.value == 0) {
      if (selectedGroupCodes.isEmpty && selectedBrandCodes.isEmpty) {
        errorMessage(message: 'Please select at least one Applicable Group or Brand, or enable "Applicable to All".');
        return false;
      }
    }

    isSubmitting.value = true;
    try {
      final response = await _couponRepository.addCoupon(
        code: codeController.text.trim(),
        discountType: selectedDiscountType.value!,
        title: titleController.text.trim(),
        discountValue: num.tryParse(discountValueController.text.trim()) ?? 0,
        maxDiscount: num.tryParse(maxDiscountController.text.trim()) ?? 0,
        minOrderAmount: num.tryParse(minOrderAmountController.text.trim()) ?? 0,
        usageLimit: int.tryParse(usageLimitController.text.trim()) ?? 0,
        usagePerCustomer: int.tryParse(usagePerCustomerController.text.trim()) ?? 0,
        applicableAll: applicableAll.value,
        applicableGroups: applicableAll.value == 1 ? [] : selectedGroupCodes.toList(),
        applicableBrands: applicableAll.value == 1 ? [] : selectedBrandCodes.toList(),
        userType: selectedUserType.value!,
        paymentType: selectedPaymentType.value!,
        startAt: startAtController.text.trim(),
        endAt: endAtController.text.trim(),
        status: couponStatus.value,
      );

      if (isClosed) return false;

      if (response.status) {
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Coupon added successfully');
        resetForm();
        await refreshCoupons();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to add coupon');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitAddCoupon');
      errorMessage(message: 'Failed to create coupon. Please check parameters.');
      return false;
    } finally {
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'CouponController');
        scope.setContexts('coupon_action', {'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    codeController.dispose();
    titleController.dispose();
    discountValueController.dispose();
    maxDiscountController.dispose();
    minOrderAmountController.dispose();
    usageLimitController.dispose();
    usagePerCustomerController.dispose();
    startAtController.dispose();
    endAtController.dispose();
    groupSearchController.dispose();
    brandSearchController.dispose();
    selectedGroupCodes.clear();
    selectedBrandCodes.clear();
    discountTypeOptions.clear();
    userTypeOptions.clear();
    paymentTypeOptions.clear();
    super.onClose();
  }
}
