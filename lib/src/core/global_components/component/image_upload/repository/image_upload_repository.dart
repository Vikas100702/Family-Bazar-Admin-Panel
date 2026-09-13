import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
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
    required String type, // 'category', 'subcategory', 'item', etc.
  }) async {
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Initiating multipart image binary upload for type: $type',
          category: 'media.upload',
          level: SentryLevel.info,
          data: {'has_mobile_bytes': mImgBytes != null && mImgBytes.isNotEmpty, 'has_web_bytes': wImgBytes != null && wImgBytes.isNotEmpty},
        ),
      );
      if ((mImgBytes == null || mImgBytes.isEmpty) && (wImgBytes == null || wImgBytes.isEmpty)) {
        throw ArgumentError('At least one image (mobile or web) is required.');
      }

      final Map<String, dynamic> formMap = {'type': type};

      if (mImgBytes != null && mImgBytes.isNotEmpty) {
        formMap['m_img'] = MultipartFile.fromBytes(mImgBytes, filename: mImgFileName ?? '${type}_m_img.png');
      }

      if (wImgBytes != null && wImgBytes.isNotEmpty) {
        formMap['w_img'] = MultipartFile.fromBytes(wImgBytes, filename: wImgFileName ?? '${type}_w_img.jpg');
      }

      final formData = FormData.fromMap(formMap);
      final response = await _apiClient.dio.post(ApiConstants.uploadImgApiEndpoint, data: formData);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> rawData = response.data as Map<String, dynamic>;

        final Map<String, dynamic> normalizedData = {
          ...rawData,
          'cat_m_img': rawData['m_img'] ?? rawData['cat_m_img'] ?? '',
          'cat_w_img': rawData['w_img'] ?? rawData['cat_w_img'] ?? '',
          'm_img': rawData['m_img'] ?? rawData['cat_m_img'] ?? '',
          'w_img': rawData['w_img'] ?? rawData['cat_w_img'] ?? '',
        };

        return ImageUploadModel.fromJson(normalizedData);
      }

      throw const FormatException('Invalid data format received from server. Expected JSON Map.');
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('layer', 'image_upload_repository');
          scope.setTag('endpoint', ApiConstants.uploadImgApiEndpoint);
          scope.setTag('upload_type', type);
          scope.setContexts('upload_meta', {'m_filename': mImgFileName, 'w_filename': wImgFileName});
        },
      );
      debugPrint('--- [IMAGE UPLOAD REPOSITORY] Upload failed: $e ---');
      rethrow;
    }
  }
}
