import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/empty_state_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_image_cell_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/controller/dashboard_group_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/view_group_items_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardGroupView extends GetView<DashboardGroupController> {
  const DashboardGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value && controller.groupList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 2.5));
        }

        if (controller.groupList.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableHeaderWidget(
              searchHintText: 'Search code, name, category, sub-category...',
              onSearchChanged: controller.onSearchChanged,
              onSearchClear: controller.clearSearch,
              onRefresh: controller.refreshAll,
              rxIsRefreshing: controller.isLoading,
              refreshTooltip: 'Refresh Group & Items',
              extraActions: [
                // 1. Add Group Button
                ElevatedButton.icon(
                  onPressed: () => _openAddGroupDialog(context),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add Group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.onPrimaryWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                // 2. Add Items Button
                ElevatedButton.icon(
                  onPressed: () => _openAddGroupItemsModal(context),
                  icon: const Icon(Icons.playlist_add_rounded, size: 18),
                  label: const Text('Add Items'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceSubtleGray,
                    foregroundColor: context.isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                    elevation: 0,
                    side: BorderSide(color: context.isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
              bottomWidget: _buildHorizontalGroupTabs(context),
            ),
            SizedBox(height: context.responsiveHeight(14, 18)),
            Expanded(child: _buildItemsTableSection(context)),
          ],
        );
      }),
    );
  }

  Widget _buildHorizontalGroupTabs(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      width: .infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: controller.groupList.map((group) {
              return _buildTabItem(context, group, isDark);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, ViewDashboardGroupDatum group, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedGroupId.value == group.groupId;

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectGroup(group),
            borderRadius: BorderRadius.circular(8),
            mouseCursor: SystemMouseCursors.click,
            hoverColor: AppColors.primaryRed.withValues(alpha: 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryRed : (isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primaryRed : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryRed.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (group.gImgM != null && group.gImgM!.trim().isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        group.gImgM!.startsWith('http')
                            ? group.gImgM!
                            : '${ApiConstants.baseUrl}${group.gImgM!.startsWith('/') ? '' : '/'}${group.gImgM}',
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.category_rounded,
                          size: 15,
                          color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate),
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.category_rounded,
                      size: 15,
                      color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    group.groupName,
                    style: TextStyle(
                      fontSize: context.responsiveSize(12, 13),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : (isDark ? AppColors.canvasDarkSlate : AppColors.borderSubtleSlate.withValues(alpha: 0.45)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 13),
                          mouseCursor: SystemMouseCursors.click,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(3),
                          splashRadius: 12,
                          tooltip: 'Edit Group',
                          color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryWhite : AppColors.textSecondarySlate),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 3),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 13),
                          mouseCursor: SystemMouseCursors.click,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(3),
                          splashRadius: 12,
                          tooltip: 'Delete Group',
                          color: isSelected ? Colors.white : (isDark ? AppColors.primaryRedLight : AppColors.primaryRedDark),
                          onPressed: () => DialogHelper.showDeleteDialog(
                            title: 'Delete Dashboard Group',
                            itemName: group.groupName,
                            message:
                                'Are you sure you want to delete group "${group.groupName.trim()}"? Items associated with this group will be unlinked.',
                            onConfirm: () => controller.deleteGroup(group),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildItemsTableSection(BuildContext context) {
    return Obx(() {
      if (controller.isItemsLoading.value && controller.pagedGroupItems.isEmpty) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: context.defaultDecoration,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                SizedBox(height: 16),
                Text('Loading Group Items...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
              child: DataTableWidget<GroupItemDatum>(
                items: controller.pagedGroupItems,
                horizontalScrollController: controller.horizontalScrollController,
                verticalScrollController: controller.verticalScrollController,
                emptyTitle: 'No Items Assigned to This Group',
                emptySubtitle: 'Click "Add Items" above to assign catalog inventory.',
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
                  DataColumn(label: Text('STOCK')),
                  DataColumn(label: Text('STATUS')),
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
            isLoading: controller.isItemsLoading.value,
            onPageChanged: controller.changePage,
            onItemsPerPageChanged: controller.changePageSize,
          ),
        ],
      );
    });
  }

  DataRow _buildDataRow(BuildContext context, GroupItemDatum item) {
    final isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText(item.iCode.isEmpty ? 'N/A' : item.iCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(Text(item.iFirmCode.isEmpty ? 'N/A' : item.iFirmCode)),
        DataCell(
          TableImageCellWidget(
            webImageUrl: item.wImg,
            mobileImageUrl: item.mImg,
            uploadType: 'item',
            entityCode: item.iCode,
            entityTitle: item.iName,
            onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
              final repo = Get.find<ItemRepository>();
              final res = await repo.addItemDetails(itemCode: entityCode, wImg: webImageUrl, mImg: mobileImageUrl);
              return res.success;
            },
            onSuccess: controller.refreshAll,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: item.iName.trim().isEmpty ? 'N/A' : item.iName,
              child: Text(
                item.iName.trim().isEmpty ? 'N/A' : item.iName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(Text(item.iItemGroup.trim().isEmpty ? '—' : item.iItemGroup)),
        DataCell(Text(item.iOtherGroup.trim().isEmpty ? '—' : item.iOtherGroup)),
        DataCell(Text('₹${item.sbMRate.toStringAsFixed(0)}', style: context.titleStyleRegular)),
        DataCell(
          Text(
            '₹${item.sbRateA.toStringAsFixed(0)}',
            style: context.titleStyleRegular.copyWith(color: context.isDarkMode ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Text(
            '${item.sbSaleableStock}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: item.sbSaleableStock > 0 ? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate) : AppColors.statusRedError,
            ),
          ),
        ),
        DataCell(StatusBadge(statusValue: item.status, activeLabel: 'Active', inactiveLabel: 'Inactive')),
        DataCell(
          Row(
            mainAxisAlignment: .spaceEvenly,
            crossAxisAlignment: .center,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View Item Details',
                splashRadius: 18,
                onPressed: () => _showItemDetails(context, item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.primaryRedLight : AppColors.primaryRedDark,
                tooltip: 'Delete Item',
                splashRadius: 18,
                onPressed: () => DialogHelper.showDeleteDialog(
                  title: 'Remove Item from Group',
                  itemName: '${item.iName.trim()} (Code: ${item.iCode})',
                  actionNoun: 'remove',
                  confirmLabel: 'Confirm Remove',
                  onConfirm: () => controller.deleteGroupItem(item),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openAddGroupDialog(BuildContext context) {
    controller.groupNameController.clear();
    final isDark = context.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Form(
            key: controller.addGroupFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Dashboard Group', style: context.titleStyleActive.copyWith(fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new group tab to organize your product dashboard catalogs.',
                  style: context.subTitleStyle.copyWith(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.groupNameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Group Name *',
                    hintText: 'e.g. Food, Kids, Household',
                    prefixIcon: const Icon(Icons.category_rounded, size: 18),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid group name';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) async {
                    final success = await controller.createGroup();
                    if (success) Get.back();
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final success = await controller.createGroup();
                        if (success) Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: AppColors.onPrimaryWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Save Group'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _openAddGroupItemsModal(BuildContext context) {
    controller.openAddItems();
    final isDark = context.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 32), vertical: context.responsiveSize(16, 24)),
        child: Container(
          width: 720,
          height: 650,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            'Add Items to ${controller.selectedGroup.value?.groupName ?? "Group"}',
                            style: context.titleStyleActive.copyWith(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            'Selected: ${controller.selectedItemIdsToAdd.length} items',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryRed),
                          ),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: controller.masterItemSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search items by name, code, EAN...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        controller.masterItemSearchController.clear();
                        controller.filterMasterItems('');
                      },
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: controller.filterMasterItems,
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isMasterItemsLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 2.5));
                  }

                  if (controller.filteredMasterItemList.isEmpty) {
                    return const Center(child: Text('No catalog items match your search.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: controller.filteredMasterItemList.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppColors.borderSubtleDark.withValues(alpha: 0.4) : AppColors.borderSubtleSlate.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      final item = controller.filteredMasterItemList[index];
                      final int itemCodeNumber = controller.extractCode(item.iCode, item.id);
                      return Obx(() {
                        final isSelected = controller.selectedItemIdsToAdd.contains(itemCodeNumber);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primaryRed,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => controller.toggleItemSelection(itemCodeNumber),
                          title: Text(item.iName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            'Code: ${item.iCode} | Firm: ${item.iFirmCode} | EAN: ${item.eanCode ?? "—"}',
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                          ),
                          secondary: Text(
                            '₹${(item.sbMRate ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSubmittingItems.value
                            ? null
                            : () async {
                                final success = await controller.submitGroupItems();
                                if (success) Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: AppColors.onPrimaryWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: controller.isSubmittingItems.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Text('Save Selected Items'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showItemDetails(BuildContext context, GroupItemDatum item) {
    EntityDetailsDialogHelper.show(
      context: context,
      title: item.iName.isNotEmpty ? item.iName.trim() : "Item Details",
      subtitle: 'Inventory details for item code: ${item.iCode}',
      headerIcon: Icons.inventory_2_rounded,
      sections: [
        DetailSection(
          title: '1. Identification & Nomenclature',
          items: [
            DetailItem(label: 'Item Code', value: item.iCode, isCopyable: true),
            DetailItem(label: 'Item Name', value: item.iName),
            DetailItem(label: 'Firm Code', value: item.iFirmCode, isCopyable: true),
            DetailItem(label: 'EAN / Barcode', value: item.eanCode, isCopyable: true),
            DetailItem(label: 'EU Code', value: item.iEuCode),
          ],
        ),
        DetailSection(
          title: '2. Group & Category Associations',
          items: [
            DetailItem(label: 'Category Group (I_ItemGroup)', value: item.iItemGroup),
            DetailItem(label: 'Sub-Category Group (I_OtherGroup)', value: item.iOtherGroup),
          ],
        ),
        DetailSection(
          title: '3. Pricing & Stock Quantities',
          items: [
            DetailItem(label: 'MRP Rate', value: '₹${item.sbMRate.toStringAsFixed(2)}'),
            DetailItem(label: 'Sale Rate (Rate A)', value: '₹${item.sbRateA.toStringAsFixed(2)}'),
            DetailItem(label: 'Saleable Stock Units', value: '${item.sbSaleableStock}'),
          ],
        ),
        DetailSection(
          title: '4. Audit Logs & Timestamps',
          items: [
            DetailItem(label: 'Inserted Timestamp', value: _formatDate(item.insertedOn)),
            DetailItem(label: 'Created Timestamp', value: _formatDate(item.createdAt)),
            DetailItem(label: 'Updated Timestamp', value: _formatDate(item.updatedAt)),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
    } catch (_) {
      return date.toString().split('.')[0];
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Dashboard Groups Found',
      subtitle: 'No group listings are provisioned for this tenant store.',
      icon: Icons.folder_off_outlined,
      actionLabel: 'Reload Groups',
      onActionPressed: controller.refreshAll,
    );
  }
}
