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
      return ViewCategoryModel(success: false, message: 'Invalid data format received from server', data: []);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Failed to fetch or parse Category list', category: 'CategoryRepository.viewCategory', level: SentryLevel.error),
      );
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'CategoryRepository');
        },
      );
      rethrow;
    }
  }

  Future<InsertCatDetailsModel> addCategoryDetails({required String catCode, required String mImg, required String wImg}) async {
    try {
      if (catCode.trim().isEmpty) {
        throw ArgumentError('Category code cannot be empty.');
      }

      final Map<String, dynamic> payload = {'cat_code': catCode.trim(), 'w_img': wImg.trim(), 'm_img': mImg.trim()};

      final response = await _apiClient.dio.post(ApiConstants.insertCategoryDetailsApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return InsertCatDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const FormatException('Invalid response format received from addCategory.');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addCategory image association',
          category: 'CategoryRepository.addCategory',
          level: SentryLevel.error,
          data: {'cat_code': catCode, 'has_w_img': wImg.isNotEmpty, 'has_m_img': mImg.isNotEmpty},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'CategoryRepository');
          scope.setContexts('category_association', {'cat_code': catCode});
        },
      );

      rethrow;
    }
  }
}
