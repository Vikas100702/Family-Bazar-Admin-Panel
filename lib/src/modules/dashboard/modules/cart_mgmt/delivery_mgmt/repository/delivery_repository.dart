import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/add_distance_rule_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_rule_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/save_delivery_rules_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/view_delivery_rules_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DeliveryRepository {
  final ApiClient _apiClient;
  const DeliveryRepository({required this._apiClient});

  /// Inserts a new delivery rule or updates an existing one when [id] is supplied.
  Future<SaveDeliveryRulesModel> addDeliveryRules({
    int? id,
    required String ruleName,
    String? description,
    required int priority,
    required int status,
    required List<int> pincodeIds,
  }) async {
    final Map<String, dynamic> payload = {
      'id': ?id,
      'rule_name': ruleName.trim(),
      'description': description?.trim() ?? '',
      'priority': priority,
      'status': status,
      'pincode_ids': pincodeIds,
    };
    try {
      final response = await _apiClient.dio.post(ApiConstants.addDeliveryRulesApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return SaveDeliveryRulesModel.fromJson(responseData);
      }
      throw FormatException(
        '[DeliveryRepository.addDeliveryRules]: Invalid data format received from endpoint: ${ApiConstants.addDeliveryRulesApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('addDeliveryRules', e, stackTrace, endpoint: ApiConstants.addDeliveryRulesApiEndpoint, payload: payload);
      rethrow;
    }
  }

  /// Fetches paginated delivery rules with search query.
  Future<ViewDeliveryRulesModel> viewDeliveryRulesList({int page = 1, int limit = 20, String? searchValue}) async {
    final String cleanSearch = searchValue?.trim() ?? '';
    final Map<String, dynamic> payload = {'searchvalue': cleanSearch, 'isAdmin': 1, 'page': page, 'limit': limit};
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewDeliveryRulesApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewDeliveryRulesModel.fromJson(responseData);
      }
      throw FormatException(
        '[DeliveryRepository.viewDeliveryRulesList]: Invalid data format received from endpoint: ${ApiConstants.viewDeliveryRulesApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('viewDeliveryRulesList', e, stackTrace, endpoint: ApiConstants.viewDeliveryRulesApiEndpoint, payload: payload);
      rethrow;
    }
  }

  /// Fetches complete detail breakdown (including mapped pincodes & distance rules) of a rule by its ID.
  Future<DeliveryRuleDetailsModel> getDeliveryRuleDetails(int id) async {
    final Map<String, dynamic> payload = {'id': id.toString()};
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewDeliveryRulesApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return DeliveryRuleDetailsModel.fromJson(responseData);
      }
      throw FormatException('[DeliveryRepository.getDeliveryRuleDetails]: Invalid data format received for rule id: $id');
    } catch (e, stackTrace) {
      _captureSentryError('getDeliveryRuleDetails', e, stackTrace, endpoint: ApiConstants.viewDeliveryRulesApiEndpoint, payload: payload);
      rethrow;
    }
  }

  /// Adds a new distance slab or updates an existing one when [id] is supplied.
  Future<AddDistanceRulesModel> saveDistanceSlab({
    int? id,
    required int ruleId,
    required int minDistanceKm,
    required int maxDistanceKm,
    required int minOrderAmount,
    int? maxOrderAmount,
    required int baseCharge,
    required int perKmCharge,
    required int priority,
    required int status,
  }) async {
    final Map<String, dynamic> payload = {
      'id': ?id,
      'rule_id': ruleId,
      'min_distance_km': minDistanceKm,
      'max_distance_km': maxDistanceKm,
      'min_order_amount': minOrderAmount,
      'max_order_amount': maxOrderAmount,
      'base_charge': baseCharge,
      'per_km_charge': perKmCharge,
      'priority': priority,
      'status': status,
    };
    try {
      final response = await _apiClient.dio.post(ApiConstants.saveDistanceSlabApiEndpoint, data: payload);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddDistanceRulesModel.fromJson(responseData);
      }
      throw FormatException(
        '[DeliveryRepository.saveDistanceSlab]: Invalid data format received from endpoint: ${ApiConstants.saveDistanceSlabApiEndpoint}',
      );
    } catch (e, stackTrace) {
      _captureSentryError('saveDistanceSlab', e, stackTrace, endpoint: ApiConstants.saveDistanceSlabApiEndpoint, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, Object error, StackTrace stackTrace, {required String endpoint, Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'DeliveryRepository.$action failed',
        category: 'delivery_mgmt.repository',
        level: SentryLevel.error,
        data: {'action': action, 'endpoint': endpoint, 'error': error.toString(), 'payload': ?payload},
      ),
    );
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('module', 'delivery_mgmt');
        scope.setTag('action', action);
        if (payload != null) {
          scope.setContexts('request_payload', payload);
        }
        if (error is DioException && error.response != null) {
          scope.setContexts('response_data', {'statusCode': error.response?.statusCode, 'data': error.response?.data});
        }
      },
    );
  }
}
