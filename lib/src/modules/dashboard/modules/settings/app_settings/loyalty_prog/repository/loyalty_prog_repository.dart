import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/mixins/common_delete_mixin.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/save_points_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/view_loyalty_rules_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoyaltyRepository with CommonDeleteMixin {
  final ApiClient _apiClient;
  const LoyaltyRepository({required this._apiClient});

  @override
  ApiClient get apiClient => _apiClient;

  Future<AvailableItemsModel> getAvailableItems({int? ruleId, String? search, int page = 1, int limit = 20}) async {
    const String endpoint = ApiConstants.getAvailableItemsApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      if (ruleId != null && ruleId > 0) 'rule_id': ruleId,
      'searchvalue': search?.trim() ?? '',
      'page': page,
      'limit': limit,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AvailableItemsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[LoyaltyRepository.getAvailableItems]: Invalid response format from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getAvailableItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewLoyaltyRulesModel> getLoyaltyRules({int? id, int? status, String? search, int page = 1, int limit = 20}) async {
    const String endpoint = ApiConstants.getRulesApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      'status': ?status,
      if (id == null) ...<String, dynamic>{'searchvalue': search?.trim() ?? '', 'page': page, 'limit': limit},
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ViewLoyaltyRulesModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[LoyaltyRepository.getLoyaltyRules]: Invalid response format from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getLoyaltyRules', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<SaveLoyaltyRuleModel> saveLoyaltyRule({
    int? id,
    required String ruleName,
    required List<String> brandCodes,
    required List<String> categoryCodes,
    required double minOrderAmt,
    double? maxOrderAmt,
    required double pointsValue,
    required int status,
    String? expiryDate,
  }) async {
    const String endpoint = ApiConstants.saveRuleApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      'rule_name': ruleName.trim(),
      'brands': brandCodes,
      'categories': categoryCodes,
      'min_order_amt': minOrderAmt,
      if (maxOrderAmt != null && maxOrderAmt > 0) 'max_order_amt': maxOrderAmt,
      'points_value': pointsValue,
      'status': status,
      if (expiryDate != null && expiryDate.trim().isNotEmpty) 'expiry_date': expiryDate.trim(),
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SaveLoyaltyRuleModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[LoyaltyRepository.saveLoyaltyRule]: Invalid response format from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('saveLoyaltyRule', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<SavePointsSettingsModel> savePointsSettings({
    int? id,
    required double rupeesPerPoint,
    required double pointsPerRupee,
    required String loyaltyConflictPriority,
    required num newCustReward,
    required num custReffReward,
  }) async {
    const String endpoint = ApiConstants.savePointsSettingsApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      if (id != null && id > 0) 'id': id,
      'rupees_per_point': rupeesPerPoint,
      'points_per_rupee': pointsPerRupee,
      'loyalty_conflict_priority': loyaltyConflictPriority.trim(),
      'new_cust_reward': newCustReward,
      'cust_reff_reward': custReffReward,
    };

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SavePointsSettingsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[LoyaltyRepository.savePointsSettings]: Invalid response format from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('savePointsSettings', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteRule({required int ruleId}) {
    return executeDelete(tableName: 'LoyaltyRules', id: ruleId);
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'LoyaltyRepository.$action failed on $endpoint',
        category: 'settings.loyalty_program.repository',
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
        scope.setTag('module', 'loyalty_program');
        scope.setTag('repository', 'LoyaltyRepository');
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
