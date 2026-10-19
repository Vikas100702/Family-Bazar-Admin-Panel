import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/controller/category_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<CategoryRepository>(() => CategoryRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<CategoryController>(() => CategoryController(categoryRepository: Get.find<CategoryRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'CategoryBinding');
          scope.setTag('module', 'category');
        },
      );
      rethrow;
    }
  }
}
