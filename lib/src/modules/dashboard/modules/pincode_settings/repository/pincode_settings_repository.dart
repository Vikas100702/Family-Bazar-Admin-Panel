import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/add_pincode_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/unmap_assign_pincode_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PincodeSettingsRepository {
  final ApiClient _apiClient;

  const PincodeSettingsRepository({required this._apiClient});

  Future<PincodeModel> getPincodes() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.getPincodeApiEndpoint);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == true) {
          return PincodeModel.fromJson(data);
        } else {
          return PincodeModel(status: false, message: data['message']?.toString() ?? 'Failed to fetch pincode data.', data: const []);
        }
      }
      throw FormatException(
        '[PincodeSettingsRepository.getPincodes]: Invalid data format received from endpoint: ${ApiConstants.getPincodeApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('getPincodes', e, stackTrace);
      rethrow;
    }
  }

  Future<AddPincodeModel> addPincode(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.insertPincodeApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        return AddPincodeModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw FormatException(
        '[PincodeSettingsRepository.addPincode]: Invalid data format received from endpoint: ${ApiConstants.insertPincodeApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('addPincode', e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<UnmapAndAssignPincodeModel> unmapAndAssignPincode(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.unmapPincodeApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        return UnmapAndAssignPincodeModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw FormatException(
        '[PincodeSettingsRepository.unmapAndAssignPincode]: Invalid data format received from endpoint: ${ApiConstants.unmapPincodeApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('unmapAndAssignPincode', e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'CRUD Failure in PincodeSettingsRepository.$action',
        category: 'pincode_settings.repository',
        level: SentryLevel.error,
        data: {'action': action, 'error': error.toString(), 'payload': ?payload},
      ),
    );
    if (error is! DioException) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('module', 'pincode_settings');
          scope.setTag('action', action);
          if (payload != null) {
            scope.setContexts('request_payload', payload);
          }
        },
      );
    }
  }
}
