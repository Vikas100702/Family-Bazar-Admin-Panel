import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/controller/time_slot_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/repository/time_slot_repository.dart';
import 'package:get/get.dart';

class TimeSlotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimeSlotRepository>(() => TimeSlotRepository(apiClient: Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<TimeSlotController>(() => TimeSlotController(repository: Get.find<TimeSlotRepository>()), fenix: true);
  }
}
