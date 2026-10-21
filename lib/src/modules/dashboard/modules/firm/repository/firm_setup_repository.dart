import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirmRepository {
  final ApiClient _apiClient;
  const FirmRepository({required this._apiClient});

  Future<ViewFirmModel> viewFirms() async {
    const String endpoint = ApiConstants.viewFirmApiEndpoint;

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ViewFirmModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[FirmRepository.viewFirms]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewFirms', endpoint, e, stackTrace);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'FirmRepository.$action failed on $endpoint',
        category: 'firm.repository.network',
        level: SentryLevel.error,
        data: <String, dynamic>{'action': action, 'endpoint': endpoint, if (error is DioException) 'status_code': error.response?.statusCode},
      ),
    );

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'firm');
        scope.setTag('repository', 'FirmRepository');
        scope.setTag('action', action);
        scope.setContexts('network_context', <String, dynamic>{
          'endpoint': endpoint,
          if (error is DioException) ...<String, dynamic>{
            'status_code': error.response?.statusCode,
            'response_data': error.response?.data?.toString(),
          },
        });
      },
    );
  }
}
