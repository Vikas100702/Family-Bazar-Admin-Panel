import 'dart:ui' as ui;

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/repository/image_upload_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef EntityLinkCallback = Future<bool> Function({required String entityCode, required String webImageUrl, required String mobileImageUrl});

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

  static const ImageConstraintConfig websiteConstraints = ImageConstraintConfig(
    maxSizeBytes: 2 * 1024 * 1024,
    minWidth: 800,
    minHeight: 450,
    targetAspectRatio: 16 / 9,
    aspectRatioTolerance: 0.05,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    ratioDisplay: '16:9 (Min 800x450 px, Max 2MB)',
  );

  static const ImageConstraintConfig mobileConstraints = ImageConstraintConfig(
    maxSizeBytes: 1 * 1024 * 1024,
    minWidth: 300,
    minHeight: 300,
    targetAspectRatio: 1.0,
    aspectRatioTolerance: 0.05,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    ratioDisplay: '1:1 Square (Min 300x300 px, Max 1MB)',
  );

  // DYNAMIC ENTITY STATE
  final RxString targetEntityCode = ''.obs;
  final RxString uploadType = 'category'.obs; // 'category', 'subcategory', 'item', etc.

  // Custom Callbacks for saving and refreshing
  EntityLinkCallback? _onLinkEntity;
  VoidCallback? _onSuccess;

  void configureEntity({required String entityCode, required String type, EntityLinkCallback? onLinkEntity, VoidCallback? onSuccess}) {
    targetEntityCode.value = entityCode.trim();
    uploadType.value = type.trim().isEmpty ? 'category' : type.trim();
    _onLinkEntity = onLinkEntity;
    _onSuccess = onSuccess;
  }

  // IMAGE BUFFERS & STATES
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

      final String extension = (file.extension ?? '').toLowerCase();
      if (!config.allowedExtensions.contains(extension)) {
        final errorMsg = 'Invalid format: .$extension. Allowed: ${config.allowedExtensions.join(", ").toUpperCase()}';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      final int fileSize = file.lengthSync() ?? await file.length();
      if (fileSize > config.maxSizeBytes) {
        final double maxMb = config.maxSizeBytes / (1024 * 1024);
        final double actualMb = fileSize / (1024 * 1024);
        final errorMsg = 'File size (${actualMb.toStringAsFixed(2)}MB) exceeds limit of ${maxMb.toStringAsFixed(0)}MB.';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        const errorMsg = 'Selected file is empty or corrupted.';
        _setImageError(isMobile: isMobile, message: errorMsg);
        errorMessage(message: errorMsg);
        return;
      }

      final ui.Image decodedImage = await decodeImageFromList(bytes);
      final double width = decodedImage.width.toDouble();
      final double height = decodedImage.height.toDouble();
      final double actualRatio = width / height;
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
      // PHASE 1: Generic Binary Upload to /uploadImage
      // debugPrint('➡️ [PHASE 1 START] Uploading image (Type: "${uploadType.value}", Entity: "${targetEntityCode.value}")');

      final uploadResponse = await _imageUploadRepository.uploadImage(
        wImgBytes: webImageBytes.value,
        wImgFileName: webImageFileName.value,
        mImgBytes: mobileImageBytes.value,
        mImgFileName: mobileImageFileName.value,
        type: uploadType.value,
      );

      // debugPrint('========================================');
      // debugPrint('📸 [PHASE 1 RESPONSE - /uploadImage]');
      // debugPrint('Success : ${uploadResponse.success}');
      // debugPrint('Message : ${uploadResponse.message}');
      // debugPrint('Type    : ${uploadResponse.type}');
      // debugPrint('M-Img   : ${uploadResponse.mImg}');
      // debugPrint('W-Img   : ${uploadResponse.wImg}');
      // debugPrint('========================================');

      if (isClosed) return;

      if (!uploadResponse.success) {
        debugPrint('❌ [PHASE 1 FAILED]: ${uploadResponse.message}');
        errorMessage(message: uploadResponse.message.isNotEmpty ? uploadResponse.message : 'Failed to upload image binaries.');
        return;
      }

      uploadedMobileImageUrl.value = uploadResponse.mImg;
      uploadedWebImageUrl.value = uploadResponse.wImg;

      // PHASE 2: Generic Entity Association via Injected Callback
      if (_onLinkEntity != null) {
        // debugPrint('➡️ [PHASE 2 START] Delegating entity link for ${uploadType.value} (${targetEntityCode.value})');

        final bool isLinkedSuccessfully = await _onLinkEntity!(
          entityCode: targetEntityCode.value,
          webImageUrl: uploadResponse.wImg,
          mobileImageUrl: uploadResponse.mImg,
        );

        debugPrint('🔗 [PHASE 2 RESULT]: isLinkedSuccessfully = $isLinkedSuccessfully');

        if (isClosed) return;

        if (isLinkedSuccessfully) {
          uploadStatusMessage.value = 'Images successfully uploaded and linked.';
          successMessage(title: 'Operation Successful', message: 'Images linked successfully with ${uploadType.value.toUpperCase()}.');
          _onSuccess?.call(); // Trigger caller's refresh callback (e.g. refreshCategories)
          Get.back();
        } else {
          errorMessage(message: 'Images uploaded, but failed to link with ${uploadType.value} record.');
        }
      } else {
        // If no link callback passed, complete upload phase only
        successMessage(title: 'Upload Successful', message: 'Images uploaded successfully.');
        _onSuccess?.call();
        Get.back();
      }
    }, message: 'Uploading and Processing Images...');
  }

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
