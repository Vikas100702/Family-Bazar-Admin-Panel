import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/mixins/common_delete_mixin.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardGroupRepository with CommonDeleteMixin {
  final ApiClient _apiClient;
  const DashboardGroupRepository({required this._apiClient});

  @override
  ApiClient get apiClient => _apiClient;

  Future<ViewDashboardGroupModel> viewGroups() async {
    const String endpoint = ApiConstants.viewDashboardGroupApiEndpoint;

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewDashboardGroupModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.viewGroups]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewGroups', endpoint, e, stackTrace);
      rethrow;
    }
  }

  Future<AddGroupModel> addGroup({required String groupName}) async {
    const String endpoint = ApiConstants.addDashboardGroupApiEndpoint;
    final String trimmedName = groupName.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Group name cannot be empty.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{'group_name': trimmedName};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.addGroup]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addGroup', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<AddGroupModel> updateGroup({required int groupId, String? groupName, int? status, String? gImgM, String? gImgW}) async {
    const String endpoint = ApiConstants.updateDashboardGroupApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{
      'group_id': groupId.toString(),
      'status': ?status,
      if (gImgM != null && gImgM.trim().isNotEmpty) 'm_img': gImgM.trim(),
      if (gImgW != null && gImgW.trim().isNotEmpty) 'w_img': gImgW.trim(),
      if (groupName != null && groupName.trim().isNotEmpty) 'group_name': groupName.trim(),
    };

    if (payload.length == 1) {
      throw ArgumentError(
        '[DashboardGroupRepository.updateGroup]: Updation rejected. At least one field (status, mobile image, web image) must be supplied.',
      );
    }

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.updateGroup]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('updateGroup', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteGroup({required int groupId}) {
    return executeDelete(tableName: 'DashboardGroup', id: groupId);
  }

  Future<ViewItemByTypeModel> viewGroupItems({required int groupId}) async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'_id': groupId.toString(), 'type': 'GROUP', 'isAdmin': '1'};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.viewGroupItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewGroupItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewItemByTypeModel> viewFirmItems(String? firmCode) async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'type': 'FIRM', 'isAdmin': '1'};
    final String? cleanCode = firmCode?.trim();

    if (cleanCode != null && cleanCode.isNotEmpty && cleanCode.toUpperCase() != 'ALL') {
      payload['_id'] = cleanCode;
    }

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.viewFirmItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewFirmItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<AddGroupItemsModel> addGroupItems({required int groupId, required List<String> itemCode}) async {
    const String endpoint = ApiConstants.addGroupItemsApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'group_id': groupId, 'item_ids': itemCode};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupItemsModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.addGroupItems]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addGroupItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteGroupItems({required int groupId, required String itemCode}) async {
    const String endpoint = ApiConstants.deleteGroupItemsApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'group_id': groupId, 'item_code': itemCode.trim()};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return CommonDeleteModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.deleteGroupItem]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('deleteGroupItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'DashboardGroupRepository.$action failed on $endpoint',
        category: 'product.dashboard_group.repository',
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
        scope.setTag('module', 'dashboard_group');
        scope.setTag('repository', 'DashboardGroupRepository');
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
