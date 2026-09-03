import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/controller/firm_setup_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/view/firm_details_dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmView extends GetView<FirmController> {
  const FirmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsiveSize(16, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: context.responsiveSize(16, 24)),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Obx(() => _buildResponsiveTable(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Firm Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(20, 24)),
        ),
        IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Refresh Firms', splashRadius: 24, onPressed: () => controller.refreshFirms()),
      ],
    );
  }

  Widget _buildResponsiveTable(BuildContext context) {
    if (controller.firmList.isEmpty) {
      return Center(
        child: Text('No Firms Available.', style: context.subTitleStyle.copyWith(fontSize: 16, color: AppColors.textHintLight)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: controller.horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: controller.horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Scrollbar(
                controller: controller.verticalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller.verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    ),
                    headingTextStyle: context.titleStyleActive.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    columnSpacing: context.responsiveSize(20, 32),
                    dataRowMaxHeight: 60.0,
                    columns: const [
                      DataColumn(label: Text('Firm Code')),
                      DataColumn(label: Text('Firm Name')),
                      DataColumn(label: Text('Location Code')),
                      DataColumn(label: Text('CE Reg No')),
                      DataColumn(label: Text('GST Number')),
                      DataColumn(label: Text('Unit Acc Code')),
                      DataColumn(label: Text('Firm Pincode')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: controller.firmList.map((firm) => _buildDataRow(context, firm)).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(BuildContext context, Datum firm) {
    return DataRow(
      cells: [
        DataCell(Text(firm.fFirmCode.isNotEmpty ? firm.fFirmCode : 'N/A')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(firm.fFirmName.isNotEmpty ? firm.fFirmName : 'N/A', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(Text(firm.fLocationCode.isNotEmpty ? firm.fLocationCode : 'N/A')),
        DataCell(Text(firm.fCeRegNo.isNotEmpty ? firm.fCeRegNo : 'N/A')),
        DataCell(Text(firm.fGstNumber.isNotEmpty ? firm.fGstNumber : 'N/A')),
        DataCell(Text(firm.fUnitAccCode.isNotEmpty ? firm.fUnitAccCode : 'N/A')),
        DataCell(Text(firm.fPinCode.isNotEmpty ? firm.fPinCode : 'N/A')),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_rounded, color: AppColors.primaryBrandOrange, size: 20),
            tooltip: 'View Details',
            splashRadius: 24,
            onPressed: () {
              FirmDetailsDialogHelper.showFirmDetailsDialog(context, firm);
            },
          ),
        ),
      ],
    );
  }
}
