import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
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
          searchHintText: 'Search customer name, phone, email...',
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

            final List<CustomerDetailsDatum> customerRecords = controller.pagedList.cast<CustomerDetailsDatum>().toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: DataTableWidget<CustomerDetailsDatum>(
                      items: customerRecords,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Customer Records Found',
                      emptySubtitle: 'No customer data matches your query. Try syncing with the server.',
                      emptyIcon: Icons.people_outline_rounded,
                      columns: const [
                        DataColumn(label: Text('USER ID')),
                        DataColumn(label: Text('CUSTOMER')),
                        DataColumn(label: Text('CONTACT')),
                        DataColumn(label: Text('WALLET BALANCE')),
                        DataColumn(label: Text('TOTAL CREDIT')),
                        DataColumn(label: Text('TOTAL DEBIT')),
                        DataColumn(label: Text('TRANSACTIONS')),
                        DataColumn(label: Text('LOCATION / CITY')),
                        DataColumn(label: Text('PHONE VERIFIED')),
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
    final String fullName = '${customer.firstName} ${customer.lastName}'.trim();
    final String displayName = fullName.isNotEmpty ? fullName : 'Unnamed Customer';

    // Safe address resolution from the List<Address>
    final Address? primaryAddress = _resolvePrimaryAddress(customer.addresses);
    final String cityOrState = primaryAddress != null
        ? (primaryAddress.city.isNotEmpty ? primaryAddress.city : (primaryAddress.state.isNotEmpty ? primaryAddress.state : 'N/A'))
        : 'N/A';

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
              SelectableText(
                customer.phone.isNotEmpty ? customer.phone : 'No Phone',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              if (customer.email.isNotEmpty)
                Text(customer.email, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)),
            ],
          ),
        ),
        DataCell(
          Text(
            '₹${customer.balance.isNotEmpty ? customer.balance : '0.00'}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.statusGreenSuccess),
          ),
        ),
        DataCell(
          Text(
            '₹${customer.totalCredit.isNotEmpty ? customer.totalCredit : '0.00'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            '₹${customer.totalDebit.isNotEmpty ? customer.totalDebit : '0.00'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
        DataCell(StatusBadge(isEditable: false, isActive: customer.isPhoneVarified == 1, activeLabel: 'Verified', inactiveLabel: 'Unverified')),
        DataCell(
          Text(
            customer.lastTransactionDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.lastTransactionDate!) : '—',
            style: const TextStyle(fontSize: 11),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Full Customer & Addresses',
            splashRadius: 18,
            onPressed: () => _showCustomerDetailsDialog(context, customer),
          ),
        ),
      ],
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, CustomerDetailsDatum customer) {
    final String fullName = '${customer.firstName} ${customer.lastName}'.trim();
    final Address? primaryAddress = _resolvePrimaryAddress(customer.addresses);

    final String primaryLocationStr = primaryAddress != null
        ? [
            primaryAddress.addLine1,
            primaryAddress.addLine2,
            primaryAddress.city,
            primaryAddress.state,
            primaryAddress.zipCode,
            primaryAddress.countryCode,
          ].where((part) => part.trim().isNotEmpty).join(', ')
        : 'No Address Registered';

    final List<DetailSection> dialogSections = [
      DetailSection(
        title: '1. Personal Information',
        items: [
          DetailItem(label: 'Full Name', value: fullName.isNotEmpty ? fullName : 'N/A'),
          DetailItem(label: 'Phone', value: customer.phone.isNotEmpty ? customer.phone : 'N/A', isCopyable: true),
          DetailItem(label: 'Phone Verified', value: customer.isPhoneVarified == 1 ? 'Yes' : 'No'),
          DetailItem(label: 'Email', value: customer.email.isNotEmpty ? customer.email : 'N/A', isCopyable: true),
          DetailItem(label: 'Email Verified', value: customer.isEmailVarifired == 1 ? 'Yes' : 'No'),
          DetailItem(label: 'Referral Code', value: customer.referralCode.isNotEmpty ? customer.referralCode : 'N/A', isCopyable: true),
        ],
      ),
      DetailSection(
        title: '2. Wallet & Financial Metrics',
        items: [
          DetailItem(label: 'Current Balance', value: '₹${customer.balance.isNotEmpty ? customer.balance : '0.00'}'),
          DetailItem(label: 'Total Credit', value: '₹${customer.totalCredit.isNotEmpty ? customer.totalCredit : '0.00'}'),
          DetailItem(label: 'Total Debit', value: '₹${customer.totalDebit.isNotEmpty ? customer.totalDebit : '0.00'}'),
          DetailItem(label: 'Transaction Count', value: customer.transactionCount.toString()),
          DetailItem(
            label: 'Last Transaction Date',
            value: customer.lastTransactionDate != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.lastTransactionDate!)
                : 'No Transactions',
          ),
        ],
      ),
      DetailSection(
        title: '3. Primary Address Details (${customer.addresses.length} Total Registered)',
        items: primaryAddress != null
            ? [
                DetailItem(label: 'Address Type', value: primaryAddress.addType.isNotEmpty ? primaryAddress.addType : 'N/A'),
                DetailItem(label: 'Full Address', value: primaryLocationStr),
                DetailItem(label: 'City', value: primaryAddress.city.isNotEmpty ? primaryAddress.city : 'N/A'),
                DetailItem(label: 'State', value: primaryAddress.state.isNotEmpty ? primaryAddress.state : 'N/A'),
                DetailItem(label: 'Zip Code', value: primaryAddress.zipCode.isNotEmpty ? primaryAddress.zipCode : 'N/A'),
                DetailItem(label: 'Is Primary Address', value: primaryAddress.isPrimary.isNotEmpty ? primaryAddress.isPrimary : 'N/A'),
              ]
            : [DetailItem(label: 'Address Info', value: 'No Address Registered')],
      ),
      DetailSection(
        title: '4. System & Audit Timestamps',
        items: [
          DetailItem(
            label: 'Last Login Time',
            value: customer.loginTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.loginTime!) : 'N/A',
          ),
          DetailItem(
            label: 'Account Created',
            value: customer.createdAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.createdAt!) : 'N/A',
          ),
          DetailItem(
            label: 'Profile Updated',
            value: customer.updatedAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(customer.updatedAt!) : 'N/A',
          ),
        ],
      ),
    ];

    EntityDetailsDialogHelper.show(
      context: context,
      title: fullName.isNotEmpty ? fullName : 'Customer #${customer.id}',
      subtitle: 'Customer ID: #${customer.id} | Referral: ${customer.referralCode.isNotEmpty ? customer.referralCode : 'N/A'}',
      headerIcon: Icons.person_rounded,
      sections: dialogSections,
    );
  }

  Address? _resolvePrimaryAddress(List<Address> addresses) {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isPrimary == '1' || a.isPrimary.toLowerCase() == 'yes' || a.isPrimary.toLowerCase() == 'true',
      orElse: () => addresses.first,
    );
  }
}
