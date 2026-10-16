import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/model/app_banners_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBannersRepository {
  final ApiClient _apiClient;
  const AppBannersRepository({required this._apiClient});

  /// Fetches paginated banner list with optional combination filters
  Future<AppBannerResponseModel> getBanners({int page = 1, int limit = 50, int? id, String? bnrType, int? status}) async {
    final Map<String, dynamic> payload = {
      'page': page,
      'limit': limit,
      if (id != null && id > 0) 'id': id,
      if (bnrType != null && bnrType.trim().isNotEmpty) 'bnr_type': bnrType.trim(),
      'status': ?status,
    };

    try {
      final Response response = await _apiClient.dio.post(ApiConstants.viewBannersApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AppBannerResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[AppBannersRepository.getBanners]: Unexpected response format received from ${ApiConstants.viewBannersApiEndpoint}');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'getBanners', payload);
      rethrow;
    }
  }

  Future<SaveBannerResponseModel> saveBanner({
    int? id,
    required String bnrType,
    required int status,
    Uint8List? imageBytes,
    String? imageName,
    String? startAt,
    String? endAt,
  }) async {
    final Map<String, dynamic> formMap = {
      if (id != null && id > 0) 'id': id,
      'bnr_type': bnrType.trim(),
      'status': status,
      if (startAt != null) 'start_at': startAt.trim(),
      if (endAt != null) 'end_at': endAt.trim(),
    };

    if (imageBytes != null && imageBytes.isNotEmpty) {
      formMap['image'] = MultipartFile.fromBytes(imageBytes, filename: imageName ?? 'banner_${DateTime.now().millisecondsSinceEpoch}.png');
    }

    final FormData formData = FormData.fromMap(formMap);

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Initiating saveBanner request',
          category: 'app_banners.repository',
          level: SentryLevel.info,
          data: {'id': ?id, 'bnr_type': bnrType, 'status': status, 'has_image': imageBytes != null},
        ),
      );

      final Response response = await _apiClient.dio.post(
        ApiConstants.addBannersApiEndpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SaveBannerResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[AppBannersRepository.saveBanner]: Unexpected response envelope from ${ApiConstants.addBannersApiEndpoint}');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'saveBanner', {'id': ?id, 'bnr_type': bnrType});
      rethrow;
    }
  }

  /// Deletes a banner entry using common system delete endpoint
  Future<CommonDeleteModel> deleteBanner({required int bannerId}) async {
    const String endpoint = ApiConstants.deleteApiEndpoint;
    final Map<String, dynamic> payload = {'tablename': 'Banner', 'id': bannerId.toString()};

    try {
      final Response response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return CommonDeleteModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[AppBannersRepository.deleteBanner]: Unexpected response received from $endpoint');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'deleteBanner', payload);
      rethrow;
    }
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'AppBannersRepository error in $action', category: 'app_banners.repository.network', level: SentryLevel.error, data: extra),
    );

    if (exception is! DioException) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'AppBannersRepository');
          scope.setContexts('app_banners_repository_action', {'action': action, ...?extra});
        },
      );
    }
  }
}
