import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_assets.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/controller/dashboard_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/controller/drawer_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/model/drawer_menu_model/drawer_menu_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DrawerView extends GetView<DashboardDrawerController> {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final bool isCollapsed = context.isDesktop && dashboardController.isDrawerCollapsed.value;

      return Drawer(
        elevation: context.isDesktop ? 0 : 4.0,
        shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(0, 0)),
        backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAdaptiveHeader(context, isCollapsed: isCollapsed),
            Divider(height: 1, thickness: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            Expanded(
              child: controller.menuItems.isEmpty
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: context.responsiveHeight(8, 12),
                        horizontal: isCollapsed ? 8 : context.responsiveWidth(8, 12),
                      ),
                      itemCount: controller.menuItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.menuItems[index];
                        return _buildDynamicMenuItem(context, item, isCollapsed: isCollapsed);
                      },
                    ),
            ),
            Divider(height: 1, thickness: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            _buildAdaptiveFooter(context, isCollapsed: isCollapsed),
          ],
        ),
      );
    });
  }

  Widget _buildAdaptiveHeader(BuildContext context, {required bool isCollapsed}) {
    final isDark = context.isDark;

    if (isCollapsed) {
      return Container(
        height: 68,
        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
        alignment: Alignment.center,
        child: Tooltip(
          message: AppStrings.appName,
          waitDuration: const Duration(milliseconds: 300),
          child: RepaintBoundary(
            child: Image.asset(
              AppAssets.appLogo,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront_rounded, color: AppColors.primaryRed, size: 24),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 20)),
      color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
      child: Row(
        children: [
          RepaintBoundary(
            child: Image.asset(
              AppAssets.appLogo,
              width: context.responsiveSize(38, 42),
              height: context.responsiveSize(38, 42),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: context.responsiveSize(38, 42),
                height: context.responsiveSize(38, 42),
                decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.storefront_rounded, color: AppColors.primaryRed, size: 22),
              ),
            ),
          ),
          SizedBox(width: context.responsiveWidth(12, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.appName,
                  style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(14, 16)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('Enterprise Console', style: context.captionStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicMenuItem(BuildContext context, DrawerMenuModel item, {required bool isCollapsed}) {
    if (item.hasSubItems) {
      return isCollapsed ? _buildCollapsedExpandableItem(context, item) : _buildExpandableMenuGroup(context, item);
    }
    return isCollapsed ? _buildCollapsedSingleItem(context, item) : _buildSingleMenuItem(context, item);
  }

  Widget _buildCollapsedSingleItem(BuildContext context, DrawerMenuModel item) {
    return Obx(() {
      final dashboardController = Get.find<DashboardController>();
      final bool isActive = dashboardController.selectedMenuKey.value == item.identifier;

      final Color tileColor = isActive ? AppColors.primaryRed.withValues(alpha: 0.12) : Colors.transparent;
      final Color borderColor = isActive ? AppColors.primaryRed.withValues(alpha: 0.35) : Colors.transparent;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: item.title,
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: tileColor,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              hoverColor: AppColors.primaryRed.withValues(alpha: 0.06),
              splashColor: AppColors.primaryRed.withValues(alpha: 0.12),
              onTap: () => _handleItemTap(context, item.identifier),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                alignment: Alignment.center,
                child: _buildMenuIcon(context, item, isActive: isActive),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCollapsedExpandableItem(BuildContext context, DrawerMenuModel item) {
    final isDark = context.isDark;

    return Obx(() {
      final dashboardController = Get.find<DashboardController>();
      final bool isAnyChildActive = item.subItems.any((sub) => sub.identifier == dashboardController.selectedMenuKey.value);
      final Color tileColor = isAnyChildActive ? AppColors.primaryRed.withValues(alpha: 0.12) : Colors.transparent;
      final Color borderColor = isAnyChildActive ? AppColors.primaryRed.withValues(alpha: 0.35) : Colors.transparent;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: item.title,
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: tileColor,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: PopupMenuButton<String>(
              tooltip: '',
              offset: const Offset(54, 0),
              color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
              ),
              onSelected: (identifier) => _handleItemTap(context, identifier),
              itemBuilder: (popupContext) {
                return [
                  PopupMenuItem<String>(
                    enabled: false,
                    height: 36,
                    child: Text(
                      item.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  ...item.subItems.map((subItem) {
                    final bool isSubActive = dashboardController.selectedMenuKey.value == subItem.identifier;
                    return PopupMenuItem<String>(
                      value: subItem.identifier,
                      height: 40,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: isSubActive ? AppColors.primaryRed : (isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            subItem.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSubActive ? FontWeight.w600 : FontWeight.w500,
                              color: isSubActive ? AppColors.primaryRed : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ];
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                alignment: Alignment.center,
                child: _buildMenuIcon(context, item, isActive: isAnyChildActive),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSingleMenuItem(BuildContext context, DrawerMenuModel item) {
    final isDark = context.isDark;

    return Obx(() {
      final dashboardController = Get.find<DashboardController>();
      final bool isActive = dashboardController.selectedMenuKey.value == item.identifier;

      final Color tileColor = isActive ? AppColors.primaryRed.withValues(alpha: 0.1) : Colors.transparent;
      final Color borderColor = isActive ? AppColors.primaryRed.withValues(alpha: 0.3) : Colors.transparent;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(2, 3)),
        child: Material(
          color: tileColor,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            mouseCursor: SystemMouseCursors.click,
            hoverColor: AppColors.primaryRed.withValues(alpha: 0.05),
            splashColor: AppColors.primaryRed.withValues(alpha: 0.12),
            onTap: () => _handleItemTap(context, item.identifier),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 14), vertical: context.responsiveHeight(10, 12)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  _buildMenuIcon(context, item, isActive: isActive),
                  SizedBox(width: context.responsiveWidth(12, 14)),
                  Expanded(
                    child: Text(
                      item.title,
                      style: isActive
                          ? context.titleStyleActive.copyWith(fontSize: context.responsiveSize(13, 14), color: AppColors.primaryRed)
                          : context.titleStyleRegular.copyWith(
                              fontSize: context.responsiveSize(13, 14),
                              color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive) Icon(Icons.chevron_right_rounded, size: context.responsiveSize(18, 20), color: AppColors.primaryRed),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExpandableMenuGroup(BuildContext context, DrawerMenuModel item) {
    final isDark = context.isDark;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent, splashColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 14), vertical: context.responsiveHeight(2, 4)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: _buildMenuIcon(context, item, isActive: false),
        title: Text(
          item.title,
          style: context.titleStyleRegular.copyWith(fontSize: context.responsiveSize(13, 14), fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconColor: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
        collapsedIconColor: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
        children: item.subItems.map((subItem) {
          return _buildSubMenuItem(context, subItem);
        }).toList(),
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, DrawerMenuModel subItem) {
    final isDark = context.isDark;

    return Obx(() {
      final dashboardController = Get.find<DashboardController>();
      final bool isSubActive = dashboardController.selectedMenuKey.value == subItem.identifier;

      final Color subColor = isSubActive ? AppColors.primaryRed.withValues(alpha: 0.08) : Colors.transparent;

      return Padding(
        padding: EdgeInsets.only(left: context.responsiveWidth(28, 34), right: context.responsiveWidth(6, 8), top: 2, bottom: 2),
        child: Material(
          color: subColor,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            hoverColor: AppColors.primaryRed.withValues(alpha: 0.04),
            onTap: () => _handleItemTap(context, subItem.identifier),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(10, 12), vertical: context.responsiveHeight(8, 10)),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: context.responsiveSize(6, 7),
                    color: isSubActive ? AppColors.primaryRed : (isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                  ),
                  SizedBox(width: context.responsiveWidth(10, 12)),
                  Expanded(
                    child: Text(
                      subItem.title,
                      style: isSubActive
                          ? context.titleStyleActive.copyWith(fontSize: context.responsiveSize(12, 13), color: AppColors.primaryRed)
                          : context.subTitleStyle.copyWith(
                              fontSize: context.responsiveSize(12, 13),
                              color: isDark ? AppColors.textPrimaryWhite : AppColors.textSecondarySlate,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAdaptiveFooter(BuildContext context, {required bool isCollapsed}) {
    final isDark = context.isDark;

    if (isCollapsed) {
      return Container(
        height: 52,
        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
        alignment: Alignment.center,
        child: Tooltip(
          message: '${AppStrings.superAdminRole} (${AppStrings.appVersion})',
          waitDuration: const Duration(milliseconds: 300),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.statusGreenSuccess, shape: BoxShape.circle),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 20), vertical: context.responsiveHeight(14, 16)),
      color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.superAdminRole,
            style: context.titleStyleRegular.copyWith(fontSize: context.responsiveSize(12, 13), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(AppStrings.appVersion, style: context.captionStyle),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(BuildContext context, DrawerMenuModel item, {required bool isActive}) {
    final isDark = context.isDark;
    final double iconSize = context.responsiveSize(20, 22);
    final Color iconColor = isActive ? AppColors.primaryRed : (isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate);

    if (item.icon != null && item.icon!.isNotEmpty) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CachedNetworkImage(
          imageUrl: item.icon!,
          fit: BoxFit.contain,
          color: isActive ? AppColors.primaryRed : null,
          colorBlendMode: isActive ? BlendMode.srcIn : null,
          errorWidget: (context, error, stackTrace) {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message: AppStrings.failedToLoadIcon,
                category: 'ui.image_load',
                level: SentryLevel.warning,
                data: {'url': item.icon, 'menu_identifier': item.identifier},
              ),
            );
            return Icon(_getIconForIdentifier(item.identifier), size: iconSize, color: iconColor);
          },
        ),
      );
    }

    if (item.fallbackIcon != null) {
      return Icon(item.fallbackIcon, size: iconSize, color: iconColor);
    }

    return Icon(_getIconForIdentifier(item.identifier), size: iconSize, color: iconColor);
  }

  IconData _getIconForIdentifier(String identifier) {
    switch (identifier.toLowerCase()) {
      case 'dashboard':
        return Icons.space_dashboard_rounded;
      case 'firm':
        return Icons.domain_rounded;
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

  void _handleItemTap(BuildContext context, String identifier) {
    final dashboardController = Get.find<DashboardController>();
    dashboardController.changeActiveMenu(identifier);

    // Auto-close overlay drawer on Mobile browsers
    if (!context.isDesktop && Scaffold.maybeOf(context)?.isDrawerOpen == true) {
      Get.back();
    }
  }
}
