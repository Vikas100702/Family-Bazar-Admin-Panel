import 'dart:convert';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardDrawerController extends BaseController {
  final StorageService _storageService;
  DashboardDrawerController({required this._storageService});

  final RxList<DrawerMenuModel> menuItems = <DrawerMenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _parseAndBuildMenu();
  }

  void _parseAndBuildMenu() {
    try {
      final String? userDataJson = _storageService.getString('user_data');
      if (userDataJson == null || userDataJson.trim().isEmpty) {
        throw Exception("User data string found null or empty in storage.");
      }

      final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);

      final dynamic rawPermissionsNew = userDataMap['permissions_new'];

      if (rawPermissionsNew == null || rawPermissionsNew is! Map<String, dynamic> || rawPermissionsNew.isEmpty) {
        throw Exception("permissions_new payload missing, malformed, or empty.");
      }

      final Map<String, dynamic> permissionsNewMap = rawPermissionsNew;

      // Dashboard will always remain anchored at the top
      final List<DrawerMenuModel> builtMenu = [
        const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded),
      ];

      permissionsNewMap.forEach((groupKey, groupValue) {
        if (groupValue is! List) return;

        final List<dynamic> rawList = groupValue;
        if (rawList.isEmpty) return;

        // RBAC View Safety Filter: Only include modules where view == true
        final List<Map<String, dynamic>> authorizedItems = rawList.whereType<Map<String, dynamic>>().where((item) {
          final perms = item['permissions'];
          if (perms is Map<String, dynamic>) {
            final viewVal = perms['view'];
            return viewVal == true || viewVal == 'true' || viewVal == 1;
          }
          return true;
        }).toList();

        if (authorizedItems.isEmpty) return;

        // If Array Length > 1 -> Create a Dropdown Group
        if (authorizedItems.length > 1) {
          final List<DrawerMenuModel> subItems = authorizedItems.map((childObj) {
            final String name = (childObj['name'] ?? '').toString().trim();
            final String? iconUrl = childObj['icon']?.toString();

            return DrawerMenuModel(
              title: name,
              identifier: name, // The exact name of the object in the array will become the identifier for taps
              icon: iconUrl,
              fallbackIcon: _getFallbackIcon(name),
            );
          }).toList();

          final String groupTitle = _formatTitle(groupKey);
          builtMenu.add(
            DrawerMenuModel(
              title: groupTitle,
              identifier: '${groupKey.toLowerCase().replaceAll(' ', '_')}_group',
              fallbackIcon: _getFallbackIcon(groupKey),
              isExpansion: true,
              subItems: subItems,
            ),
          );
        }
        // If Array Length == 1 -> Create a direct single menu item
        else {
          final singleItem = authorizedItems.first;
          final String name = (singleItem['name'] ?? groupKey).toString().trim();
          final String? iconUrl = singleItem['icon']?.toString();

          builtMenu.add(
            DrawerMenuModel(
              title: name,
              identifier: name, // The exact name will be passed even for a single item tap
              icon: iconUrl,
              fallbackIcon: _getFallbackIcon(name),
              isExpansion: false,
            ),
          );
        }
      });

      // Only update reactive state if the controller is active
      if (!isClosed) {
        menuItems.assignAll(builtMenu);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DashboardDrawerController');
          scope.setContexts('DashboardDrawerController', {'action': '_parseAndBuildMenu', 'error': 'Failed to parse pure permissions_new structure'});
        },
      );

      if (!isClosed) {
        menuItems.assignAll(const [DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
      }
    }
  }

  /// Title formatting helper: Converts snake_case or lowercase strings to Title Case
  String _formatTitle(String key) {
    final String clean = key.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (clean.isEmpty) return key;

    final String spaced = clean.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    return spaced.split(' ').where((word) => word.isNotEmpty).map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  /// Platform safe Material Icons mapping according to module names
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
    } else if (clean.contains('order')) {
      return Icons.shopping_cart_rounded;
    } else if (clean.contains('customer')) {
      return Icons.people_rounded;
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
    Sentry.addBreadcrumb(Breadcrumb(message: 'DashboardDrawerController Disposed', category: 'drawer.controller', level: SentryLevel.info));
    super.onClose();
  }
}
