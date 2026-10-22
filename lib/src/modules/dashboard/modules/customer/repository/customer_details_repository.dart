import 'dart:async';

import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/mixins/common_delete_mixin.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_dashboard_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_details_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomerDetailsRepository with CommonDeleteMixin {
  final ApiClient _apiClient;
  const CustomerDetailsRepository({required this._apiClient});

  @override
  ApiClient get apiClient => _apiClient;

  Future<CustomerDetailsModel> viewDetails({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewCustomerDetailsApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};
    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return CustomerDetailsModel.fromJson(responseData);
      }
      throw FormatException('[CustomerDetailsRepository.viewDetails]: Invalid data format from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewDetails', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<CustomerDashboardModel> getCustomerDashboardDetails({required int customerId}) async {
    if (customerId <= 0) {
      throw ArgumentError('[CustomerDetailsRepository.getCustomerDashboardDetails]: Invalid customer ID: $customerId');
    }

    const String apiEndpoint = ApiConstants.viewCustomerDashboardApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'customer_id': customerId};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(apiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        return CustomerDashboardModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw FormatException('[CustomerDetailsRepository.getCustomerDashboardDetails]: Unexpected payload from $apiEndpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getCustomerDashboardDetails', apiEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteCustomer({required int customerId}) {
    return executeDelete(tableName: 'CustomerDetails', id: customerId);
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'CustomerDetailsRepository.$action failed on $endpoint',
        category: 'customer.repository',
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
        scope.setTag('module', 'customer');
        scope.setTag('repository', 'CustomerDetailsRepository');
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
