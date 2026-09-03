import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmDetailsDialogHelper {
  /// Displays a comprehensive, responsive, view-only dialog mapping all Firm configuration fields.
  static void showFirmDetailsDialog(BuildContext context, Datum firm) {
    final mediaQuery = MediaQuery.sizeOf(context);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          width: context.isDesktop ? 920 : mediaQuery.width * 0.95,
          constraints: BoxConstraints(maxHeight: mediaQuery.height * 0.90, maxWidth: 920),
          padding: EdgeInsets.all(context.responsiveSize(20, 28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              _buildHeader(context, firm),
              const Divider(height: 28, thickness: 1),

              // --- Scrollable Body Content covering ALL fields ---
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Basic & Identification Info
                        _buildSectionHeader(context, '1. Basic & Identification Information'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Firm Code', firm.fFirmCode),
                          _infoItem('Firm Name', firm.fFirmName),
                          _infoItem('Short Name', firm.fShortName),
                          _infoItem('Parent Firm', firm.fParentFirm),
                          _infoItem('Base Firm Code', firm.fBaseFirmCode),
                          _infoItem('Primary Firm Code (P)', firm.fPFirmCode),
                          _infoItem('Billing Firm Code (B)', firm.fBFirmCode),
                          _infoItem('Other Firm Code (O)', firm.fOFirmCode),
                          _infoItem('Business Type', firm.fBussinessType),
                          _infoItem('Location Code', firm.fLocationCode),
                          _infoItem('Station Code', firm.fStationCode),
                          _infoItem('Order Firm', firm.fOrderFirm),
                          _infoItem('Rate Type', firm.fRateType),
                          _infoItem('Godown', firm.fGodown),
                          _infoItem('Is ShowRoom', firm.fIsShowRoom),
                        ]),
                        const SizedBox(height: 24),

                        // 2. Address & Location Details
                        _buildSectionHeader(context, '2. Address & Location Details'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Address Line 1', firm.fFirmAdd1),
                          _infoItem('Address Line 2', firm.fFirmAdd2),
                          _infoItem('Address Line 3', firm.fFirmAdd3),
                          _infoItem('Pin Code', firm.fPinCode),
                          _infoItem('Jurisdiction City', firm.fFirmJurisdictionCity),
                          _infoItem('City', firm.fCity),
                          _infoItem('Range Address', firm.fRangeAddress),
                          _infoItem('Division Address', firm.fDivisionAddress),
                        ]),
                        const SizedBox(height: 24),

                        // 3. Contact & Communication
                        _buildSectionHeader(context, '3. Contact & Communication'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Phone', firm.fFirmPhone),
                          _infoItem('Phone 1', firm.fFirmPhone1),
                          _infoItem('Mobile', firm.fFirmMobile),
                          _infoItem('Email', firm.fFirmEmail),
                          _infoItem('Web', firm.fFirmWeb),
                          _infoItem('Fax', firm.fFirmFax),
                        ]),
                        const SizedBox(height: 24),

                        // 4. Tax, Statutory & Registration Details
                        _buildSectionHeader(context, '4. Tax, Statutory & Registration Details'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('GST Number', firm.fGstNumber),
                          _infoItem('PAN Number', firm.fPanNo),
                          _infoItem('TIN Number', firm.fTinNo),
                          _infoItem('CST Number', firm.fCstNumber),
                          _infoItem('UPTT Number', firm.fUpttNumber),
                          _infoItem('CE Reg No', firm.fCeRegNo),
                          _infoItem('Software License No', firm.fSwLicenseNo),
                          _infoItem('Drug Lic No 1', firm.fDrugLicNo1),
                          _infoItem('Drug Lic No 2', firm.fDrugLicNo2),
                          _infoItem('ECC Number', firm.fEccNumber),
                          _infoItem('Range', firm.fRange),
                          _infoItem('Division', firm.fDivision),
                          _infoItem('Commissionerate', firm.fCommissionerate),
                          _infoItem('Assessing Authority Designation', firm.fDesignationOfAssessingAuthority),
                          _infoItem('Circle Name', firm.fCircleName),
                          _infoItem('Tin Head', firm.fTinHead),
                          _infoItem('CST Head', firm.fCstHead),
                          _infoItem('Tin Date', firm.fTinDate),
                          _infoItem('CST Date', firm.fCstDate),
                        ]),
                        const SizedBox(height: 24),

                        // 5. Billing, Sales & Financial Limits
                        _buildSectionHeader(context, '5. Billing, Sales & Financial Limits'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFlagChip(context, 'Sale Allow', firm.fSaleAllow),
                            _buildFlagChip(context, 'Not Invoice Print', firm.fNotInvoicePrint),
                            _buildFlagChip(context, 'Not Transaction Req', firm.fNotTransactionReq),
                            _buildFlagChip(context, 'TCS Applicable', firm.fTcsApplicable),
                            _buildFlagChip(context, 'Show Stock', firm.fShowStock),
                            _buildFlagChip(context, 'Is Head Office (HO)', firm.fIsHo),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoGrid(context, [
                          _infoItem('Account No', firm.fAccNo),
                          _infoItem('Unit Acc Code', firm.fUnitAccCode),
                          _infoItem('Min Cash Sale Amt in Bill', firm.fMinimumCashSaleAmtInBill),
                          _infoItem('Max Cash Sale Amt in Bill', firm.fMaximumCashSaleAmtInBill),
                          _infoItem('Min Credit Sale Amt in Bill', firm.fMinimumCreditSaleAmtInBill),
                          _infoItem('Max Credit Sale Amt in Bill', firm.fMaximumCreditSaleAmtInBill),
                          _infoItem('Export Detail', firm.fExportDetail),
                        ]),
                        const SizedBox(height: 24),

                        // 6. API, E-Way & Token Integrations
                        _buildSectionHeader(context, '6. API, E-Way & Token Integrations'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Eway API User', firm.fEwayApiUser),
                          _infoItem('Eway API Password', firm.fEwayApiPasswd),
                          _infoItem('Eway Token', firm.fEwayToken, isCopyable: true),
                          _infoItem('GST User ID', firm.fGstUserId),
                          _infoItem('GST Token', firm.fGstToken, isCopyable: true),
                          _infoItem('E-Invoice', firm.fEInvoice),
                          _infoItem('E-Invoice Token', firm.fEInvoiceToken, isCopyable: true),
                        ]),
                        const SizedBox(height: 24),

                        // 7. UPI & Banking Configuration
                        _buildSectionHeader(context, '7. UPI & Banking Configuration'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Bank Code', firm.fBankCode),
                          _infoItem('UPI Merchant Name', firm.fUpiMerchantName),
                          _infoItem('UPI MID', firm.fUpiMid, isCopyable: true),
                          _infoItem('UPI Key', firm.fUpiKey, isCopyable: true),
                          _infoItem('UPI VPA', firm.fUpiVpa),
                          _infoItem('UPI Merchant Code', firm.fUpiMerchantCode),
                          _infoItem('UPI Merchant String', firm.fUpiMerchantString, isCopyable: true),
                        ]),
                        const SizedBox(height: 24),

                        // 8. Third-Party Integrations (AIOCD, IMS, Retailio, Pharmarack)
                        _buildSectionHeader(context, '8. Third-Party & Distributor Integrations'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Retailio Dist Code', firm.fRetailioDistCode),
                          _infoItem('Pharmarack Dist Code', firm.fPharmarackDistCode),
                          _infoItem('AIOCD Code', firm.fAiocdCode),
                          _infoItem('AIOCD Data Type', firm.fAiocdDataType),
                          _infoItem('AIOCD Upload Frequency', firm.fAiocdDataUploadFrequency),
                          _infoItem('AIOCD Company List', firm.fAiocdCompanyList),
                          _infoItem('AIOCD Impl. Date', firm.fAiocdImplementationDate),
                          _infoItem('AIOCD Password', firm.fAiocdPasswd),
                          _infoItem('AIOCD Sale Company List', firm.fAiocdSaleCompanyList),
                          _infoItem('IMS Code', firm.fImsCode),
                          _infoItem('IMS User Code', firm.fImsUserCode),
                          _infoItem('IMS Password', firm.fImsPasswd),
                          _infoItem('IMS Upload Frequency', firm.fImsDataUploadFrequency),
                          _infoItem('IMS Company List', firm.fImsCompanyList),
                          _infoItem('IMS Impl. Date', firm.fImsImplementationDate),
                          _infoItem('IMS Sale Company List', firm.fImsSaleCompanyList),
                          _infoItem('IMS Sale File', firm.fImsSaleFile),
                          _infoItem('IMS Price File', firm.fImsPriceFile),
                          _infoItem('IMS Stock File', firm.fImsStockFile),
                          _infoItem('R-IMS Code', firm.fRImsCode),
                          _infoItem('R-IMS User Code', firm.fRImsUserCode),
                          _infoItem('R-IMS Password', firm.fRImsPasswd),
                          _infoItem('R-IMS Upload Frequency', firm.fRImsDataUploadFrequency),
                          _infoItem('R-IMS Impl. Date', firm.fRImsImplementationDate),
                          _infoItem('R-IMS Sale File', firm.fRImsSaleFile),
                          _infoItem('R-IMS Purchase File', firm.fRImsPurchaseFile),
                          _infoItem('R-IMS Stock File', firm.fRImsStockFile),
                        ]),
                        const SizedBox(height: 24),

                        // 9. Security, Certificates & Metadata
                        _buildSectionHeader(context, '9. Security, Certificates & Metadata'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('EU Code', firm.fEuCode),
                          _infoItem('MU Code', firm.fMuCode),
                          _infoItem('Auth Sig Name', firm.fAuthSigName),
                          _infoItem('Auth Sig Father Name', firm.fAuthSigFatherName),
                          _infoItem('Auth Sig Status', firm.fAuthSigStatus),
                          _infoItem('Certificate Name', firm.fCertificateName),
                          _infoItem('Certificate Pin', firm.fCertificatePin),
                          _infoItem('App Lock', firm.fAppLock),
                          _infoItem('R1 Lock Date', firm.fR1LockDate),
                          _infoItem('R3B Lock Date', firm.fR3BLockDate),
                          _infoItem('Sync Date', firm.fSyncDate),
                          _infoItem('Priority', firm.fPriority),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Footer Action ---
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrandOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bounded header preventing horizontal overflow when firm names are lengthy
  static Widget _buildHeader(BuildContext context, Datum firm) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryBrandOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.business_rounded, color: AppColors.primaryBrandOrange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${firm.fFirmName.isNotEmpty ? firm.fFirmName : "Firm"} Details',
                style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 19), fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Complete configuration overview for ${firm.fFirmCode.isNotEmpty ? firm.fFirmCode : "N/A"}',
                style: context.subTitleStyle.copyWith(fontSize: context.responsiveSize(12, 13), color: AppColors.textSecondaryLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.close_rounded), splashRadius: 24, tooltip: 'Close Dialog', onPressed: () => Get.back()),
      ],
    );
  }

  static String _formatVal(dynamic val) {
    if (val == null) return 'N/A';
    final str = val.toString().trim();
    return str.isEmpty ? 'N/A' : str;
  }

  static Map<String, dynamic> _infoItem(String label, dynamic value, {bool isCopyable = false}) {
    return {'label': label, 'value': _formatVal(value), 'isCopyable': isCopyable};
  }

  static Widget _buildInfoGrid(BuildContext context, List<Map<String, dynamic>> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 520;
        final double itemWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _buildInfoCard(
                context,
                item['label'] as String,
                item['value'] as String,
                Icons.info_outline_rounded,
                isCopyable: item['isCopyable'] as bool? ?? false,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  static Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Text(
        title,
        style: context.titleStyleActive.copyWith(
          fontSize: context.responsiveSize(14, 15),
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBrandOrange,
        ),
      ),
    );
  }

  static Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon, {bool isCopyable = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.subTitleStyle.copyWith(fontSize: 11, color: AppColors.textHintLight)),
                const SizedBox(height: 3),
                isCopyable
                    ? SelectableText(
                        value,
                        style: context.subTitleStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      )
                    : Text(
                        value,
                        style: context.subTitleStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFlagChip(BuildContext context, String label, bool value) {
    final Color chipColor = value ? Colors.green.shade800 : Colors.red.shade800;
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      avatar: Icon(value ? Icons.check_circle_rounded : Icons.cancel_rounded, color: chipColor, size: 15),
      backgroundColor: chipColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
    );
  }
}
