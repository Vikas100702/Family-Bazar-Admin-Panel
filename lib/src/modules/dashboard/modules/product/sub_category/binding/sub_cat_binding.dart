import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/controller/sub_cat_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:get/get.dart';

class SubCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubCategoryRepository>(() => SubCategoryRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<SubCategoryController>(() => SubCategoryController(subCategoryRepository: Get.find<SubCategoryRepository>()));
  }
}
