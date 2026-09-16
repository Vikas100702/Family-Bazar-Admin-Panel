import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/controller/brand_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:get/get.dart';

class BrandBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandRepository>(() => BrandRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<BrandController>(() => BrandController(brandRepository: Get.find<BrandRepository>()));
  }
}
