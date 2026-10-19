import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/controller/items_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
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
          child: Obx(
            () => PaginatedTableContainer<ViewItemByTypeDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Product Items...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Product Items Available',
              emptySubtitle: 'Sync with server or configure inventory catalog.',
              emptyIcon: Icons.inventory_2_outlined,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('ITEM CODE')),
                DataColumn(label: Text('FIRM CODE')),
                DataColumn(label: Text('IMAGES')),
                DataColumn(label: Text('ITEM NAME')),
                DataColumn(label: Text('ITEM MRP')),
                DataColumn(label: Text('SALES PRICE')),
                DataColumn(label: Text('AVAILABLE STOCK')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, item) => _buildDataRow(context, item),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewItemByTypeDatum item) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: item.iCode,
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(AppTableCellText(text: item.iFirmCode, maxWidth: 100)),
        DataCell(
          TableImageCellWidget(
            webImageUrl: item.imImageWeb,
            mobileImageUrl: item.imImageMob,
            secondaryImageUrl: item.imSecondryImage,
            informationImageUrl: item.imImformation,
            uploadType: 'item',
            entityCode: item.iCode,
            entityTitle: item.iName,
            onLinkEntity: ({required String entityCode, required String webImageUrl, required String mobileImageUrl}) async {
              final ItemRepository repo = Get.find<ItemRepository>();
              final res = await repo.addItemDetails(itemCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
              return res.success;
            },
            onSuccess: controller.refreshItems,
          ),
        ),
        DataCell(
          AppTableCellText(
            text: item.iName,
            maxWidth: 240,
            maxLines: 2,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(Text(item.sbMRate.toString().toPrice(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          Text(
            item.sbRateA.toString().toPrice(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Builder(
            builder: (_) {
              final int stock = item.sbSaleableStock.toString().toSafeInt();
              return Text(
                '$stock',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: stock > 0 ? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate) : AppColors.statusRedError,
                ),
              );
            },
          ),
        ),
        DataCell(
          StatusBadge(
            isEditable: true,
            statusValue: item.iStatus,
            activeLabel: 'Active',
            inactiveLabel: 'Inactive',
            onToggle: (bool val) => controller.toggleItemStatus(item, val),
          ),
        ),
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

  void _showItemDetails(BuildContext context, ViewItemByTypeDatum item) {
    final int stockCount = item.sbSaleableStock.toString().toSafeInt();

    EntityDetailsDialogHelper.show(
      context: context,
      title: item.iName.isNotEmpty ? item.iName.trim() : 'Item Details',
      subtitle: 'Code: ${item.iCode}',
      headerIcon: Icons.inventory_2_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          items: [
            DetailItem(label: 'Item Code', value: item.iCode, isCopyable: true),
            DetailItem(label: 'Item Name', value: item.iName),
            DetailItem(label: 'EAN Code', value: item.iBarCode, isCopyable: true),
            DetailItem(label: 'Firm Code', value: item.iFirmCode, isCopyable: true),
            DetailItem(label: 'Brand Name', value: item.brandName),
          ],
        ),
        DetailSection(
          title: 'System Information',
          flags: [DetailFlag(label: 'Active Status', value: item.isStatusActive)],
          items: [
            DetailItem(label: 'Category Name', value: item.itemGroupName),
            DetailItem(label: 'Category Code', value: item.iItemGroup, isCopyable: true),
            DetailItem(label: 'Sub-Category Name', value: item.otherGroupName),
            DetailItem(label: 'Sub-Category Code', value: item.iOtherGroup, isCopyable: true),
            DetailItem(label: 'Mfg Company Code', value: item.iMfgComp),
          ],
        ),
        DetailSection(
          title: 'Pricing & Stock Quantities',
          flags: [DetailFlag(label: 'In Stock', value: stockCount > 0)],
          items: [
            DetailItem(label: 'MRP Rate', value: item.sbMRate.toString().toPrice()),
            DetailItem(label: 'Sale Rate', value: item.sbRateA.toString().toPrice()),
            DetailItem(label: 'Saleable Stock Units', value: '$stockCount'),
          ],
        ),
      ],
    );
  }
}

typedef ItemView = ItemsView;
