import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardController extends BaseController {

  // 1. Reactive State for SPA Routing
  // Default screen will always be 'Dashboard'
  final RxString selectedMenuKey = 'dashboard'.obs;

  @override
  void onInit() {
    super.onInit();
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'Dashboard SPA Controller Initialized',
        category: 'dashboard.controller',
        level: SentryLevel.info,
      ),
    );
  }

  /// 2. SPA Navigation Logic
  /// This method will be called by the DrawerView when a menu item is tapped.
  void changeActiveMenu(String newMenuKey) {
    if (selectedMenuKey.value != newMenuKey) {
      selectedMenuKey.value = newMenuKey;

      // Observability: Track which modules the admin is accessing
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'SPA Module Switched',
          category: 'dashboard.navigation',
          data: {'selected_module': newMenuKey},
          level: SentryLevel.info,
        ),
      );
    }
  }
}