import 'dart:typed_data';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/model/app_banners_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/repository/app_banners_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBannersController extends BaseServerTableController<AppBannerDatum> {
  final AppBannersRepository _bannerRepository;

  AppBannersController({required AppBannersRepository bannerRepository}) : _bannerRepository = bannerRepository;

  // Form Keys & State Management
  final GlobalKey<FormState> bannerFormKey = GlobalKey<FormState>();
  final Rxn<int> editingBannerId = Rxn<int>();
  final RxBool isSubmitting = false.obs;
  final RxBool isDetailsEditing = false.obs;

  // Form Fields & Controllers
  late final TextEditingController bnrTypeController;
  late final TextEditingController startAtController;
  late final TextEditingController endAtController;
  final RxInt bannerStatus = 1.obs;

  // In-Memory Byte Buffers for Form Modal
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxnString selectedImageName = RxnString();
  final RxnString existingImageUrl = RxnString();

  // Banner Type Options
  final List<String> bannerTypeSuggestions = const ['home_slider', 'category_banner', 'deal_of_the_day', 'bottom_promo'];

  // Search & Combination Filters
  final RxnString filterBnrType = RxnString();
  final RxnInt filterStatus = RxnInt();

  @override
  void onInit() {
    super.onInit();
    bnrTypeController = TextEditingController();
    startAtController = TextEditingController();
    endAtController = TextEditingController();
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
        _logException(e, stackTrace, 'fetchServerData', {'page': currentPage.value, 'limit': itemsPerPage.value, 'query': searchQuery.value});
        errorMessage(message: 'Failed to retrieve app banners from server.');
      }
    });
  }

  Future<void> refreshBanners() async => refreshData();

  void applyFilter({String? bnrType, int? status}) {
    filterBnrType.value = bnrType;
    filterStatus.value = status;
    currentPage.value = 1;
    fetchServerData();
  }

  void clearFilters() {
    filterBnrType.value = null;
    filterStatus.value = null;
    clearSearch();
  }

  /// Date picker adhering strictly to 'YYYY-MM-DD' contract
  Future<void> pickDate({required BuildContext context, required bool isStart}) async {
    final DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(2020), lastDate: DateTime(2040));

    if (picked == null || !context.mounted) return;

    final String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
    if (isStart) {
      startAtController.text = formattedDate;
    } else {
      endAtController.text = formattedDate;
    }
  }

  void clearDateField({required bool isStart}) {
    if (isStart) {
      startAtController.clear();
    } else {
      endAtController.clear();
    }
  }

  /// Web-safe Image Picker for dialog form modal
  Future<void> pickImageWeb() async {
    try {
      final List<PlatformFile>? files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp']);

      if (files == null || files.isEmpty) return;
      final PlatformFile file = files.first;

      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        errorMessage(message: 'Selected image contains no valid data bytes.');
        return;
      }

      if (bytes.length > 5 * 1024 * 1024) {
        errorMessage(message: 'File size exceeds 5MB limit.');
        return;
      }

      selectedImageBytes.value = bytes;
      selectedImageName.value = file.name;
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'pickImageWeb');
      errorMessage(message: 'Failed to pick image: $e');
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
    startAtController.text = banner.startAt ?? '';
    endAtController.text = banner.endAt ?? '';
    existingImageUrl.value = banner.bnrImg;
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    isDetailsEditing.value = false;
  }

  void enableDetailsEditMode(AppBannerDatum banner) {
    prefillForEdit(banner);
    isDetailsEditing.value = true;
  }

  void cancelDetailsEditMode() {
    isDetailsEditing.value = false;
    clearSelectedImage();
  }

  void resetForm() {
    editingBannerId.value = null;
    bnrTypeController.clear();
    startAtController.clear();
    endAtController.clear();
    bannerStatus.value = 1;
    existingImageUrl.value = null;
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    isDetailsEditing.value = false;
  }

  /// Inline status toggle directly via the single saveBanner API
  Future<bool> toggleBannerStatus(AppBannerDatum banner, bool newStatus) async {
    final int targetStatus = newStatus ? 1 : 0;
    try {
      final SaveBannerResponseModel response = await _bannerRepository.saveBanner(
        id: banner.id,
        bnrType: banner.bnrType,
        status: targetStatus,
        startAt: banner.startAt,
        endAt: banner.endAt,
      );

      if (isClosed) return false;

      if (response.success) {
        successMessage(title: 'Status Updated', message: 'Banner #${banner.id} status updated successfully.');
        await refreshBanners();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update status.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'toggleBannerStatus', {'banner_id': banner.id, 'status': targetStatus});
      errorMessage(message: 'Error updating banner status.');
      return false;
    }
  }

  /// Directly picks and updates image from Table row using the same single saveBanner API
  Future<void> uploadBannerImageFromTable(AppBannerDatum banner) async {
    try {
      final List<PlatformFile>? files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp']);

      if (files == null || files.isEmpty) return;
      final PlatformFile file = files.first;

      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        errorMessage(message: 'Selected image contains no valid data bytes.');
        return;
      }

      if (bytes.length > 5 * 1024 * 1024) {
        errorMessage(message: 'File size exceeds 5MB limit.');
        return;
      }

      await runWithLoading(() async {
        final SaveBannerResponseModel response = await _bannerRepository.saveBanner(
          id: banner.id,
          bnrType: banner.bnrType,
          status: banner.status,
          imageBytes: bytes,
          imageName: file.name,
          startAt: banner.startAt,
          endAt: banner.endAt,
        );

        if (isClosed) return;

        if (response.success) {
          successMessage(title: 'Success', message: 'Banner #${banner.id} image updated successfully.');
          await refreshBanners();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update banner image.');
        }
      }, message: 'Updating Banner Image...');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'uploadBannerImageFromTable', {'banner_id': banner.id});
      errorMessage(message: 'Failed to upload banner image: $e');
    }
  }

  /// Submits Add or Edit form modal via the single saveBanner API
  Future<bool> submitBanner() async {
    if (!bannerFormKey.currentState!.validate()) return false;

    if (editingBannerId.value == null && selectedImageBytes.value == null) {
      errorMessage(message: 'Please upload an image for the banner.');
      return false;
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

    isSubmitting.value = true;

    try {
      final SaveBannerResponseModel response = await _bannerRepository.saveBanner(
        id: editingBannerId.value,
        bnrType: bnrTypeController.text.trim(),
        status: bannerStatus.value,
        imageBytes: selectedImageBytes.value,
        imageName: selectedImageName.value,
        startAt: start.isNotEmpty ? start : null,
        endAt: end.isNotEmpty ? end : null,
      );

      if (isClosed) return false;

      if (response.success) {
        final String action = editingBannerId.value != null ? 'updated' : 'added';
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Banner $action successfully.');
        resetForm();
        await refreshBanners();
        return true;
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to save banner.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitBanner', {'id': editingBannerId.value, 'bnr_type': bnrTypeController.text.trim()});
      errorMessage(message: 'An error occurred while saving the banner.');
      return false;
    } finally {
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }

  /// Deletes a banner entry using common system endpoint
  Future<bool> deleteBanner(AppBannerDatum banner) async {
    if (banner.id <= 0) {
      errorMessage(message: 'Invalid banner ID.');
      return false;
    }

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
        _logException(e, stackTrace, 'deleteBanner', {'banner_id': banner.id});
        errorMessage(message: 'An error occurred while deleting the banner.');
      }
    });

    return isSuccess;
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'AppBannersController');
        scope.setContexts('banner_action', {'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    bnrTypeController.dispose();
    startAtController.dispose();
    endAtController.dispose();
    selectedImageBytes.value = null;
    super.onClose();
  }
}
