import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
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
}
