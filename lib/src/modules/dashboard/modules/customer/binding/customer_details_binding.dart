import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_details_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/repository/customer_details_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomerDetailsBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<CustomerDetailsRepository>(() => CustomerDetailsRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<CustomerDetailsController>(
        () => CustomerDetailsController(customerDetailsRepository: Get.find<CustomerDetailsRepository>()),
        fenix: true,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'CustomerDetailsBinding');
          scope.setTag('module', 'customer');
        },
      );
      rethrow;
    }
  }
}
