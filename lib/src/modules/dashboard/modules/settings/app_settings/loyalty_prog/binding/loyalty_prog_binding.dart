import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/controller/loyalty_prog_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/repository/loyalty_prog_repository.dart';
import 'package:get/get.dart';

class LoyaltyProgBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoyaltyRepository>(() => LoyaltyRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<LoyaltyProgController>(() => LoyaltyProgController(repository: Get.find<LoyaltyRepository>()), fenix: true);
  }
}
