import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_details_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/view/customer_dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // In-Panel Switch: agar customer dashboard mode on hai toh wahi panel ke andar render hoga
      if (controller.isViewingCustomerDashboard.value) {
        return CustomerDashboardView();
      }

      return _buildCustomerTable(context);
    });
  }

  Widget _buildCustomerTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search customer name, phone, email, referral code...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshDetails,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Customer Records',
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<CustomerDetailsDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Customer Details...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Customer Records Found',
              emptySubtitle: 'No customer data matches your search query.',
              emptyIcon: Icons.people_outline_rounded,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('USER ID')),
                DataColumn(label: Text('CUSTOMER')),
                DataColumn(label: Text('CONTACT')),
                DataColumn(label: Text('WALLET BALANCE')),
                DataColumn(label: Text('TRANSACTIONS')),
                DataColumn(label: Text('PRIMARY CITY')),
                DataColumn(label: Text('PHONE STATUS')),
                DataColumn(label: Text('LAST TRANSACTION')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, item) => _buildDataRow(context, item),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, CustomerDetailsDatum customer) {
    final bool isDark = context.isDark;
    final String displayName = customer.fullName;
    final Address? primaryAdd = customer.primaryAddress;
    final String cityOrState = primaryAdd != null
        ? (primaryAdd.city.isNotEmpty ? primaryAdd.city : (primaryAdd.state.isNotEmpty ? primaryAdd.state : '—'))
        : '—';

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: '#${customer.id}',
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () => controller.openCustomerDashboard(customer),
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(4),
            child: AppTableCellText(
              text: displayName,
              maxWidth: 180,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryRed),
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(customer.phone.withDashFallback, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              if (customer.email.isNotEmpty)
                Text(customer.email, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)),
            ],
          ),
        ),
        DataCell(
          AppTableCellText(
            text: customer.balance.toPrice(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.statusGreenSuccess),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('${customer.transactionCount} Txns', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        DataCell(AppTableCellText(text: cityOrState, style: const TextStyle(fontSize: 12))),
        DataCell(StatusBadge(isEditable: false, isActive: customer.isPhoneVerified, activeLabel: 'Verified', inactiveLabel: 'Unverified')),
        DataCell(AppTableCellText(text: EntityDetailsDialogHelper.formatDate(customer.lastTransactionDate), style: context.captionStyle)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.primaryRed,
                tooltip: 'Open Customer Dashboard',
                splashRadius: 18,
                onPressed: () => controller.openCustomerDashboard(customer),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.statusRedError,
                tooltip: 'Delete / Soft-Delete Customer',
                splashRadius: 18,
                onPressed: () => DialogHelper.showDeleteDialog(
                  title: 'Delete Customer',
                  itemName: customer.fullName,
                  message: 'Are you sure you want to delete customer "${customer.fullName}"?',
                  onConfirm: () => controller.deleteCustomer(customer),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
