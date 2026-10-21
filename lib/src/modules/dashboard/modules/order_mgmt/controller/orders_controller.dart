import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/model/view_orders_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/repository/orders_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OrdersController extends BaseServerTableController<OrderDatum> {
  final OrdersRepository _ordersRepository;
  OrdersController({required this._ordersRepository});

  @override
  void onInit() {
    super.onInit();
    fetchServerData();
  }

  @override
  String searchTokenBuilder(OrderDatum item) {
    return '${item.orderNumber} ${item.id} ${item.customerFullName} ${item.phone} ${item.email} ${item.paymentMethod} ${item.orderStatus} ${item.city}'
        .toLowerCase()
        .trim();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final ViewOrdersModel response = await _ordersRepository.getOrders(
          page: currentPage.value,
          limit: itemsPerPage.value,
          search: searchQuery.value,
        );

        if (isClosed) return;

        if (response.success) {
          final int totalRecords = response.pagination?.totalRecords ?? response.data.length;
          final int? totalPages = response.pagination?.totalPages;

          setServerData(data: response.data, totalCount: totalRecords, pageCount: totalPages);
        } else {
          errorMessage(message: 'Failed to fetch orders from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData');
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching orders.');
        }
      }
    });
  }

  Future<void> refreshOrders() async => refreshData();

  void _logException(dynamic exception, StackTrace stackTrace, String action) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'orders');
        scope.setTag('controller', 'OrdersController');
        scope.setContexts('order_action', <String, dynamic>{'action': action, 'currentPage': currentPage.value});
      },
    );
  }
}
