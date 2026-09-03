import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/add_pincode_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/pincode_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/model/unmap_assign_pincode_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PincodeSettingsRepository {
  final ApiClient _apiClient;
  const PincodeSettingsRepository({required this._apiClient});

  /// 1. READ: Fetch all mapped pincodes
  Future<PincodeModel> getPincodes() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.getPincodeApiEndpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == true) {
          return PincodeModel.fromJson(data);
        } else {
          throw Exception(data['message']?.toString() ?? 'Failed to fetch pincode data.');
        }
      }
      throw Exception('Server returned an invalid or empty response.');
    } catch (e, stackTrace) {
      _captureSentryError('getPincodes', e, stackTrace);
      rethrow;
    }
  }

  /// 2. CREATE: Map a new pincode
  Future<AddPincodeModel> addPincode(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.addPincodeApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AddPincodeModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AddPincodeModel(success: false, message: 'Invalid response format from server.');
    } catch (e, stackTrace) {
      _captureSentryError('addPincode', e, stackTrace, payload: payload);
      rethrow;
    }
  }

  /// 3. UPDATE: Unmap existing assignment and reassign pincode
  Future<UnmapAndAssignPincodeModel> unmapAndAssignPincode(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.unmapPincodeApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return UnmapAndAssignPincodeModel.fromJson(response.data as Map<String, dynamic>);
      }
      return UnmapAndAssignPincodeModel(success: false, message: 'Invalid response format from server.');
    } catch (e, stackTrace) {
      _captureSentryError('unmapAndAssignPincode', e, stackTrace, payload: payload);
      rethrow;
    }
  }

  // /// 4. DELETE: Remove an existing pincode mapping
  // Future<Map<String, dynamic>> deletePincode(Map<String, dynamic> payload) async {
  //   try {
  //     final response = await _apiClient.dio.post(ApiConstants.deletePincodeApiEndpoint, data: payload);
  //
  //     if (response.data != null && response.data is Map<String, dynamic>) {
  //       final data = response.data as Map<String, dynamic>;
  //       if (data['status'] == true) {
  //         return data;
  //       } else {
  //         throw Exception(data['message']?.toString() ?? 'Failed to delete pincode.');
  //       }
  //     }
  //     throw Exception('Server returned an invalid or empty response.');
  //   } catch (e, stackTrace) {
  //     _captureSentryError('deletePincode', e, stackTrace, payload: payload);
  //     rethrow;
  //   }
  // }

  /// Centralized Sentry Observability capturing Breadcrumb + Exception Stack Trace
  void _captureSentryError(String action, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'CRUD Failure in PincodeSettingsRepository.$action',
        category: 'pincode_settings.repository',
        level: SentryLevel.error,
        data: {'action': action, 'error': error.toString(), if (payload != null) 'payload': payload},
      ),
    );

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
