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

  // REACTIVE STATE & LOCKS
  final RxList<DrawerMenuModel> menuItems = <DrawerMenuModel>[].obs;
  final RxBool isSyncingPermissions = false.obs;
  bool _isSyncLocked = false;

  @override
  void onInit() {
    super.onInit();
    _parseAndBuildMenuFromStorage();
    syncPermissionsFromServer();
  }

  Future<void> syncPermissionsFromServer() async {
    if (_isSyncLocked) return;

    try {
      final String? token = _storageService.getString(AppConstants.authTokenKey);
      if (token == null || token.trim().isEmpty) return;

      final int roleId = _resolveCurrentRoleId();
      if (roleId <= 0) return;

      _isSyncLocked = true;
      isSyncingPermissions.value = true;

      final Map<String, List<PermissionModuleItem>> freshPermissions = await _loginRepository.fetchPermissionMenu(roleId: roleId);

      if (isClosed) return;

      if (freshPermissions.isNotEmpty) {
        _buildMenuFromPermissionsMap(freshPermissions);
        _updateStoredPermissions(freshPermissions);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('controller', 'DashboardDrawerController');
          scope.setTag('action', 'syncPermissionsFromServer');
        },
      );
    } finally {
      _isSyncLocked = false;
      if (!isClosed) {
        isSyncingPermissions.value = false;
      }
    }
  }

  int _resolveCurrentRoleId() {
    try {
      final String? userDataJson = _storageService.getString('user_data');
      if (userDataJson != null && userDataJson.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(userDataJson);
        if (decoded is Map<String, dynamic>) {
          final dynamic roleId = decoded['role_id'] ?? decoded['role-id'];
          if (roleId is int) return roleId;
          return int.tryParse(roleId?.toString() ?? '') ?? 1;
        }
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

      final dynamic decoded = jsonDecode(userDataJson);
      if (decoded is! Map<String, dynamic>) {
        _setFallbackDashboardOnly();
        return;
      }

      final dynamic rawPermissionsNew = decoded['permissions_new'];
      if (rawPermissionsNew == null || rawPermissionsNew is! Map<String, dynamic>) {
        _setFallbackDashboardOnly();
        return;
      }

      final Map<String, List<PermissionModuleItem>> parsedMap = <String, List<PermissionModuleItem>>{};
      rawPermissionsNew.forEach((String key, dynamic listVal) {
        if (listVal is List) {
          parsedMap[key] = listVal.whereType<Map<String, dynamic>>().map(PermissionModuleItem.fromJson).toList(growable: false);
        }
      });

      _buildMenuFromPermissionsMap(parsedMap);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('controller', 'DashboardDrawerController');
          scope.setTag('action', '_parseAndBuildMenuFromStorage');
        },
      );
      _setFallbackDashboardOnly();
    }
  }

  void _buildMenuFromPermissionsMap(Map<String, List<PermissionModuleItem>> permissionsMap) {
    final List<DrawerMenuModel> builtMenu = <DrawerMenuModel>[
      DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded),
    ];

    permissionsMap.forEach((String groupKey, List<PermissionModuleItem> groupItems) {
      if (groupItems.isEmpty) return;

      // Filter viewable items only
      final List<PermissionModuleItem> authorizedItems = groupItems
          .where((PermissionModuleItem item) => item.permissions.view)
          .toList(growable: false);

      if (authorizedItems.isEmpty) return;

      DrawerMenuModel mapToDrawerItem(PermissionModuleItem item) {
        final String name = item.name.trim();

        // 3rd Tier: child contains viewable modules
        final List<PermissionModuleItem> authorizedChildren = item.child
            .where((PermissionModuleItem c) => c.permissions.view)
            .toList(growable: false);

        if (authorizedChildren.isNotEmpty) {
          final List<DrawerMenuModel> thirdTierSubItems = authorizedChildren
              .map((PermissionModuleItem c) {
                final String childName = c.name.trim();
                return DrawerMenuModel(
                  title: childName,
                  identifier: childName,
                  icon: c.icon,
                  fallbackIcon: _getFallbackIcon(childName),
                  isExpansion: false,
                );
              })
              .toList(growable: false);

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
        final List<DrawerMenuModel> subItems = authorizedItems.map(mapToDrawerItem).toList(growable: false);

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
        final PermissionModuleItem singleItem = authorizedItems.first;
        final DrawerMenuModel mappedItem = mapToDrawerItem(singleItem);

        if (mappedItem.hasSubItems) {
          builtMenu.add(
            DrawerMenuModel(
              title: _formatTitle(groupKey),
              identifier: '${groupKey.toLowerCase().replaceAll(' ', '_')}_group',
              fallbackIcon: _getFallbackIcon(groupKey),
              isExpansion: true,
              subItems: <DrawerMenuModel>[mappedItem],
            ),
          );
        } else {
          final String name = singleItem.name.trim().isNotEmpty ? singleItem.name.trim() : groupKey;
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
      Map<String, dynamic> userDataMap = <String, dynamic>{};

      if (userDataJson != null && userDataJson.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(userDataJson);
        if (decoded is Map<String, dynamic>) {
          userDataMap = decoded;
        }
      }

      userDataMap['permissions_new'] = freshPermissions.map(
        (String key, List<PermissionModuleItem> list) =>
            MapEntry(key, list.map((PermissionModuleItem item) => item.toJson()).toList(growable: false)),
      );

      _storageService.setString('user_data', jsonEncode(userDataMap));
    } catch (_) {}
  }

  void _setFallbackDashboardOnly() {
    if (!isClosed) {
      menuItems.assignAll(<DrawerMenuModel>[DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
    }
  }

  String _formatTitle(String key) {
    final String clean = key.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (clean.isEmpty) return key;
    final String spaced = clean.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    return spaced
        .split(' ')
        .where((String word) => word.isNotEmpty)
        .map((String word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  IconData _getFallbackIcon(String identifier) {
    final String cleanKey = identifier.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
    if (cleanKey.contains('dashboard')) {
      return Icons.space_dashboard_rounded;
    } else if (cleanKey.contains('firm')) {
      return Icons.domain_rounded;
    } else if (cleanKey.contains('pincode') || cleanKey.contains('pin')) {
      return Icons.pin_drop_rounded;
    } else if (cleanKey.contains('coupon')) {
      return Icons.discount_rounded;
    } else if (cleanKey.contains('category')) {
      return Icons.category_rounded;
    } else if (cleanKey.contains('subcategory')) {
      return Icons.account_tree_rounded;
    } else if (cleanKey.contains('brand')) {
      return Icons.branding_watermark_rounded;
    } else if (cleanKey.contains('item') || cleanKey.contains('product')) {
      return Icons.inventory_2_rounded;
    } else if (cleanKey.contains('dashboardgroup') || cleanKey.contains('group')) {
      return Icons.grid_view_rounded;
    } else if (cleanKey.contains('banner')) {
      return Icons.view_carousel_rounded;
    } else if (cleanKey.contains('cart')) {
      return Icons.shopping_cart_rounded;
    } else if (cleanKey.contains('customer')) {
      return Icons.people_rounded;
    } else if (cleanKey.contains('loyalty')) {
      return Icons.military_tech_rounded;
    } else if (cleanKey.contains('coin')) {
      return Icons.monetization_on_rounded;
    } else if (cleanKey.contains('payment')) {
      return Icons.payment_rounded;
    } else if (cleanKey.contains('report')) {
      return Icons.analytics_rounded;
    } else if (cleanKey.contains('setting')) {
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
