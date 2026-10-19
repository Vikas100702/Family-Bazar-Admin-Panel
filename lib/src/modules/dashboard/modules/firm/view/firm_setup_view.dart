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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: DataTableWidget<ViewFirmDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Registered Firms Found',
                      emptySubtitle: 'Add a new firm or refresh to sync with server.',
                      emptyIcon: Icons.domain_disabled_rounded,
                      columns: const [
                        DataColumn(label: Text('FIRM CODE')),
                        DataColumn(label: Text('FIRM NAME')),
                        DataColumn(label: Text('GSTIN')),
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

  DataRow _buildDataRow(BuildContext context, ViewFirmDatum firm) {
    final bool isDark = context.isDark;
    final String address = [firm.fFirmAdd1, firm.fFirmAdd2, firm.fFirmAdd3].where((part) => part.trim().isNotEmpty).join(', ');

    return DataRow(
      cells: [
        DataCell(SelectableText(firm.fFirmCode.isEmpty ? '—' : firm.fFirmCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: firm.fFirmName.isEmpty ? '—' : firm.fFirmName,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                firm.fFirmName.isEmpty ? '—' : firm.fFirmName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SelectableText(
            firm.fGstNumber.isEmpty ? '—' : firm.fGstNumber,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: address.isEmpty ? '—' : address,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(address.isEmpty ? '—' : address, maxLines: 5, overflow: TextOverflow.ellipsis, style: context.captionStyle),
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

  void _inspectFirmDetails(BuildContext context, ViewFirmDatum firm) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: firm.fFirmName.isNotEmpty ? firm.fFirmName.trim() : 'Firm Details',
      subtitle: 'Entity Profile for Code: ${firm.fFirmCode}',
      headerIcon: Icons.domain_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          items: [
            DetailItem(label: 'Firm Code', value: firm.fFirmCode, isCopyable: true),
            DetailItem(label: 'Firm Name', value: firm.fFirmName, isCopyable: true),
            DetailItem(label: 'GST Number', value: firm.fGstNumber, isCopyable: true),
            DetailItem(label: 'CE Reg No', value: firm.fCeRegNo, isCopyable: true),
            DetailItem(label: 'Pin Code', value: firm.fPinCode, isCopyable: true),
            if (firm.fCity != null && firm.fCity.toString().isNotEmpty) DetailItem(label: 'City', value: firm.fCity),
          ],
        ),
        DetailSection(
          title: 'Address Details',
          items: [
            DetailItem(label: 'Address Line 1', value: firm.fFirmAdd1),
            DetailItem(label: 'Address Line 2', value: firm.fFirmAdd2),
            if (firm.fFirmAdd3.toString().isNotEmpty) DetailItem(label: 'Address Line 3', value: firm.fFirmAdd3),
          ],
        ),
        DetailSection(
          title: 'History Details',
          items: [
            DetailItem(label: 'Created At', value: firm.fCreatedTimeStamp),
            DetailItem(label: 'Created By', value: firm.fCreatedBy),
            DetailItem(label: 'Modified At', value: firm.fModifyTimeStamp),
            DetailItem(label: 'Modified By', value: firm.fModifyBy),
          ],
        ),
      ],
    );
  }
}

typedef FirmSetupView = FirmView;
