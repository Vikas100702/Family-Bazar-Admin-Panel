import 'dart:convert';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
import 'package:family_bazar_admin_panel/src/modules/login/model/login_model/login_model.dart';
import 'package:family_bazar_admin_panel/src/modules/login/repository/login_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardDrawerController extends BaseController {
  final LoginRepository _loginRepository;
  final StorageService _storageService;

  DashboardDrawerController({required this._storageService, required this._loginRepository});

  final RxList<DrawerMenuModel> menuItems = <DrawerMenuModel>[].obs;
  final RxBool isSyncingPermissions = false.obs;

  @override
  void onInit() {
    super.onInit();
    _parseAndBuildMenuFromStorage();
    syncPermissionsFromServer();
  }

  Future<void> syncPermissionsFromServer() async {
    try {
      final String? token = _storageService.getString(AppConstants.authTokenKey);
      if (token == null || token.trim().isEmpty) return;

      final int roleId = _resolveCurrentRoleId();
      if (roleId <= 0) return;

      isSyncingPermissions.value = true;
      final Map<String, List<PermissionModuleItem>> freshPermissions = await _loginRepository.fetchPermissionMenu(roleId: roleId);

      if (freshPermissions.isNotEmpty) {
        _buildMenuFromPermissionsMap(freshPermissions);
        _updateStoredPermissions(freshPermissions);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DashboardDrawerController');
          scope.setTag('action', 'syncPermissionsFromServer');
        },
      );
    } finally {
      if (!isClosed) {
        isSyncingPermissions.value = false;
      }
    }
  }

  int _resolveCurrentRoleId() {
    try {
      final String? userDataJson = _storageService.getString('user_data');
      if (userDataJson != null && userDataJson.isNotEmpty) {
        final Map<String, dynamic> dataMap = jsonDecode(userDataJson);
        final dynamic roleId = dataMap['role_id'] ?? dataMap['role-id'];
        if (roleId is int) return roleId;
        return int.tryParse(roleId?.toString() ?? '') ?? 1;
      }
    } catch (_) {}
    return 1;
  }

  void _parseAndBuildMenuFromStorage() {
    try {
      final String? userDataJson = _storageService.getString('user_data');
      if (userDataJson == null || userDataJson.trim().isEmpty) {
        _setFallbackDashboardOnly();
        return;
      }

      final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      final dynamic rawPermissionsNew = userDataMap['permissions_new'];
      if (rawPermissionsNew == null || rawPermissionsNew is! Map<String, dynamic>) {
        _setFallbackDashboardOnly();
        return;
      }

      final Map<String, List<PermissionModuleItem>> parsedMap = {};
      rawPermissionsNew.forEach((key, listVal) {
        if (listVal is List) {
          parsedMap[key] = listVal.whereType<Map<String, dynamic>>().map((item) => PermissionModuleItem.fromJson(item)).toList();
        }
      });

      _buildMenuFromPermissionsMap(parsedMap);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DashboardDrawerController');
          scope.setTag('action', '_parseAndBuildMenuFromStorage');
        },
      );
      _setFallbackDashboardOnly();
    }
  }

  void _buildMenuFromPermissionsMap(Map<String, List<PermissionModuleItem>> permissionsMap) {
    final List<DrawerMenuModel> builtMenu = [
      const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded),
    ];

    permissionsMap.forEach((groupKey, groupItems) {
      if (groupItems.isEmpty) return;

      // 1st Tier Guard: Only items with view == true
      final List<PermissionModuleItem> authorizedItems = groupItems.where((item) => item.permissions.view).toList();
      if (authorizedItems.isEmpty) return;

      // Helper function to map PermissionModuleItem to DrawerMenuModel recursively
      DrawerMenuModel mapToDrawerItem(PermissionModuleItem item) {
        final String name = item.name.trim();

        // 3rd Tier Check: If child exists and contains viewable items
        final List<PermissionModuleItem> authorizedChildren = item.child.where((c) => c.permissions.view).toList();

        if (authorizedChildren.isNotEmpty) {
          final List<DrawerMenuModel> thirdTierSubItems = authorizedChildren.map((c) {
            final String childName = c.name.trim();
            return DrawerMenuModel(
              title: childName,
              identifier: childName,
              icon: c.icon,
              fallbackIcon: _getFallbackIcon(childName),
              isExpansion: false,
            );
          }).toList();

          return DrawerMenuModel(
            title: name,
            identifier: name,
            icon: item.icon,
            fallbackIcon: _getFallbackIcon(name),
            isExpansion: true,
            subItems: thirdTierSubItems,
          );
        }

        return DrawerMenuModel(title: name, identifier: name, icon: item.icon, fallbackIcon: _getFallbackIcon(name), isExpansion: false);
      }

      if (authorizedItems.length > 1) {
        final List<DrawerMenuModel> subItems = authorizedItems.map((childObj) => mapToDrawerItem(childObj)).toList();

        builtMenu.add(
          DrawerMenuModel(
            title: _formatTitle(groupKey),
            identifier: '${groupKey.toLowerCase().replaceAll(' ', '_')}_group',
            fallbackIcon: _getFallbackIcon(groupKey),
            isExpansion: true,
            subItems: subItems,
          ),
        );
      } else {
        final singleItem = authorizedItems.first;
        final mappedItem = mapToDrawerItem(singleItem);

        if (mappedItem.hasSubItems) {
          builtMenu.add(
            DrawerMenuModel(
              title: _formatTitle(groupKey),
              identifier: '${groupKey.toLowerCase().replaceAll(' ', '_')}_group',
              fallbackIcon: _getFallbackIcon(groupKey),
              isExpansion: true,
              subItems: [mappedItem],
            ),
          );
        } else {
          final String name = singleItem.name.isNotEmpty ? singleItem.name : groupKey;
          builtMenu.add(
            DrawerMenuModel(title: name, identifier: name, icon: singleItem.icon, fallbackIcon: _getFallbackIcon(name), isExpansion: false),
          );
        }
      }
    });

    if (!isClosed) {
      menuItems.assignAll(builtMenu);
    }
  }

  void _updateStoredPermissions(Map<String, List<PermissionModuleItem>> freshPermissions) {
    try {
      final String? userDataJson = _storageService.getString('user_data');
      Map<String, dynamic> userDataMap = {};
      if (userDataJson != null && userDataJson.isNotEmpty) {
        userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
      }

      userDataMap['permissions_new'] = freshPermissions.map((key, list) => MapEntry(key, list.map((item) => item.toJson()).toList()));

      _storageService.setString('user_data', jsonEncode(userDataMap));
    } catch (_) {}
  }

  void _setFallbackDashboardOnly() {
    if (!isClosed) {
      menuItems.assignAll(const [DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
    }
  }

  String _formatTitle(String key) {
    final String clean = key.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (clean.isEmpty) return key;

    final String spaced = clean.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    return spaced.split(' ').where((word) => word.isNotEmpty).map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  IconData _getFallbackIcon(String identifier) {
    final String clean = identifier.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');

    if (clean.contains('firm')) {
      return Icons.domain_rounded;
    } else if (clean.contains('pincode') || clean.contains('pin')) {
      return Icons.pin_drop_rounded;
    } else if (clean.contains('coupon')) {
      return Icons.discount_rounded;
    } else if (clean.contains('category')) {
      return Icons.category_rounded;
    } else if (clean.contains('subcategory')) {
      return Icons.account_tree_rounded;
    } else if (clean.contains('brand')) {
      return Icons.branding_watermark_rounded;
    } else if (clean.contains('item') || clean.contains('product')) {
      return Icons.inventory_2_rounded;
    } else if (clean.contains('dashboardgroup') || clean.contains('group')) {
      return Icons.grid_view_rounded;
    } else if (clean.contains('banner')) {
      return Icons.view_carousel_rounded;
    } else if (clean.contains('cart')) {
      return Icons.shopping_cart_rounded;
    } else if (clean.contains('customer')) {
      return Icons.people_rounded;
    } else if (clean.contains('loyalty')) {
      return Icons.military_tech_rounded;
    } else if (clean.contains('coin')) {
      return Icons.monetization_on_rounded;
    } else if (clean.contains('payment')) {
      return Icons.payment_rounded;
    } else if (clean.contains('report')) {
      return Icons.analytics_rounded;
    } else if (clean.contains('setting')) {
      return Icons.settings_rounded;
    }
    return Icons.widgets_rounded;
  }

  @override
  void onClose() {
    menuItems.clear();
    super.onClose();
  }
}
