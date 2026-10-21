import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardController extends BaseController {
  final StorageService _storageService = Get.find<StorageService>();
  final RxString selectedMenuKey = 'dashboard'.obs; // Default screen will always be 'Dashboard'
  final RxBool isDrawerCollapsed = false.obs;

  @override
  void onInit() {
    super.onInit();
    Sentry.addBreadcrumb(Breadcrumb(message: 'Dashboard SPA Controller Initialized', category: 'dashboard.controller', level: SentryLevel.info));
  }

  String get formatMenuKey => selectedMenuKey.value.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '').trim();

  /// This method will be called by the Drawer View when a menu item is tapped.
  void changeActiveMenu(String newMenuKey) {
    final String trimmedKey = newMenuKey.trim();
    if (trimmedKey.isEmpty) return;

    if (selectedMenuKey.value != trimmedKey) {
      selectedMenuKey.value = trimmedKey;

      // Observability: Track which modules the admin is accessing
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'SPA Module Switched', category: 'dashboard.navigation', data: {'selected_module': newMenuKey}, level: SentryLevel.info),
      );
    }
  }

  void toggleDrawerCollapse() {
    isDrawerCollapsed.toggle();
  }

  /// Explicit setter for responsive breakpoint overrides
  void setDrawerCollapsed(bool collapsed) {
    if (isDrawerCollapsed.value != collapsed) {
      isDrawerCollapsed.value = collapsed;
    }
  }

  Future<void> logout() async {
    Sentry.addBreadcrumb(Breadcrumb(message: 'User initiated administrative logout', category: 'auth.session', level: SentryLevel.info));
    await _storageService.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    Sentry.addBreadcrumb(Breadcrumb(message: 'Dashboard SPA Controller Disposed', category: 'dashboard.controller', level: SentryLevel.info));
    super.onClose();
  }
}
