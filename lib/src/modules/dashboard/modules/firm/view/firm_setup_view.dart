import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
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
          child: Obx(
            () => PaginatedTableContainer<ViewFirmDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Registered Firms...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Registered Firms Found',
              emptySubtitle: 'Add a new firm or refresh to sync with server.',
              emptyIcon: Icons.domain_disabled_rounded,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
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
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewFirmDatum firm) {
    final bool isDark = context.isDark;
    final String address = [firm.fFirmAdd1, firm.fFirmAdd2, firm.fFirmAdd3].where((part) => part.trim().isNotEmpty).join(', ');

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: firm.fFirmCode.withDashFallback,
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(
          AppTableCellText(
            text: firm.fFirmName.withDashFallback,
            maxWidth: 220,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          AppTableCellText(
            text: firm.fGstNumber.withDashFallback,
            isSelectable: true,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(AppTableCellText(text: address.withDashFallback, maxWidth: 240, maxLines: 2, style: context.captionStyle)),
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
            DetailItem(label: 'Firm Code', value: firm.fFirmCode.withDashFallback, isCopyable: true),
            DetailItem(label: 'Firm Name', value: firm.fFirmName.withDashFallback, isCopyable: true),
            DetailItem(label: 'GST Number', value: firm.fGstNumber.withDashFallback, isCopyable: true),
            DetailItem(label: 'CE Reg No', value: firm.fCeRegNo.withDashFallback, isCopyable: true),
            DetailItem(label: 'Pin Code', value: firm.fPinCode.withDashFallback, isCopyable: true),
            DetailItem(label: 'City', value: firm.fCity?.toString().withDashFallback ?? '—'),
          ],
        ),
        DetailSection(
          title: 'Address Details',
          items: [
            DetailItem(label: 'Address Line 1', value: firm.fFirmAdd1.withDashFallback),
            DetailItem(label: 'Address Line 2', value: firm.fFirmAdd2.withDashFallback),
            DetailItem(label: 'Address Line 3', value: firm.fFirmAdd3.withDashFallback),
          ],
        ),
        DetailSection(
          title: 'History Details',
          items: [
            DetailItem(label: 'Created At', value: firm.fCreatedTimeStamp),
            DetailItem(label: 'Created By', value: firm.fCreatedBy.withDashFallback),
            DetailItem(label: 'Modified At', value: firm.fModifyTimeStamp),
            DetailItem(label: 'Modified By', value: firm.fModifyBy.withDashFallback),
          ],
        ),
      ],
    );
  }
}

typedef FirmSetupView = FirmView;
