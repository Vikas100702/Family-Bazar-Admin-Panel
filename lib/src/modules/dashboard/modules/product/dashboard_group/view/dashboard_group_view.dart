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
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          return EmptyStateWidget(
            title: 'No Dashboard Groups Found',
            subtitle: 'No group listings are provisioned for this tenant store.',
            icon: Icons.folder_off_outlined,
            actionLabel: 'Reload Groups',
            onActionPressed: controller.refreshAll,
          );
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
                // Add Group Button
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

                // Add Items Button
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
      width: double.infinity,
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
          child: Obx(
            () => Row(
              children: controller.groupList.map((group) {
                return _buildTabItem(context, group, isDark);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, ViewDashboardGroupDatum group, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedGroupId.value == group.id;
      final String mobImg = (group.imImageMob).trim();

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
                  if (mobImg.isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        mobImg.startsWith('http') ? mobImg : '${ApiConstants.baseUrl}${mobImg.startsWith('/') ? '' : '/'}$mobImg',
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
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
                    group.dgName,
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
                          onPressed: () => _openEditGroupDialog(context, group),
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
                            itemName: group.dgName,
                            message:
                                'Are you sure you want to delete group "${group.dgName.trim()}"? Items associated with this group will be unlinked.',
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
              child: DataTableWidget<ViewItemByTypeDatum>(
                items: controller.pagedGroupItems.toList(),
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

  DataRow _buildDataRow(BuildContext context, ViewItemByTypeDatum item) {
    final isDark = context.isDark;
    final int stock = int.tryParse(item.sbSaleableStock?.toString().trim() ?? '') ?? 0;

    return DataRow(
      cells: [
        DataCell(SelectableText(item.iCode.isEmpty ? 'N/A' : item.iCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(Text(item.iFirmCode.isEmpty ? 'N/A' : item.iFirmCode)),
        DataCell(
          TableImageCellWidget(
            webImageUrl: (item.imageWeb).toString().trim(),
            mobileImageUrl: (item.imageMob).toString().trim(),
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
        DataCell(Text('₹${_formatPrice(item.sbMRate)}', style: context.titleStyleRegular)),
        DataCell(
          Text(
            '₹${_formatPrice(item.sbRateA)}',
            style: context.titleStyleRegular.copyWith(color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(
          Text(
            '$stock',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: stock > 0 ? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate) : AppColors.statusRedError,
            ),
          ),
        ),
        DataCell(StatusBadge(statusValue: item.iStatus, activeLabel: 'Active', inactiveLabel: 'Inactive')),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    if (success) {
                      Get.back();
                      controller.successMessage(title: 'Success', message: 'Group added successfully.');
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                final success = await controller.createGroup();
                                if (success) {
                                  Get.back();
                                  controller.successMessage(title: 'Success', message: 'Group added successfully.');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: AppColors.onPrimaryWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Text('Save Group'),
                      ),
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
          constraints: BoxConstraints(maxWidth: 720, maxHeight: MediaQuery.sizeOf(context).height * 0.85),
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
                            'Add Items to ${controller.selectedGroup.value?.dgName ?? "Group"}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            'Selected: ${controller.selectedItemCodeToAdd.length} items',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryRed),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFirmDropdown(context),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                      ],
                    ),
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
                    final bool isSearchActive = controller.masterItemSearchController.text.trim().isNotEmpty;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSearchActive ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                              size: 40,
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isSearchActive ? 'No items match your search query.' : 'No items found for the selected firm.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: controller.filteredMasterItemList.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: isDark ? AppColors.borderSubtleDark.withValues(alpha: 0.4) : AppColors.borderSubtleSlate.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      final item = controller.filteredMasterItemList[index];
                      final String itemCode = item.iCode.trim();
                      return Obx(() {
                        final isSelected = controller.selectedItemCodeToAdd.contains(itemCode);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primaryRed,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => controller.toggleItemSelection(itemCode),
                          title: Text(item.iName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            'Code: ${item.iCode} | Firm: ${item.iFirmCode} | EAN: ${item.iBarCode}',
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                          ),
                          secondary: Text('₹${_formatPrice(item.sbRateA)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  void _showItemDetails(BuildContext context, ViewItemByTypeDatum item) {
    final int stock = int.tryParse(item.sbSaleableStock?.toString().trim() ?? '') ?? 0;

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
            DetailItem(label: 'EAN / Barcode', value: item.iBarCode, isCopyable: true),
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
            DetailItem(label: 'MRP Rate', value: '₹${_formatPrice(item.sbMRate, 2)}'),
            DetailItem(label: 'Sale Rate (Rate A)', value: '₹${_formatPrice(item.sbRateA, 2)}'),
            DetailItem(label: 'Saleable Stock Units', value: '$stock'),
          ],
        ),
      ],
    );
  }

  void _openEditGroupDialog(BuildContext context, ViewDashboardGroupDatum group) {
    controller.prepareEditGroup(group);
    final isDark = context.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24), vertical: context.responsiveSize(16, 24)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Form(
            key: controller.editGroupFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Dashboard Group', style: context.titleStyleActive.copyWith(fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Update status, images, and details for group code: ${group.dgCode}',
                  style: context.subTitleStyle.copyWith(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                ),
                const SizedBox(height: 20),

                // Group Name Field
                TextFormField(
                  controller: controller.editGroupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    prefixIcon: const Icon(Icons.category_rounded, size: 18),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Group name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Images',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Web Banner (16:9) & Mobile Icon (1:1)',
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                            ),
                          ],
                        ),
                        TableImageCellWidget(
                          webImageUrl: controller.editGImgW.value,
                          mobileImageUrl: controller.editGImgM.value,
                          uploadType: 'group',
                          entityCode: group.dgCode.toString(),
                          entityTitle: group.dgName,
                          onLinkEntity: ({required entityCode, required webImageUrl, required mobileImageUrl}) async {
                            controller.editGImgW.value = webImageUrl;
                            controller.editGImgM.value = mobileImageUrl;
                            return true;
                          },
                          onSuccess: () {},
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Status Toggle
                Obx(() {
                  final bool isActive = controller.editStatus.value == 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 20,
                              color: isActive ? AppColors.statusGreenSuccess : AppColors.statusRedError,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                                  ),
                                ),
                                Text(
                                  isActive ? 'Active (Visible in Store)' : 'Inactive (Hidden in Store)',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                                ),
                              ],
                            ),
                          ],
                        ),
                        StatusBadge(
                          isEditable: true,
                          isActive: isActive,
                          activeLabel: 'Active',
                          inactiveLabel: 'Inactive',
                          onToggle: (bool val) {
                            controller.editStatus.value = val ? 1 : 0;
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                final success = await controller.submitEditGroup();
                                if (success) Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: AppColors.onPrimaryWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Text('Update Group'),
                      ),
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

  Widget _buildFirmDropdown(BuildContext context) {
    final isDark = context.isDark;

    return Obx(() {
      if (controller.isFirmLoading.value && controller.firmList.isEmpty) {
        return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed));
      }

      // Remove duplicate or empty firm codes
      final seenCodes = <String>{'ALL'};
      final uniqueFirms = controller.firmList.where((firm) {
        final code = firm.fFirmCode.trim();
        if (code.isEmpty || seenCodes.contains(code)) return false;
        seenCodes.add(code);
        return true;
      }).toList();

      final String currentValue = controller.selectedFirmCode.value.trim();
      final bool valueExists = currentValue == 'ALL' || uniqueFirms.any((f) => f.fFirmCode.trim().toLowerCase() == currentValue.toLowerCase());

      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: valueExists ? currentValue : 'ALL',
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
            onChanged: controller.isMasterItemsLoading.value ? null : controller.onFirmFilterChanged,
            items: [
              const DropdownMenuItem<String>(
                value: 'ALL',
                child: Text('All Firms', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              ...uniqueFirms.map((firm) {
                final code = firm.fFirmCode.trim();
                final name = firm.fFirmName.trim();
                return DropdownMenuItem<String>(
                  value: code,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(name.isNotEmpty ? '$name ($code)' : code, overflow: TextOverflow.ellipsis),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  String _formatPrice(dynamic price, [int fractionDigits = 0]) {
    if (price == null) {
      return fractionDigits > 0 ? (0.0).toStringAsFixed(fractionDigits) : '0';
    }
    final double? parsed = double.tryParse(price.toString().trim());
    if (parsed == null) return '0';
    return parsed.toStringAsFixed(fractionDigits);
  }
}
