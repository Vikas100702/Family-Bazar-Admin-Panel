import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/controller/drawer_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/login/repository/login_repository.dart';
import 'package:get/get.dart';

class DrawerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LoginRepository>()) {
      Get.lazyPut<LoginRepository>(() => LoginRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    }

    Get.lazyPut<DashboardDrawerController>(
      () => DashboardDrawerController(storageService: Get.find<StorageService>(), loginRepository: Get.find<LoginRepository>()),
      fenix: true,
    );
  }
}
