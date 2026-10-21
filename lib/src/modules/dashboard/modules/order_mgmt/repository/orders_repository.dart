import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/model/view_orders_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OrdersRepository {
  final ApiClient _apiClient;
  const OrdersRepository({required this._apiClient});

  Future<ViewOrdersModel> getOrders({int page = 1, int limit = 20, String? search}) async {
    const String endpoint = ApiConstants.viewOrdersApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      if (search != null && search.trim().isNotEmpty) 'searchvalue': search.trim(),
      'page': page,
      'limit': limit,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ViewOrdersModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[OrdersRepository.getOrders]: Invalid response structure received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getOrders', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'OrdersRepository.$action failed on $endpoint',
        category: 'orders.repository',
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
        scope.setTag('module', 'orders');
        scope.setTag('repository', 'OrdersRepository');
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
