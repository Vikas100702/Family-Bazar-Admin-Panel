import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_model.dart';
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

      return ViewDashboardGroupModel(success: false, message: 'Invalid data format received from server', data: []);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch Dashboard Group list',
          category: 'DashboardGroupRepository.viewGroups',
          level: SentryLevel.error,
          data: {'endpoint': ApiConstants.viewDashboardGroupApiEndpoint},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'DashboardGroupRepository');
          scope.setContexts('network_action', {'endpoint': ApiConstants.viewDashboardGroupApiEndpoint, 'method': 'POST'});
        },
      );

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

      return const ViewGroupItemsModel(success: false, message: 'Invalid item data format received from server', data: null);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch items for group ID: $groupId',
          category: 'DashboardGroupRepository.viewGroupItems',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId},
        ),
      );

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

      rethrow;
    }
  }

  Future<AddGroupModel> addGroup({required String groupName}) async {
    const String endpoint = '/api/product/addGroup';

    try {
      final sanitizedName = groupName.trim();
      if (sanitizedName.isEmpty) {
        throw ArgumentError('Group name cannot be empty.');
      }

      final response = await _apiClient.dio.post(endpoint, data: {'group_name': sanitizedName});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupModel.fromJson(responseData);
      }

      return AddGroupModel(success: false, message: 'Invalid response format received from server', data: null);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addGroup mutation',
          category: 'DashboardGroupRepository.addGroup',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_name': groupName},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'DashboardGroupRepository');
          scope.setContexts('add_group_action', {'endpoint': endpoint, 'group_name': groupName});
        },
      );

      rethrow;
    }
  }

  Future<AddGroupItemsModel> addGroupItems({required int groupId, required List<int> itemIds}) async {
    const String endpoint = '/api/product/addGroupItems';

    try {
      final response = await _apiClient.dio.post(endpoint, data: {'group_id': groupId, 'item_ids': itemIds});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupItemsModel.fromJson(responseData);
      }

      return const AddGroupItemsModel(success: false, message: 'Invalid response format received from server', data: null);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing addGroupItems mutation',
          category: 'DashboardGroupRepository.addGroupItems',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId, 'item_ids_count': itemIds.length},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'DashboardGroupRepository');
          scope.setTag('group_id', groupId.toString());
          scope.setContexts('add_group_items_action', {'endpoint': endpoint, 'group_id': groupId, 'item_ids': itemIds});
        },
      );

      rethrow;
    }
  }

  Future<AddGroupItemsModel> deleteGroupItems({required int groupId, required int itemId}) async {
    const String endpoint = ApiConstants.deleteGroupItemsApiEndpoint;

    try {
      final response = await _apiClient.dio.post(endpoint, data: {'group_id': groupId, 'item_id': itemId});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return AddGroupItemsModel.fromJson(responseData);
      }

      return const AddGroupItemsModel(success: false, message: 'Invalid response format received from server', data: null);
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing deleteGroupItem mutation',
          category: 'DashboardGroupRepository.deleteGroupItem',
          level: SentryLevel.error,
          data: {'endpoint': endpoint, 'group_id': groupId, 'item_id': itemId},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'DashboardGroupRepository');
          scope.setTag('group_id', groupId.toString());
          scope.setContexts('delete_group_item_action', {'endpoint': endpoint, 'group_id': groupId, 'item_id': itemId});
        },
      );

      rethrow;
    }
  }
}
