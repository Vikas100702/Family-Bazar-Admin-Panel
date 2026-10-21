import 'dart:typed_data';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/model/app_banners_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/repository/app_banners_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBannersController extends BaseServerTableController<AppBannerDatum> {
  final AppBannersRepository _bannerRepository;

  AppBannersController({required this._bannerRepository});

  bool _isActionLocked = false;

  // FORM KEYS & REACTIVE MODAL STATE
  final GlobalKey<FormState> bannerFormKey = GlobalKey<FormState>();
  final Rxn<int> editingBannerId = Rxn<int>();
  final RxBool isSubmitting = false.obs;
  final RxBool isDetailsEditing = false.obs;

  // FORM CONTROLLERS & DATA ANCHORS
  late final TextEditingController bnrTypeController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  final RxInt bannerStatus = 1.obs;

  // In Memory Byte Buffers (Web-Safe)
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxnString selectedImageName = RxnString();
  final RxnString existingImageUrl = RxnString();

  // Banner Type Suggestion Constants
  final List<String> bannerTypeSuggestions = const <String>['home_slider', 'category_banner', 'deal_of_the_day', 'bottom_promo'];

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

  // SERVER-SIDE DATA FETCHING
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
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch banner list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'query': searchQuery.value,
        });
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
      if (bytes.isEmpty) {
        errorMessage(message: 'Selected image contains no valid data bytes.');
        return;
      }

      selectedImageBytes.value = bytes;
      selectedImageName.value = file.name;
    } on UnimplementedError catch (e, stackTrace) {
      _logException(e, stackTrace, 'pickImageWeb.unimplemented');
      errorMessage(message: 'File picker web plugin is not registered. Please restart the web server.');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'pickImageWeb');
      errorMessage(message: 'Failed to pick image: $e');
    }
  }

  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = null;
  }

  // FORM & MODAL STATE PREFILLS
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
    startDateController.clear();
    endDateController.clear();
    bannerStatus.value = 1;
    existingImageUrl.value = null;
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    isDetailsEditing.value = false;
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
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update status.');
        return false;
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'toggleBannerStatus', <String, dynamic>{'banner_id': banner.id, 'status': targetStatus});
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

      final int fileSize = file.lengthSync() ?? await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        errorMessage(message: 'File size exceeds 5MB limit.');
        return;
      }

      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        errorMessage(message: 'Selected image contains no valid data bytes.');
        return;
      }

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
          successMessage(title: 'Success', message: 'Banner #${banner.id} image updated successfully.');
          await refreshBanners();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to update banner image.');
        }
      }, message: 'Updating Banner Image...');
    } on UnimplementedError catch (e, stackTrace) {
      _logException(e, stackTrace, 'uploadBannerImageFromTable.unimplemented');
      errorMessage(message: 'File picker web plugin is not registered. Please restart the web server.');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'uploadBannerImageFromTable', <String, dynamic>{'banner_id': banner.id});
      errorMessage(message: 'Failed to upload banner image: $e');
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

    final String start = startDateController.text.trim();
    final String end = endDateController.text.trim();
    if (start.isNotEmpty && end.isNotEmpty) {
      final DateTime? startDate = DateTime.tryParse(start);
      final DateTime? endDate = DateTime.tryParse(end);
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        errorMessage(message: 'Start date cannot be after end date.');
        return false;
      }
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
        startDate: start.isNotEmpty ? start : null,
        endDate: end.isNotEmpty ? end : null,
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
      _logException(e, stackTrace, 'submitBanner', <String, dynamic>{'id': editingBannerId.value, 'bnr_type': bnrTypeController.text.trim()});
      errorMessage(message: 'An error occurred while saving the banner.');
      return false;
    } finally {
      _isActionLocked = false;
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }

  Future<bool> deleteBanner(AppBannerDatum banner) async {
    if (banner.id <= 0) {
      errorMessage(message: 'Invalid banner ID.');
      return false;
    }

    if (_isActionLocked) return false;
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
        _logException(e, stackTrace, 'deleteBanner', <String, dynamic>{'banner_id': banner.id});
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
        scope.setContexts('banner_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    bnrTypeController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    selectedImageBytes.value = null;
    selectedImageName.value = null;
    existingImageUrl.value = null;
    editingBannerId.value = null;
    super.onClose();
  }
}
