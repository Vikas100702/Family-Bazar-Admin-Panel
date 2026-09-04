// // import 'dart:convert';
// //
// // import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
// // import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
// // import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:sentry_flutter/sentry_flutter.dart';
// //
// // class DashboardDrawerController extends BaseController {
// //   final StorageService _storageService;
// //
// //   DashboardDrawerController(this._storageService);
// //
// //   // Reactive state for memory-safe UI rendering
// //   final RxList<DrawerMenuModel> menuItems = <DrawerMenuModel>[].obs;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     _parseAndBuildMenu();
// //   }
// //
// //   /// Parses RBAC permissions from local storage and constructs the menu hierarchy.
// //   void _parseAndBuildMenu() {
// //     try {
// //       final String? userDataJson = _storageService.getString('user_data');
// //       if (userDataJson == null || userDataJson.isEmpty) {
// //         throw Exception("User data string is null or empty in storage.");
// //       }
// //
// //       final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
// //
// //       // Extracting the "permissions" block safely
// //       final Map<String, dynamic>? apiPermissions = userDataMap['permissions'] as Map<String, dynamic>?;
// //       if (apiPermissions == null || apiPermissions.isEmpty) {
// //         throw Exception("Permissions object is missing or empty in user data.");
// //       }
// //
// //       List<DrawerMenuModel> builtMenu = [const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)];
// //       List<DrawerMenuModel> masterSubItems = [];
// //
// //       apiPermissions.forEach((key, value) {
// //         // Safe extraction of network image URL (can be null)
// //         final String? apiIconUrl = value['icon'] as String?;
// //
// //         if (key.toLowerCase().startsWith('master')) {
// //           masterSubItems.add(
// //             DrawerMenuModel(title: _formatMasterTitle(key), identifier: key, icon: apiIconUrl, fallbackIcon: Icons.subdirectory_arrow_right_rounded),
// //           );
// //         } else {
// //           builtMenu.add(DrawerMenuModel(title: key, identifier: key, icon: apiIconUrl, fallbackIcon: _getFallbackIcon(key)));
// //         }
// //       });
// //
// //       // Group master items if they exist
// //       if (masterSubItems.isNotEmpty) {
// //         builtMenu.insert(
// //           1, // Place right after Dashboard
// //           DrawerMenuModel(
// //             title: 'Master Settings',
// //             identifier: 'master_group',
// //             fallbackIcon: Icons.admin_panel_settings_rounded,
// //             isExpansion: true,
// //             subItems: masterSubItems,
// //           ),
// //         );
// //       }
// //
// //       // Defensive Tactic: Ensure controller is still mounted before updating UI
// //       if (!isClosed) {
// //         menuItems.assignAll(builtMenu);
// //       }
// //     } catch (e, stackTrace) {
// //       // Rule 5: Zero-Tolerance Error Handling via Sentry
// //       Sentry.captureException(
// //         e,
// //         stackTrace: stackTrace,
// //         withScope: (scope) {
// //           scope.setContexts('DashboardDrawerController', {'action': '_parseAndBuildMenu', 'error': 'Failed to parse RBAC permissions'});
// //         },
// //       );
// //
// //       // Fallback UI to prevent a blank red screen of death on storage corruption
// //       if (!isClosed) {
// //         menuItems.assignAll([const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
// //       }
// //     }
// //   }
// //
// //   /// Formats raw API keys into human-readable titles
// //   String _formatMasterTitle(String key) {
// //     if (key.length > 6) {
// //       String formatted = key.substring(6);
// //       return formatted.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
// //     }
// //     return key;
// //   }
// //
// //   /// Provides static native icons based on the module key
// //   IconData _getFallbackIcon(String key) {
// //     switch (key.toLowerCase()) {
// //       case 'firm setup':
// //         return Icons.domain_rounded;
// //       case 'store':
// //         return Icons.storefront_rounded;
// //       case 'product':
// //         return Icons.inventory_2_rounded;
// //       case 'order':
// //         return Icons.shopping_cart_rounded;
// //       case 'customer':
// //         return Icons.people_rounded;
// //       case 'payment':
// //         return Icons.payment_rounded;
// //       case 'settings':
// //         return Icons.settings_rounded;
// //       case 'reports':
// //         return Icons.analytics_rounded;
// //       case 'delivery boy':
// //         return Icons.delivery_dining_rounded;
// //       case 'policy':
// //         return Icons.policy_rounded;
// //       default:
// //         return Icons.circle_outlined;
// //     }
// //   }
// // }
//
// import 'dart:convert';
//
// import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
// import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
// import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
//
// class DashboardDrawerController extends BaseController {
//   final StorageService _storageService;
//
//   // Strict Named Constructor Injection
//   DashboardDrawerController({required StorageService storageService}) : _storageService = storageService;
//
//   // Reactive state for memory-safe UI rendering
//   final RxList<DrawerMenuModel> menuItems = <DrawerMenuModel>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _parseAndBuildMenu();
//   }
//
//   /// Parses RBAC permissions from local storage and constructs the menu hierarchy.
//   void _parseAndBuildMenu() {
//     try {
//       final String? userDataJson = _storageService.getString('user_data');
//       if (userDataJson == null || userDataJson.isEmpty) {
//         throw Exception("User data string is null or empty in storage.");
//       }
//
//       final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
//
//       // Extracting the "permissions" block safely
//       final Map<String, dynamic>? apiPermissions = userDataMap['permissions'] as Map<String, dynamic>?;
//       if (apiPermissions == null || apiPermissions.isEmpty) {
//         throw Exception("Permissions object is missing or empty in user data.");
//       }
//
//       List<DrawerMenuModel> builtMenu = [const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)];
//       List<DrawerMenuModel> masterSubItems = [];
//       List<DrawerMenuModel> productSubItems = [];
//
//       apiPermissions.forEach((key, value) {
//         // Safe extraction of network image URL (can be null)
//         final String? apiIconUrl = value['icon'] as String?;
//
//         if (key.toLowerCase().startsWith('master')) {
//           masterSubItems.add(
//             DrawerMenuModel(title: _formatTitle(key), identifier: key, icon: apiIconUrl, fallbackIcon: Icons.subdirectory_arrow_right_rounded),
//           );
//         } else if (key.toLowerCase().startsWith('product')) {
//           productSubItems.add(
//             DrawerMenuModel(title: _formatTitle(key), identifier: key, icon: apiIconUrl, fallbackIcon: Icons.subdirectory_arrow_right_rounded),
//           );
//         } else {
//           builtMenu.add(DrawerMenuModel(title: key, identifier: key, icon: apiIconUrl, fallbackIcon: _getFallbackIcon(key)));
//         }
//       });
//
//       // Group master items if they exist
//       if (masterSubItems.isNotEmpty) {
//         builtMenu.insert(
//           1, // Place right after Dashboard
//           DrawerMenuModel(
//             title: 'Master Settings',
//             identifier: 'master_group',
//             fallbackIcon: Icons.admin_panel_settings_rounded,
//             isExpansion: true,
//             subItems: masterSubItems,
//           ),
//         );
//       }
//
//       // Defensive Tactic: Ensure controller is still mounted before updating UI
//       if (!isClosed) {
//         menuItems.assignAll(builtMenu);
//       }
//     } catch (e, stackTrace) {
//       // Rule 5: Zero-Tolerance Error Handling via Sentry
//       Sentry.captureException(
//         e,
//         stackTrace: stackTrace,
//         withScope: (scope) {
//           scope.setContexts('DashboardDrawerController', {'action': '_parseAndBuildMenu', 'error': 'Failed to parse RBAC permissions'});
//         },
//       );
//
//       // Fallback UI to prevent a blank red screen of death on storage corruption
//       if (!isClosed) {
//         menuItems.assignAll([const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
//       }
//     }
//   }
//
//   /// Formats raw API keys into human-readable titles
//   String _formatTitle(String key, {String? prefixToRemove}) {
//     String text = key;
//
//     // Dynamically prefix hta do (e.g. "productCategory" -> "Category", "masterFirmSetup" -> "FirmSetup")
//     if (prefixToRemove != null && text.toLowerCase().startsWith(prefixToRemove.toLowerCase())) {
//       text = text.substring(prefixToRemove.length);
//     }
//
//     // Extra underscores, dashes ya spaces clean karo
//     text = text.replaceAll(RegExp(r'^[_\-\s]+'), '');
//
//     if (text.isEmpty) return key;
//
//     // CamelCase to Spaced Words (e.g. "FirmSetup" -> "Firm Setup")
//     String formatted = text.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
//
//     // First letter capital karo
//     return formatted[0].toUpperCase() + formatted.substring(1);
//   }
// }
//
// /// Provides static native icons based on the module key
// IconData _getFallbackIcon(String key) {
//   switch (key.toLowerCase()) {
//     case 'firm setup':
//       return Icons.domain_rounded; // Safely mapped the Firm module icon
//     case 'store':
//       return Icons.storefront_rounded;
//     case 'product':
//       return Icons.domain_rounded;
//     case 'order':
//       return Icons.shopping_cart_rounded;
//     case 'customer':
//       return Icons.people_rounded;
//     case 'payment':
//       return Icons.payment_rounded;
//     case 'settings':
//       return Icons.settings_rounded;
//     case 'reports':
//       return Icons.analytics_rounded;
//     case 'delivery boy':
//       return Icons.delivery_dining_rounded;
//     case 'policy':
//       return Icons.policy_rounded;
//     default:
//       return Icons.circle_outlined;
//   }
// }

import 'dart:convert';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Group Configuration Data Model
class DrawerGroupConfig {
  final String title;
  final String identifier;
  final IconData icon;

  const DrawerGroupConfig({required this.title, required this.identifier, required this.icon});
}

class DashboardDrawerController extends BaseController {
  final StorageService _storageService;

  DashboardDrawerController({required StorageService storageService}) : _storageService = storageService;

  final RxList<DrawerMenuModel> menuItems = <DrawerMenuModel>[].obs;

  /// 1. Dynamic Group Configurations Map
  /// (Future mein naye groups add karne ke liye bas yahan entry add karni hai)
  final Map<String, DrawerGroupConfig> _groupConfigs = const {
    'master': DrawerGroupConfig(title: 'Master Settings', identifier: 'master_group', icon: Icons.admin_panel_settings_rounded),
    'product': DrawerGroupConfig(title: 'Product Management', identifier: 'product_group', icon: Icons.inventory_2_rounded),
  };

  @override
  void onInit() {
    super.onInit();
    _parseAndBuildMenu();
  }

  void _parseAndBuildMenu() {
    try {
      final String? userDataJson = _storageService.getString('user_data');
      if (userDataJson == null || userDataJson.isEmpty) {
        throw Exception("User data string is null or empty in storage.");
      }

      final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      final Map<String, dynamic>? apiPermissions = userDataMap['permissions'] as Map<String, dynamic>?;

      if (apiPermissions == null || apiPermissions.isEmpty) {
        throw Exception("Permissions object is missing or empty in user data.");
      }

      List<DrawerMenuModel> builtMenu = [const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)];

      // Dynamic map to accumulate sub-items for each configured prefix group
      final Map<String, List<DrawerMenuModel>> groupedSubItems = {for (var prefix in _groupConfigs.keys) prefix: <DrawerMenuModel>[]};

      apiPermissions.forEach((key, value) {
        final String? apiIconUrl = value['icon'] as String?;
        final String lowerKey = key.toLowerCase();

        // Check if key starts with any configured prefix
        String? matchedPrefix;
        for (final prefix in _groupConfigs.keys) {
          if (lowerKey.startsWith(prefix.toLowerCase())) {
            matchedPrefix = prefix;
            break;
          }
        }

        if (matchedPrefix != null) {
          // Prefix hta kar dynamic title formatting apply karein
          groupedSubItems[matchedPrefix]!.add(
            DrawerMenuModel(
              title: _formatTitle(key, prefixToRemove: matchedPrefix),
              identifier: key,
              icon: apiIconUrl,
              fallbackIcon: Icons.subdirectory_arrow_right_rounded,
            ),
          );
        } else {
          // Regular un-grouped menu items
          builtMenu.add(DrawerMenuModel(title: _formatTitle(key), identifier: key, icon: apiIconUrl, fallbackIcon: _getFallbackIcon(key)));
        }
      });

      // Groups ko main menu mein Dashboard ke baad sequentially insert karna
      int insertPosition = 4;
      _groupConfigs.forEach((prefix, config) {
        final subItems = groupedSubItems[prefix];
        if (subItems != null && subItems.isNotEmpty) {
          builtMenu.insert(
            insertPosition++,
            DrawerMenuModel(title: config.title, identifier: config.identifier, fallbackIcon: config.icon, isExpansion: true, subItems: subItems),
          );
        }
      });

      if (!isClosed) {
        menuItems.assignAll(builtMenu);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts('DashboardDrawerController', {'action': '_parseAndBuildMenu', 'error': 'Failed to parse RBAC permissions'});
        },
      );

      if (!isClosed) {
        menuItems.assignAll([const DrawerMenuModel(title: 'Dashboard', identifier: 'dashboard', fallbackIcon: Icons.dashboard_rounded)]);
      }
    }
  }

  /// 2. Generic Title Formatter
  /// - Pehle passed `prefixToRemove` ko string se remove karta hai.
  /// - Phir CamelCase / concatenated text ko human-readable title mein formatted karta hai.
  String _formatTitle(String key, {String? prefixToRemove}) {
    String text = key;

    // Dynamically prefix hta do (e.g. "productCategory" -> "Category", "masterFirmSetup" -> "FirmSetup")
    if (prefixToRemove != null && text.toLowerCase().startsWith(prefixToRemove.toLowerCase())) {
      text = text.substring(prefixToRemove.length);
    }

    // Extra underscores, dashes ya spaces clean karo
    text = text.replaceAll(RegExp(r'^[_\-\s]+'), '');

    if (text.isEmpty) return key;

    // CamelCase to Spaced Words (e.g. "FirmSetup" -> "Firm Setup")
    String formatted = text.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');

    // First letter capital karo
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  /// Provides static native icons based on the module key
  IconData _getFallbackIcon(String key) {
    // Key ko clean & normalize karein (spaces, underscores, dashes hata kar lower-case)
    final String cleanKey = key.toLowerCase().replaceAll(RegExp(r'[_\-\s]+'), '');

    if (cleanKey.contains('firm')) {
      return Icons.domain_rounded;
    } else if (cleanKey.contains('pin code') || cleanKey.contains('pin')) {
      return Icons.pin_drop_rounded;
    } else if (cleanKey.contains('product')) {
      return Icons.inventory_2_rounded;
    } else if (cleanKey.contains('order')) {
      return Icons.shopping_cart_rounded;
    } else if (cleanKey.contains('delivery')) {
      return Icons.delivery_dining_rounded;
    } else if (cleanKey.contains('customer') || cleanKey.contains('user')) {
      return Icons.people_rounded;
    } else if (cleanKey.contains('payment')) {
      return Icons.payment_rounded;
    } else if (cleanKey.contains('store')) {
      return Icons.storefront_rounded;
    } else if (cleanKey.contains('setting')) {
      return Icons.settings_rounded;
    } else if (cleanKey.contains('report')) {
      return Icons.analytics_rounded;
    } else if (cleanKey.contains('policy')) {
      return Icons.policy_rounded;
    }

    // Default icon agar koi bhi match na mile
    return Icons.widgets_rounded;
  }
}
