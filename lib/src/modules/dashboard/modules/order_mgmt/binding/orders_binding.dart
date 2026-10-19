import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/controller/orders_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/repository/orders_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.lazyPut<OrdersRepository>(() => OrdersRepository(apiClient: apiClient), fenix: true);
      Get.lazyPut<OrdersController>(() => OrdersController(ordersRepository: Get.find<OrdersRepository>()), fenix: true);
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'OrdersBinding');
          scope.setTag('module', 'orders');
        },
      );
      rethrow;
    }
  }
}
