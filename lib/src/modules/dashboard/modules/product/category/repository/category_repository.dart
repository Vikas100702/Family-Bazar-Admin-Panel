import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/insert_cat_details_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  const CategoryRepository({required this._apiClient});

  Future<ViewCategoryModel> viewCategories() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewCategoryApiEndpoint);

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

  Future<AddCatDetailsModel> addCategoryDetails({required String catCode, required String mImg, required String wImg}) async {
    final String trimmedCatCode = catCode.trim();
    final String trimmedMImg = mImg.trim();
    final String trimmedWImg = wImg.trim();

    if (trimmedCatCode.isEmpty) {
      throw ArgumentError('Category code cannot be empty.');
    }
    final Map<String, dynamic> payload = {'cat_code': trimmedCatCode, 'w_img': trimmedWImg, 'm_img': trimmedMImg};

    try {
      final response = await _apiClient.dio.post(ApiConstants.insertCategoryDetailsApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AddCatDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException(
        '[CategoryRepository.addCategoryDetails]: Invalid response format received from endpoint: ${ApiConstants.insertCategoryDetailsApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addCategoryDetails image association',
          category: 'category.repository',
          level: SentryLevel.error,
          data: {'cat_code': trimmedCatCode, 'has_w_img': trimmedWImg.isNotEmpty, 'has_m_img': trimmedMImg.isNotEmpty, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'CategoryRepository');
            scope.setTag('action', 'addCategoryDetails');
            scope.setContexts('category_association', {'cat_code': trimmedCatCode});
          },
        );
      }

      rethrow;
    }
  }
}
