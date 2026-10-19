import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/controller/drawer_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/login/repository/login_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DrawerBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      final StorageService storageService = Get.isRegistered<StorageService>()
          ? Get.find<StorageService>()
          : Get.put<StorageService>(StorageService(), permanent: true);

      if (!Get.isRegistered<LoginRepository>()) {
        Get.lazyPut<LoginRepository>(() => LoginRepository(apiClient: apiClient), fenix: true);
      }

      Get.lazyPut<DashboardDrawerController>(
        () => DashboardDrawerController(storageService: storageService, loginRepository: Get.find<LoginRepository>()),
        fenix: true,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'DrawerBinding');
          scope.setTag('module', 'drawer');
        },
      );
      rethrow;
    }
  }
}
