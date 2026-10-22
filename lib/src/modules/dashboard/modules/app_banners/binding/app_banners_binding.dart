import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/controller/app_banners_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/repository/app_banners_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBannersBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);

      Get.lazyPut<AppBannersRepository>(() => AppBannersRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<CategoryRepository>(() => CategoryRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<SubCategoryRepository>(() => SubCategoryRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<BrandRepository>(() => BrandRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<DashboardGroupRepository>(() => DashboardGroupRepository(apiClient: apiClient), fenix: true);

      Get.lazyPut<AppBannersController>(
        () => AppBannersController(
          bannerRepository: Get.find<AppBannersRepository>(),
          categoryRepository: Get.find<CategoryRepository>(),
          subCategoryRepository: Get.find<SubCategoryRepository>(),
          brandRepository: Get.find<BrandRepository>(),
          groupRepository: Get.find<DashboardGroupRepository>(),
        ),
        fenix: true,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('layer', 'AppBannersBinding');
          scope.setTag('module', 'app_banners');
        },
      );
      rethrow;
    }
  }
}
