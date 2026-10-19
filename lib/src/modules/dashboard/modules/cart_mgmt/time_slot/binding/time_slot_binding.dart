import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/controller/time_slot_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/repository/time_slot_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TimeSlotBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<TimeSlotRepository>(() => TimeSlotRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<TimeSlotController>(() => TimeSlotController(slotRepository: Get.find<TimeSlotRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'TimeSlotBinding');
          scope.setTag('module', 'time_slot');
        },
      );
      rethrow;
    }
  }
}
