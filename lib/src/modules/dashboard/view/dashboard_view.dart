import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/coming_soon_view.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/controller/dashboard_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/view/coupon_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/view/drawer_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/view/firm_setup_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/view/pincode_settings_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/view/brand_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/view/category_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/view/dashboard_group_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/view/item_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/view/sub_cat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final bool isDark = context.isDark;

    return ResponsiveLayout(
      useSafeArea: true,
      backgroundColor: isDark ? AppColors.canvasDarkSlate : AppColors.canvasLightGray,
      drawer: isDesktop ? null : const DrawerView(),
      appBar: isDesktop ? null : _buildMobileAppBar(context),
      desktop: isDesktop ? _buildDesktopLayout(context) : const SizedBox.shrink(),
      tablet: !isDesktop ? _buildMobileTabletLayout(context) : null,
      mobile: !isDesktop ? _buildMobileTabletLayout(context) : const SizedBox.shrink(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final bool isDark = context.isDark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible Desktop Sidebar
        Obx(() {
          final bool isCollapsed = controller.isDrawerCollapsed.value;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            width: isCollapsed ? 76 : 320,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              border: Border(right: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                drawerTheme: const DrawerThemeData(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              child: const DrawerView(),
            ),
          );
        }),

        // Main Desktop Content Body
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDesktopTopBar(context),
              Expanded(
                child: Container(
                  color: isDark ? AppColors.canvasDarkSlate : AppColors.canvasLightGray,
                  padding: const EdgeInsets.all(24.0),
                  child: Obx(() => _buildDynamicContent(context, controller.selectedMenuKey.value)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabletLayout(BuildContext context) {
    final bool isDark = context.isDark;

    return Container(
      color: isDark ? AppColors.canvasDarkSlate : AppColors.canvasLightGray,
      padding: EdgeInsets.all(context.responsiveSize(14, 20)),
      child: Obx(() => _buildDynamicContent(context, controller.selectedMenuKey.value)),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    final bool isDark = context.isDark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
      iconTheme: IconThemeData(color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
      title: Text(
        AppStrings.appName,
        style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), color: AppColors.primaryRed),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: () {
            Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20),
          color: AppColors.primaryRed,
          tooltip: 'Logout',
          onPressed: () => _confirmLogout(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    final bool isDark = context.isDark;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Drawer Collapse Toggle + Breadcrumb Module Title
          Row(
            children: [
              IconButton(
                onPressed: controller.toggleDrawerCollapse,
                tooltip: 'Toggle Navigation Bar',
                splashRadius: 20,
                icon: Obx(
                  () => Icon(
                    controller.isDrawerCollapsed.value ? Icons.menu_open_rounded : Icons.menu_rounded,
                    size: 22,
                    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => Text(controller.selectedMenuKey.value, style: context.titleStyleActive.copyWith(fontSize: 18, letterSpacing: -0.2))),
            ],
          ),

          // Right: Theme Mode Switcher, Notifications & Log out Button
          Row(
            children: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
                color: isDark ? AppColors.accentGoldAmber : AppColors.textSecondarySlate,
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                splashRadius: 20,
                onPressed: () {
                  Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 20),
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                tooltip: 'Notifications',
                splashRadius: 20,
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3), width: 1.5),
                ),
                child: IconButton(
                  tooltip: 'Logout Session',
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.primaryRed, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContent(BuildContext context, String menuKey) {
    final String cleanKey = menuKey.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '').trim();

    switch (cleanKey) {
      // Static Root
      case 'dashboard':
        return _buildDashboardOverviewPlaceholder(context);

      // Firm Setup Module (Single array item)
      case 'firm':
      case 'firmsetup':
        return const FirmView();

      // Pin Code Settings Module (Single array item)
      case 'pincode':
      case 'pincodesetting':
      case 'pincodesettings':
        return const PincodeSettingsView();

      // Category Module (Array child name: "Category")
      case 'category':
      case 'productcategory':
      case 'mastercategory':
        return const CategoryView();

      // Sub Category Module (Array child name: "Sub Category")
      case 'subcategory':
      case 'productsubcategory':
      case 'mastersubcategory':
        return const SubCategoryView();

      // Brand Module (Array child name: "Brand")
      case 'brand':
      case 'productbrand':
      case 'masterbrandname':
        return const BrandView();

      // Dashboard Group Module (Array child name: "Dashboard Group")
      case 'dashboardgroup':
      case 'productdashboardgroup':
        return const DashboardGroupView();

      // Item Module (Array child name: "Item")
      case 'item':
      case 'productitem':
      case 'masteritem':
        return const ItemsView();

      // Coupon Management Module (Single array item)
      case 'coupon':
      case 'couponmanagement':
      case 'couponmgmt':
        return const CouponView();
      default:
        return ComingSoonView(title: menuKey);
    }
  }

  // DASHBOARD OVERVIEW PLACEHOLDER CARD
  Widget _buildDashboardOverviewPlaceholder(BuildContext context) {
    final bool isDark = context.isDark;

    return Container(
      width: double.infinity,
      decoration: context.defaultDecoration,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.analytics_outlined, size: 48, color: AppColors.primaryRed),
          ),
          const SizedBox(height: 20),
          Text('Enterprise Analytics Dashboard', style: context.titleStyleActive.copyWith(fontSize: 20), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Real-time metrics, live revenue, and order dispatch telemetry will appear here.',
            style: context.subTitleStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // SECURE SESSION TERMINATION DIALOG
  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to terminate your administrative session?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              Get.find<StorageService>().clearAll();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
