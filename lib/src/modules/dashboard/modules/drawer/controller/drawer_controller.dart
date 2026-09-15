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

  static const Set<String> _allowedDirectKeys = {'firm setup', 'pin code settings'};

  static const Set<String> _allowedProductKeys = {'productcategory', 'productsubcategory', 'productitem', 'productdashboardgroup', 'productbrand'};

  @override
  void onInit() {
    super.onInit();
    _parseAndBuildMenu();
  }

  void _parseAndBuildMenu() {
    try {
      // Proactive Memory & Architecture: Use centralized storage token key
      final String? userDataJson = _storageService.getString('user_data');
      if (userDataJson == null || userDataJson.trim().isEmpty) {
        throw Exception("User data string is null or empty in storage.");
      }

      final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      final dynamic rawPermissions = userDataMap['permissions'];

      if (rawPermissions == null || rawPermissions is! Map<String, dynamic> || rawPermissions.isEmpty) {
        throw Exception("Permissions map is missing, malformed, or empty in user data.");
      }

      final Map<String, dynamic> apiPermissions = rawPermissions;

      // Dashboard is always anchored at the top
      final List<DrawerMenuModel> builtMenu = [
        const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded),
      ];

      final List<DrawerMenuModel> productSubItems = [];

      apiPermissions.forEach((key, value) {
        // Prevents runtime Type Error on Flutter Web
        if (value is! Map<String, dynamic>) return;

        final String? apiIconUrl = value['icon']?.toString();
        final String cleanKey = key.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');

        // Filter Product sub-items
        if (_allowedProductKeys.contains(cleanKey) ||
            cleanKey == 'category' ||
            cleanKey == 'subcategory' ||
            cleanKey == 'item' ||
            cleanKey == 'dashboardgroup' ||
            cleanKey == 'brand') {
          productSubItems.add(
            DrawerMenuModel(
              title: _formatTitle(key, prefixToRemove: 'product'),
              identifier: key,
              icon: apiIconUrl,
              fallbackIcon: Icons.subdirectory_arrow_right_rounded,
            ),
          );
        }
        // Filter Direct root items
        else if (_allowedDirectKeys.any((allowed) {
          final cleanAllowed = allowed.replaceAll(RegExp(r'[\s_\-]+'), '');
          return cleanKey.contains(cleanAllowed);
        })) {
          builtMenu.add(DrawerMenuModel(title: _formatTitle(key), identifier: key, icon: apiIconUrl, fallbackIcon: _getFallbackIcon(key)));
        }
      });

      // Attach Product Management expandable group with sorting
      if (productSubItems.isNotEmpty) {
        productSubItems.sort((a, b) {
          const sortOrder = {'category': 1, 'sub category': 2, 'item': 3, 'dashboard group': 4, 'brand': 4};
          final aOrder = sortOrder[a.title.toLowerCase()] ?? 99;
          final bOrder = sortOrder[b.title.toLowerCase()] ?? 99;
          return aOrder.compareTo(bOrder);
        });

        builtMenu.add(
          DrawerMenuModel(
            title: 'Product Management',
            identifier: 'product_group',
            fallbackIcon: Icons.inventory_2_rounded,
            isExpansion: true,
            subItems: productSubItems,
          ),
        );
      }

      // Protect state mutation if disposed during execution
      if (!isClosed) {
        menuItems.assignAll(builtMenu);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('controller', 'DashboardDrawerController');
          scope.setContexts('DashboardDrawerController', {'action': '_parseAndBuildMenu', 'error': 'Failed to parse RBAC permissions'});
        },
      );

      if (!isClosed) {
        menuItems.assignAll(const [DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
      }
    }
  }

  String _formatTitle(String key, {String? prefixToRemove}) {
    String text = key;

    if (prefixToRemove != null && text.toLowerCase().startsWith(prefixToRemove.toLowerCase())) {
      text = text.substring(prefixToRemove.length);
    }

    text = text.replaceAll(RegExp(r'^[_\-\s]+'), '');
    if (text.isEmpty) return key;

    final String formatted = text.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    return formatted[0].toUpperCase() + formatted.substring(1).trim();
  }

  IconData _getFallbackIcon(String key) {
    final String cleanKey = key.toLowerCase().replaceAll(RegExp(r'[_\-\s]+'), '');

    if (cleanKey.contains('firm')) {
      return Icons.domain_rounded;
    } else if (cleanKey.contains('pin')) {
      return Icons.pin_drop_rounded;
    } else if (cleanKey.contains('product')) {
      return Icons.inventory_2_rounded;
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
