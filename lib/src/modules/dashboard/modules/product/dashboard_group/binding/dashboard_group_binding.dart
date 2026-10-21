import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/controller/dashboard_group_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardGroupBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      if (!Get.isRegistered<ItemRepository>()) {
        Get.lazyPut<ItemRepository>(() => ItemRepository(apiClient: apiClient), fenix: true);
      }
      if (!Get.isRegistered<FirmRepository>()) {
        Get.lazyPut<FirmRepository>(() => FirmRepository(apiClient: apiClient), fenix: true);
      }
      Get.lazyPut<DashboardGroupRepository>(() => DashboardGroupRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<DashboardGroupController>(
        () => DashboardGroupController(
          groupRepository: Get.find<DashboardGroupRepository>(),
          itemRepository: Get.find<ItemRepository>(),
          firmRepository: Get.find<FirmRepository>(),
        ),
        fenix: true,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'DashboardGroupBinding');
          scope.setTag('module', 'dashboard_group');
        },
      );
      rethrow;
    }
  }
}
