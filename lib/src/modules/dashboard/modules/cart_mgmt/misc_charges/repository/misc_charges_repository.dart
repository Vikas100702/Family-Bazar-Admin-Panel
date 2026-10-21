import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/mixins/common_delete_mixin.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/model/misc_charges_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MiscChargesRepository with CommonDeleteMixin {
  final ApiClient _apiClient;
  const MiscChargesRepository({required this._apiClient});

  @override
  ApiClient get apiClient => _apiClient;

  Future<MiscChargesResponseModel> getAllMiscCharges({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.viewChargesApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = <String, dynamic>{'searchvalue': cleanSearch, 'page': page, 'limit': limit};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return MiscChargesResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[MiscChargesRepository.getAllMiscCharges]: Invalid response envelope received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getAllMiscCharges', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<MiscChargesResponseModel> addMiscCharges({
    required double handlingFee,
    required double smallCartCharge,
    required double smallCartMinAmount,
  }) async {
    const String endpoint = ApiConstants.addChargesApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      'handling_fee': handlingFee.toStringAsFixed(2),
      'small_cart_charge': smallCartCharge.toStringAsFixed(2),
      'small_cart_min_amount': smallCartMinAmount.toStringAsFixed(2),
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return MiscChargesResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[MiscChargesRepository.addMiscCharges]: Invalid response envelope received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addMiscCharges', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<MiscChargesResponseModel> updateMiscCharges({
    required int id,
    required double handlingFee,
    required double smallCartCharge,
    required double smallCartMinAmount,
    required int status,
  }) async {
    const String endpoint = ApiConstants.updateChargesApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': id.toString(),
      'handling_fee': handlingFee.toStringAsFixed(2),
      'small_cart_charge': smallCartCharge.toStringAsFixed(2),
      'small_cart_min_amount': smallCartMinAmount.toStringAsFixed(2),
      'status': status.toString(),
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return MiscChargesResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[MiscChargesRepository.updateMiscCharges]: Invalid response envelope received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('updateMiscCharges', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  /// Deletes a charge configuration utilizing the centralized CommonDeleteMixin contract.
  Future<CommonDeleteModel> deleteCharges({required int chargeId}) {
    return executeDelete(tableName: 'MiscellaneousCartCharges', id: chargeId);
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'MiscChargesRepository.$action failed on $endpoint',
        category: 'cart_mgmt.misc_charges.repository',
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
        scope.setTag('module', 'misc_charges');
        scope.setTag('repository', 'MiscChargesRepository');
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
