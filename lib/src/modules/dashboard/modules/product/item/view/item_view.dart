import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/binding/image_upload_binding.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/widget/image_upload_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/controller/items_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemsView extends GetView<ItemController> {
  const ItemsView({super.key});

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
              () => DataTableWidget<ViewItemDatum>(
                items: controller.pagedList.toList(),
                horizontalScrollController: controller.horizontalScrollController,
                verticalScrollController: controller.verticalScrollController,
                emptyTitle: 'No Items Available',
                emptyIcon: Icons.category_outlined,
                columns: const [
                  DataColumn(label: Text('ITEM CODE')),
                  DataColumn(label: Text('FIRM CODE')),
                  DataColumn(label: Text('CATEGORY CODE')),
                  DataColumn(label: Text('SUB CATEGORY CODE')),
                  DataColumn(label: Text('IMAGES')),
                  DataColumn(label: Text('ITEM NAME')),
                  DataColumn(label: Text('EU CODE')),
                  DataColumn(label: Text('EAN CODE')),
                ],
                rowBuilder: (context, category) => _buildDataRow(context, category),
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
              'Category Management',
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
          onPressed: () => controller.refreshCategories(),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewItemDatum item) {
    return DataRow(
      cells: [
        DataCell(Text(_formatText(item.iCode), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(_formatText(item.iFirmCode))),
        DataCell(Text(_formatText(item.iItemGroup))),
        DataCell(Text(_formatText(item.iOtherGroup))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.blueAccent, size: 22),
            tooltip: 'Upload Item Images',
            splashRadius: 24,
            mouseCursor: SystemMouseCursors.click,
            onPressed: () => _openImageUploadModal(context, item),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(item.iName),
              child: Text(_formatText(item.iName), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        DataCell(Text(_formatDate(item.iEuCode))),
        DataCell(Text(_formatDate(item.eanCode))),
      ],
    );
  }

  void _openImageUploadModal(BuildContext context, ViewItemDatum item) {
    ImageUploadBinding().dependencies();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24), vertical: context.responsiveSize(16, 24)),
        child: ImageUploadView(
          uploadType: 'item',
          entityCode: item.iName,
          entityTitle: item.iName,
          onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
            final repo = Get.find<ItemRepository>();
            final res = await repo.addItemDetails(itemCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            debugPrint('🔗 [ITEM LINK API RESPONSE]: success=${res.success}, message=${res.message}');
            return res.success;
          },
          onSuccess: () {
            if (Get.isRegistered<ItemController>()) {
              Get.find<ItemController>().refreshCategories();
            }
          },
          onDismiss: () => Get.back(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /*void _showCategoryDetails(BuildContext context, ViewItemDatum category) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: '${category.igName.isNotEmpty ? category.igName.trim() : "Category"} Details',
      subtitle: 'Configuration overview for code: ${category.igCode.isNotEmpty ? category.igCode : "N/A"}',
      headerIcon: Icons.category_rounded,
      sections: [
        DetailSection(
          title: '1. Basic & Identification Information',
          items: [
            DetailItem(label: 'Category Code', value: category.igCode, isCopyable: true),
            DetailItem(label: 'Category Name', value: category.igName),
            DetailItem(label: 'CM Code', value: category.igCmCode, isCopyable: true),
            DetailItem(label: 'Type', value: category.igType),
            DetailItem(label: 'Old Code', value: category.igOldCode),
            DetailItem(label: 'New Code', value: category.igNewCode),
          ],
        ),
        DetailSection(
          title: '2. Operational Flags & POS Settings',
          flags: [
            DetailFlag(label: 'On POS', value: category.igOnPos),
            DetailFlag(label: 'Negative Stock Billing', value: category.igNegativeStockBilling),
            DetailFlag(label: 'Locked', value: category.igLock),
            DetailFlag(label: 'Rate Wise Tax', value: category.igRateWiseTax),
          ],
          items: [
            DetailItem(label: 'POS Index', value: category.igPosINdex),
            DetailItem(label: 'POS Name', value: category.igPosName),
            DetailItem(label: 'Point Value Per', value: category.igPointValuePer),
            DetailItem(label: 'Print SrNo', value: category.igPrintSrNo),
            DetailItem(label: 'Rate Wise Tax Rate Type', value: category.igRateWiseTaxRateType),
          ],
        ),
        DetailSection(
          title: '3. Measurement & Timestamps',
          items: [
            DetailItem(label: 'EU Code', value: category.igEucode),
            DetailItem(label: 'MU Code', value: category.igMucode),
            DetailItem(label: 'Entry Date', value: EntityDetailsDialogHelper.formatDate(category.igEdate)),
            DetailItem(label: 'Modified Date', value: EntityDetailsDialogHelper.formatDate(category.igMdate)),
            DetailItem(label: 'Sync Date', value: category.igSyncDate),
          ],
        ),
        DetailSection(
          title: '4. MRP Rate Slabs Configuration',
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igMrpRateSlabLessThanOrEqualTo),
            DetailItem(label: 'Slab F1', value: category.igMrpRateSlabF1),
            DetailItem(label: 'Slab U1', value: category.igMrpRateSlabU1),
            DetailItem(label: 'Slab F2', value: category.igMrpRateSlabF2),
            DetailItem(label: 'Slab U2', value: category.igMrpRateSlabU2),
            DetailItem(label: 'Slab F3', value: category.igMrpRateSlabF3),
            DetailItem(label: 'Slab U3', value: category.igMrpRateSlabU3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igMrpRateSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          title: '5. State Tax Slabs',
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igStateTaxSlabLessThanOrEqualTo),
            DetailItem(label: 'Tax Slab 1', value: category.igStateTaxSlab1),
            DetailItem(label: 'Tax Slab 2', value: category.igStateTaxSlab2),
            DetailItem(label: 'Tax Slab 3', value: category.igStateTaxSlab3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igStateTaxSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          title: '6. Ex-State Tax Slabs',
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igExStateTaxSlabLessThanOrEqualTo),
            DetailItem(label: 'Ex-Tax Slab 1', value: category.igExStateTaxSlab1),
            DetailItem(label: 'Ex-Tax Slab 2', value: category.igExStateTaxSlab2),
            DetailItem(label: 'Ex-Tax Slab 3', value: category.igExStateTaxSlab3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igExStateTaxSlabGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          title: '7. Rate Diff Days Slabs',
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igRateDiffDaysLessThanOrEqualTo),
            DetailItem(label: 'Days Slab F1', value: category.igRateDiffDaysSlabF1),
            DetailItem(label: 'Days Slab U1', value: category.igRateDiffDaysSlabU1),
            DetailItem(label: 'Days Slab F2', value: category.igRateDiffDaysSlabF2),
            DetailItem(label: 'Days Slab U2', value: category.igRateDiffDaysSlabU2),
            DetailItem(label: 'Days Slab F3', value: category.igRateDiffDaysSlabF3),
            DetailItem(label: 'Days Slab U3', value: category.igRateDiffDaysSlabU3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igRateDiffDaysGreaterThanOrEqualTo),
          ],
        ),
        DetailSection(
          title: '8. Rate Difference Rate Slabs',
          items: [
            DetailItem(label: 'Less Than Or Equal To', value: category.igRateDiffRateLessThanOrEqualTo),
            DetailItem(label: 'Rate Slab 1', value: category.igRateDiffRateSlab1),
            DetailItem(label: 'Rate Slab 2', value: category.igRateDiffRateSlab2),
            DetailItem(label: 'Rate Slab 3', value: category.igRateDiffRateSlab3),
            DetailItem(label: 'Greater Than Or Equal To', value: category.igRateDiffRateGreaterThanOrEqualTo),
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
*/
  String _formatText(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '—';
    try {
      final DateTime parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return date.toString().split(' ').first;
    }
  }
}
