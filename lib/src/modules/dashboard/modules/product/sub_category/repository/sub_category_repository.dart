import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubCategoryRepository {
  final ApiClient _apiClient;

  const SubCategoryRepository({required this._apiClient});

  Future<ViewSubCategoryModel> viewSubCategories({int page = 1, int limit = 20, String? searchValue}) async {
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {"searchvalue": cleanSearch, "isAdmin": 1, "page": page, "limit": limit};
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewSubCategoryApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewSubCategoryModel.fromJson(responseData);
      }
      throw FormatException(
        '[SubCategoryRepository.viewSubCategories]: Invalid data format received from endpoint: ${ApiConstants.viewSubCategoryApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch or parse SubCategory list',
          category: 'sub_category.repository',
          level: SentryLevel.error,
          data: {'endpoint': ApiConstants.viewSubCategoryApiEndpoint, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'SubCategoryRepository');
            scope.setTag('action', 'viewSubCategories');
          },
        );
      }
      rethrow;
    }
  }

  Future<ViewSubCategoryDatum> updateSubCategoryDetails({required String ogCode, int? status}) async {
    final String trimmedSubCatCode = ogCode.trim();

    if (trimmedSubCatCode.isEmpty) {
      throw ArgumentError('Sub category code cannot be empty.');
    }
    final Map<String, dynamic> payload = {'OG_Code': trimmedSubCatCode, 'status': status};

    try {
      final response = await _apiClient.dio.post(ApiConstants.updateSubCatApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        // Handle both flat JSON or nested 'data' object response
        final Map<String, dynamic> targetJson = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : responseData;
        return ViewSubCategoryDatum.fromJson(targetJson);
      }

      throw FormatException(
        '[SubCategoryRepository.updateSubCategoryDetails]: Invalid response format received from endpoint: ${ApiConstants.updateSubCatApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing updateSubCategoryDetails',
          category: 'sub_category.repository',
          level: SentryLevel.error,
          data: {'OG_Code': trimmedSubCatCode, 'status': status, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'SubCategoryRepository');
            scope.setTag('action', 'updateSubCategoryDetails');
            scope.setContexts('sub_category_association', {'OG_Code': trimmedSubCatCode});
          },
        );
      }

      rethrow;
    }
  }
}
