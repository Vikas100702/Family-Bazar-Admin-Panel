import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/controller/coupon_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/repository/coupon_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CouponBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<CouponRepository>(() => CouponRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<DashboardGroupRepository>(() => DashboardGroupRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<BrandRepository>(() => BrandRepository(apiClient: apiClient), fenix: true);

      Get.lazyPut<CouponController>(
        () => CouponController(
          couponRepository: Get.find<CouponRepository>(),
          groupRepository: Get.find<DashboardGroupRepository>(),
          brandRepository: Get.find<BrandRepository>(),
        ),
        fenix: true,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'CouponBinding');
          scope.setTag('module', 'coupon_mgmt');
        },
      );
      rethrow;
    }
  }
}
