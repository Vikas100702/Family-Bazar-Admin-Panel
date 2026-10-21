import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubCategoryRepository {
  final ApiClient _apiClient;
  const SubCategoryRepository({required this._apiClient});

  Future<ViewSubCategoryModel> viewSubCategories({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewSubCategoryApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewSubCategoryModel.fromJson(responseData);
      }

      throw FormatException('[SubCategoryRepository.viewSubCategories]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewSubCategories', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewSubCategoryDatum> updateSubCategoryDetails({required String ogCode, int? status}) async {
    const String endpoint = ApiConstants.updateSubCatApiEndpoint;
    final String trimmedSubCatCode = ogCode.trim();

    if (trimmedSubCatCode.isEmpty) {
      throw ArgumentError('Sub category code cannot be empty.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{'OG_Code': trimmedSubCatCode, 'status': ?status};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final Map<String, dynamic> targetJson = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : responseData;
        return ViewSubCategoryDatum.fromJson(targetJson);
      }

      throw FormatException('[SubCategoryRepository.updateSubCategoryDetails]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('updateSubCategoryDetails', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'SubCategoryRepository.$action failed on $endpoint',
        category: 'product.sub_category.repository',
        level: SentryLevel.error,
        data: <String, dynamic>{
          'action': action,
          'endpoint': endpoint,
          if (error is DioException) 'status_code': error.response?.statusCode,
          'payload': ?payload,
        },
      ),
    );

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'sub_category');
        scope.setTag('repository', 'SubCategoryRepository');
        scope.setTag('action', action);
        scope.setContexts('network_context', <String, dynamic>{
          'endpoint': endpoint,
          if (error is DioException) ...<String, dynamic>{
            'status_code': error.response?.statusCode,
            'response_data': error.response?.data?.toString(),
          },
          'payload': ?payload,
        });
      },
    );
  }
}
