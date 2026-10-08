import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/add_image_model.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/model/image_upload_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ImageUploadRepository {
  final ApiClient _apiClient;
  const ImageUploadRepository({required this._apiClient});

  Future<ImageUploadModel> uploadImage({
    Uint8List? mImgBytes,
    String? mImgFileName,
    Uint8List? wImgBytes,
    String? wImgFileName,
    List<Uint8List>? secondaryBytesList,
    List<String>? secondaryFileNames,
    List<Uint8List>? informationBytesList,
    List<String>? informationFileNames,
    required String type,
  }) async {
    try {
      final Map<String, dynamic> formMap = {'type': type};

      if (mImgBytes != null && mImgBytes.isNotEmpty) {
        formMap['m_img'] = MultipartFile.fromBytes(mImgBytes, filename: mImgFileName ?? '${type}_m_img.png');
      }

      if (wImgBytes != null && wImgBytes.isNotEmpty) {
        formMap['w_img'] = MultipartFile.fromBytes(wImgBytes, filename: wImgFileName ?? '${type}_w_img.jpg');
      }

      // Handle Secondary Images Array
      if (secondaryBytesList != null && secondaryBytesList.isNotEmpty) {
        final List<MultipartFile> secondaryFiles = [];
        for (int i = 0; i < secondaryBytesList.length; i++) {
          final filename = (secondaryFileNames != null && secondaryFileNames.length > i) ? secondaryFileNames[i] : '${type}_secondary_$i.png';
          secondaryFiles.add(MultipartFile.fromBytes(secondaryBytesList[i], filename: filename));
        }
        formMap['secondary_img'] = secondaryFiles;
      }

      // Handle Information Images Array
      if (informationBytesList != null && informationBytesList.isNotEmpty) {
        final List<MultipartFile> infoFiles = [];
        for (int i = 0; i < informationBytesList.length; i++) {
          final filename = (informationFileNames != null && informationFileNames.length > i) ? informationFileNames[i] : '${type}_info_$i.png';
          infoFiles.add(MultipartFile.fromBytes(informationBytesList[i], filename: filename));
        }
        formMap['information_img'] = infoFiles;
      }

      final formData = FormData.fromMap(formMap);
      final response = await _apiClient.dio.post(ApiConstants.uploadImgApiEndpoint, data: formData);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ImageUploadModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const FormatException('Invalid data format received from server.');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('--- [IMAGE UPLOAD REPOSITORY] Upload failed: $e ---');
      rethrow;
    }
  }

  Future<AddImageModel> addImage({
    required String imgCode,
    required String imgType,
    required String imgM,
    required String imgW,
    List<String>? secondaryImages,
    List<String>? informationImages,
  }) async {
    final Map<String, dynamic> payload = {
      'ItemCode': imgCode.trim(),
      'ItemType': imgType.trim().toUpperCase(),
      'ImageMob': imgM.trim(),
      'ImageWeb': imgW.trim(),
      'SecondryImage': secondaryImages ?? [],
      'Imformation': informationImages ?? [],
    };

    try {
      final response = await _apiClient.dio.post(ApiConstants.addImgApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        return AddImageModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('Invalid response format received from /addImage.');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('--- [IMAGE UPLOAD REPOSITORY] Link Image failed: $e ---');
      rethrow;
    }
  }
}
