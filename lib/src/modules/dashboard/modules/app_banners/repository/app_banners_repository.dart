import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/mixins/common_delete_mixin.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/model/app_banners_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBannersRepository with CommonDeleteMixin {
  final ApiClient _apiClient;
  const AppBannersRepository({required this._apiClient});

  @override
  ApiClient get apiClient => _apiClient;

  Future<AppBannerResponseModel> getBanners({int page = 1, int limit = 50, int? id, String? bnrType, int? status}) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (id != null && id > 0) 'id': id,
      if (bnrType != null && bnrType.trim().isNotEmpty) 'bnr_type': bnrType.trim(),
      'status': ?status,
      'isAdmin': 1,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(ApiConstants.viewBannersApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AppBannerResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[AppBannersRepository.getBanners]: Unexpected response format received from ${ApiConstants.viewBannersApiEndpoint}');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'getBanners', payload);
      rethrow;
    }
  }

  /// Creates or updates a banner entry using multipart upload.
  Future<SaveBannerResponseModel> saveBanner({
    int? id,
    required String bnrType,
    required int status,
    Uint8List? imageBytes,
    String? imageName,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> formMap = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      'bnr_type': bnrType.trim(),
      'status': status,
      if (startDate != null && startDate.trim().isNotEmpty) 'start_date': startDate.trim(),
      if (endDate != null && endDate.trim().isNotEmpty) 'end_date': endDate.trim(),
    };

    if (imageBytes != null && imageBytes.isNotEmpty) {
      formMap['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: imageName != null && imageName.trim().isNotEmpty ? imageName.trim() : 'banner_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }

    final FormData formData = FormData.fromMap(formMap);

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Initiating saveBanner request',
          category: 'app_banners.repository',
          level: SentryLevel.info,
          data: <String, dynamic>{
            if (id != null) 'id': id,
            'bnr_type': bnrType,
            'status': status,
            'has_image': imageBytes != null && imageBytes.isNotEmpty,
          },
        ),
      );

      final Response<dynamic> response = await _apiClient.dio.post(
        ApiConstants.addBannersApiEndpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SaveBannerResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[AppBannersRepository.saveBanner]: Unexpected response envelope from ${ApiConstants.addBannersApiEndpoint}');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'saveBanner', <String, dynamic>{if (id != null) 'id': id, 'bnr_type': bnrType});
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteBanner({required int bannerId}) {
    return executeDelete(tableName: 'AppBanners', id: bannerId);
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'AppBannersRepository error in $action', category: 'app_banners.repository.network', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('repository', 'AppBannersRepository');
        scope.setContexts('app_banners_repository_action', <String, dynamic>{
          'action': action,
          if (exception is DioException) 'status_code': exception.response?.statusCode,
          if (exception is DioException && exception.response?.data != null) 'response_data': exception.response?.data.toString(),
          ...?extra,
        });
      },
    );
  }
}
