import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/save_points_settings_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/view_loyalty_rules_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoyaltyRepository {
  final ApiClient _apiClient;

  const LoyaltyRepository({required this._apiClient});

  Future<AvailableItemsModel> getAvailableItems({int? ruleId, String? search, int page = 1, int limit = 1000}) async {
    final Map<String, dynamic> payload = {
      if (ruleId != null && ruleId > 0) 'rule_id': ruleId,
      'searchvalue': search?.trim() ?? '',
      'page': page,
      'limit': limit,
    };

    try {
      final Response response = await _apiClient.dio.post(ApiConstants.getAvailableItemsEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return AvailableItemsModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('[LoyaltyRepository.getAvailableItems]: Invalid response format');
    } catch (e, stackTrace) {
      _captureSentryError('getAvailableItems', ApiConstants.getAvailableItemsEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewLoyaltyRulesModel> getLoyaltyRules({int? id, int? status, String? search, int page = 1, int limit = 10}) async {
    final Map<String, dynamic> payload = {
      if (id != null && id > 0) 'id': id,
      if (status != null) 'status': status,
      if (id == null) ...{'searchvalue': search?.trim() ?? '', 'page': page, 'limit': limit},
    };

    try {
      final Response response = await _apiClient.dio.post(ApiConstants.getRulesEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return ViewLoyaltyRulesModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('[LoyaltyRepository.getLoyaltyRules]: Invalid response format');
    } catch (e, stackTrace) {
      _captureSentryError('getLoyaltyRules', ApiConstants.getRulesEndpoint, e, stackTrace, payload: payload);
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
    final Map<String, dynamic> payload = {
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
      final Response response = await _apiClient.dio.post(ApiConstants.saveRuleEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SaveLoyaltyRuleModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('[LoyaltyRepository.saveLoyaltyRule]: Invalid response format');
    } catch (e, stackTrace) {
      _captureSentryError('saveLoyaltyRule', ApiConstants.saveRuleEndpoint, e, stackTrace, payload: payload);
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
    final Map<String, dynamic> payload = {
      if (id != null && id > 0) 'id': id,
      'rupees_per_point': rupeesPerPoint,
      'points_per_rupee': pointsPerRupee,
      'loyalty_conflict_priority': loyaltyConflictPriority.trim(),
      'new_cust_reward': newCustReward,
      'cust_reff_reward': custReffReward,
    };

    try {
      final Response response = await _apiClient.dio.post(ApiConstants.savePointsSettingsEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return SavePointsSettingsModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('[LoyaltyRepository.savePointsSettings]: Invalid response format');
    } catch (e, stackTrace) {
      _captureSentryError('savePointsSettings', ApiConstants.savePointsSettingsEndpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'LoyaltyRepository.$action failed',
        category: 'loyalty_program.repository',
        level: SentryLevel.error,
        data: {'action': action, 'endpoint': endpoint, 'error': error.toString(), if (payload != null) 'payload': payload},
      ),
    );

    if (error is! DioException) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('module', 'loyalty_program');
          scope.setTag('action', action);
          if (payload != null) {
            scope.setContexts('request_payload', payload);
          }
        },
      );
    }
  }
}
