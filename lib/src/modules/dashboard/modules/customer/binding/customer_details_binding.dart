import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_details_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/repository/customer_details_repository.dart';
import 'package:get/get.dart';

class CustomerDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerDetailsRepository>(() => CustomerDetailsRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<CustomerDetailsController>(() => CustomerDetailsController(customerDetailsRepository: Get.find<CustomerDetailsRepository>()));
  }
}
