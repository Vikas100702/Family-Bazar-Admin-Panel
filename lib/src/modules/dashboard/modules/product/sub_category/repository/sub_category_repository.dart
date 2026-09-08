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
      return ViewSubCategoryModel(success: false, message: 'Invalid data format received from server', data: []);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch or parse SubCategory list',
          category: 'SubCategoryRepository.viewSubCategories',
          level: SentryLevel.error,
        ),
      );
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'SubCategoryRepository');
        },
      );
      rethrow;
    }
  }

  Future<InsertSubCatDetailsModel> addSubCategoryDetails({required String subCatCode, required String mImg, required String wImg}) async {
    try {
      if (subCatCode.trim().isEmpty) {
        throw ArgumentError('SubCategory code cannot be empty.');
      }

      final Map<String, dynamic> payload = {'subcat_code': subCatCode.trim(), 'w_img': wImg.trim(), 'm_img': mImg.trim()};

      final response = await _apiClient.dio.post(ApiConstants.insertSubCatDetailsApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return InsertSubCatDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const FormatException('Invalid response format received from addSubCategoryDetails.');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addSubCategory image association',
          category: 'SubCategoryRepository.addSubCategoryDetails',
          level: SentryLevel.error,
          data: {'subcat_code': subCatCode, 'has_w_img': wImg.isNotEmpty, 'has_m_img': mImg.isNotEmpty},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'SubCategoryRepository');
          scope.setContexts('sub_category_association', {'subcat_code': subCatCode});
        },
      );

      rethrow;
    }
  }
}
