import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/controller/items_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemsView extends GetView<ItemController> {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search code, name, category, sub-category...',
          onSearchChanged: controller.onSearchChanged,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshItems,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Items',
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
                      Text('Loading Product Items...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewItemDatum>(
                      items: controller.pagedList,
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Product Items Available',
                      emptySubtitle: 'Sync with server or configure inventory catalog.',
                      emptyIcon: Icons.inventory_2_outlined,
                      columns: const [
                        DataColumn(label: Text('ITEM CODE')),
                        DataColumn(label: Text('FIRM CODE')),
                        DataColumn(label: Text('IMAGES')),
                        DataColumn(label: Text('ITEM NAME')),
                        DataColumn(label: Text('CATEGORY')),
                        DataColumn(label: Text('SUB-CATEGORY')),
                        DataColumn(label: Text('ITEM MRP')),
                        DataColumn(label: Text('SALES PRICE')),
                        DataColumn(label: Text('AVAILABLE STOCK')),
                        DataColumn(label: Text('EU CODE')),
                        DataColumn(label: Text('EAN / BARCODE')),
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

  DataRow _buildDataRow(BuildContext context, ViewItemDatum item) {
    final isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText(_formatText(item.iCode), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(Text(_formatText(item.iFirmCode))),
        DataCell(
          TableImageCellWidget(
            webImageUrl: item.iImgW,
            mobileImageUrl: item.iImgM,
            uploadType: 'item',
            entityCode: item.iCode,
            entityTitle: item.iName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              final repo = Get.find<ItemRepository>();
              final res = await repo.addItemDetails(itemCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
              return res.success;
            },
            onSuccess: controller.refreshItems,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(item.iName),
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                _formatText(item.iName),
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SelectableText(
            _formatText(item.itemGroup),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          SelectableText(
            _formatText(item.otherGroup),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
          ),
        ),
        DataCell(Text(_formatText(item.sbMRate.toString()))),
        DataCell(Text(_formatText(item.sbRateA.toString()))),
        DataCell(Text(_formatText(item.sbSaleableStock.toString()))),
        DataCell(Text(_formatText(item.iEuCode))),
        DataCell(SelectableText(_formatText(item.eanCode), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
            tooltip: 'View Item Details',
            splashRadius: 18,
            onPressed: () => _showItemDetails(context, item),
          ),
        ),
      ],
    );
  }

  void _showItemDetails(BuildContext context, ViewItemDatum item) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: item.iName.isNotEmpty ? item.iName.trim() : "Item",
      headerIcon: Icons.inventory_2_rounded,
      sections: [
        DetailSection(
          title: '',
          items: [
            DetailItem(label: 'Item Code', value: item.iCode, isCopyable: true),
            DetailItem(label: 'Item Name', value: item.iName),
            DetailItem(label: 'EAN / Barcode', value: item.eanCode, isCopyable: true),
            DetailItem(label: 'Firm Code', value: item.iFirmCode, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '',
          items: [
            DetailItem(label: 'Category Code', value: item.iItemGroup, isCopyable: true),
            DetailItem(label: 'Sub-Category Code', value: item.iOtherGroup, isCopyable: true),
          ],
        ),
        DetailSection(
          title: '',
          items: [DetailItem(label: 'EU Code', value: item.iEuCode)],
        ),
      ],
    );
  }

  String _formatText(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }
}

typedef ItemView = ItemsView;
