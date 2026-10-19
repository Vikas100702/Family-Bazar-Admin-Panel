import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/controller/brand_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<BrandRepository>(() => BrandRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<BrandController>(() => BrandController(brandRepository: Get.find<BrandRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'BrandBinding');
          scope.setTag('module', 'brand');
        },
      );
      rethrow;
    }
  }
}
