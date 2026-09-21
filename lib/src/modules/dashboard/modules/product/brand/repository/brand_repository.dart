/*
import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandRepository {
  final ApiClient _apiClient;

  const BrandRepository({required this._apiClient});

  Future<ViewBrandModel> viewBrands() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewBrandsApiEndpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewBrandModel.fromJson(responseData);
      }
      throw FormatException('[BrandRepository.viewBrands]: Invalid data format received from endpoint: ${ApiConstants.viewBrandsApiEndpoint}');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Failed to fetch or parse Category list', category: 'BrandRepository.viewBrands', level: SentryLevel.error),
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

  Future<ViewBrandDatum> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    final String endpoint = ApiConstants.updateBrandApiEndpoint;

    final Map<String, dynamic> payload = {'MC_CompCode': mcCompCode.trim()};

    if (featuredBrand != null) payload['featured_brand'] = featuredBrand;
    if (status != null) payload['status'] = status;
    if (mImg != null) payload['m_img'] = mImg.trim();
    if (wImg != null) payload['w_img'] = wImg.trim();

    final response = await _apiClient.dio.post(endpoint, data: payload);
    return ViewBrandDatum.fromJson(response.data['data']);
  }

  Future<ViewItemByTypeModel> viewBrandItems({required int brandId}) async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint, data: {'_id': brandId.toString(), 'type': 'BRAND'});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }

      throw FormatException('[DashboardBrandRepository.viewBrandItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch items for brand ID: $brandId',
          category: 'dashboard_brand.repository',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'brand_id': brandId, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardBrandRepository');
            scope.setTag('brand_id', brandId.toString());
            scope.setContexts('network_action', {
              'endpoint': endpoint,
              'method': 'POST',
              'query_params': {'brand_id': brandId},
            });
          },
        );
      }

      rethrow;
    }
  }
}
*/

import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandRepository {
  final ApiClient _apiClient;

  const BrandRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ViewBrandModel> viewBrands() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewBrandsApiEndpoint);
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

  Future<ViewBrandDatum> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    final String endpoint = ApiConstants.updateBrandApiEndpoint;
    final Map<String, dynamic> payload = {'MC_CompCode': mcCompCode.trim()};
    if (featuredBrand != null) payload['featured_brand'] = featuredBrand;
    if (status != null) payload['status'] = status;
    if (mImg != null) payload['m_img'] = mImg.trim();
    if (wImg != null) payload['w_img'] = wImg.trim();

    final response = await _apiClient.dio.post(endpoint, data: payload);
    return ViewBrandDatum.fromJson(response.data['data']);
  }

  Future<ViewItemByTypeModel> viewBrandItems({required String brandCode}) async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;
    final String sanitizedCode = brandCode.trim();
    try {
      final response = await _apiClient.dio.post(endpoint, data: {'_id': sanitizedCode, 'type': 'BRAND'});
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }
      throw FormatException('[BrandRepository.viewBrandItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch items for brand Code: $sanitizedCode',
          category: 'brand.repository',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'brand_code': sanitizedCode, 'error': e.toString()},
        ),
      );
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'BrandRepository');
            scope.setTag('brand_code', sanitizedCode);
            scope.setContexts('network_action', {
              'endpoint': endpoint,
              'method': 'POST',
              'query_params': {'brand_code': sanitizedCode},
            });
          },
        );
      }
      rethrow;
    }
  }
}
