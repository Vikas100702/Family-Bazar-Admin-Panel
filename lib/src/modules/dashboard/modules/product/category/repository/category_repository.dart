import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  const CategoryRepository({required this._apiClient});

  Future<ViewCategoryModel> viewCategories({int page = 1, int limit = 20, String? searchValue}) async {
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {"searchvalue": cleanSearch, "isAdmin": 1, "page": page, "limit": limit};

    try {
      final response = await _apiClient.dio.post(ApiConstants.viewCategoryApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewCategoryModel.fromJson(responseData);
      }
      throw FormatException(
        '[CategoryRepository.viewCategories]: Invalid data format received from endpoint: ${ApiConstants.viewCategoryApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Failed to fetch or parse Category list', category: 'CategoryRepository.viewCategory', level: SentryLevel.error),
      );
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'CategoryRepository');
            scope.setTag('action', 'viewCategories');
          },
        );
      }
      rethrow;
    }
  }

  Future<ViewCategoryDatum> updateCategoryDetails({required String catCode, int? status}) async {
    final String trimmedCatCode = catCode.trim();

    if (trimmedCatCode.isEmpty) {
      throw ArgumentError('Category code cannot be empty.');
    }
    final Map<String, dynamic> payload = {'IG_Code': trimmedCatCode, 'status': status};

    try {
      final response = await _apiClient.dio.post(ApiConstants.updateCategoryApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        // Handle both flat JSON or nested 'data' object response
        final Map<String, dynamic> targetJson = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : responseData;
        return ViewCategoryDatum.fromJson(targetJson);
      }

      throw FormatException(
        '[CategoryRepository.updateCategoryDetails]: Invalid response format received from endpoint: ${ApiConstants.updateCategoryApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing updateCategoryDetails',
          category: 'category.repository',
          level: SentryLevel.error,
          data: {'IG_Code': trimmedCatCode, 'status': status, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'CategoryRepository');
            scope.setTag('action', 'updateCategoryDetails');
            scope.setContexts('category_association', {'IG_Code': trimmedCatCode});
          },
        );
      }

      rethrow;
    }
  }
}
