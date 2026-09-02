import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/controller/dashboard_coontroller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/controller/drawer_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DrawerView extends GetView<DashboardDrawerController> {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(0, 0)),
      child: Column(
        children: [
          _buildDrawerHeader(context),

          // Dynamic List Body
          Expanded(
            child: Obx(() {
              if (controller.menuItems.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.menuItems.length,
                itemBuilder: (context, index) {
                  final item = controller.menuItems[index];
                  return _buildMenuItem(context, item);
                },
              );
            }),
          ),

          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      accountName: Text(AppStrings.appName, style: context.headingTextStyle),
      accountEmail: Text(
        "",
        // AppStrings.superAdminRole,
        // style: context.subTitleStyle,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.admin_panel_settings_rounded, size: context.responsiveSize(40, 40), color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, DrawerMenuModel item) {
    if (item.isExpansion && item.subItems != null) {
      return ExpansionTile(
        leading: _buildIcon(context, item),
        title: Text(item.title, style: context.titleStyleRegular.copyWith(fontWeight: FontWeight.w600)),
        children: item.subItems!.map((subItem) => _buildSubMenuItem(context, subItem)).toList(),
      );
    }

    return ListTile(
      leading: _buildIcon(context, item),
      title: Text(item.title, style: context.titleStyleRegular),
      onTap: () {
        Get.find<DashboardController>().changeActiveMenu(item.identifier);
        if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
          Get.back();
        }
      },
    );
  }

  /// Builds indented sub-items inside Master categories dynamically
  Widget _buildSubMenuItem(BuildContext context, DrawerMenuModel item) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: context.responsiveWidth(56, 56), right: context.responsiveWidth(16, 16)),
      leading: _buildIcon(context, item, size: context.responsiveSize(20, 20)),
      title: Text(item.title, style: context.bodyTextStyle),
      onTap: () {
        Get.find<DashboardController>().changeActiveMenu(item.identifier);
        if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
          Get.back();
        }
      },
    );
  }

  Widget _buildIcon(BuildContext context, DrawerMenuModel item, {double? size}) {
    final double iconSize = size ?? context.responsiveSize(24, 24);

    if (item.icon != null && item.icon!.isNotEmpty) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Image.network(
          item.icon!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message: AppStrings.failedToLoadIcon,
                category: 'ui.image_load',
                level: SentryLevel.warning,
                data: {'url': item.icon, 'menu_identifier': item.identifier},
              ),
            );

            Sentry.captureMessage('${AppStrings.drawerMenuIconLoadFailure} ${item.identifier}', level: SentryLevel.warning);

            return Icon(_getIconForIdentifier(item.identifier), size: iconSize, color: Colors.grey);
          },
        ),
      );
    }
    return Icon(_getIconForIdentifier(item.identifier), size: iconSize, color: Colors.grey[700]);
  }

  IconData _getIconForIdentifier(String identifier) {
    switch (identifier.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard_rounded;
      case 'store':
        return Icons.storefront_rounded;
      case 'product':
        return Icons.inventory_2_rounded;
      case 'order':
        return Icons.shopping_cart_rounded;
      case 'customer':
        return Icons.people_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'reports':
        return Icons.analytics_rounded;
      case 'delivery boy':
        return Icons.delivery_dining_rounded;
      case 'policy':
        return Icons.policy_rounded;
      case 'master_group':
        return Icons.admin_panel_settings_rounded;
      default:
        if (identifier.toLowerCase().startsWith('master')) {
          return Icons.subdirectory_arrow_right_rounded;
        }
        return Icons.circle_outlined;
    }
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsiveSize(16, 16)),
      child: Text(AppStrings.appVersion, style: context.subTitleStyle.copyWith(fontSize: context.responsiveSize(12, 12))),
    );
  }
}
