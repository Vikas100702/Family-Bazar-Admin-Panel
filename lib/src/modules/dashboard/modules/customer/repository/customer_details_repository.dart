import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_details_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomerDetailsRepository {
  final ApiClient _apiClient;
  CustomerDetailsRepository({required this._apiClient});

  Future<CustomerDetailsModel> viewDetails({int page = 1, int limit = 20, String? searchValue}) async {
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {"searchvalue": cleanSearch, "isAdmin": 1, "page": page, "limit": limit};

    try {
      final response = await _apiClient.dio.post(ApiConstants.viewCustDetailsWalletApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return CustomerDetailsModel.fromJson(responseData);
      }
      throw FormatException(
        '[CustomerDetailsAndWalletModel.viewDetails]: Invalid data format received from endpoint: ${ApiConstants.viewCustDetailsWalletApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Failed to fetch or parse CustomerDetails', category: 'CustomerWalletRepository.viewDetails', level: SentryLevel.error),
      );
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'CustomerWalletRepository');
            scope.setTag('action', 'viewDetails');
          },
        );
      }
      rethrow;
    }
  }
}
