import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/controller/firm_setup_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmView extends GetView<FirmController> {
  const FirmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search firm code, GSTIN, name...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshFirms,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Registered Firms',
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
                      Text('Loading Registered Firms...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<Datum>(
                      items: controller.pagedList.toList(),
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Registered Firms Found',
                      emptySubtitle: 'Add a new firm or refresh to sync with server.',
                      emptyIcon: Icons.domain_disabled_rounded,
                      columns: const [
                        DataColumn(label: Text('FIRM CODE')),
                        DataColumn(label: Text('FIRM NAME')),
                        DataColumn(label: Text('GSTIN / UIN')),
                        DataColumn(label: Text('LOCATION')),
                        DataColumn(label: Text('UNIT ACC')),
                        DataColumn(label: Text('FULL ADDRESS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, firm) => _buildDataRow(context, firm),
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

  DataRow _buildDataRow(BuildContext context, Datum firm) {
    final isDark = context.isDark;
    final address = [firm.fFirmAdd1, firm.fFirmAdd2, firm.fFirmAdd3].where((part) => part.trim().isNotEmpty).join(', ');

    return DataRow(
      cells: [
        DataCell(SelectableText(firm.fFirmCode.isEmpty ? 'N/A' : firm.fFirmCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: firm.fFirmName.isEmpty ? 'N/A' : firm.fFirmName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                firm.fFirmName.isEmpty ? 'N/A' : firm.fFirmName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SelectableText(
            firm.fGstNumber.isEmpty ? 'N/A' : firm.fGstNumber,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(Text(firm.fLocationCode.isEmpty ? 'N/A' : firm.fLocationCode)),
        DataCell(Text(firm.fUnitAccCode.isEmpty ? 'N/A' : firm.fUnitAccCode)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: address.isEmpty ? 'N/A' : address,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(address.isEmpty ? 'N/A' : address, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.captionStyle),
            ),
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
                tooltip: 'View Full Firm Details',
                splashRadius: 18,
                onPressed: () => _inspectFirmDetails(context, firm),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _inspectFirmDetails(BuildContext context, Datum firm) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: firm.fFirmName.isNotEmpty ? firm.fFirmName.trim() : 'Firm Details',
      subtitle: 'Entity Profile for Code: ${firm.fFirmCode}',
      headerIcon: Icons.domain_rounded,
      sections: [
        DetailSection(
          title: '1. Legal & Identity Information',
          items: [
            DetailItem(label: 'Firm Code', value: firm.fFirmCode, isCopyable: true),
            DetailItem(label: 'Firm Name', value: firm.fFirmName),
            DetailItem(label: 'GSTIN / UIN', value: firm.fGstNumber, isCopyable: true),
            DetailItem(label: 'CE Reg No', value: firm.fCeRegNo, isCopyable: true),
            DetailItem(label: 'Unit Acc Code', value: firm.fUnitAccCode, isCopyable: true),
            DetailItem(label: 'Location Code', value: firm.fLocationCode),
            DetailItem(label: 'Jurisdiction City', value: firm.fFirmJurisdictionCity),
          ],
        ),
        DetailSection(
          title: '2. Operational & Regulatory Flags',
          flags: [
            DetailFlag(label: 'Sale Allowed', value: firm.fSaleAllow),
            DetailFlag(label: 'Show Stock', value: firm.fShowStock),
            DetailFlag(label: 'Is Head Office', value: firm.fIsHo),
            DetailFlag(label: 'TCS Applicable', value: firm.fTcsApplicable),
            DetailFlag(label: 'No Invoice Print', value: firm.fNotInvoicePrint),
          ],
          items: [
            DetailItem(label: 'Business Type', value: firm.fBussinessType),
            DetailItem(label: 'SW License No', value: firm.fSwLicenseNo),
            DetailItem(label: 'Pin Code', value: firm.fPinCode),
            DetailItem(label: 'EU Code', value: firm.fEuCode),
            DetailItem(label: 'MU Code', value: firm.fMuCode),
          ],
        ),
        DetailSection(
          title: '3. Registered Physical Address',
          items: [
            DetailItem(label: 'Address Line 1', value: firm.fFirmAdd1),
            DetailItem(label: 'Address Line 2', value: firm.fFirmAdd2),
            DetailItem(label: 'Address Line 3', value: firm.fFirmAdd3),
          ],
        ),
        DetailSection(
          title: '4. E-Way Bill & Compliance Settings',
          items: [
            DetailItem(label: 'Eway API User', value: firm.fEwayApiUser),
            DetailItem(label: 'Parent Firm Code', value: firm.fPFirmCode),
            DetailItem(label: 'Base Firm Code', value: firm.fBFirmCode),
            DetailItem(label: 'Order Firm Code', value: firm.fOFirmCode),
          ],
        ),
      ],
    );
  }
}

typedef FirmSetupView = FirmView;
