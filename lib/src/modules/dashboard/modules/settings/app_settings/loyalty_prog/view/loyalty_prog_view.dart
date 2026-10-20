import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/controller/loyalty_prog_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/models/view_loyalty_rules_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoyaltyProgView extends GetView<LoyaltyProgController> {
  const LoyaltyProgView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isFormOpen.value) {
        return _buildStudioForm(context);
      }
      return _buildMainConsole(context);
    });
  }

  Widget _buildMainConsole(BuildContext context) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              borderRadius: context.responsiveRadius(8, 10),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: isMobile,
                    tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
                    indicatorColor: AppColors.primaryRed,
                    labelColor: AppColors.primaryRed,
                    unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(icon: Icon(Icons.table_chart_outlined, size: 18), text: 'Loyalty Rules Tiers'),
                      Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Global Points & Referral Settings'),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: controller.openCreateForm,
                    icon: const Icon(Icons.add_card_rounded, size: 18),
                    label: const Text('Add Loyalty Rule', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.onPrimaryWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: context.responsiveHeight(14, 18)),
          Expanded(child: TabBarView(children: [_buildRulesTableTab(context), _buildPointsSettingsTab(context)])),
        ],
      ),
    );
  }

  Widget _buildRulesTableTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search loyalty rule name...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshRules,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Loyalty Rules',
          extraActions: [
            if (context.isMobile)
              ElevatedButton.icon(
                onPressed: controller.openCreateForm,
                icon: const Icon(Icons.add_card_rounded, size: 16),
                label: const Text('Add Rule', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.onPrimaryWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                ),
              ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(12, 16)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<LoyaltyRuleDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Loyalty Rules...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Loyalty Rules Found',
              emptySubtitle: 'Click "Add Loyalty Rule" above to create reward tiers.',
              emptyIcon: Icons.card_giftcard_outlined,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
              columns: const [
                DataColumn(label: Text('RULE ID')),
                DataColumn(label: Text('RULE NAME')),
                DataColumn(label: Text('ORDER RANGE')),
                DataColumn(label: Text('POINTS VALUE')),
                DataColumn(label: Text('MAPPED BRANDS')),
                DataColumn(label: Text('EXPIRY DATE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rowBuilder: (context, rule) => _buildDataRow(context, rule),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, LoyaltyRuleDatum rule) {
    final String rangeStr = rule.maxOrderAmt != null && rule.maxOrderAmt! > 0
        ? '₹${rule.minOrderAmt.toStringAsFixed(0)} - ₹${rule.maxOrderAmt!.toStringAsFixed(0)}'
        : '₹${rule.minOrderAmt.toStringAsFixed(0)} and above';

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: '#${rule.id}',
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        DataCell(
          AppTableCellText(
            text: rule.ruleName,
            maxWidth: 180,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(Text(rangeStr, style: const TextStyle(fontSize: 12))),
        DataCell(
          Text(
            rule.pointsValue.toCurrency(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
          ),
        ),
        DataCell(Text('${rule.brands.length} Brands, ${rule.categories.length} Cats', style: const TextStyle(fontSize: 12))),
        DataCell(Text(EntityDetailsDialogHelper.formatDate(rule.expiryDate), style: const TextStyle(fontSize: 12))),
        DataCell(
          Obx(() {
            final bool isUpdating = controller.togglingStatusMap[rule.id] == true;
            if (isUpdating) {
              return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed));
            }
            return StatusBadge(
              isEditable: true,
              isActive: rule.isActive,
              statusValue: rule.status.toString(),
              onToggle: (val) => controller.toggleRuleStatus(rule, val),
            );
          }),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            mouseCursor: SystemMouseCursors.click,
            color: AppColors.statusBlueInfo,
            tooltip: 'Edit Rule',
            splashRadius: 18,
            onPressed: () => controller.openEditForm(rule),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSettingsTab(BuildContext context) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveSize(16, 24)),
      child: Form(
        key: controller.pointsSettingsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                borderRadius: context.responsiveRadius(10, 12),
                border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
              ),
              padding: EdgeInsets.all(context.responsiveSize(16, 22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.tune_rounded, color: AppColors.primaryRed, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Global Points Conversion & Referral Reward Parameters',
                              style: TextStyle(
                                fontSize: context.responsiveSize(14, 16),
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Define redemption conversion ratios, signup rewards, and catalog conflict precedence.',
                              style: context.captionStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          label: 'Rupees Per Point (₹) *',
                          hint: '0.50',
                          controller: controller.rupeesPerPointCtrl,
                          isDark: isDark,
                          isDecimal: true,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Points Per Rupee *',
                          hint: '2.00',
                          controller: controller.pointsPerRupeeCtrl,
                          isDark: isDark,
                          isDecimal: true,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildConflictPriorityDropdown(isDark),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'New Customer Reward Points *',
                          hint: '100',
                          controller: controller.newCustRewardCtrl,
                          isDark: isDark,
                          isDecimal: false,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Customer Referral Reward Points *',
                          hint: '50',
                          controller: controller.custReffRewardCtrl,
                          isDark: isDark,
                          isDecimal: false,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Rupees Per Point (₹) *',
                                hint: '0.50',
                                controller: controller.rupeesPerPointCtrl,
                                isDark: isDark,
                                isDecimal: true,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _buildTextField(
                                label: 'Points Per Rupee *',
                                hint: '2.00',
                                controller: controller.pointsPerRupeeCtrl,
                                isDark: isDark,
                                isDecimal: true,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(child: _buildConflictPriorityDropdown(isDark)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'New Customer Reward Points *',
                                hint: '100',
                                controller: controller.newCustRewardCtrl,
                                isDark: isDark,
                                isDecimal: false,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _buildTextField(
                                label: 'Customer Referral Reward Points *',
                                hint: '50',
                                controller: controller.custReffRewardCtrl,
                                isDark: isDark,
                                isDecimal: false,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() {
                      final bool isSubmitting = controller.isSubmittingPointsSettings.value;
                      final bool isEdit = controller.pointsSettingsId.value != null;

                      return ElevatedButton.icon(
                        onPressed: isSubmitting ? null : controller.submitPointsSettings,
                        icon: isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(
                          isSubmitting ? 'Saving Settings...' : (isEdit ? 'Update Points Settings' : 'Save Points Settings'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictPriorityDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loyalty Conflict Priority *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        Obx(() {
          return DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: controller.loyaltyConflictPriority.value,
            dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(
                value: 'category',
                child: Text('Category Precedence', style: TextStyle(fontSize: 13)),
              ),
              DropdownMenuItem(
                value: 'brand',
                child: Text('Brand Precedence', style: TextStyle(fontSize: 13)),
              ),
            ],
            onChanged: (val) {
              if (val != null) controller.loyaltyConflictPriority.value = val;
            },
          );
        }),
      ],
    );
  }

  Widget _buildStudioForm(BuildContext context) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: context.responsiveRadius(12, 16),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeader(context, isDark),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingItems.value) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(context.responsiveSize(20, 28)),
                child: Form(
                  key: controller.loyaltyFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard(
                        context: context,
                        isDark: isDark,
                        stepNumber: '1',
                        title: 'Rule Parameters & Tiers',
                        subtitle: 'Set up cart conditions, expiry, and points value.',
                        child: _buildParameterFields(context, isDark, isMobile),
                      ),
                      SizedBox(height: context.responsiveHeight(20, 24)),
                      _buildSectionCard(
                        context: context,
                        isDark: isDark,
                        stepNumber: '2',
                        title: 'Target Catalogs (Brands & Categories)',
                        subtitle: 'Select applicable product groups using codes.',
                        child: _buildCatalogMultiSelect(context, isDark, isMobile),
                      ),
                      SizedBox(height: context.responsiveHeight(20, 24)),
                      _buildFormActions(context),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(20, 28), vertical: context.responsiveHeight(14, 18)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.closeForm,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                tooltip: 'Back to Loyalty Rules',
                splashRadius: 20,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.card_giftcard_rounded, color: AppColors.primaryRed, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.editingRuleId.value != null ? 'Edit Loyalty Rule Studio' : 'Create Loyalty Rule Studio',
                    style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Configure reward point ratios, catalog targeting, and expiry dates',
                    style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: controller.closeForm,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Exit Studio'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required bool isDark,
    required String stepNumber,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
        borderRadius: context.responsiveRadius(10, 12),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      padding: EdgeInsets.all(context.responsiveSize(16, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryRed,
                child: Text(
                  stepNumber,
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: context.responsiveSize(14, 15),
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                      ),
                    ),
                    Text(subtitle, style: context.captionStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildParameterFields(BuildContext context, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            label: 'Rule Name *',
            hint: 'e.g. Dairy Loyalty',
            controller: controller.ruleNameController,
            isDark: isDark,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Min Order Amount (₹) *',
            hint: '0',
            controller: controller.minOrderAmtController,
            isDark: isDark,
            isDecimal: true,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Max Order Amount (₹)',
            hint: 'Optional (Leave blank if infinite)',
            controller: controller.maxOrderAmtController,
            isDark: isDark,
            isDecimal: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Points Value (1 Point = ₹) *',
            hint: 'e.g. 50',
            controller: controller.pointsValueController,
            isDark: isDark,
            isDecimal: true,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          _buildDateField(context, isDark),
          const SizedBox(height: 12),
          _buildStatusToggle(isDark),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'Rule Name *',
                hint: 'e.g. Dairy Loyalty',
                controller: controller.ruleNameController,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildStatusToggle(isDark)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Min Order Amount (₹) *',
                hint: '0',
                controller: controller.minOrderAmtController,
                isDark: isDark,
                isDecimal: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                label: 'Max Order Amount (₹)',
                hint: 'Optional',
                controller: controller.maxOrderAmtController,
                isDark: isDark,
                isDecimal: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                label: 'Points Value (1 Point = ₹) *',
                hint: 'e.g. 50',
                controller: controller.pointsValueController,
                isDark: isDark,
                isDecimal: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: _buildDateField(context, isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.expiryDateController,
          readOnly: true,
          onTap: () => controller.selectExpiryDate(context),
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD (Optional)',
            filled: true,
            fillColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: IconButton(icon: const Icon(Icons.clear_rounded, size: 16), onPressed: () => controller.expiryDateController.clear()),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogMultiSelect(BuildContext context, bool isDark, bool isMobile) {
    final Widget brandBlock = _buildMultiSelectBlock(
      isDark: isDark,
      title: 'Applicable Brands *',
      isAllSelectedRx: controller.isAllBrandsSelected,
      onToggleAll: controller.toggleSelectAllBrands,
      itemsLength: controller.availableBrands.length,
      selectedLengthRx: Obx(
        () => Text(
          '${controller.selectedBrandCodes.length} Selected',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
        ),
      ),
      listBuilder: () => ListView.separated(
        itemCount: controller.availableBrands.length,
        separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.5),
        itemBuilder: (context, index) {
          final brand = controller.availableBrands[index];
          return Obx(() {
            final bool isSelected = controller.selectedBrandCodes.contains(brand.brandCode);
            return CheckboxListTile(
              key: ValueKey('brand_${brand.brandCode}'),
              dense: true,
              value: isSelected,
              activeColor: AppColors.primaryRed,
              title: Text(brand.brandName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              subtitle: Text('Code: ${brand.brandCode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              onChanged: (_) => controller.toggleBrandSelection(brand.brandCode),
            );
          });
        },
      ),
    );

    final Widget categoryBlock = _buildMultiSelectBlock(
      isDark: isDark,
      title: 'Applicable Categories *',
      isAllSelectedRx: controller.isAllCategoriesSelected,
      onToggleAll: controller.toggleSelectAllCategories,
      itemsLength: controller.availableCategories.length,
      selectedLengthRx: Obx(
        () => Text(
          '${controller.selectedCategoryCodes.length} Selected',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
        ),
      ),
      listBuilder: () => ListView.separated(
        itemCount: controller.availableCategories.length,
        separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.5),
        itemBuilder: (context, index) {
          final cat = controller.availableCategories[index];
          return Obx(() {
            final bool isSelected = controller.selectedCategoryCodes.contains(cat.categoryCode);
            return CheckboxListTile(
              key: ValueKey('cat_${cat.categoryCode}'),
              dense: true,
              value: isSelected,
              activeColor: AppColors.primaryRed,
              title: Text(cat.categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              subtitle: Text('Code: ${cat.categoryCode}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              onChanged: (_) => controller.toggleCategorySelection(cat.categoryCode),
            );
          });
        },
      ),
    );

    if (isMobile) {
      return Column(children: [brandBlock, const SizedBox(height: 16), categoryBlock]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: brandBlock),
        const SizedBox(width: 16),
        Expanded(child: categoryBlock),
      ],
    );
  }

  Widget _buildMultiSelectBlock({
    required bool isDark,
    required String title,
    required RxBool isAllSelectedRx,
    required Function(bool?) onToggleAll,
    required int itemsLength,
    required Widget selectedLengthRx,
    required Widget Function() listBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: selectedLengthRx,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Obx(() => Checkbox(value: isAllSelectedRx.value, activeColor: AppColors.primaryRed, onChanged: onToggleAll)),
              const Text('Select All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          if (itemsLength == 0)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No items available', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                borderRadius: BorderRadius.circular(6),
              ),
              child: listBuilder(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(bool isDark) {
    return Obx(() {
      final bool isActive = controller.status.value == 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive ? AppColors.statusGreenSuccess : AppColors.borderSubtleSlate),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [StatusBadge(isEditable: true, isActive: isActive, onToggle: (val) => controller.status.value = val ? 1 : 0)],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    bool isDecimal = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: isDecimal ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))] : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFormActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: controller.closeForm,
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8))),
            child: const Text('Discard Changes'),
          ),
          Obx(() {
            final bool isSubmitting = controller.isSubmitting.value;
            final bool isEdit = controller.editingRuleId.value != null;

            return ElevatedButton.icon(
              onPressed: isSubmitting ? null : controller.submitLoyaltyRule,
              icon: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                isSubmitting ? 'Saving Configuration...' : (isEdit ? 'Update Loyalty Rule' : 'Save & Publish Loyalty Rule'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
