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
      return ViewFirmModel(success: false, message: 'Invalid data format received from server', data: []);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(Breadcrumb(message: 'Failed to fetch or parse Firm list', category: 'FirmRepository.viewFirms', level: SentryLevel.error));
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'FirmRepository');
        },
      );
      rethrow;
    }
  }
}
