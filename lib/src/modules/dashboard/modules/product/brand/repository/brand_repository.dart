import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
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
}
