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
    const String endpoint = ApiConstants.viewBrandsApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewBrandModel.fromJson(responseData);
      }

      throw FormatException('[BrandRepository.viewBrands]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewBrands', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewBrandDatum> updateBrand({required String mcCompCode, int? featuredBrand, int? status}) async {
    const String endpoint = ApiConstants.updateBrandApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'MC_CompCode': mcCompCode.trim(), 'featured_brand': ?featuredBrand, 'status': ?status};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null &&
          response.data is Map<String, dynamic> &&
          response.data['data'] != null &&
          response.data['data'] is Map<String, dynamic>) {
        return ViewBrandDatum.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw FormatException('[BrandRepository.updateBrand]: Invalid response payload received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('updateBrand', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewItemByTypeModel> viewBrandItems({required String brandCode, int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;
    final String trimmedCode = brandCode.trim();
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{
      '_id': trimmedCode,
      'type': 'BRAND',
      'searchvalue': cleanSearch,
      'isAdmin': '1',
      'page': page,
      'limit': limit,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }

      throw FormatException('[BrandRepository.viewBrandItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewBrandItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'BrandRepository.$action failed on $endpoint',
        category: 'product.brand.repository',
        level: SentryLevel.error,
        data: <String, dynamic>{
          'action': action,
          'endpoint': endpoint,
          if (error is DioException) 'status_code': error.response?.statusCode,
          if (payload != null) 'payload': payload,
        },
      ),
    );

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'brand');
        scope.setTag('repository', 'BrandRepository');
        scope.setTag('action', action);
        scope.setContexts('network_context', <String, dynamic>{
          'endpoint': endpoint,
          if (error is DioException) ...<String, dynamic>{
            'status_code': error.response?.statusCode,
            'response_data': error.response?.data?.toString(),
          },
          if (payload != null) 'payload': payload,
        });
      },
    );
  }
}
