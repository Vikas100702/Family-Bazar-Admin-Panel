import 'dart:async';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_dashboard_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/repository/customer_details_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomerDashboardController extends BaseController {
  final CustomerDetailsRepository _repository;
  CustomerDashboardController({required this._repository});

  final Rxn<CustomerDashboardData> dashboardData = Rxn<CustomerDashboardData>();
  final RxInt customerId = 0.obs;
  final RxString customerName = ''.obs;
  final RxInt activeTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _extractRouteArguments();
    if (customerId.value > 0) {
      fetchCustomerDashboard();
    }
  }

  void _extractRouteArguments() {
    final dynamic args = Get.arguments;
    if (args is Map<String, dynamic>) {
      customerId.value = int.tryParse(args['customer_id']?.toString() ?? '0') ?? 0;
      customerName.value = args['customer_name']?.toString() ?? 'Customer Dashboard';
    } else if (args is int) {
      customerId.value = args;
    }
  }

  Future<void> fetchCustomerDashboard() async {
    if (customerId.value <= 0) {
      errorMessage(message: 'Invalid Customer ID provided for dashboard inspection.');
      return;
    }

    await runWithLoading(() async {
      try {
        final CustomerDashboardModel response = await _repository.getCustomerDashboardDetails(customerId: customerId.value);

        if (isClosed) return;

        if (response.status && response.data != null) {
          dashboardData.value = response.data;
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to retrieve Customer 360 metrics.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchCustomerDashboard');
        if (!isClosed) {
          errorMessage(message: 'Error fetching Customer Dashboard.');
        }
      }
    });
  }

  void switchTab(int index) {
    activeTabIndex.value = index;
  }

  void refreshDashboard() {
    fetchCustomerDashboard();
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'customer_360');
        scope.setTag('controller', 'CustomerDashboardController');
        scope.setContexts('customer_context', <String, dynamic>{'action': action, 'customerId': customerId.value});
      },
    );
  }

  @override
  void onClose() {
    dashboardData.value = null;
    super.onClose();
  }
}
