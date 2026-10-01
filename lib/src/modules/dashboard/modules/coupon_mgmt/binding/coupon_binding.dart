import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/controller/coupon_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/repository/coupon_repository.dart';
import 'package:get/get.dart';

class CouponBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponRepository>(() => CouponRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<CouponController>(() => CouponController(couponRepository: Get.find<CouponRepository>()));
  }
}
