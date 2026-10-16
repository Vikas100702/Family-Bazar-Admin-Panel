import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/repository/customer_details_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomerDetailsController extends BaseServerTableController<CustomerDetailsDatum> {
  final CustomerDetailsRepository _customerDetailsRepository;
  CustomerDetailsController({required this._customerDetailsRepository});

  @override
  void onInit() {
    super.onInit();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final response = await _customerDetailsRepository.viewDetails(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );
        if (isClosed) return;

        if (response.status) {
          setServerData(data: response.data, totalCount: response.pagination?.totalRecords ?? 0, pageCount: response.pagination?.totalPages);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the customer details from server.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'CustomerWalletController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching customer details.');
      }
    });
  }

  Future<void> refreshDetails() async => fetchServerData();
}
