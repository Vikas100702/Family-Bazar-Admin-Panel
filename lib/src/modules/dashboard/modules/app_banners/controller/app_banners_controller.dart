import 'dart:typed_data';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/model/app_banners_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/repository/app_banners_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBannersController extends BaseServerTableController<AppBannerDatum> {
  final AppBannersRepository _bannerRepository;
  final CategoryRepository _categoryRepository;
  final SubCategoryRepository _subCategoryRepository;
  final BrandRepository _brandRepository;
  final DashboardGroupRepository _groupRepository;

  AppBannersController({
    required this._bannerRepository,
    required this._categoryRepository,
    required this._subCategoryRepository,
    required this._brandRepository,
    required this._groupRepository,
  });

  bool _isActionLocked = false;

  // FORM KEYS & REACTIVE MODAL STATE
  final GlobalKey<FormState> bannerFormKey = GlobalKey<FormState>();
  final Rxn<int> editingBannerId = Rxn<int>();
  final RxBool isSubmitting = false.obs;
  final RxBool isDetailsEditing = false.obs;

  late final TextEditingController bnrTypeController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  final RxInt bannerStatus = 1.obs;

  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxnString selectedImageName = RxnString();
  final RxnString existingImageUrl = RxnString();

  final List<String> bannerTypeSuggestions = const <String>['home_slider', 'category_banner', 'deal_of_the_day', 'bottom_promo'];

  // =========================================================================
  // TARGET SELECTION STATE (OPTIONAL + MUTUAL EXCLUSIVE + CLEARABLE)
  // =========================================================================
  final RxBool isAllSelected = false.obs;
  final RxnString selectedTargetType = RxnString();
  final RxnString selectedTargetItemCode = RxnString();
  final RxnString selectedTargetItemName = RxnString();

  final List<String> targetTypeOptions = const ['Category', 'Subcategory', 'Brands', 'Group'];
  final RxList<Map<String, String>> currentTargetItems = <Map<String, String>>[].obs;
  final RxBool isLoadingItems = false.obs;
  final TextEditingController searchItemTextCtrl = TextEditingController();

  // 1. Toggle All Button (Tap karega toh All hoga, dubara tap karega toh unselect/empty ho jayega)
  void toggleAllTarget() {
    if (isAllSelected.value) {
      clearAllTargetSelections();
    } else {
      isAllSelected.value = true;
      selectedTargetType.value = null;
      selectedTargetItemCode.value = null;
      selectedTargetItemName.value = null;
      currentTargetItems.clear();
      searchItemTextCtrl.clear();
    }
  }

  // Pure target selection ko clear/empty karne ke liye
  void clearAllTargetSelections() {
    isAllSelected.value = false;
    selectedTargetType.value = null;
    selectedTargetItemCode.value = null;
    selectedTargetItemName.value = null;
    currentTargetItems.clear();
    searchItemTextCtrl.clear();
  }

  // 2. Dropdown 1 Selection Handler (All clear ho jayega)
  Future<void> onTargetTypeChanged(String? type) async {
    if (type == null) {
      clearAllTargetSelections();
      return;
    }
    isAllSelected.value = false;
    selectedTargetType.value = type;
    selectedTargetItemCode.value = null;
    selectedTargetItemName.value = null;
    searchItemTextCtrl.clear();

    await loadItemsFromRepository(type);
  }

  // 3. Dropdown 2 Selection Handler
  void onTargetItemSelected(String code, String name) {
    selectedTargetItemCode.value = code;
    selectedTargetItemName.value = name;
    searchItemTextCtrl.text = '$name ($code)';
  }

  // API Call to fetch Items from injected repositories
  Future<void> loadItemsFromRepository(String type) async {
    isLoadingItems.value = true;
    currentTargetItems.clear();
    try {
      if (type == 'Category') {
        final res = await _categoryRepository.viewCategories(limit: 100);
        final items = res.data.map((c) => {'code': c.igCode, 'name': c.igName}).toList();
        currentTargetItems.assignAll(items);
      } else if (type == 'Subcategory') {
        final res = await _subCategoryRepository.viewSubCategories(limit: 100);
        final items = res.data.map((sc) => {'code': sc.ogCode, 'name': sc.ogName}).toList();
        currentTargetItems.assignAll(items);
      } else if (type == 'Brands') {
        final res = await _brandRepository.viewBrands(limit: 100);
        final items = res.data.map((b) => {'code': b.mcCompCode, 'name': b.mcCompName}).toList();
        currentTargetItems.assignAll(items);
      } else if (type == 'Group') {
        final res = await _groupRepository.viewGroups();
        final items = res.data.map((g) => {'code': g.id.toString(), 'name': g.dgName}).toList();
        currentTargetItems.assignAll(items);
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'loadItemsFromRepository', {'type': type});
      errorMessage(message: 'Failed to load $type items.');
    } finally {
      isLoadingItems.value = false;
    }
  }

  // Table Server-Side Combination Filters
  final RxnString filterBnrType = RxnString();
  final RxnInt filterStatus = RxnInt();

  @override
  void onInit() {
    super.onInit();
    bnrTypeController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final int? idQuery = int.tryParse(searchQuery.value.trim());
        final String? typeQuery = idQuery == null && searchQuery.value.trim().isNotEmpty ? searchQuery.value.trim() : filterBnrType.value;
        final AppBannerResponseModel response = await _bannerRepository.getBanners(
          page: currentPage.value,
          limit: itemsPerPage.value,
          id: idQuery,
          bnrType: typeQuery,
          status: filterStatus.value,
        );
        if (isClosed) return;
        if (response.success) {
          setServerData(
            data: response.data,
            totalCount: response.pagination?.totalRecords ?? response.data.length,
            pageCount: response.pagination?.totalPages,
          );
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch banner list.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData');
        errorMessage(message: 'Failed to retrieve app banners from server.');
      }
    });
  }

  Future<void> refreshBanners() async => refreshData();

  void setDate({required String formattedDate, required bool isStart}) {
    if (isStart) {
      startDateController.text = formattedDate;
    } else {
      endDateController.text = formattedDate;
    }
  }

  void clearDateField({required bool isStart}) {
    if (isStart) {
      startDateController.clear();
    } else {
      endDateController.clear();
    }
  }

  Future<void> pickImageWeb() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp']);
      if (files.isEmpty) return;
      final PlatformFile file = files.first;
      final int fileSize = file.lengthSync() ?? await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        errorMessage(message: 'File size exceeds 5MB limit.');
        return;
      }
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;
      selectedImageBytes.value = bytes;
      selectedImageName.value = file.name;
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'pickImageWeb');
      errorMessage(message: 'Failed to pick image.');
    }
  }

  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = null;
  }

  void prefillForEdit(AppBannerDatum banner) {
    editingBannerId.value = banner.id;
    bnrTypeController.text = banner.bnrType;
    bannerStatus.value = banner.status;
    startDateController.text = banner.startDate ?? '';
    endDateController.text = banner.endDate ?? '';
    existingImageUrl.value = banner.bnrImg;
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    isDetailsEditing.value = false;

    // Check if banner target is specific prefix
    final cleanType = banner.bnrType.trim().toLowerCase();
    bool matched = false;
    for (final type in targetTypeOptions) {
      final prefix = '${type.toLowerCase()}_';
      if (cleanType.startsWith(prefix)) {
        final code = cleanType.replaceFirst(prefix, '').trim();
        isAllSelected.value = false;
        selectedTargetType.value = type;
        selectedTargetItemCode.value = code;
        selectedTargetItemName.value = code;
        searchItemTextCtrl.text = code;
        loadItemsFromRepository(type);
        matched = true;
        break;
      }
    }
    if (!matched) {
      clearAllTargetSelections();
    }
  }

  void resetForm() {
    editingBannerId.value = null;
    bnrTypeController.clear();
    startDateController.clear();
    endDateController.clear();
    bannerStatus.value = 1;
    existingImageUrl.value = null;
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    isDetailsEditing.value = false;

    // Default completely empty & unselected
    clearAllTargetSelections();
  }

  Future<bool> toggleBannerStatus(AppBannerDatum banner, bool newStatus) async {
    if (_isActionLocked) return false;
    _isActionLocked = true;
    final int targetStatus = newStatus ? 1 : 0;
    try {
      final SaveBannerResponseModel response = await _bannerRepository.saveBanner(
        id: banner.id,
        bnrType: banner.bnrType,
        status: targetStatus,
        startDate: banner.startDate,
        endDate: banner.endDate,
      );
      if (isClosed) return false;
      if (response.success) {
        successMessage(title: 'Status Updated', message: 'Banner #${banner.id} status updated successfully.');
        await refreshBanners();
        return true;
      }
      errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update status.');
      return false;
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'toggleBannerStatus');
      errorMessage(message: 'Error updating banner status.');
      return false;
    } finally {
      _isActionLocked = false;
    }
  }

  Future<void> uploadBannerImageFromTable(AppBannerDatum banner) async {
    if (_isActionLocked) return;
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp']);
      if (files.isEmpty) return;
      final PlatformFile file = files.first;
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;

      _isActionLocked = true;
      await runWithLoading(() async {
        final SaveBannerResponseModel response = await _bannerRepository.saveBanner(
          id: banner.id,
          bnrType: banner.bnrType,
          status: banner.status,
          imageBytes: bytes,
          imageName: file.name,
          startDate: banner.startDate,
          endDate: banner.endDate,
        );
        if (isClosed) return;
        if (response.success) {
          successMessage(title: 'Success', message: 'Banner #${banner.id} image updated.');
          await refreshBanners();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update image.');
        }
      });
    } finally {
      _isActionLocked = false;
    }
  }

  Future<bool> submitBanner() async {
    if (isSubmitting.value || _isActionLocked) return false;
    if (bannerFormKey.currentState == null || !bannerFormKey.currentState!.validate()) {
      return false;
    }
    if (editingBannerId.value == null && selectedImageBytes.value == null) {
      errorMessage(message: 'Please upload an image for the banner.');
      return false;
    }

    // Optional Check: Only validate if user selected a target type but skipped selecting an item
    if (selectedTargetType.value != null && (selectedTargetItemCode.value == null || selectedTargetItemCode.value!.isEmpty)) {
      errorMessage(message: 'Please select an item for ${selectedTargetType.value} or clear the selection.');
      return false;
    }

    _isActionLocked = true;
    isSubmitting.value = true;
    try {
      final SaveBannerResponseModel response = await _bannerRepository.saveBanner(
        id: editingBannerId.value,
        bnrType: bnrTypeController.text.trim(),
        status: bannerStatus.value,
        imageBytes: selectedImageBytes.value,
        imageName: selectedImageName.value,
        startDate: startDateController.text.trim().isNotEmpty ? startDateController.text.trim() : null,
        endDate: endDateController.text.trim().isNotEmpty ? endDateController.text.trim() : null,
      );
      if (isClosed) return false;
      if (response.success) {
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Banner saved successfully.');
        resetForm();
        await refreshBanners();
        return true;
      }
      errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save banner.');
      return false;
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitBanner');
      errorMessage(message: 'An error occurred while saving the banner.');
      return false;
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmitting.value = false;
    }
  }

  Future<bool> deleteBanner(AppBannerDatum banner) async {
    if (banner.id <= 0 || _isActionLocked) return false;
    _isActionLocked = true;
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _bannerRepository.deleteBanner(bannerId: banner.id);
        if (isClosed) return;
        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Banner deleted successfully.');
          await refreshBanners();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete banner.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteBanner');
        errorMessage(message: 'An error occurred while deleting the banner.');
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
        scope.setTag('controller', 'AppBannersController');
        scope.setContexts('banner_action', <String, dynamic>{'action': action, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    bnrTypeController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    searchItemTextCtrl.dispose();
    super.onClose();
  }
}
