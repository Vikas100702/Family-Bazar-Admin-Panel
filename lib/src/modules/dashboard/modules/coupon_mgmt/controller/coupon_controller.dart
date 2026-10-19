import 'dart:async';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/add_coupon_model.dart';
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
  final DashboardGroupRepository _groupRepository;
  final BrandRepository _brandRepository;

  CouponController({required this._couponRepository, DashboardGroupRepository? groupRepository, BrandRepository? brandRepository})
    : _groupRepository =
          groupRepository ??
          DashboardGroupRepository(
            apiClient: Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true),
          ),
      _brandRepository =
          brandRepository ??
          BrandRepository(apiClient: Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true));

  bool _isActionLocked = false;

  // LOADING & SUBMISSION STATES
  final RxBool isSubmitting = false.obs;
  final RxBool isMetaLoading = false.obs;
  final RxBool isFilterTypeLoading = false.obs;

  // FORM KEYS & CONTROLLERS
  final GlobalKey<FormState> couponFormKey = GlobalKey<FormState>();
  final Rxn<int> editingCouponId = Rxn<int>();
  final Rxn<ViewCouponListDatum> activeViewingCoupon = Rxn<ViewCouponListDatum>();

  late final TextEditingController codeController;
  late final TextEditingController titleController;
  late final TextEditingController discountValueController;
  late final TextEditingController maxDiscountController;
  late final TextEditingController minOrderAmountController;
  late final TextEditingController usageLimitController;
  late final TextEditingController usagePerCustomerController;
  late final TextEditingController startAtController;
  late final TextEditingController endAtController;

  // Drop down States
  final RxnString selectedDiscountType = RxnString();
  final RxList<Map<String, String>> discountTypeOptions = <Map<String, String>>[].obs;
  final RxnString selectedUserType = RxnString();
  final RxList<Map<String, String>> userTypeOptions = <Map<String, String>>[].obs;
  final RxnString selectedPaymentType = RxnString();
  final RxList<Map<String, String>> paymentTypeOptions = <Map<String, String>>[].obs;

  final RxInt couponStatus = 1.obs;
  final RxInt applicableAll = 1.obs;

  // Groups Selection
  final RxList<ViewDashboardGroupDatum> allGroups = <ViewDashboardGroupDatum>[].obs;
  final RxList<ViewDashboardGroupDatum> filteredGroups = <ViewDashboardGroupDatum>[].obs;
  final RxList<String> selectedGroupCodes = <String>[].obs;
  late final TextEditingController groupSearchController;

  // Brands Selection
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
        final ViewCouponListModel response = await _couponRepository.viewCouponList(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );

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
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching coupons.');
        }
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

      if (results[0] is ViewDashboardGroupModel) {
        final ViewDashboardGroupModel groupModel = results[0] as ViewDashboardGroupModel;
        allGroups.assignAll(groupModel.data);
        filteredGroups.assignAll(groupModel.data);
      }

      if (results[1] is ViewBrandModel) {
        final ViewBrandModel brandModel = results[1] as ViewBrandModel;
        allBrands.assignAll(brandModel.data);
        filteredBrands.assignAll(brandModel.data);
      }

      if (results[2] is ViewCouponFilterTypeModel) {
        final ViewCouponFilterTypeModel filterModel = results[2] as ViewCouponFilterTypeModel;
        if (filterModel.status && filterModel.data != null) {
          final data = filterModel.data!;
          if (data.discountType.isNotEmpty) {
            discountTypeOptions.assignAll(data.discountType.map((t) => {'label': t.name.toUpperCase(), 'value': t.value}).toList(growable: false));
            selectedDiscountType.value ??= discountTypeOptions.first['value'];
          }
          if (data.userType.isNotEmpty) {
            userTypeOptions.assignAll(data.userType.map((t) => {'label': t.name.toUpperCase(), 'value': t.value}).toList(growable: false));
            selectedUserType.value ??= userTypeOptions.first['value'];
          }
          if (data.paymentType.isNotEmpty) {
            paymentTypeOptions.assignAll(data.paymentType.map((t) => {'label': t.name.toUpperCase(), 'value': t.value}).toList(growable: false));
            selectedPaymentType.value ??= paymentTypeOptions.first['value'];
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

  void openCreateDialog() {
    resetForm();
  }

  void openEditDialog(ViewCouponListDatum coupon) {
    editingCouponId.value = coupon.id;
    activeViewingCoupon.value = coupon;

    codeController.text = coupon.code;
    titleController.text = coupon.title;
    discountValueController.text = coupon.discountValue;
    maxDiscountController.text = coupon.maxDiscount;
    minOrderAmountController.text = coupon.minOrderAmount;
    usageLimitController.text = coupon.usageLimit.toString();
    usagePerCustomerController.text = coupon.usagePerCustomer.toString();

    startAtController.text = coupon.startAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(coupon.startAt!.toLocal()) : '';
    endAtController.text = coupon.endAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(coupon.endAt!.toLocal()) : '';

    final String dt = coupon.discountType.toLowerCase().trim();
    final matchDt = discountTypeOptions.firstWhereOrNull((opt) => opt['value']?.toLowerCase() == dt);
    selectedDiscountType.value = matchDt?['value'] ?? (discountTypeOptions.isNotEmpty ? discountTypeOptions.first['value'] : dt);

    final String ut = coupon.userType.toLowerCase().trim();
    final matchUt = userTypeOptions.firstWhereOrNull((opt) => opt['value']?.toLowerCase() == ut);
    selectedUserType.value = matchUt?['value'] ?? (userTypeOptions.isNotEmpty ? userTypeOptions.first['value'] : ut);

    final String pt = coupon.paymentType.toLowerCase().trim();
    final matchPt = paymentTypeOptions.firstWhereOrNull((opt) => opt['value']?.toLowerCase() == pt);
    selectedPaymentType.value = matchPt?['value'] ?? (paymentTypeOptions.isNotEmpty ? paymentTypeOptions.first['value'] : pt);

    couponStatus.value = coupon.status;
    final int appAll = int.tryParse(coupon.applicableAll.trim()) ?? 1;
    applicableAll.value = appAll;

    selectedGroupCodes.assignAll(coupon.applicableGroup.map((e) => e.trim()).where((e) => e.isNotEmpty));
    selectedBrandCodes.assignAll(coupon.applicableBrand.map((e) => e.trim()).where((e) => e.isNotEmpty));
  }

  void resetForm() {
    editingCouponId.value = null;
    activeViewingCoupon.value = null;

    codeController.clear();
    titleController.clear();
    discountValueController.clear();
    maxDiscountController.clear();
    minOrderAmountController.clear();
    usageLimitController.clear();
    usagePerCustomerController.clear();
    startAtController.clear();
    endAtController.clear();

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

  void toggleApplicableAll(bool isChecked) {
    applicableAll.value = isChecked ? 1 : 0;
    if (isChecked) {
      selectedGroupCodes.clear();
      selectedBrandCodes.clear();
    }
  }

  void filterGroups(String query) {
    final String clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredGroups.assignAll(allGroups);
    } else {
      filteredGroups.assignAll(
        allGroups.where((g) => g.dgName.toLowerCase().contains(clean) || g.dgCode.toLowerCase().contains(clean) || g.id.toString().contains(clean)),
      );
    }
  }

  void toggleGroupSelection(String groupCode) {
    if (applicableAll.value == 1) return;
    final String trimmed = groupCode.trim();
    if (trimmed.isEmpty) return;

    if (selectedGroupCodes.contains(trimmed)) {
      selectedGroupCodes.remove(trimmed);
    } else {
      selectedGroupCodes.add(trimmed);
    }
  }

  void filterBrands(String query) {
    final String clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      filteredBrands.assignAll(allBrands);
    } else {
      filteredBrands.assignAll(allBrands.where((b) => b.mcCompName.toLowerCase().contains(clean) || b.mcCompCode.toLowerCase().contains(clean)));
    }
  }

  void toggleBrandSelection(String brandCode) {
    if (applicableAll.value == 1) return;
    final String trimmed = brandCode.trim();
    if (trimmed.isEmpty) return;

    if (selectedBrandCodes.contains(trimmed)) {
      selectedBrandCodes.remove(trimmed);
    } else {
      selectedBrandCodes.add(trimmed);
    }
  }

  void setDateTime({required String formattedDateTime, required bool isStart}) {
    if (isStart) {
      startAtController.text = formattedDateTime;
    } else {
      endAtController.text = formattedDateTime;
    }
  }

  Future<bool> submitCoupon() async {
    if (isSubmitting.value || _isActionLocked) return false;
    if (couponFormKey.currentState == null || !couponFormKey.currentState!.validate()) {
      return false;
    }

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

    final String start = startAtController.text.trim();
    final String end = endAtController.text.trim();
    if (start.isNotEmpty && end.isNotEmpty) {
      final DateTime? startDate = DateTime.tryParse(start);
      final DateTime? endDate = DateTime.tryParse(end);
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        errorMessage(message: 'Start date cannot be after end date.');
        return false;
      }
    }

    final num discountValue = num.tryParse(discountValueController.text.trim()) ?? 0;
    if (discountValue <= 0) {
      errorMessage(message: 'Discount value must be greater than zero.');
      return false;
    }

    _isActionLocked = true;
    isSubmitting.value = true;

    try {
      final int? id = editingCouponId.value;
      final AddCouponModel response = await _couponRepository.addCoupon(
        id: id,
        code: codeController.text.trim(),
        discountType: selectedDiscountType.value!,
        title: titleController.text.trim(),
        discountValue: discountValue,
        maxDiscount: num.tryParse(maxDiscountController.text.trim()) ?? 0,
        minOrderAmount: num.tryParse(minOrderAmountController.text.trim()) ?? 0,
        usageLimit: int.tryParse(usageLimitController.text.trim()) ?? 0,
        usagePerCustomer: int.tryParse(usagePerCustomerController.text.trim()) ?? 0,
        applicableAll: applicableAll.value,
        applicableGroups: applicableAll.value == 1 ? [] : selectedGroupCodes.toList(growable: false),
        applicableBrands: applicableAll.value == 1 ? [] : selectedBrandCodes.toList(growable: false),
        userType: selectedUserType.value!,
        paymentType: selectedPaymentType.value!,
        startAt: start,
        endAt: end,
        status: couponStatus.value,
      );

      if (isClosed) return false;

      if (response.status) {
        final String actionVerb = id != null ? 'updated' : 'added';
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Coupon $actionVerb successfully.');
        resetForm();
        await refreshCoupons();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save coupon.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitCoupon');
      if (!isClosed) {
        errorMessage(message: 'Failed to process coupon. Please check parameters.');
      }
      return false;
    } finally {
      _isActionLocked = false;
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }

  Future<bool> deleteCoupon(ViewCouponListDatum coupon) async {
    if (coupon.id <= 0) {
      errorMessage(message: 'Invalid coupon ID.');
      return false;
    }

    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _couponRepository.deleteCoupon(couponId: coupon.id);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Coupon deleted successfully.');
          await refreshCoupons();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete coupon.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteCoupon', <String, dynamic>{'coupon_id': coupon.id, 'coupon_code': coupon.code});
        errorMessage(message: 'An error occurred while deleting the coupon.');
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
        scope.setTag('controller', 'CouponController');
        scope.setTag('module', 'coupon_mgmt');
        scope.setContexts('coupon_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
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
    allGroups.clear();
    filteredGroups.clear();
    allBrands.clear();
    filteredBrands.clear();

    super.onClose();
  }
}
