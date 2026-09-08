import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
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
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.responsiveSize(16, 24),
            context.responsiveSize(16, 24),
            context.responsiveSize(16, 24),
            context.responsiveSize(12, 16),
          ),
          child: _buildHeader(context),
        ),

        // Generic Responsive Data Table
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24)),
            child: Obx(
              () => DataTableWidget<Datum>(
                items: controller.pagedList.toList(),
                horizontalScrollController: controller.horizontalScrollController,
                verticalScrollController: controller.verticalScrollController,
                emptyTitle: 'No Firms Available',
                emptyIcon: Icons.business_outlined,
                columns: const [
                  DataColumn(label: Text('FIRM CODE')),
                  DataColumn(label: Text('FIRM NAME')),
                  DataColumn(label: Text('LOCATION CODE')),
                  DataColumn(label: Text('CE REG NO')),
                  DataColumn(label: Text('GST NUMBER')),
                  DataColumn(label: Text('UNIT ACC CODE')),
                  DataColumn(label: Text('PINCODE')),
                  DataColumn(label: Text('SALE ALLOW')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rowBuilder: (context, firm) => _buildDataRow(context, firm),
              ),
            ),
          ),
        ),

        // Pagination
        Padding(
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          child: Obx(
            () => CustomPaginationWidget(
              currentPage: controller.currentPage.value,
              totalPages: controller.totalPages.value,
              totalRecords: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              pageSizeOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onPageSizeChanged: controller.changePageSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firm Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.responsiveSize(20, 24)),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrandOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.w600)),
          onPressed: () => controller.refreshFirms(),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, Datum firm) {
    return DataRow(
      cells: [
        DataCell(Text(_formatText(firm.fFirmCode), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(firm.fFirmName),
              child: Text(_formatText(firm.fFirmName), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        DataCell(Text(_formatText(firm.fLocationCode))),
        DataCell(Text(_formatText(firm.fCeRegNo))),
        DataCell(Text(_formatText(firm.fGstNumber))),
        DataCell(Text(_formatText(firm.fUnitAccCode))),
        DataCell(Text(_formatText(firm.fPinCode))),
        DataCell(_buildStatusBadge(firm.fSaleAllow.toString())),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryBrandOrange, size: 22),
            tooltip: 'View Configurations',
            splashRadius: 24,
            mouseCursor: SystemMouseCursors.click,
            onPressed: () => _showFirmDetails(context, firm),
          ),
        ),
      ],
    );
  }

  void _showFirmDetails(BuildContext context, Datum firm) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: '${firm.fFirmName.isNotEmpty ? firm.fFirmName.trim() : "Firm"} Details',
      subtitle: 'Configuration overview for code: ${firm.fFirmCode.isNotEmpty ? firm.fFirmCode : "N/A"}',
      headerIcon: Icons.business_rounded,
      sections: [
        DetailSection(
          title: '1. Basic & Identification Information',
          items: [
            DetailItem(label: 'Firm Code', value: firm.fFirmCode, isCopyable: true),
            DetailItem(label: 'Firm Name', value: firm.fFirmName),
            DetailItem(label: 'Short Name', value: firm.fShortName),
            DetailItem(label: 'Parent Firm', value: firm.fParentFirm),
            DetailItem(label: 'Base Firm Code', value: firm.fBaseFirmCode),
            DetailItem(label: 'Primary Firm Code (P)', value: firm.fPFirmCode),
            DetailItem(label: 'Billing Firm Code (B)', value: firm.fBFirmCode),
            DetailItem(label: 'Other Firm Code (O)', value: firm.fOFirmCode),
            DetailItem(label: 'Business Type', value: firm.fBussinessType),
            DetailItem(label: 'Location Code', value: firm.fLocationCode),
            DetailItem(label: 'Station Code', value: firm.fStationCode),
            DetailItem(label: 'Order Firm', value: firm.fOrderFirm),
            DetailItem(label: 'Rate Type', value: firm.fRateType),
            DetailItem(label: 'Godown', value: firm.fGodown),
            DetailItem(label: 'Is ShowRoom', value: firm.fIsShowRoom),
          ],
        ),
        DetailSection(
          title: '2. Address & Location Details',
          items: [
            DetailItem(label: 'Address Line 1', value: firm.fFirmAdd1),
            DetailItem(label: 'Address Line 2', value: firm.fFirmAdd2),
            DetailItem(label: 'Address Line 3', value: firm.fFirmAdd3),
            DetailItem(label: 'Pin Code', value: firm.fPinCode),
            DetailItem(label: 'City', value: firm.fCity),
            DetailItem(label: 'Jurisdiction City', value: firm.fFirmJurisdictionCity),
            DetailItem(label: 'Range Address', value: firm.fRangeAddress),
            DetailItem(label: 'Division Address', value: firm.fDivisionAddress),
          ],
        ),
        DetailSection(
          title: '3. Contact & Communication',
          items: [
            DetailItem(label: 'Phone', value: firm.fFirmPhone),
            DetailItem(label: 'Phone 1', value: firm.fFirmPhone1),
            DetailItem(label: 'Mobile', value: firm.fFirmMobile),
            DetailItem(label: 'Email', value: firm.fFirmEmail),
            DetailItem(label: 'Web', value: firm.fFirmWeb),
            DetailItem(label: 'Fax', value: firm.fFirmFax),
          ],
        ),
        DetailSection(
          title: '4. Tax, Statutory & Registration Details',
          items: [
            DetailItem(label: 'GST Number', value: firm.fGstNumber, isCopyable: true),
            DetailItem(label: 'PAN Number', value: firm.fPanNo, isCopyable: true),
            DetailItem(label: 'TIN Number', value: firm.fTinNo),
            DetailItem(label: 'CST Number', value: firm.fCstNumber),
            DetailItem(label: 'UPTT Number', value: firm.fUpttNumber),
            DetailItem(label: 'CE Reg No', value: firm.fCeRegNo),
            DetailItem(label: 'Software License No', value: firm.fSwLicenseNo),
            DetailItem(label: 'Drug Lic No 1', value: firm.fDrugLicNo1),
            DetailItem(label: 'Drug Lic No 2', value: firm.fDrugLicNo2),
            DetailItem(label: 'ECC Number', value: firm.fEccNumber),
            DetailItem(label: 'Range', value: firm.fRange),
            DetailItem(label: 'Division', value: firm.fDivision),
            DetailItem(label: 'Commissionerate', value: firm.fCommissionerate),
            DetailItem(label: 'Assessing Authority Designation', value: firm.fDesignationOfAssessingAuthority),
            DetailItem(label: 'Circle Name', value: firm.fCircleName),
            DetailItem(label: 'TIN Head', value: firm.fTinHead),
            DetailItem(label: 'CST Head', value: firm.fCstHead),
            DetailItem(label: 'TIN Date', value: firm.fTinDate),
            DetailItem(label: 'CST Date', value: firm.fCstDate),
          ],
        ),
        DetailSection(
          title: '5. Operational Flags & Billing Limits',
          flags: [
            DetailFlag(label: 'Sale Allow', value: firm.fSaleAllow),
            DetailFlag(label: 'Not Invoice Print', value: firm.fNotInvoicePrint),
            DetailFlag(label: 'Not Transaction Req', value: firm.fNotTransactionReq),
            DetailFlag(label: 'TCS Applicable', value: firm.fTcsApplicable),
            DetailFlag(label: 'Show Stock', value: firm.fShowStock),
            DetailFlag(label: 'Is Head Office (HO)', value: firm.fIsHo),
          ],
          items: [
            DetailItem(label: 'Account No', value: firm.fAccNo),
            DetailItem(label: 'Unit Acc Code', value: firm.fUnitAccCode),
            DetailItem(label: 'Min Cash Sale Amt in Bill', value: firm.fMinimumCashSaleAmtInBill),
            DetailItem(label: 'Max Cash Sale Amt in Bill', value: firm.fMaximumCashSaleAmtInBill),
            DetailItem(label: 'Min Credit Sale Amt in Bill', value: firm.fMinimumCreditSaleAmtInBill),
            DetailItem(label: 'Max Credit Sale Amt in Bill', value: firm.fMaximumCreditSaleAmtInBill),
            DetailItem(label: 'Export Detail', value: firm.fExportDetail),
          ],
        ),
        DetailSection(
          title: '6. API, E-Way & Token Integrations',
          items: [
            DetailItem(label: 'Eway API User', value: firm.fEwayApiUser),
            DetailItem(label: 'Eway API Password', value: firm.fEwayApiPasswd),
            DetailItem(label: 'Eway Token', value: firm.fEwayToken, isCopyable: true),
            DetailItem(label: 'GST User ID', value: firm.fGstUserId),
            DetailItem(label: 'GST Token', value: firm.fGstToken, isCopyable: true),
            DetailItem(label: 'E-Invoice', value: firm.fEInvoice),
            DetailItem(label: 'E-Invoice Token', value: firm.fEInvoiceToken, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '7. UPI & Banking Configuration',
          items: [
            DetailItem(label: 'Bank Code', value: firm.fBankCode),
            DetailItem(label: 'UPI Merchant Name', value: firm.fUpiMerchantName),
            DetailItem(label: 'UPI MID', value: firm.fUpiMid, isCopyable: true),
            DetailItem(label: 'UPI Key', value: firm.fUpiKey, isCopyable: true),
            DetailItem(label: 'UPI VPA', value: firm.fUpiVpa),
            DetailItem(label: 'UPI Merchant Code', value: firm.fUpiMerchantCode),
            DetailItem(label: 'UPI Merchant String', value: firm.fUpiMerchantString, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '8. Third-Party & Distributor Integrations',
          items: [
            DetailItem(label: 'Retailio Dist Code', value: firm.fRetailioDistCode),
            DetailItem(label: 'Pharmarack Dist Code', value: firm.fPharmarackDistCode),
            DetailItem(label: 'AIOCD Code', value: firm.fAiocdCode),
            DetailItem(label: 'AIOCD Data Type', value: firm.fAiocdDataType),
            DetailItem(label: 'AIOCD Upload Frequency', value: firm.fAiocdDataUploadFrequency),
            DetailItem(label: 'AIOCD Company List', value: firm.fAiocdCompanyList),
            DetailItem(label: 'AIOCD Impl. Date', value: firm.fAiocdImplementationDate),
            DetailItem(label: 'AIOCD Password', value: firm.fAiocdPasswd),
            DetailItem(label: 'AIOCD Sale Company List', value: firm.fAiocdSaleCompanyList),
            DetailItem(label: 'IMS Code', value: firm.fImsCode),
            DetailItem(label: 'IMS User Code', value: firm.fImsUserCode),
            DetailItem(label: 'IMS Password', value: firm.fImsPasswd),
            DetailItem(label: 'IMS Upload Frequency', value: firm.fImsDataUploadFrequency),
            DetailItem(label: 'IMS Company List', value: firm.fImsCompanyList),
            DetailItem(label: 'IMS Impl. Date', value: firm.fImsImplementationDate),
            DetailItem(label: 'IMS Sale Company List', value: firm.fImsSaleCompanyList),
            DetailItem(label: 'IMS Sale File', value: firm.fImsSaleFile),
            DetailItem(label: 'IMS Price File', value: firm.fImsPriceFile),
            DetailItem(label: 'IMS Stock File', value: firm.fImsStockFile),
            DetailItem(label: 'R-IMS Code', value: firm.fRImsCode),
            DetailItem(label: 'R-IMS User Code', value: firm.fRImsUserCode),
            DetailItem(label: 'R-IMS Password', value: firm.fRImsPasswd),
            DetailItem(label: 'R-IMS Upload Frequency', value: firm.fRImsDataUploadFrequency),
            DetailItem(label: 'R-IMS Impl. Date', value: firm.fRImsImplementationDate),
            DetailItem(label: 'R-IMS Sale File', value: firm.fRImsSaleFile),
            DetailItem(label: 'R-IMS Purchase File', value: firm.fRImsPurchaseFile),
            DetailItem(label: 'R-IMS Stock File', value: firm.fRImsStockFile),
          ],
        ),
        DetailSection(
          title: '9. Security, Certificates & Metadata',
          items: [
            DetailItem(label: 'EU Code', value: firm.fEuCode),
            DetailItem(label: 'MU Code', value: firm.fMuCode),
            DetailItem(label: 'Auth Sig Name', value: firm.fAuthSigName),
            DetailItem(label: 'Auth Sig Father Name', value: firm.fAuthSigFatherName),
            DetailItem(label: 'Auth Sig Status', value: firm.fAuthSigStatus),
            DetailItem(label: 'Certificate Name', value: firm.fCertificateName),
            DetailItem(label: 'Certificate Pin', value: firm.fCertificatePin),
            DetailItem(label: 'App Lock', value: firm.fAppLock),
            DetailItem(label: 'R1 Lock Date', value: firm.fR1LockDate),
            DetailItem(label: 'R3B Lock Date', value: firm.fR3BLockDate),
            DetailItem(label: 'Sync Date', value: firm.fSyncDate),
            DetailItem(label: 'Priority', value: firm.fPriority),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String value) {
    final bool isTrue = value.toLowerCase() == 'true' || value == '1';
    final Color color = isTrue ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isTrue ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            isTrue ? 'Enabled' : 'Disabled',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatText(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString().trim();
  }
}
