import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryRepository {
  final ApiClient _apiClient;
  const CategoryRepository({required this._apiClient});

  Future<ViewCategoryModel> viewCategories({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewCategoryApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewCategoryModel.fromJson(responseData);
      }

      throw FormatException('[CategoryRepository.viewCategories]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewCategories', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewCategoryDatum> updateCategoryDetails({required String catCode, int? status}) async {
    const String endpoint = ApiConstants.updateCategoryApiEndpoint;
    final String trimmedCatCode = catCode.trim();

    if (trimmedCatCode.isEmpty) {
      throw ArgumentError('Category code cannot be empty.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{'IG_Code': trimmedCatCode, 'status': ?status};

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Initiating updateCategoryDetails request', category: 'category.repository', level: SentryLevel.info, data: payload),
      );

      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final Map<String, dynamic> targetJson = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : responseData;
        return ViewCategoryDatum.fromJson(targetJson);
      }

      throw FormatException('[CategoryRepository.updateCategoryDetails]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('updateCategoryDetails', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'CategoryRepository.$action failed on $endpoint',
        category: 'product.category.repository',
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
        scope.setTag('module', 'category');
        scope.setTag('repository', 'CategoryRepository');
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
