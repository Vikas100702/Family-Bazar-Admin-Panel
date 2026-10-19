import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/controller/loyalty_prog_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/repository/loyalty_prog_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoyaltyProgBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<LoyaltyRepository>(() => LoyaltyRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<LoyaltyProgController>(() => LoyaltyProgController(repository: Get.find<LoyaltyRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'LoyaltyProgBinding');
          scope.setTag('module', 'loyalty_program');
        },
      );
      rethrow;
    }
  }
}
