import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/controller/drawer_controller.dart';
import 'package:get/get.dart';

class DrawerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardDrawerController>(() => DashboardDrawerController(Get.find<StorageService>()));
  }
}
