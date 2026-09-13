import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<SplashController>(() => SplashController(Get.find<StorageService>()));
    Get.put<SplashController>(SplashController(storageService: Get.find<StorageService>()));
  }
}
