import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/view_group_items_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardGroupRepository {
  final ApiClient _apiClient;

  const DashboardGroupRepository({required this._apiClient});

  Future<ViewDashboardGroupModel> viewGroups() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewDashboardGroupApiEndpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewDashboardGroupModel.fromJson(responseData);
      }

      throw FormatException(
        '[DashboardGroupRepository.viewGroups]: Invalid data format received from endpoint: ${ApiConstants.viewDashboardGroupApiEndpoint}',
      );
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch Dashboard Group list',
          category: 'dashboard_group.repository',
          level: SentryLevel.error,
          data: {'endpoint': ApiConstants.viewDashboardGroupApiEndpoint, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setContexts('network_action', {'endpoint': ApiConstants.viewDashboardGroupApiEndpoint, 'method': 'POST'});
          },
        );
      }

      rethrow;
    }
  }

  Future<AddGroupModel> addGroup({required String groupName}) async {
    const String endpoint = ApiConstants.addDashboardGroupApiEndpoint;

    try {
      final trimmedName = groupName.trim();
      if (trimmedName.isEmpty) {
        throw ArgumentError('Group name cannot be empty.');
      }

      final response = await _apiClient.dio.post(endpoint, data: {'group_name': trimmedName});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.addGroup]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addGroup mutation',
          category: 'DashboardGroupRepository.addGroup',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_name': groupName},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setContexts('add_group_action', {'endpoint': endpoint, 'group_name': groupName});
          },
        );
      }
      rethrow;
    }
  }

  Future<AddGroupModel> updateGroup({required int groupId, String? groupName, int? status, String? gImgM, String? gImgW}) async {
    const String endpoint = ApiConstants.updateDashboardGroupApiEndpoint;

    final Map<String, dynamic> payload = {'group_id': groupId.toString()};

    if (status != null) {
      payload['status'] = status;
    }
    if (gImgM != null && gImgM.trim().isNotEmpty) {
      payload['m_img'] = gImgM.trim();
    }
    if (gImgW != null && gImgW.trim().isNotEmpty) {
      payload['w_img'] = gImgW.trim();
    }
    if (groupName != null && groupName.trim().isNotEmpty) {
      payload['group_name'] = groupName.trim();
    }

    if (payload.length == 1) {
      throw ArgumentError(
        '[DashboardGroupRepository.updateGroup]: Updation rejected. At least one field (status, mobile image, web image) must be supplied.',
      );
    }

    try {
      final response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.updateGroup]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing updateGroup mutation',
          category: 'DashboardGroupRepository.updateGroup',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setContexts('update_group_action', {'endpoint': endpoint, 'group_id': groupId});
          },
        );
      }
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteGroup({required int groupId}) async {
    const String endpoint = ApiConstants.deleteDashboardGroupApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint, data: {'group_id': groupId});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return CommonDeleteModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.deleteGroup]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing deleteGroup mutation',
          category: 'DashboardGroupRepository.deleteGroup',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setTag('group_id', groupId.toString());
            scope.setContexts('delete_group_action', {'endpoint': endpoint, 'group_id': groupId});
          },
        );
      }
      rethrow;
    }
  }

  Future<ViewGroupItemsModel> viewGroupItems({required int groupId}) async {
    const String endpoint = ApiConstants.viewGroupItemsApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint, queryParameters: {'group_id': groupId}, data: '');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewGroupItemsModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.viewGroupItems]: Invalid item data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch items for group ID: $groupId',
          category: 'dashboard_group.repository',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setTag('group_id', groupId.toString());
            scope.setContexts('network_action', {
              'endpoint': endpoint,
              'method': 'POST',
              'query_params': {'group_id': groupId},
            });
          },
        );
      }

      rethrow;
    }
  }

  Future<AddGroupItemsModel> addGroupItems({required int groupId, required List<int> itemIds}) async {
    const String endpoint = ApiConstants.addGroupItemsApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint, data: {'group_id': groupId, 'item_ids': itemIds});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupItemsModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.addGroupItems]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addGroupItems mutation',
          category: 'DashboardGroupRepository.addGroupItems',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId, 'item_ids_count': itemIds.length},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setTag('group_id', groupId.toString());
            scope.setContexts('add_group_items_action', {'endpoint': endpoint, 'group_id': groupId, 'item_ids': itemIds});
          },
        );
      }
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteGroupItems({required int groupId, required int itemId}) async {
    const String endpoint = ApiConstants.deleteGroupItemsApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint, data: {'group_id': groupId, 'item_id': itemId});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return CommonDeleteModel.fromJson(responseData);
      }

      throw FormatException('[DashboardGroupRepository.deleteGroupItem]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing deleteGroupItem mutation',
          category: 'DashboardGroupRepository.deleteGroupItem',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId, 'item_id': itemId},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'DashboardGroupRepository');
            scope.setTag('group_id', groupId.toString());
            scope.setContexts('delete_group_item_action', {'endpoint': endpoint, 'group_id': groupId, 'item_id': itemId});
          },
        );
      }
      rethrow;
    }
  }
}
