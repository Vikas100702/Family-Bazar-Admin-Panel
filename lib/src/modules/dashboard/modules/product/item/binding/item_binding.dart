import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/controller/items_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:get/get.dart';

class ItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemRepository>(() => ItemRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<ItemController>(() => ItemController(itemRepository: Get.find<ItemRepository>()));
  }
}
