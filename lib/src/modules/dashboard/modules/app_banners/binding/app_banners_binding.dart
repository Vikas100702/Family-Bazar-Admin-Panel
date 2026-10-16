import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/controller/app_banners_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/repository/app_banners_repository.dart';
import 'package:get/get.dart';

class AppBannersBinding extends Bindings {
  @override
  void dependencies() {
    final ApiClient apiClient = Get.find<ApiClient>();
    Get.lazyPut<AppBannersRepository>(() => AppBannersRepository(apiClient: apiClient), fenix: true);
    Get.lazyPut<AppBannersController>(() => AppBannersController(bannerRepository: Get.find<AppBannersRepository>()), fenix: true);
  }
}
