import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PincodeSettingsRepository {
  final ApiClient _apiClient;
  const PincodeSettingsRepository({required this._apiClient});

  Future<PincodeModel> getPincodes({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.getPincodeApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        if (data['status'] == true || data['status'] == 1) {
          return PincodeModel.fromJson(data);
        } else {
          return PincodeModel(
            status: false,
            message: data['message']?.toString().trim() ?? 'Failed to fetch pincode data.',
            data: const <Datum>[],
            pagination: data['pagination'] is Map<String, dynamic> ? Pagination.fromJson(data['pagination'] as Map<String, dynamic>) : null,
          );
        }
      }

      throw FormatException('[PincodeSettingsRepository.getPincodes]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getPincodes', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<AddPincodeModel> addPincode({
    required String userName,
    required String firmCode,
    required String firmName,
    required String pincode,
    int? id,
    required int isScheduleSlot,
    required int isRegularSlot,
  }) async {
    const String endpoint = ApiConstants.insertPincodeApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      'user_name': userName.trim(),
      'P_FirmCode': firmCode.trim(),
      'P_FirmName': firmName.trim(),
      'P_PinCode': pincode.trim(),
      if (id != null && id > 0) 'id': id,
      'IsScheduleSlot': isScheduleSlot,
      'IsRegularSlot': isRegularSlot,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AddPincodeModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[PincodeSettingsRepository.addPincode]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addPincode', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<UnmapAndAssignPincodeModel> unmapAndAssignPincode({
    required String userName,
    required String firmCode,
    required String firmName,
    required String pincode,
    required int isScheduleSlot,
    required int isRegularSlot,
  }) async {
    const String endpoint = ApiConstants.unmapPincodeApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      'user_name': userName.trim(),
      'P_FirmCode': firmCode.trim(),
      'P_FirmName': firmName.trim(),
      'P_PinCode': pincode.trim(),
      'IsScheduleSlot': isScheduleSlot,
      'IsRegularSlot': isRegularSlot,
    };

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Initiating unmapAndAssignPincode request',
          category: 'pincode_settings.repository',
          level: SentryLevel.info,
          data: payload,
        ),
      );

      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return UnmapAndAssignPincodeModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[PincodeSettingsRepository.unmapAndAssignPincode]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('unmapAndAssignPincode', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'PincodeSettingsRepository.$action failed on $endpoint',
        category: 'pincode_settings.repository.network',
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
        scope.setTag('module', 'pincode_settings');
        scope.setTag('repository', 'PincodeSettingsRepository');
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
