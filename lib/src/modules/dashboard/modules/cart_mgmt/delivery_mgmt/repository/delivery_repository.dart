import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_management_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DeliveryRepository {
  final ApiClient _apiClient;
  const DeliveryRepository({required this._apiClient});

  Future<DeliveryRulesResponseModel> getDeliveryRules({int? id, String? search, int page = 1, int limit = 20}) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      if (id == null) ...<String, dynamic>{'search': search?.trim() ?? '', 'page': page, 'limit': limit},
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(ApiConstants.viewDeliveryRulesApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return DeliveryRulesResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException(
        '[DeliveryRepository.getDeliveryRules]: Unexpected response envelope received from ${ApiConstants.viewDeliveryRulesApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('getDeliveryRules', ApiConstants.viewDeliveryRulesApiEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<SaveDeliveryRuleResponseModel> saveRule({
    int? id,
    required String ruleName,
    required String ruleType,
    String? description,
    required int status,
    required List<int> pincodeIds,
    required List<DeliveryRuleSlabItem> deliveryRules,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      'rule_name': ruleName.trim(),
      'rule_type': ruleType.trim(),
      'description': description?.trim() ?? '',
      'priority': 1,
      'status': status,
      'pincode_ids': pincodeIds,
      'delivery_rules': deliveryRules.map((DeliveryRuleSlabItem slab) => slab.toSavePayloadJson(ruleType: ruleType)).toList(growable: false),
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(ApiConstants.addDeliveryRulesApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SaveDeliveryRuleResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[DeliveryRepository.saveRule]: Unexpected response envelope received from ${ApiConstants.addDeliveryRulesApiEndpoint}');
    } catch (e, stackTrace) {
      _captureSentryError('saveRule', ApiConstants.addDeliveryRulesApiEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<DeliveryRulePincodeListResponse> getPincodeList({int? ruleId, String? search}) async {
    final Map<String, dynamic> payload = <String, dynamic>{if (ruleId != null && ruleId > 0) 'rule_id': ruleId, 'search': search?.trim() ?? ''};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(ApiConstants.pincodeListDeliveryRulesApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return DeliveryRulePincodeListResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException(
        '[DeliveryRepository.getPincodeList]: Unexpected response envelope received from ${ApiConstants.addDeliveryRulesApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('getPincodeList', ApiConstants.addDeliveryRulesApiEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'DeliveryRepository.$action failed on $endpoint',
        category: 'cart_mgmt.delivery_mgmt.repository',
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
        scope.setTag('module', 'delivery_mgmt');
        scope.setTag('repository', 'DeliveryRepository');
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
