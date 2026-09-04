import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/controller/category_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:get/get.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<CategoryController>(
      () => CategoryController(categoryRepository: Get.find<CategoryRepository>(), storageService: Get.find<StorageService>()),
    );
  }
}
