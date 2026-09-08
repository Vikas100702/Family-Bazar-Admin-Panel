import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/binding/image_upload_binding.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/widget/image_upload_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/controller/sub_cat_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SubCategoryView extends GetView<SubCategoryController> {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
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
              () => DataTableWidget<ViewSubCategoryDatum>(
                items: controller.pagedList.toList(),
                horizontalScrollController: controller.horizontalScrollController,
                verticalScrollController: controller.verticalScrollController,
                emptyTitle: 'No Categories Available',
                emptyIcon: Icons.category_outlined,
                columns: const [
                  DataColumn(label: Text('CODE')),
                  DataColumn(label: Text('IMAGES')),
                  DataColumn(label: Text('SUB CATEGORY NAME')),
                  DataColumn(label: Text('SC CODE')),
                  DataColumn(label: Text('EU CODE')),
                  DataColumn(label: Text('ENTRY DATE')),
                  DataColumn(label: Text('POS STATUS')),
                  DataColumn(label: Text('NEG. BILLING')),
                  DataColumn(label: Text('ACTIONS')),
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

  DataRow _buildDataRow(BuildContext context, ViewSubCategoryDatum subCategory) {
    return DataRow(
      cells: [
        DataCell(Text(_formatText(subCategory.ogCode), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.blueAccent, size: 22),
            tooltip: 'Upload Category Images',
            splashRadius: 24,
            mouseCursor: SystemMouseCursors.click,
            onPressed: () => _openImageUploadModal(context, subCategory),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(subCategory.ogName),
              child: Text(_formatText(subCategory.ogName), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        DataCell(Text(_formatText(subCategory.ogScCode))),
        DataCell(Text(_formatText(subCategory.ogEucode))),
        DataCell(Text(_formatDate(subCategory.ogEdate))),
        DataCell(_buildStatusBadge(subCategory.ogOnPos.toString())),
        DataCell(_buildStatusBadge(subCategory.ogNegativeStockBilling.toString())),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryBrandOrange, size: 22),
            tooltip: 'View Configurations',
            splashRadius: 24,
            mouseCursor: SystemMouseCursors.click,
            onPressed: () => _showSubCategoryDetails(context, subCategory),
          ),
        ),
      ],
    );
  }

  void _openImageUploadModal(BuildContext context, ViewSubCategoryDatum subCategory) {
    ImageUploadBinding().dependencies();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24), vertical: context.responsiveSize(16, 24)),
        child: ImageUploadView(
          uploadType: 'subcategory',
          entityCode: subCategory.ogCode,
          entityTitle: subCategory.ogName,
          onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
            final repo = Get.find<SubCategoryRepository>();
            final res = await repo.addSubCategoryDetails(subCatCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
            debugPrint('🔗 [CATEGORY LINK API RESPONSE]: success=${res.success}, message=${res.message}');
            return res.success;
          },
          onSuccess: () {
            if (Get.isRegistered<SubCategoryController>()) {
              Get.find<SubCategoryController>().refreshCategories();
            }
          },
          onDismiss: () => Get.back(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSubCategoryDetails(BuildContext context, ViewSubCategoryDatum subCategory) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: '${subCategory.ogName.isNotEmpty ? subCategory.ogName.trim() : "Sub Category"} Details',
      subtitle: 'Configuration overview for code: ${subCategory.ogCode.isNotEmpty ? subCategory.ogCode : "N/A"}',
      headerIcon: Icons.account_tree_rounded,
      sections: [
        // 1. Identification & Hierarchy
        DetailSection(
          title: '1. Basic & Identification Information',
          items: [
            DetailItem(label: 'Sub Category Code', value: subCategory.ogCode, isCopyable: true),
            DetailItem(label: 'Sub Category Name', value: subCategory.ogName),
            DetailItem(label: 'Parent / SC Code', value: subCategory.ogScCode, isCopyable: true),
            DetailItem(label: 'Old Code', value: subCategory.ogOldCode),
            DetailItem(label: 'New Code', value: subCategory.ogNewCode),
          ],
        ),

        // 2. Operational Flags & POS Configuration
        DetailSection(
          title: '2. Operational Flags & POS Settings',
          flags: [
            DetailFlag(label: 'On POS', value: subCategory.ogOnPos == true),
            DetailFlag(label: 'Negative Stock Billing', value: subCategory.ogNegativeStockBilling == true),
            DetailFlag(label: 'Locked', value: subCategory.ogLock == true),
          ],
          items: [
            DetailItem(label: 'POS Index', value: subCategory.ogPosIndex),
            DetailItem(label: 'POS Name', value: subCategory.ogPosName),
            DetailItem(label: 'Print SrNo', value: subCategory.ogPrintSrNo),
          ],
        ),

        // 3. Audit Trails & Timestamps
        DetailSection(
          title: '3. Audit & Timestamps',
          items: [
            DetailItem(label: 'EU Code (Created By)', value: subCategory.ogEucode),
            DetailItem(label: 'MU Code (Modified By)', value: subCategory.ogMucode),
            DetailItem(label: 'Entry Date', value: EntityDetailsDialogHelper.formatDate(subCategory.ogEdate)),
            DetailItem(label: 'Modified Date', value: EntityDetailsDialogHelper.formatDate(subCategory.ogMdate)),
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
