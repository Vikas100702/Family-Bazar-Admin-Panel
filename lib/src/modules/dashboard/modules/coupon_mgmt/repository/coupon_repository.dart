import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/add_coupon_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_filter_type_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_list_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CouponRepository {
  final ApiClient _apiClient;
  const CouponRepository({required this._apiClient});

  Future<ViewCouponListModel> viewCouponList({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewCouponListApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ViewCouponListModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[CouponRepository.viewCouponList]: Invalid data format received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewCouponList', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<AddCouponModel> addCoupon({
    int? id,
    required String code,
    required String discountType,
    required String title,
    required num discountValue,
    required num maxDiscount,
    required num minOrderAmount,
    required int usageLimit,
    required int usagePerCustomer,
    required int applicableAll,
    required List<String> applicableGroups,
    required List<String> applicableBrands,
    required String userType,
    required String paymentType,
    required String startAt,
    required String endAt,
    int status = 1,
  }) async {
    const String endpoint = ApiConstants.addCouponListApiEndpoint;
    final String trimmedCode = code.trim();
    final String trimmedTitle = title.trim();

    if (trimmedCode.isEmpty) {
      throw ArgumentError('Coupon code cannot be empty.');
    }
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Coupon title cannot be empty.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      'code': trimmedCode,
      'discount_type': discountType.trim(),
      'title': trimmedTitle,
      'discount_value': discountValue,
      'max_discount': maxDiscount,
      'min_order_amount': minOrderAmount,
      'usage_limit': usageLimit,
      'usage_per_customer': usagePerCustomer,
      'applicable_all': applicableAll,
      'applicable_group': applicableGroups,
      'applicable_brand': applicableBrands,
      'user_type': userType.trim(),
      'payment_type': paymentType.trim(),
      'start_at': startAt.trim(),
      'end_at': endAt.trim(),
      'status': status,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AddCouponModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[CouponRepository.addCoupon]: Invalid response format from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addCoupon', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewCouponFilterTypeModel> getCouponFilterType() async {
    const String endpoint = ApiConstants.getCouponFilterTypeApiEndpoint;
    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ViewCouponFilterTypeModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const FormatException('[CouponRepository.getCouponFilterType]: Invalid data format received.');
    } catch (e, stackTrace) {
      _captureSentryError('getCouponFilterType', endpoint, e, stackTrace);
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteCoupon({required int couponId}) async {
    if (couponId <= 0) {
      throw ArgumentError('[CouponRepository.deleteCoupon]: Invalid coupon ID: $couponId');
    }

    final Map<String, dynamic> payload = <String, dynamic>{'id': couponId.toString()};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(ApiConstants.deleteCouponApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return CommonDeleteModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[CouponRepository.deleteCoupon]: Invalid response format from ${ApiConstants.deleteCouponApiEndpoint}');
    } catch (e, stackTrace) {
      _captureSentryError('deleteCoupon', ApiConstants.deleteCouponApiEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'CouponRepository.$action failed on $endpoint',
        category: 'coupon.repository.network',
        level: SentryLevel.error,
        data: <String, dynamic>{
          'action': action,
          'endpoint': endpoint,
          if (error is DioException) 'status_code': error.response?.statusCode,
          'payload': ?payload,
        },
      ),
    );

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'coupon_mgmt');
        scope.setTag('repository', 'CouponRepository');
        scope.setTag('action', action);
        scope.setContexts('network_context', <String, dynamic>{
          'endpoint': endpoint,
          if (error is DioException) ...<String, dynamic>{
            'status_code': error.response?.statusCode,
            'response_data': error.response?.data?.toString(),
          },
          'payload': ?payload,
        });
      },
    );
  }
}
