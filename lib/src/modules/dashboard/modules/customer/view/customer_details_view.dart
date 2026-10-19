/*
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_details_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search customer name, phone, email, referral code...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshDetails,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Customer Records',
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.pagedList.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: context.defaultDecoration,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                      SizedBox(height: 16),
                      Text('Loading Customer Details...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: DataTableWidget<CustomerDetailsDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Customer Records Found',
                      emptySubtitle: 'No customer data matches your search query.',
                      emptyIcon: Icons.people_outline_rounded,
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
                SizedBox(height: context.responsiveHeight(12, 16)),
                CustomPaginationWidget(
                  currentPage: controller.currentPage.value,
                  totalItems: controller.totalRecords.value,
                  itemsPerPage: controller.itemsPerPage.value,
                  itemsPerPageOptions: controller.pageSizeOptions,
                  isLoading: controller.isLoading.value,
                  onPageChanged: controller.changePage,
                  onItemsPerPageChanged: controller.changePageSize,
                ),
              ],
            );
          }),
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
        DataCell(SelectableText('#${customer.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Tooltip(
              message: displayName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(customer.phone.isNotEmpty ? customer.phone : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              if (customer.email.isNotEmpty)
                Text(customer.email, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)),
            ],
          ),
        ),
        DataCell(
          Text(
            '₹${customer.balance.isNotEmpty ? customer.balance : "0.00"}',
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
        DataCell(Text(cityOrState, style: const TextStyle(fontSize: 12))),
        DataCell(StatusBadge(isEditable: false, isActive: customer.isPhoneVerified, activeLabel: 'Verified', inactiveLabel: 'Unverified')),
        DataCell(
          Text(
            customer.lastTransactionDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.lastTransactionDate!.toLocal()) : '—',
            style: const TextStyle(fontSize: 11),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View Full Customer Details & All Addresses',
                splashRadius: 18,
                onPressed: () => _showCustomerDetailsDialog(context, customer),
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
                  message: 'Are you sure you want to delete coupon "${customer.fullName}"?',
                  onConfirm: () => controller.deleteCustomer(customer),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, CustomerDetailsDatum customer) {
    final List<DetailSection> dialogSections = [
      DetailSection(
        title: '1. Personal Profile & Credentials',
        flags: [
          DetailFlag(label: 'Phone Verified', value: customer.isPhoneVerified),
          DetailFlag(label: 'Email Verified', value: customer.isEmailVerified),
          DetailFlag(label: 'Active (Not Soft-Deleted)', value: customer.softDelete != '1'),
        ],
        items: [
          DetailItem(label: 'Customer ID', value: '#${customer.id}', isCopyable: true),
          DetailItem(label: 'Full Name', value: customer.fullName),
          DetailItem(label: 'Phone Number', value: customer.phone.isNotEmpty ? customer.phone : '—', isCopyable: true),
          DetailItem(label: 'Email Address', value: customer.email.isNotEmpty ? customer.email : '—', isCopyable: true),
          DetailItem(label: 'Referral Code', value: customer.referralCode.isNotEmpty ? customer.referralCode : '—', isCopyable: true),
          DetailItem(label: 'Firebase Token', value: customer.firbaseToken.isNotEmpty ? customer.firbaseToken : '—', isCopyable: true),
          DetailItem(label: 'Login Location', value: customer.loginLocation.isNotEmpty ? customer.loginLocation : '—'),
        ],
      ),
      DetailSection(
        title: '2. Wallet & Financial Balances',
        items: [
          DetailItem(label: 'Current Wallet Balance', value: '₹${customer.balance.isNotEmpty ? customer.balance : "0.00"}'),
          DetailItem(label: 'Lifetime Total Credit', value: '₹${customer.totalCredit.isNotEmpty ? customer.totalCredit : "0.00"}'),
          DetailItem(label: 'Lifetime Total Debit', value: '₹${customer.totalDebit.isNotEmpty ? customer.totalDebit : "0.00"}'),
          DetailItem(label: 'Total Completed Transactions', value: '${customer.transactionCount} Txns'),
          DetailItem(
            label: 'Last Transaction At',
            value: customer.lastTransactionDate != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.lastTransactionDate!.toLocal())
                : 'No Transactions',
          ),
        ],
      ),
    ];

    if (customer.addresses.isEmpty) {
      dialogSections.add(
        const DetailSection(
          title: '3. Registered Delivery Addresses (0)',
          items: [DetailItem(label: 'Address Info', value: 'No registered addresses found for this customer.')],
        ),
      );
    } else {
      for (int i = 0; i < customer.addresses.length; i++) {
        final Address add = customer.addresses[i];
        final bool isPrimary = add.isPrimaryAddress;

        dialogSections.add(
          DetailSection(
            title: '3.${i + 1}. Address: ${add.addType.isNotEmpty ? add.addType : "Address #${add.addressId}"}${isPrimary ? " [PRIMARY]" : ""}',
            flags: [DetailFlag(label: 'Primary Address', value: isPrimary)],
            items: [
              DetailItem(label: 'Address ID', value: '#${add.addressId}', isCopyable: true),
              DetailItem(label: 'Address Type', value: add.addType.isNotEmpty ? add.addType : 'Home'),
              DetailItem(label: 'Complete Street Address', value: add.formattedAddress, isCopyable: true),
              DetailItem(label: 'Address Line 1', value: add.addLine1.isNotEmpty ? add.addLine1 : '—'),
              if (add.addLine2.isNotEmpty) DetailItem(label: 'Address Line 2', value: add.addLine2),
              DetailItem(label: 'City', value: add.city.isNotEmpty ? add.city : '—'),
              DetailItem(label: 'State', value: add.state.isNotEmpty ? add.state : '—'),
              DetailItem(label: 'Pincode / Zip', value: add.zipCode.isNotEmpty ? add.zipCode : '—', isCopyable: true),
              DetailItem(label: 'Country Code', value: add.countryCode.isNotEmpty ? add.countryCode : 'IN'),
              if (add.latitude.isNotEmpty && add.longitude.isNotEmpty)
                DetailItem(label: 'Coordinates (Lat, Long)', value: '${add.latitude}, ${add.longitude}', isCopyable: true),
            ],
          ),
        );
      }
    }

    dialogSections.add(
      DetailSection(
        title: '4. System & Audit Logs',
        items: [
          DetailItem(
            label: 'Last Login Timestamp',
            value: customer.loginTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.loginTime!.toLocal()) : '—',
          ),
          DetailItem(
            label: 'Account Registration Date',
            value: customer.createdAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.createdAt!.toLocal()) : '—',
          ),
          DetailItem(
            label: 'Profile Last Updated',
            value: customer.updatedAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.updatedAt!.toLocal()) : '—',
          ),
        ],
      ),
    );

    EntityDetailsDialogHelper.show(
      context: context,
      title: customer.fullName,
      subtitle: 'Customer #${customer.id} | ${customer.addresses.length} Registered Address(es)',
      headerIcon: Icons.person_rounded,
      sections: dialogSections,
    );
  }
}
*/

import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
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
import 'package:intl/intl.dart';

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
          Text(
            customer.balance.toPrice(),
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
        DataCell(Text(cityOrState, style: const TextStyle(fontSize: 12))),
        DataCell(StatusBadge(isEditable: false, isActive: customer.isPhoneVerified, activeLabel: 'Verified', inactiveLabel: 'Unverified')),
        DataCell(
          Text(
            customer.lastTransactionDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.lastTransactionDate!.toLocal()) : '—',
            style: const TextStyle(fontSize: 11),
          ),
        ),
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
