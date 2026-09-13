import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirmRepository {
  final ApiClient _apiClient;

  const FirmRepository({required this._apiClient});

  Future<ViewFirmModel> viewFirms() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewFirmApiEndpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewFirmModel.fromJson(responseData);
      }
      throw FormatException('[FirmRepository.viewFirms]: Invalid data format received from endpoint: ${ApiConstants.viewFirmApiEndpoint}');
    } catch (e, stackTrace) {
      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('layer', 'firm_repository');
            scope.setTag('endpoint', ApiConstants.viewFirmApiEndpoint);
            scope.setTag('action', 'viewFirms');
          },
        );
      }
      rethrow;
    }
  }
}
