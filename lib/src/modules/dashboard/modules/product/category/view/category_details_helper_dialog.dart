import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CategoryDetailsDialogHelper {
  /// Displays a comprehensive, responsive, view-only dialog mapping all Category configuration fields.
  static void showCategoryDetailsDialog(BuildContext context, ViewCategoryDatum category) {
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
              _buildHeader(context, category),
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
                          _infoItem('Category Code', category.igCode, isCopyable: true),
                          _infoItem('Category Name', category.igName),
                          _infoItem('CM Code', category.igCmCode),
                          _infoItem('Type', category.igType),
                          _infoItem('Old Code', category.igOldCode),
                          _infoItem('New Code', category.igNewCode),
                        ]),
                        const SizedBox(height: 24),

                        // 2. Operational & POS Configuration
                        _buildSectionHeader(context, '2. Operational Flags & POS Settings'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFlagChip(context, 'On POS', category.igOnPos),
                            _buildFlagChip(context, 'Negative Stock Billing', category.igNegativeStockBilling),
                            _buildFlagChip(context, 'Locked', category.igLock),
                            _buildFlagChip(context, 'Rate Wise Tax', category.igRateWiseTax),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoGrid(context, [
                          _infoItem('POS Index', category.igPosINdex),
                          _infoItem('POS Name', category.igPosName),
                          _infoItem('Point Value Per', category.igPointValuePer),
                          _infoItem('Print SrNo', category.igPrintSrNo),
                          _infoItem('Rate Wise Tax Rate Type', category.igRateWiseTaxRateType),
                        ]),
                        const SizedBox(height: 24),

                        // 3. Measurement & Metadata
                        _buildSectionHeader(context, '3. Measurement & Timestamps'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('EU Code', category.igEucode),
                          _infoItem('MU Code', category.igMucode),
                          _infoItem('Entry Date', _formatDate(category.igEdate)),
                          _infoItem('Modified Date', _formatDate(category.igMdate)),
                          _infoItem('Sync Date', category.igSyncDate), // Can be dynamic string or date
                        ]),
                        const SizedBox(height: 24),

                        // 4. MRP Rate Slabs
                        _buildSectionHeader(context, '4. MRP Rate Slabs Configuration'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Less Than Or Equal To', category.igMrpRateSlabLessThanOrEqualTo),
                          _infoItem('Slab F1', category.igMrpRateSlabF1),
                          _infoItem('Slab U1', category.igMrpRateSlabU1),
                          _infoItem('Slab F2', category.igMrpRateSlabF2),
                          _infoItem('Slab U2', category.igMrpRateSlabU2),
                          _infoItem('Slab F3', category.igMrpRateSlabF3),
                          _infoItem('Slab U3', category.igMrpRateSlabU3),
                          _infoItem('Greater Than Or Equal To', category.igMrpRateSlabGreaterThanOrEqualTo),
                        ]),
                        const SizedBox(height: 24),

                        // 5. State Tax Slabs
                        _buildSectionHeader(context, '5. State Tax Slabs'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Less Than Or Equal To', category.igStateTaxSlabLessThanOrEqualTo),
                          _infoItem('Tax Slab 1', category.igStateTaxSlab1),
                          _infoItem('Tax Slab 2', category.igStateTaxSlab2),
                          _infoItem('Tax Slab 3', category.igStateTaxSlab3),
                          _infoItem('Greater Than Or Equal To', category.igStateTaxSlabGreaterThanOrEqualTo),
                        ]),
                        const SizedBox(height: 24),

                        // 6. Ex-State Tax Slabs
                        _buildSectionHeader(context, '6. Ex-State Tax Slabs'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Less Than Or Equal To', category.igExStateTaxSlabLessThanOrEqualTo),
                          _infoItem('Ex-Tax Slab 1', category.igExStateTaxSlab1),
                          _infoItem('Ex-Tax Slab 2', category.igExStateTaxSlab2),
                          _infoItem('Ex-Tax Slab 3', category.igExStateTaxSlab3),
                          _infoItem('Greater Than Or Equal To', category.igExStateTaxSlabGreaterThanOrEqualTo),
                        ]),
                        const SizedBox(height: 24),

                        // 7. Rate Diff Days Slabs
                        _buildSectionHeader(context, '7. Rate Difference Days Slabs'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Less Than Or Equal To', category.igRateDiffDaysLessThanOrEqualTo),
                          _infoItem('Days Slab F1', category.igRateDiffDaysSlabF1),
                          _infoItem('Days Slab U1', category.igRateDiffDaysSlabU1),
                          _infoItem('Days Slab F2', category.igRateDiffDaysSlabF2),
                          _infoItem('Days Slab U2', category.igRateDiffDaysSlabU2),
                          _infoItem('Days Slab F3', category.igRateDiffDaysSlabF3),
                          _infoItem('Days Slab U3', category.igRateDiffDaysSlabU3),
                          _infoItem('Greater Than Or Equal To', category.igRateDiffDaysGreaterThanOrEqualTo),
                        ]),
                        const SizedBox(height: 24),

                        // 8. Rate Diff Rate Slabs
                        _buildSectionHeader(context, '8. Rate Difference Rate Slabs'),
                        const SizedBox(height: 12),
                        _buildInfoGrid(context, [
                          _infoItem('Less Than Or Equal To', category.igRateDiffRateLessThanOrEqualTo),
                          _infoItem('Rate Slab 1', category.igRateDiffRateSlab1),
                          _infoItem('Rate Slab 2', category.igRateDiffRateSlab2),
                          _infoItem('Rate Slab 3', category.igRateDiffRateSlab3),
                          _infoItem('Greater Than Or Equal To', category.igRateDiffRateGreaterThanOrEqualTo),
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

  /// Bounded header preventing horizontal overflow when category names are lengthy
  static Widget _buildHeader(BuildContext context, ViewCategoryDatum category) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryBrandOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.category_rounded, color: AppColors.primaryBrandOrange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${category.igName.isNotEmpty ? category.igName.trim() : "Category"} Details',
                style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 19), fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Complete configuration overview for code: ${category.igCode.isNotEmpty ? category.igCode : "N/A"}',
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

  static String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toLocal());
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
