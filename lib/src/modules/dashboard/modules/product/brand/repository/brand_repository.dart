import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandRepository {
  final ApiClient _apiClient;

  const BrandRepository({required this._apiClient});

  Future<ViewBrandModel> viewBrands({int page = 1, int limit = 20, String? searchValue}) async {
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {"searchvalue": cleanSearch, "isAdmin": 1, "page": page, "limit": limit};

    try {
      final response = await _apiClient.dio.post(ApiConstants.viewBrandsApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewBrandModel.fromJson(responseData);
      }
      throw FormatException('[BrandRepository.viewBrands]: Invalid data format received from endpoint: ${ApiConstants.viewBrandsApiEndpoint}');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Failed to fetch or parse Brand list', category: 'BrandRepository.viewBrands', level: SentryLevel.error),
      );
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'BrandRepository');
            scope.setTag('action', 'viewBrands');
          },
        );
      }
      rethrow;
    }
  }

  Future<ViewBrandDatum> updateBrand({required String mcCompCode, int? featuredBrand, int? status}) async {
    final String endpoint = ApiConstants.updateBrandApiEndpoint;
    final Map<String, dynamic> payload = {'MC_CompCode': mcCompCode.trim()};
    if (featuredBrand != null) payload['featured_brand'] = featuredBrand;
    if (status != null) payload['status'] = status;

    final response = await _apiClient.dio.post(endpoint, data: payload);
    return ViewBrandDatum.fromJson(response.data['data']);
  }

  Future<ViewItemByTypeModel> viewBrandItems({required String brandCode, int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;
    final String trimmedCode = brandCode.trim();
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {
      '_id': trimmedCode,
      'type': 'BRAND',
      "searchvalue": cleanSearch,
      "isAdmin": 1,
      "page": page,
      "limit": limit,
    };

    try {
      final response = await _apiClient.dio.post(endpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }
      throw FormatException('[BrandRepository.viewBrandItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch items for brand Code: $trimmedCode',
          category: 'brand.repository',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'brand_code': trimmedCode, 'error': e.toString()},
        ),
      );
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'BrandRepository');
            scope.setTag('brand_code', trimmedCode);
            scope.setContexts('network_action', {
              'endpoint': endpoint,
              'method': 'POST',
              'query_params': {'brand_code': trimmedCode},
            });
          },
        );
      }
      rethrow;
    }
  }
}
