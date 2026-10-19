import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/controller/firm_setup_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirmBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<FirmRepository>(() => FirmRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<FirmController>(() => FirmController(firmRepository: Get.find<FirmRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'FirmBinding');
          scope.setTag('module', 'firm');
        },
      );
      rethrow;
    }
  }
}
