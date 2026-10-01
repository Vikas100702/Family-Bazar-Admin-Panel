import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/add_coupon_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_filter_type_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_list_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CouponRepository {
  final ApiClient _apiClient;
  const CouponRepository({required this._apiClient});

  Future<ViewCouponListModel> viewCouponList({int page = 1, int limit = 20, String? searchValue, CancelToken? cancelToken}) async {
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {"searchvalue": cleanSearch, "isAdmin": 1, "page": page, "limit": limit};

    try {
      final response = await _apiClient.dio.post(ApiConstants.viewCouponListApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewCouponListModel.fromJson(responseData);
      }
      throw FormatException(
        '[CouponRepository.viewCouponList]: Invalid data format received from endpoint: ${ApiConstants.viewCouponListApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Failed to fetch or parse Coupon list', category: 'CouponRepository.viewCouponList', level: SentryLevel.error),
      );
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'CouponRepository');
            scope.setTag('action', 'viewCouponList');
          },
        );
      }
      rethrow;
    }
  }

  Future<AddCouponModel> addCoupon({
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

    final Map<String, dynamic> payload = {
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
      final response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddCouponModel.fromJson(responseData);
      }

      throw FormatException('[CouponRepository.addCoupon]: Invalid response format from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'addCoupon', {'endpoint': endpoint, 'payload': payload});
      rethrow;
    }
  }

  Future<ViewCouponFilterTypeModel> getCouponFilterType() async {
    String endpoint = ApiConstants.getCouponFilterTypeApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewCouponFilterTypeModel.fromJson(responseData);
      }
      throw const FormatException('[CouponRepository.getCouponFilterType]: Invalid data format received.');
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'getCouponFilterType', {'endpoint': endpoint});
      rethrow;
    }
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'CouponRepository error in $action', category: 'coupon.repository.network', level: SentryLevel.error, data: extra),
    );

    if (exception is! DioException) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'CouponRepository');
          scope.setContexts('coupon_repository_action', {'action': action, ...?extra});
        },
      );
    }
  }
}
