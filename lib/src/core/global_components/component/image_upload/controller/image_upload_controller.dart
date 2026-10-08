import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/add_image_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/image_upload_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/repository/image_upload_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ImageUploadController extends BaseController {
  final ImageUploadRepository _imageUploadRepository;

  ImageUploadController({required this._imageUploadRepository});

  final RxString targetEntityCode = ''.obs;
  final RxString uploadType = ''.obs;
  VoidCallback? _onSuccess;

  // App & Web Primary Images
  final Rxn<Uint8List> webImageBytes = Rxn<Uint8List>();
  final Rxn<String> webImageFileName = Rxn<String>();
  final Rxn<Uint8List> mobileImageBytes = Rxn<Uint8List>();
  final Rxn<String> mobileImageFileName = Rxn<String>();

  // Secondary Images
  final RxList<Uint8List> secondaryBytesList = <Uint8List>[].obs;
  final RxList<String> secondaryFileNames = <String>[].obs;

  // Informational Images
  final RxList<Uint8List> informationBytesList = <Uint8List>[].obs;
  final RxList<String> informationFileNames = <String>[].obs;

  // Server URLs
  final RxString uploadedWebImageUrl = ''.obs;
  final RxString uploadedMobileImageUrl = ''.obs;
  final RxList<String> uploadedSecondaryUrls = <String>[].obs;
  final RxList<String> uploadedInformationUrls = <String>[].obs;

  final RxString uploadStatusMessage = ''.obs;

  void configureEntity({
    required String entityCode,
    required String type,
    VoidCallback? onSuccess,
    String? initialWebImageUrl,
    String? initialMobileImageUrl,
    List<String>? initialSecondaryUrls,
    List<String>? initialInformationUrls,
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
    if (secondaryBytesList.isEmpty && initialSecondaryUrls != null) {
      uploadedSecondaryUrls.assignAll(initialSecondaryUrls);
    }
    if (informationBytesList.isEmpty && initialInformationUrls != null) {
      uploadedInformationUrls.assignAll(initialInformationUrls);
    }
  }

  Future<void> pickMainImage({required bool isMobile}) async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'webp']);

      if (files.isEmpty) return;
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

      if (isMobile) {
        mobileImageBytes.value = bytes;
        mobileImageFileName.value = file.name;
      } else {
        webImageBytes.value = bytes;
        webImageFileName.value = file.name;
      }
    } catch (e) {
      errorMessage(message: 'Failed to pick image: $e');
    }
  }

  Future<void> pickMultipleImage({required bool isSecondary}) async {
    final int currentCount =
        (isSecondary ? uploadedSecondaryUrls.length : uploadedInformationUrls.length) +
        (isSecondary ? secondaryBytesList.length : informationBytesList.length);

    if (currentCount >= 5) {
      errorMessage(message: 'Max limit reached! You can only upload up to 5 images in this section.');
      return;
    }

    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'webp']);

      if (files.isEmpty) return;
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

      if (isSecondary) {
        secondaryBytesList.add(bytes);
        secondaryFileNames.add(file.name);
      } else {
        informationBytesList.add(bytes);
        informationFileNames.add(file.name);
      }
    } catch (e) {
      errorMessage(message: 'Failed to select image: $e');
    }
  }

  void removeImageAtIndex(int index, {required bool isSecondary}) {
    if (isSecondary) {
      if (index < secondaryBytesList.length) {
        secondaryBytesList.removeAt(index);
        secondaryFileNames.removeAt(index);
      }
    } else {
      if (index < informationBytesList.length) {
        informationBytesList.removeAt(index);
        informationFileNames.removeAt(index);
      }
    }
  }

  Future<void> uploadImages() async {
    if (targetEntityCode.value.isEmpty) {
      errorMessage(message: 'Entity Code is missing.');
      return;
    }

    await runWithLoading(() async {
      // Upload files to /uploadImage
      final ImageUploadModel uploadResponse = await _imageUploadRepository.uploadImage(
        wImgBytes: webImageBytes.value,
        wImgFileName: webImageFileName.value,
        mImgBytes: mobileImageBytes.value,
        mImgFileName: mobileImageFileName.value,
        secondaryBytesList: secondaryBytesList.isNotEmpty ? secondaryBytesList.toList() : null,
        secondaryFileNames: secondaryFileNames.isNotEmpty ? secondaryFileNames.toList() : null,
        informationBytesList: informationBytesList.isNotEmpty ? informationBytesList.toList() : null,
        informationFileNames: informationFileNames.isNotEmpty ? informationFileNames.toList() : null,
        type: uploadType.value.toLowerCase(),
      );

      if (isClosed) return;

      if (!uploadResponse.success) {
        errorMessage(message: uploadResponse.message.isNotEmpty ? uploadResponse.message : 'Failed to upload images.');
        return;
      }

      // Resolve Main Images
      final String resolvedMobImg = uploadResponse.mImg.isNotEmpty ? uploadResponse.mImg : uploadedMobileImageUrl.value;
      final String resolvedWebImg = uploadResponse.wImg.isNotEmpty ? uploadResponse.wImg : uploadedWebImageUrl.value;

      // Merge Secondary Images with Existing ones
      final List<String> mergedSecondary = List<String>.from(uploadedSecondaryUrls);
      if (uploadResponse.secondaryImages.isNotEmpty) {
        mergedSecondary.addAll(uploadResponse.secondaryImages);
      }

      // Merge Information Images with Existing ones
      final List<String> mergedInfo = List<String>.from(uploadedInformationUrls);
      if (uploadResponse.informationImages.isNotEmpty) {
        mergedInfo.addAll(uploadResponse.informationImages);
      }

      // 5. Link Images with /addImage
      final AddImageModel addImageResponse = await _imageUploadRepository.addImage(
        imgCode: targetEntityCode.value,
        imgType: uploadType.value,
        imgM: resolvedMobImg,
        imgW: resolvedWebImg,
        secondaryImages: mergedSecondary,
        informationImages: mergedInfo,
      );

      if (isClosed) return;

      if (addImageResponse.success) {
        uploadedMobileImageUrl.value = resolvedMobImg;
        uploadedWebImageUrl.value = resolvedWebImg;

        if (addImageResponse.data != null) {
          uploadedSecondaryUrls.assignAll(addImageResponse.data!.secondaryImages);
          uploadedInformationUrls.assignAll(addImageResponse.data!.informationImages);
        } else {
          uploadedSecondaryUrls.assignAll(mergedSecondary);
          uploadedInformationUrls.assignAll(mergedInfo);
        }

        // Clear in-memory local byte buffers so the UI renders the network images from the server instead
        secondaryBytesList.clear();
        secondaryFileNames.clear();
        informationBytesList.clear();
        informationFileNames.clear();
        webImageBytes.value = null;
        webImageFileName.value = null;
        mobileImageBytes.value = null;
        mobileImageFileName.value = null;

        Get.back();
        successMessage(title: 'Successful', message: addImageResponse.message);
        _onSuccess?.call();
      } else {
        errorMessage(message: addImageResponse.message);
      }
    }, message: 'Uploading Images...');
  }

  void clearImageBuffers() {
    webImageBytes.value = null;
    webImageFileName.value = null;
    mobileImageBytes.value = null;
    mobileImageFileName.value = null;

    secondaryBytesList.clear();
    secondaryFileNames.clear();
    informationBytesList.clear();
    informationFileNames.clear();
  }

  @override
  void onClose() {
    clearImageBuffers();
    super.onClose();
  }
}
