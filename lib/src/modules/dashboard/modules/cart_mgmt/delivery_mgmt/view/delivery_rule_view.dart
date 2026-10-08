import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/controller/delivery_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/delivery_rule_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/view_delivery_rules_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/view/widget/delivery_rule_studio_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryView extends GetView<DeliveryController> {
  const DeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // IN-PAGE STUDIO VIEW (Rule + Pincodes + Slabs Editor)
      if (controller.isStudioMode.value) {
        return const DeliveryRuleStudioView();
      }

      // STANDARD RULES LIST TABLE VIEW
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TableHeaderWidget(
            searchHintText: 'Search delivery rule, priority...',
            onSearchChanged: controller.onSearchChanged,
            onSearchClear: controller.clearSearch,
            onRefresh: controller.refreshDeliveryRules,
            rxIsRefreshing: controller.isLoading,
            refreshTooltip: 'Refresh Rules',
            extraActions: [
              ElevatedButton.icon(
                onPressed: controller.openCreateRuleStudio,
                icon: const Icon(Icons.add_road_rounded, size: 18),
                label: const Text('Add Delivery Rule'),
                style: ElevatedButton.styleFrom(
                  enabledMouseCursor: SystemMouseCursors.click,
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
                      child: DataTableWidget<Rule>(
                        items: controller.pagedList,
                        horizontalScrollController: controller.horizontalScrollController,
                        verticalScrollController: controller.verticalScrollController,
                        emptyTitle: 'No Delivery Rules Available',
                        emptySubtitle: 'Create a delivery rule or refresh from server.',
                        emptyIcon: Icons.local_shipping_outlined,
                        columns: const [
                          DataColumn(label: Text('RULE ID')),
                          DataColumn(label: Text('RULE NAME')),
                          DataColumn(label: Text('PRIORITY')),
                          DataColumn(label: Text('TOTAL PINCODES')),
                          DataColumn(label: Text('STATUS')),
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

  DataRow _buildDataRow(BuildContext context, Rule rule) {
    final bool isDark = context.isDark;

    return DataRow(
      cells: [
        DataCell(SelectableText(rule.id > 0 ? '#${rule.id}' : '-', style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Tooltip(
              message: _formatText(rule.ruleName),
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                _formatText(rule.ruleName),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'P${rule.priority}',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
            ),
          ),
        ),
        DataCell(Text('${rule.pincodeCount}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        DataCell(
          Obx(() {
            final bool isUpdating = controller.togglingStatusMap[rule.id] == true;
            if (isUpdating) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
              );
            }
            return StatusBadge(isEditable: true, isActive: rule.isActive, onToggle: (bool val) => controller.toggleRuleStatus(rule, val));
          }),
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
                onPressed: () => _showRuleDetails(context, rule),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.primaryRed,
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

  void _showRuleDetails(BuildContext context, Rule rule) async {
    final DeliveryRuleDetailsData? details = await controller.loadRuleDetails(rule.id);
    final List<String> resolvedPincodes = details != null && details.pincodes.isNotEmpty
        ? details.pincodes.map((p) => p.pincode).toList()
        : controller.getPincodeLabelsForRule(rule);
    final List<RuleDistanceItem> slabs = details?.distanceRules ?? [];

    if (!context.mounted) return;
    final bool isDark = context.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 32), vertical: context.responsiveHeight(16, 24)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 680, maxHeight: context.screenHeight * 0.90),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: context.responsiveRadius(14, 18),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(20, 24), vertical: context.responsiveHeight(16, 20)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.local_shipping_rounded, color: AppColors.primaryRed, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  rule.ruleName,
                                  style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentAzureBlue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'P${rule.priority}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentAzureBlue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rule ID: #${rule.id} • ${rule.description.isNotEmpty ? rule.description : "No description provided"}',
                            style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 20), splashRadius: 20, onPressed: () => Get.back()),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Container(
                color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(20, 24), vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricTile(
                      label: 'STATUS',
                      child: StatusBadge(statusValue: rule.status, activeLabel: 'Active', inactiveLabel: 'Inactive'),
                    ),
                    _buildMetricDivider(isDark),
                    _buildMetricTile(
                      label: 'COVERAGE',
                      child: Text(
                        '${resolvedPincodes.length} Pincodes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                        ),
                      ),
                    ),
                    _buildMetricDivider(isDark),
                    _buildMetricTile(
                      label: 'SLABS CONFIGURED',
                      child: Text(
                        '${slabs.length} Active Slabs',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryRed),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.responsiveSize(20, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section A: Serviceable Pincodes
                      Text(
                        'Serviceable Postal Areas',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (resolvedPincodes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('No pincodes linked to this rule.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: resolvedPincodes.map((pin) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primaryRed),
                                  const SizedBox(width: 4),
                                  Text(
                                    pin,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 22),

                      // Section B: Amount Slabs Break down
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Value & Fee Slabs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                            ),
                          ),
                          Text('${slabs.length} Total', style: context.captionStyle),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (slabs.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 30, color: Colors.grey),
                              const SizedBox(height: 6),
                              const Text('No slabs configured yet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Use the Studio to add cart thresholds and base charges.', style: context.captionStyle),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: slabs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final RuleDistanceItem slab = slabs[index];
                            final String amountRange =
                                '₹${slab.minOrderAmount.toStringAsFixed(0)} - ${slab.maxOrderAmount > 0 ? "₹${slab.maxOrderAmount.toStringAsFixed(0)}" : "Open-ended"}';

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentAzureBlue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'P${slab.priority}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentAzureBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Cart: $amountRange', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(
                                          'Delivery Fee: ₹${slab.baseCharge.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.primaryRed, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(statusValue: slab.status, activeLabel: 'Active', inactiveLabel: 'Inactive'),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Footer Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(20, 24), vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Close')),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.openEditRuleStudio(rule);
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Open in Studio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildMetricTile({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, letterSpacing: 0.6, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildMetricDivider(bool isDark) {
    return Container(height: 28, width: 1, color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate);
  }

  String _formatText(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '-';
    return value.toString().trim();
  }
}
