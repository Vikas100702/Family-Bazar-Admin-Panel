import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/controller/dashboard_group_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:get/get.dart';

class DashboardGroupBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ItemRepository>()) {
      Get.lazyPut<ItemRepository>(() => ItemRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    }
    Get.lazyPut<DashboardGroupRepository>(() => DashboardGroupRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<DashboardGroupController>(
      () => DashboardGroupController(groupRepository: Get.find<DashboardGroupRepository>(), itemRepository: Get.find<ItemRepository>()),
      fenix: true,
    );
  }
}
