import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/controller/misc_charges_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/repository/misc_charges_repository.dart';
import 'package:get/get.dart';

class MiscChargesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiscChargesRepository>(() => MiscChargesRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<MiscChargesController>(() => MiscChargesController(miscChargesRepository: Get.find<MiscChargesRepository>()), fenix: true);
  }
}
