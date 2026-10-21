import 'dart:async';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_dashboard_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/repository/customer_details_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomerDetailsController extends BaseServerTableController<CustomerDetailsDatum> {
  final CustomerDetailsRepository _customerDetailsRepository;
  CustomerDetailsController({required this._customerDetailsRepository});

  bool _isActionLocked = false;

  /// ########################################
  final RxBool isViewingCustomerDashboard = false.obs;
  final RxInt selectedCustomerId = 0.obs;
  final RxString selectedCustomerName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServerData();
  }

  @override
  String searchTokenBuilder(CustomerDetailsDatum item) {
    return '${item.id} ${item.fullName} ${item.phone} ${item.email} ${item.referralCode} ${item.primaryAddress?.city ?? ''} ${item.primaryAddress?.state ?? ''}'
        .toLowerCase()
        .trim();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final CustomerDetailsModel response = await _customerDetailsRepository.viewDetails(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );

        if (isClosed) return;

        if (response.status) {
          setServerData(
            data: response.data,
            totalCount: response.pagination?.totalRecords ?? response.data.length,
            pageCount: response.pagination?.totalPages,
          );
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the customer details from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching customer details.');
        }
      }
    });
  }

  Future<void> refreshDetails() async => refreshData();

  Future<bool> deleteCustomer(CustomerDetailsDatum customer) async {
    if (customer.id <= 0) {
      errorMessage(message: 'Invalid customer ID.');
      return false;
    }

    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _customerDetailsRepository.deleteCustomer(customerId: customer.id);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Customer deleted successfully.');
          await refreshDetails();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete customer.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteCustomer', <String, dynamic>{'customer_id': customer.id, 'customer_name': customer.fullName});
        if (!isClosed) {
          errorMessage(message: 'An error occurred while deleting the customer.');
        }
      }
    });

    _isActionLocked = false;
    return isSuccess;
  }

  void openCustomerDashboard(CustomerDetailsDatum customer) {
    selectedCustomerId.value = customer.id;
    selectedCustomerName.value = customer.fullName;

    if (!Get.isRegistered<CustomerDashboardController>()) {
      Get.lazyPut<CustomerDashboardController>(() => CustomerDashboardController(repository: _customerDetailsRepository), fenix: true);
    }

    // Assign customer ID to dashboard controller and trigger data fetch
    final dashboardCtrl = Get.find<CustomerDashboardController>();
    dashboardCtrl.customerId.value = customer.id;
    dashboardCtrl.customerName.value = customer.fullName;
    dashboardCtrl.fetchCustomerDashboard();

    // Show the dashboard view on the screen
    isViewingCustomerDashboard.value = true;
  }

  void closeCustomerDashboard() {
    isViewingCustomerDashboard.value = false;
    selectedCustomerId.value = 0;
    selectedCustomerName.value = '';
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'CustomerDetailsController error in $action', category: 'customer.controller', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'customer');
        scope.setTag('controller', 'CustomerDetailsController');
        scope.setContexts('customer_action', <String, dynamic>{'action': action, 'currentPage': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
