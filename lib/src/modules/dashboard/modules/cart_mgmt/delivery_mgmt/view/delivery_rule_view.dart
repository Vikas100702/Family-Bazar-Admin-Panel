import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/controller/delivery_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_management_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/view/widget/delivery_rule_studio_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryView extends GetView<DeliveryController> {
  const DeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isStudioMode.value) {
        return const DeliveryRuleStudioView();
      }

      // 2. STANDARD RULES LIST TABLE VIEW
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TableHeaderWidget(
            searchHintText: 'Search delivery rule, type, priority...',
            onSearchChanged: controller.onSearchChanged,
            onSearchSubmitted: controller.onSearchSubmitted,
            onSearchClear: controller.clearSearch,
            onRefresh: controller.refreshDeliveryRules,
            rxIsRefreshing: controller.isLoading,
            refreshTooltip: 'Refresh Delivery Rules',
            extraActions: [
              ElevatedButton.icon(
                onPressed: controller.openCreateRuleStudio,
                icon: const Icon(Icons.add_road_rounded, size: 18),
                label: const Text('Add Delivery Rule', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.onPrimaryWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
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
                        Text('Loading Delivery Rules...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                      child: DataTableWidget<DeliveryRuleItem>(
                        items: controller.pagedList.toList(),
                        horizontalScrollController: controller.horizontalScrollController,
                        verticalScrollController: controller.verticalScrollController,
                        emptyTitle: 'No Delivery Rules Configured',
                        emptySubtitle: 'Click "Add Delivery Rule" above to define zonal pricing and distance bands.',
                        emptyIcon: Icons.local_shipping_outlined,
                        columns: const [
                          DataColumn(label: Text('RULE ID')),
                          DataColumn(label: Text('RULE NAME')),
                          DataColumn(label: Text('TYPE')),
                          DataColumn(label: Text('PRIORITY')),
                          DataColumn(label: Text('SERVICEABLE PINCODES')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('CREATED AT')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rowBuilder: (context, rule) => _buildDataRow(context, rule),
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
    });
  }

  DataRow _buildDataRow(BuildContext context, DeliveryRuleItem rule) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText(rule.id > 0 ? '#${rule.id}' : '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: rule.ruleName.isNotEmpty ? rule.ruleName : '—',
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                rule.ruleName.isNotEmpty ? rule.ruleName : '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            child: Text(
              _formatRuleType(rule.ruleType),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentAzureBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(
              'P${rule.priority}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.accentAzureBlue),
            ),
          ),
        ),
        DataCell(Text('${rule.pincodeCount} Pincodes', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        DataCell(
          Obx(() {
            final bool isUpdating = controller.togglingStatusMap[rule.id] == true;
            if (isUpdating) {
              return const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
              );
            }
            return StatusBadge(
              statusValue: rule.status,
              activeLabel: 'Active',
              inactiveLabel: 'Inactive',
              isEditable: true,
              onToggle: (bool val) => controller.toggleRuleStatus(rule, val),
            );
          }),
        ),
        DataCell(
          Text(
            rule.createdAt != null && rule.createdAt!.year >= 1970 ? rule.createdAt!.toLocal().toString().split('.').first : '—',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'Quick Overview',
                splashRadius: 18,
                onPressed: () => _showQuickOverview(context, rule),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.statusBlueInfo,
                tooltip: 'Open Rule Studio (Configure Slabs & Pincodes)',
                splashRadius: 18,
                onPressed: () => controller.openEditRuleStudio(rule),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showQuickOverview(BuildContext context, DeliveryRuleItem rule) async {
    final DeliveryRuleDataWrapper? details = await controller.loadRuleDetails(rule.id);
    if (!context.mounted) return;

    final List<RuleAssignedPincodeItem> pincodes = details?.pincodes ?? [];
    final List<DeliveryRuleSlabItem> slabs = details?.deliveryRules ?? [];

    EntityDetailsDialogHelper.show(
      context: context,
      title: rule.ruleName.isNotEmpty ? rule.ruleName : 'Delivery Rule #${rule.id}',
      subtitle: 'Rule Specifications & Coverage #${rule.id}',
      headerIcon: Icons.local_shipping_rounded,
      sections: [
        DetailSection(
          title: '1. Rule Identification',
          items: [
            DetailItem(label: 'Rule ID', value: rule.id.toString(), isCopyable: true),
            DetailItem(label: 'Rule Name', value: rule.ruleName),
            DetailItem(label: 'Calculation Basis', value: _formatRuleType(rule.ruleType)),
            DetailItem(label: 'Priority', value: 'Priority ${rule.priority}'),
            DetailItem(label: 'Status', value: rule.isActive ? 'Active (Live in Checkout)' : 'Inactive'),
            DetailItem(label: 'Description', value: rule.description.isNotEmpty ? rule.description : '—'),
          ],
        ),
        DetailSection(
          title: '2. Serviceable Pincodes (${pincodes.length})',
          items: pincodes.isEmpty
              ? [const DetailItem(label: 'Assigned Postal Codes', value: 'No postal codes linked')]
              : pincodes.map((p) => DetailItem(label: 'Pincode ID #${p.pincodeId}', value: p.pincode, isCopyable: true)).toList(),
        ),
        DetailSection(
          title: '3. Charge Slabs Matrix (${slabs.length})',
          items: slabs.isEmpty
              ? [const DetailItem(label: 'Configured Slabs', value: 'No delivery fee slabs configured')]
              : slabs.map((slab) {
                  final String distStr = '${slab.minDistanceKm.toStringAsFixed(0)} - ${slab.maxDistanceKm.toStringAsFixed(0)} KM';
                  final String cartStr =
                      '₹ ${slab.minOrderAmount.toStringAsFixed(0)} - ${slab.maxOrderAmount != null && slab.maxOrderAmount! > 0 ? "₹ ${slab.maxOrderAmount!.toStringAsFixed(0)}" : "Open"}';
                  return DetailItem(
                    label: 'Slab P${slab.priority}',
                    value: 'Base: ₹ ${slab.baseCharge.toStringAsFixed(0)} | Cart: $cartStr | Dist: $distStr',
                  );
                }).toList(),
        ),
        DetailSection(
          title: '4. Audit Timestamps',
          items: [
            DetailItem(
              label: 'Created At',
              value: rule.createdAt != null && rule.createdAt!.year >= 1970 ? rule.createdAt!.toLocal().toString().split('.').first : '—',
            ),
            DetailItem(
              label: 'Updated At',
              value: rule.updatedAt != null && rule.updatedAt!.year >= 1970 ? rule.updatedAt!.toLocal().toString().split('.').first : '—',
            ),
          ],
        ),
      ],
    );
  }

  String _formatRuleType(String rawType) {
    switch (rawType.toLowerCase().trim()) {
      case 'distance':
        return 'Distance Only';
      case 'amount':
        return 'Order Value Only';
      case 'distance_amount':
      case 'both':
        return 'Distance + Order Value';
      default:
        return rawType.toUpperCase();
    }
  }
}
