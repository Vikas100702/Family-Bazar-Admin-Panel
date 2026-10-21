import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/controller/misc_charges_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/repository/misc_charges_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MiscChargesBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<MiscChargesRepository>(() => MiscChargesRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<MiscChargesController>(() => MiscChargesController(miscChargesRepository: Get.find<MiscChargesRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'MiscChargesBinding');
          scope.setTag('module', 'misc_charges');
        },
      );
      rethrow;
    }
  }
}
