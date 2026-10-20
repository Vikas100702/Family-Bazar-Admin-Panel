import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/controller/orders_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/model/view_orders_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search order number, customer, phone, city...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshOrders,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Orders List',
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<OrderDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Customer Orders...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Orders Found',
              emptySubtitle: 'No customer orders match your query.',
              emptyIcon: Icons.shopping_bag_outlined,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('ORDER NO')),
                DataColumn(label: Text('CUSTOMER')),
                DataColumn(label: Text('CONTACT')),
                DataColumn(label: Text('TOTAL AMOUNT')),
                DataColumn(label: Text('PAYMENT')),
                DataColumn(label: Text('ORDER STATUS')),
                DataColumn(label: Text('DELIVERY CITY')),
                DataColumn(label: Text('ORDER PLACED')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, order) => _buildDataRow(context, order),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, OrderDatum order) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: order.orderNumber.isNotEmpty ? order.orderNumber : '#${order.id}',
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        DataCell(
          AppTableCellText(
            text: order.customerFullName,
            maxWidth: 160,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(order.phone.isNotEmpty ? order.phone : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              if (order.email.isNotEmpty)
                Text(order.email, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)),
            ],
          ),
        ),
        DataCell(
          Text(
            order.totalAmount.toCurrency(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryRed),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Text(
                order.paymentStatus,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: order.isPaid ? AppColors.statusGreenSuccess : AppColors.statusAmberWarning,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(
              order.orderStatus,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
            ),
          ),
        ),
        DataCell(AppTableCellText(text: order.city, maxWidth: 120, style: const TextStyle(fontSize: 12))),
        DataCell(Text(EntityDetailsDialogHelper.formatDate(order.createdAt), style: const TextStyle(fontSize: 11))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Full Order Details & Address',
            splashRadius: 18,
            onPressed: () => _showOrderDetailsDialog(context, order),
          ),
        ),
      ],
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrderDatum order) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: 'Order ${order.orderNumber}',
      subtitle: 'Customer: ${order.customerFullName} | Phone: ${order.phone}',
      headerIcon: Icons.receipt_long_rounded,
      sections: [
        DetailSection(
          title: 'Order Overview & Status',
          flags: [DetailFlag(label: 'Payment Completed', value: order.isPaid)],
          items: [
            DetailItem(label: 'Order ID', value: '#${order.id}', isCopyable: true),
            DetailItem(label: 'Order Number', value: order.orderNumber, isCopyable: true),
            DetailItem(label: 'Order Status', value: order.orderStatus),
            DetailItem(label: 'Payment Method', value: order.paymentMethod),
            DetailItem(label: 'Payment Status', value: order.paymentStatus),
            DetailItem(label: 'Delivery Slot ID', value: '#${order.deliverySlotId}'),
            if (order.couponCode != null) DetailItem(label: 'Coupon Code', value: order.couponCode!),
          ],
        ),
        DetailSection(
          title: 'Billing & Price Breakdown',
          items: [
            DetailItem(label: 'Subtotal Items', value: order.subtotal.toCurrency()),
            DetailItem(label: 'Discount Amount', value: '-${order.discountAmount.toCurrency()}'),
            DetailItem(label: 'Delivery Charge', value: order.deliveryCharge.toCurrency()),
            DetailItem(label: 'Small Cart Charge', value: order.smallCartCharge.toCurrency()),
            DetailItem(label: 'Handling Charge', value: order.handlingCharge.toCurrency()),
            DetailItem(label: 'Total Paid Amount', value: order.totalAmount.toCurrency(), isCopyable: true),
          ],
        ),
        DetailSection(
          title: 'Customer & Delivery Destination',
          items: [
            DetailItem(label: 'Customer ID', value: '#${order.customerId}', isCopyable: true),
            DetailItem(label: 'Customer Name', value: order.customerFullName),
            DetailItem(label: 'Phone Number', value: order.phone, isCopyable: true),
            DetailItem(label: 'Email Address', value: order.email, isCopyable: true),
            DetailItem(label: 'Address Type', value: order.addType),
            DetailItem(label: 'Full Address', value: order.formattedAddress, isCopyable: true),
            DetailItem(label: 'City & State', value: '${order.city}, ${order.state}'),
            DetailItem(label: 'Pincode', value: order.zipCode, isCopyable: true),
            if (order.latitude.isNotEmpty && order.longitude.isNotEmpty)
              DetailItem(label: 'Coordinates (Lat, Long)', value: '${order.latitude}, ${order.longitude}', isCopyable: true),
          ],
        ),
        DetailSection(
          title: 'System Timestamps & Gateway References',
          items: [
            DetailItem(label: 'Order Created Timestamp', value: EntityDetailsDialogHelper.formatDate(order.createdAt)),
            DetailItem(label: 'Razorpay Payment ID', value: order.razorpayPaymentId ?? '—', isCopyable: order.razorpayPaymentId != null),
            DetailItem(label: 'Transaction Status', value: order.paymentTxnStatus.isNotEmpty ? order.paymentTxnStatus : '—'),
          ],
        ),
      ],
    );
  }
}
