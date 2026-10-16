import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/controller/delivery_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/repository/delivery_repository.dart';
import 'package:get/get.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryRepository>(() => DeliveryRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<DeliveryController>(() => DeliveryController(repository: Get.find<DeliveryRepository>()), fenix: true);
  }
}
