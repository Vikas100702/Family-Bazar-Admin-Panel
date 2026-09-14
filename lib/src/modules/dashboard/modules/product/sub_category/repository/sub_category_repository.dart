import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/insert_sub_cat_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubCategoryRepository {
  final ApiClient _apiClient;

  const SubCategoryRepository({required this._apiClient});

  Future<ViewSubCategoryModel> viewSubCategories() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewSubCategoryApiEndpoint);

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

  Future<InsertSubCatDetailsModel> addSubCategoryDetails({required String subCatCode, required String mImg, required String wImg}) async {
    final String trimmedCode = subCatCode.trim();
    final String trimmedMImg = mImg.trim();
    final String trimmedWImg = wImg.trim();

    if (trimmedCode.isEmpty) {
      throw ArgumentError('SubCategory code cannot be empty.');
    }

    final Map<String, dynamic> payload = {'subcat_code': trimmedCode, 'w_img': trimmedWImg, 'm_img': trimmedMImg};
    try {
      final response = await _apiClient.dio.post(ApiConstants.insertSubCatDetailsApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return InsertSubCatDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException(
        '[SubCategoryRepository.addSubCategoryDetails]: Invalid response format received from endpoint: ${ApiConstants.insertSubCatDetailsApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addSubCategoryDetails image association',
          category: 'sub_category.repository',
          level: SentryLevel.error,
          data: {'subcat_code': trimmedCode, 'has_w_img': trimmedWImg.isNotEmpty, 'has_m_img': trimmedMImg.isNotEmpty, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'SubCategoryRepository');
            scope.setTag('action', 'addSubCategoryDetails');
            scope.setContexts('sub_category_association', {'subcat_code': trimmedCode});
          },
        );
      }

      rethrow;
    }
  }
}
