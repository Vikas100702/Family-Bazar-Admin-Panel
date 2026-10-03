/*
import 'dart:ui' as ui;

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/add_image_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/image_upload_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/repository/image_upload_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Immutable configuration defining aspect ratio, resolution, and size constraints.
class ImageConstraintConfig {
  final int maxSizeBytes;
  final double minWidth;
  final double minHeight;
  final double targetAspectRatio;
  final double aspectRatioTolerance;
  final List<String> allowedExtensions;
  final String ratioDisplay;

  const ImageConstraintConfig({
    required this.maxSizeBytes,
    required this.minWidth,
    required this.minHeight,
    required this.targetAspectRatio,
    required this.aspectRatioTolerance,
    required this.allowedExtensions,
    required this.ratioDisplay,
  });
}

class ImageUploadController extends BaseController {
  final ImageUploadRepository _imageUploadRepository;
  ImageUploadController({required this._imageUploadRepository});

  // STRICT PLATFORM IMAGE CONSTRAINTS (WEB / DESKTOP / MOBILE COMPLIANT)
  static const ImageConstraintConfig websiteConstraints = ImageConstraintConfig(
    maxSizeBytes: 2 * 1024 * 1024, // 2 megabytes
    minWidth: 800,
    minHeight: 450,
    targetAspectRatio: 16 / 9,
    aspectRatioTolerance: 0.05,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    ratioDisplay: '16:9 Banner (Min 800x450 px, Max 2MB)',
  );

  static const ImageConstraintConfig mobileConstraints = ImageConstraintConfig(
    maxSizeBytes: 1 * 1024 * 1024, // 1 megabyte
    minWidth: 300,
    minHeight: 300,
    targetAspectRatio: 1.0,
    aspectRatioTolerance: 0.05,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    ratioDisplay: '1:1 Square (Min 300x300 px, Max 1MB)',
  );

  final RxString targetEntityCode = ''.obs;
  final RxString uploadType = ''.obs; // e.g. 'ITEM', 'CATEGORY', 'BRAND'

  VoidCallback? _onSuccess;

  /// Synchronizes entity context when dialog mounts
  void configureEntity({
    required String entityCode,
    required String type,
    VoidCallback? onSuccess,
    String? initialWebImageUrl,
    String? initialMobileImageUrl,
  }) {
    targetEntityCode.value = entityCode.trim();
    uploadType.value = type.trim().isEmpty ? 'ITEM' : type.trim().toUpperCase();
    _onSuccess = onSuccess;

    if (webImageBytes.value == null) {
      uploadedWebImageUrl.value = initialWebImageUrl?.trim() ?? '';
    }
    if (mobileImageBytes.value == null) {
      uploadedMobileImageUrl.value = initialMobileImageUrl?.trim() ?? '';
    }
  }

  // IN-MEMORY BYTE BUFFERS & REACTIVE UI STATES
  final Rxn<Uint8List> webImageBytes = Rxn<Uint8List>();
  final Rxn<String> webImageFileName = Rxn<String>();
  final RxString webImageError = ''.obs;

  final Rxn<Uint8List> mobileImageBytes = Rxn<Uint8List>();
  final Rxn<String> mobileImageFileName = Rxn<String>();
  final RxString mobileImageError = ''.obs;

  final RxString uploadedWebImageUrl = ''.obs;
  final RxString uploadedMobileImageUrl = ''.obs;
  final RxString uploadStatusMessage = ''.obs;

  Future<void> pickImage({required bool isMobile}) async {
    final ImageConstraintConfig config = isMobile ? mobileConstraints : websiteConstraints;
    _setImageError(isMobile: isMobile, message: '');

    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: config.allowedExtensions);

      if (files.isEmpty) return;
      final PlatformFile file = files.first;

      // Extension Verification
      final String extension = (file.extension ?? '').toLowerCase();
      if (!config.allowedExtensions.contains(extension)) {
        final errorMsg = 'Invalid format: .$extension. Allowed: ${config.allowedExtensions.join(", ").toUpperCase()}';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      // File Size Verification
      final int fileSize = file.lengthSync() ?? await file.length();
      if (fileSize > config.maxSizeBytes) {
        final double maxMb = config.maxSizeBytes / (1024 * 1024);
        final double actualMb = fileSize / (1024 * 1024);
        final errorMsg = 'File size (${actualMb.toStringAsFixed(2)}MB) exceeds limit of ${maxMb.toStringAsFixed(0)}MB.';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      // in-memory Bytes Extraction
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        const errorMsg = 'Selected file is empty or corrupted.';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      // Pixel Dimension & Ratio Verification
      final ui.Image decodedImage = await decodeImageFromList(bytes);
      final double width = decodedImage.width.toDouble();
      final double height = decodedImage.height.toDouble();
      final double actualRatio = width / height;

      // Release image memory immediately after getting dimensions
      decodedImage.dispose();

      if (width < config.minWidth || height < config.minHeight) {
        final errorMsg = 'Resolution too low (${width.toInt()}x${height.toInt()}px). Min: ${config.minWidth.toInt()}x${config.minHeight.toInt()}px.';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      final double ratioDiff = (actualRatio - config.targetAspectRatio).abs();
      if (ratioDiff > config.aspectRatioTolerance) {
        final errorMsg = 'Invalid aspect ratio (${actualRatio.toStringAsFixed(2)}:1). Required: ${config.ratioDisplay}.';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      if (isClosed) return;

      if (isMobile) {
        mobileImageBytes.value = bytes;
        mobileImageFileName.value = file.name;
        mobileImageError.value = '';
      } else {
        webImageBytes.value = bytes;
        webImageFileName.value = file.name;
        webImageError.value = '';
      }
    } on UnimplementedError catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      const errorMsg = 'File picker web plugin is not registered. Please reload the page.';
      _setImageError(isMobile: isMobile, message: errorMsg);
      errorMessage(message: errorMsg);
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      final errorMsg = 'Failed to validate image: ${e.toString()}';
      _setImageError(isMobile: isMobile, message: errorMsg);
      errorMessage(message: errorMsg);
    }
  }

  void _setImageError({required bool isMobile, required String message}) {
    if (isMobile) {
      mobileImageError.value = message;
    } else {
      webImageError.value = message;
    }
  }

  /// 1. Upload images to server -> 2. Add them to their respective entity
  Future<void> uploadImages() async {
    final bool hasWebImage = webImageBytes.value != null && webImageBytes.value!.isNotEmpty;
    final bool hasMobileImage = mobileImageBytes.value != null && mobileImageBytes.value!.isNotEmpty;

    if (!hasWebImage && !hasMobileImage) {
      errorMessage(message: 'Please select at least one valid image to upload.');
      return;
    }

    if (targetEntityCode.value.isEmpty) {
      errorMessage(message: 'Entity Code is missing. Please reopen the dialog.');
      return;
    }

    await runWithLoading(() async {
      //  Multipart Binary Upload (/uploadImage)
      final ImageUploadModel uploadResponse = await _imageUploadRepository.uploadImage(
        wImgBytes: webImageBytes.value,
        wImgFileName: webImageFileName.value,
        mImgBytes: mobileImageBytes.value,
        mImgFileName: mobileImageFileName.value,
        type: uploadType.value.toLowerCase(),
      );

      if (isClosed) return;

      if (!uploadResponse.success) {
        debugPrint('[PHASE 1 FAILED]: ${uploadResponse.message}');
        errorMessage(message: uploadResponse.message.isNotEmpty ? uploadResponse.message : 'Failed to upload image binaries.');
        return;
      }

      // Preserve existing URLs if only one image is being uploaded
      final String resolvedMobImg = uploadResponse.mImg.isNotEmpty ? uploadResponse.mImg : uploadedMobileImageUrl.value;

      final String resolvedWebImg = uploadResponse.wImg.isNotEmpty ? uploadResponse.wImg : uploadedWebImageUrl.value;

      uploadedMobileImageUrl.value = resolvedMobImg;
      uploadedWebImageUrl.value = resolvedWebImg;

      // Link the uploaded images to their specific entity
      final AddImageModel addImageResponse = await _imageUploadRepository.addImage(
        imgCode: targetEntityCode.value,
        imgType: uploadType.value,
        imgM: resolvedMobImg,
        imgW: resolvedWebImg,
      );

      if (isClosed) return;

      final String backendMsg = addImageResponse.message.trim().isNotEmpty
          ? addImageResponse.message.trim()
          : (addImageResponse.success ? 'Image processed successfully.' : 'Failed to link image with record.');

      if (addImageResponse.success) {
        uploadStatusMessage.value = backendMsg;
        Get.back(); // Dismiss dialog to prevent UI stacking/freezing issues
        successMessage(
          title: 'Successful',
          message: backendMsg, // Displays the exact message from the server
        );
        _onSuccess?.call(); // Trigger parent view refresh
      } else {
        errorMessage(message: backendMsg);
      }
    }, message: 'Uploading and Linking Images...');
  }

  /// Prevents memory leaks by clearing in-memory buffers
  void clearImageBuffers() {
    webImageBytes.value = null;
    webImageFileName.value = null;
    webImageError.value = '';

    mobileImageBytes.value = null;
    mobileImageFileName.value = null;
    mobileImageError.value = '';
  }

  @override
  void onClose() {
    clearImageBuffers();
    super.onClose();
  }
}
*/

import 'dart:ui' as ui;

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/add_image_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/image_upload_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/repository/image_upload_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Represents a single dynamic image item slot in the gallery list.
class DynamicImageSlot {
  final String id;
  Rxn<Uint8List> bytes;
  Rxn<String> fileName;
  RxString error;
  RxString uploadedUrl;
  String slotType; // e.g., 'mobile', 'web', 'ingredient', 'nutrition', 'gallery'

  DynamicImageSlot({
    required this.id,
    Uint8List? initialBytes,
    String? initialFileName,
    String? initialError,
    String? initialUrl,
    required this.slotType,
  }) : bytes = Rxn<Uint8List>(initialBytes),
       fileName = Rxn<String>(initialFileName),
       error = RxString(initialError ?? ''),
       uploadedUrl = RxString(initialUrl ?? '');
}

class ImageUploadController extends BaseController {
  final ImageUploadRepository _imageUploadRepository;
  ImageUploadController({required this._imageUploadRepository});

  final RxString targetEntityCode = ''.obs;
  final RxString uploadType = ''.obs;
  VoidCallback? _onSuccess;

  // Dynamic list of image slots supporting unlimited images
  final RxList<DynamicImageSlot> imageSlots = <DynamicImageSlot>[].obs;
  final RxString uploadStatusMessage = ''.obs;

  /// Synchronizes entity context and initializes default slots (Mobile & Web) + any initial extra images
  void configureEntity({
    required String entityCode,
    required String type,
    VoidCallback? onSuccess,
    String? initialWebImageUrl,
    String? initialMobileImageUrl,
    List<String>? initialGalleryUrls,
  }) {
    targetEntityCode.value = entityCode.trim();
    uploadType.value = type.trim().isEmpty ? 'ITEM' : type.trim().toUpperCase();
    _onSuccess = onSuccess;

    if (imageSlots.isEmpty) {
      // Default core slots
      imageSlots.add(DynamicImageSlot(id: 'mobile_slot', initialUrl: initialMobileImageUrl, slotType: 'mobile'));
      imageSlots.add(DynamicImageSlot(id: 'web_slot', initialUrl: initialWebImageUrl, slotType: 'web'));

      // If there are existing extra/gallery images, load them dynamically
      if (initialGalleryUrls != null && initialGalleryUrls.isNotEmpty) {
        for (int i = 0; i < initialGalleryUrls.length; i++) {
          imageSlots.add(
            DynamicImageSlot(id: 'gallery_${DateTime.now().millisecondsSinceEpoch}_$i', initialUrl: initialGalleryUrls[i], slotType: 'gallery'),
          );
        }
      }
    }
  }

  /// Adds a new empty slot for uploading an additional image (e.g., ingredient, nutrition, extra angle)
  void addNewSlot({String slotType = 'gallery'}) {
    imageSlots.add(DynamicImageSlot(id: 'slot_${DateTime.now().millisecondsSinceEpoch}', slotType: slotType));
  }

  /// Removes an image slot by its unique ID
  void removeSlot(String id) {
    if (imageSlots.length <= 1) {
      errorMessage(message: 'At least one image slot is required.');
      return;
    }
    imageSlots.removeWhere((slot) => slot.id == id);
  }

  /// Picks and validates an image file for a specific slot
  Future<void> pickImageForSlot(DynamicImageSlot slot) async {
    slot.error.value = '';
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'webp']);
      if (files.isEmpty) return;
      final PlatformFile file = files.first;

      // Extension Check
      final String extension = (file.extension ?? '').toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        final errorMsg = 'Invalid format: .$extension. Allowed: JPG, PNG, WEBP';
        slot.error.value = errorMsg;
        errorMessage(message: errorMsg);
        return;
      }

      // File Size Check (Max 2MB)
      final int fileSize = file.lengthSync() ?? await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        const errorMsg = 'File size exceeds limit of 2MB.';
        slot.error.value = errorMsg;
        errorMessage(message: errorMsg);
        return;
      }

      // Bytes Extraction
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        const errorMsg = 'Selected file is empty or corrupted.';
        slot.error.value = errorMsg;
        errorMessage(message: errorMsg);
        return;
      }

      // Dimension Check
      final ui.Image decodedImage = await decodeImageFromList(bytes);
      final double width = decodedImage.width.toDouble();
      final double height = decodedImage.height.toDouble();
      decodedImage.dispose();

      if (width < 300 || height < 300) {
        const errorMsg = 'Resolution too low. Min: 300x300 px.';
        slot.error.value = errorMsg;
        errorMessage(message: errorMsg);
        return;
      }

      if (isClosed) return;
      slot.bytes.value = bytes;
      slot.fileName.value = file.name;
      slot.error.value = '';
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      slot.error.value = 'Failed to load image.';
      errorMessage(message: 'Failed to pick image: $e');
    }
  }

  /// Uploads all populated slots to the server sequentially or as a batch
  Future<void> uploadImages() async {
    final bool hasSelection = imageSlots.any(
      (slot) => (slot.bytes.value != null && slot.bytes.value!.isNotEmpty) || slot.uploadedUrl.value.isNotEmpty,
    );
    if (!hasSelection) {
      errorMessage(message: 'Please select at least one valid image to upload.');
      return;
    }
    if (targetEntityCode.value.isEmpty) {
      errorMessage(message: 'Entity Code is missing. Please reopen the dialog.');
      return;
    }

    await runWithLoading(() async {
      // Prepare maps for repository upload
      final Map<String, Uint8List> bytesMap = {};
      final Map<String, String> nameMap = {};

      for (int i = 0; i < imageSlots.length; i++) {
        final slot = imageSlots[i];
        if (slot.bytes.value != null && slot.bytes.value!.isNotEmpty) {
          final key = '${slot.slotType}_$i';
          bytesMap[key] = slot.bytes.value!;
          nameMap[key] = slot.fileName.value ?? 'image_$i.png';
        }
      }

      // Upload binaries via repository
      final ImageUploadModel uploadResponse = await _imageUploadRepository.uploadImages(
        imageBytesMap: bytesMap,
        fileNameMap: nameMap,
        type: uploadType.value.toLowerCase(),
      );

      if (isClosed) return;
      if (!uploadResponse.success) {
        errorMessage(message: uploadResponse.message.isNotEmpty ? uploadResponse.message : 'Failed to upload image binaries.');
        return;
      }

      // Resolve primary URLs for backend linking
      String mobImg = '';
      String webImg = '';
      final List<String> extraImgs = [];

      for (var slot in imageSlots) {
        if (slot.slotType == 'mobile' && slot.uploadedUrl.value.isNotEmpty) {
          mobImg = slot.uploadedUrl.value;
        } else if (slot.slotType == 'web' && slot.uploadedUrl.value.isNotEmpty) {
          webImg = slot.uploadedUrl.value;
        } else if (slot.uploadedUrl.value.isNotEmpty) {
          extraImgs.add(slot.uploadedUrl.value);
        }
      }

      // Link images with entity
      final AddImageModel addImageResponse = await _imageUploadRepository.addImage(
        imgCode: targetEntityCode.value,
        imgType: uploadType.value,
        imagesMap: {'ImageMob': mobImg, 'ImageWeb': webImg, if (extraImgs.isNotEmpty) 'ExtraImages': extraImgs.join(',')},
      );

      if (isClosed) return;
      final String backendMsg = addImageResponse.message.trim().isNotEmpty
          ? addImageResponse.message.trim()
          : (addImageResponse.success ? 'Images processed successfully.' : 'Failed to link images.');

      if (addImageResponse.success) {
        uploadStatusMessage.value = backendMsg;
        Get.back();
        successMessage(title: 'Successful', message: backendMsg);
        _onSuccess?.call();
      } else {
        errorMessage(message: backendMsg);
      }
    }, message: 'Uploading and Linking Images...');
  }

  void clearImageBuffers() {
    for (var slot in imageSlots) {
      slot.bytes.value = null;
      slot.fileName.value = null;
      slot.error.value = '';
    }
  }

  @override
  void onClose() {
    clearImageBuffers();
    super.onClose();
  }
}
