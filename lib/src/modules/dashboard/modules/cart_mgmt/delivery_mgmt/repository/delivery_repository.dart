import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_management_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DeliveryRepository {
  final ApiClient _apiClient;

  const DeliveryRepository({required this._apiClient});

  // Endpoint Constants
  static const String _listRulesEndpoint = ApiConstants.viewDeliveryRulesApiEndpoint;
  static const String _saveRuleEndpoint = ApiConstants.addDeliveryRulesApiEndpoint;
  static const String _pincodeListEndpoint = ApiConstants.pincodeListDeliveryRulesApiEndpoint;

  Future<DeliveryRulesResponseModel> getDeliveryRules({int? id, String? search, int page = 1, int limit = 20}) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      if (id == null) ...{'search': search?.trim() ?? '', 'page': page, 'limit': limit},
    };

    try {
      final Response response = await _apiClient.dio.post(_listRulesEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return DeliveryRulesResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[DeliveryRepository.getDeliveryRules]: Invalid response format from $_listRulesEndpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getDeliveryRules', _listRulesEndpoint, e, stackTrace, payload: payload);
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
      'delivery_rules': deliveryRules.map((slab) => slab.toSavePayloadJson(ruleType: ruleType)).toList(),
    };

    try {
      final Response response = await _apiClient.dio.post(_saveRuleEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SaveDeliveryRuleResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[DeliveryRepository.saveRule]: Invalid response format from $_saveRuleEndpoint');
    } catch (e, stackTrace) {
      _captureSentryError('saveRule', _saveRuleEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<DeliveryRulePincodeListResponse> getPincodeList({int? ruleId, String? search}) async {
    final Map<String, dynamic> payload = <String, dynamic>{if (ruleId != null && ruleId > 0) 'rule_id': ruleId, 'search': search?.trim() ?? ''};

    try {
      final Response response = await _apiClient.dio.post(_pincodeListEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return DeliveryRulePincodeListResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[DeliveryRepository.getPincodeList]: Invalid response format from $_pincodeListEndpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getPincodeList', _pincodeListEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'DeliveryRepository.$action failed',
        category: 'cart_mgmt.delivery_mgmt.repository',
        level: SentryLevel.error,
        data: {'action': action, 'endpoint': endpoint, 'error': error.toString(), if (payload != null) 'payload': payload},
      ),
    );

    if (error is! DioException) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('module', 'delivery_mgmt');
          scope.setTag('action', action);
          if (payload != null) {
            scope.setContexts('request_payload', payload);
          }
        },
      );
    }
  }
}
