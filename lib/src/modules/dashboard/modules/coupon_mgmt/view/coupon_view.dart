import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/custom_pagination_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/data_table_widget.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/table_header_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/controller/coupon_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/model/view_coupon_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CouponView extends GetView<CouponController> {
  const CouponView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableHeaderWidget(
          searchHintText: 'Search coupon code, title...',
          onSearchChanged: controller.onSearchChanged,
          onSearchSubmitted: controller.onSearchSubmitted,
          onSearchClear: controller.clearSearch,
          onRefresh: controller.refreshCoupons,
          rxIsRefreshing: controller.isLoading,
          refreshTooltip: 'Refresh Coupons',
          extraActions: [
            ElevatedButton.icon(
              onPressed: () {
                controller.resetForm();
                _openAddCouponDialog(context);
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Coupon', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.onPrimaryWhite,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      Text('Loading Coupons...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    child: DataTableWidget<ViewCouponListDatum>(
                      items: controller.pagedList.toList(),
                      horizontalScrollController: controller.horizontalScrollController,
                      verticalScrollController: controller.verticalScrollController,
                      emptyTitle: 'No Coupons Found',
                      emptySubtitle: 'Click "Add Coupon" above to configure promotional offers.',
                      emptyIcon: Icons.discount_outlined,
                      columns: const [
                        DataColumn(label: Text('CODE')),
                        DataColumn(label: Text('TITLE')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('DISCOUNT')),
                        DataColumn(label: Text('MIN ORDER')),
                        DataColumn(label: Text('MAX DISCOUNT')),
                        DataColumn(label: Text('VALIDITY')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rowBuilder: (context, coupon) => _buildDataRow(context, coupon),
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

  DataRow _buildDataRow(BuildContext context, ViewCouponListDatum coupon) {
    final isDark = context.isDark;
    final isPercentage = coupon.discountType.toLowerCase().contains('percent');

    return DataRow(
      cells: [
        DataCell(SelectableText(coupon.code.isEmpty ? 'N/A' : coupon.code, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Tooltip(
              message: coupon.title.trim().isEmpty ? 'N/A' : coupon.title,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                coupon.title.trim().isEmpty ? 'N/A' : coupon.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            coupon.discountType.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
          ),
        ),
        DataCell(
          Text(
            isPercentage ? '${coupon.discountValue}%' : '₹${coupon.discountValue}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(Text('₹${coupon.minOrderAmount}', style: const TextStyle(fontSize: 12))),
        DataCell(Text('₹${coupon.maxDiscount}', style: const TextStyle(fontSize: 12))),
        DataCell(Text('${_formatDate(coupon.startAt)} - ${_formatDate(coupon.endAt)}', style: const TextStyle(fontSize: 11))),
        DataCell(StatusBadge(isEditable: false, statusValue: coupon.status.toString(), activeLabel: 'Active', inactiveLabel: 'Inactive')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                tooltip: 'View Coupon Details',
                splashRadius: 18,
                onPressed: () => _showCouponDetails(context, coupon),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: isDark ? AppColors.primaryRedLight : AppColors.primaryRedDark,
                tooltip: 'Delete Coupon',
                splashRadius: 18,
                onPressed: () => DialogHelper.showDeleteDialog(
                  title: 'Delete Coupon',
                  itemName: coupon.code,
                  message: 'Are you sure you want to delete coupon "${coupon.code}"?',
                  onConfirm: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openAddCouponDialog(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;
    final double dialogWidth = isMobile ? context.screenWidth * 0.95 : 750.0;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxWidth: 750, maxHeight: context.screenHeight * 0.92),
          padding: EdgeInsets.all(context.responsiveSize(16, 24)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: controller.addCouponFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Coupon', style: context.titleStyleActive.copyWith(fontSize: 18)),
                      IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure promotional codes, eligibility bounds, and group/brand restrictions.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                  ),
                  const SizedBox(height: 20),

                  // Code & Title
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.codeController,
                      decoration: _buildInputDecoration(context, 'Coupon Code *', 'e.g., SAVE10', Icons.qr_code_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Code is required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.titleController,
                      decoration: _buildInputDecoration(context, 'Title *', 'e.g., ₹100 Off', Icons.title_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dynamic Discount Type & Discount Value
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: Obx(() {
                      final currentValue = controller.selectedDiscountType.value;
                      final bool isMatch = controller.discountTypeOptions.any((opt) => opt['value'] == currentValue);

                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: isMatch ? currentValue : null,
                        hint: const Text('Select Discount Type *', style: TextStyle(fontSize: 13)),
                        decoration: _buildInputDecoration(context, 'Discount Type *', '', Icons.percent_rounded),
                        dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                        items: controller.discountTypeOptions.map((opt) {
                          return DropdownMenuItem<String>(value: opt['value'], child: Text(opt['label']!));
                        }).toList(),
                        validator: (val) => (val == null || val.isEmpty) ? 'Discount type required' : null,
                        onChanged: (val) {
                          if (val != null) controller.selectedDiscountType.value = val;
                        },
                      );
                    }),
                    second: TextFormField(
                      controller: controller.discountValueController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildInputDecoration(context, 'Discount Value *', 'e.g., 100', Icons.discount_outlined),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Discount value required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Max Discount & Minimum Order Amount
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.maxDiscountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildInputDecoration(context, 'Max Discount *', 'e.g., 200', Icons.money_off_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Max discount required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.minOrderAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildInputDecoration(context, 'Min Order Amount *', 'e.g., 500', Icons.shopping_cart_outlined),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Min order required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Usage Limit & Usage Per Customer
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.usageLimitController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(context, 'Usage Limit *', 'e.g., 10000', Icons.group_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Usage limit required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.usagePerCustomerController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(context, 'Usage Per Customer *', 'e.g., 1', Icons.person_outline_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Usage per customer required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dynamic User Type & Dynamic Payment Type
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: Obx(() {
                      final currentValue = controller.selectedUserType.value;
                      final bool isMatch = controller.userTypeOptions.any((opt) => opt['value'] == currentValue);

                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: isMatch ? currentValue : null,
                        hint: const Text('Select User Type *', style: TextStyle(fontSize: 13)),
                        decoration: _buildInputDecoration(context, 'User Type *', '', Icons.people_outline_rounded),
                        dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                        items: controller.userTypeOptions.map((opt) {
                          return DropdownMenuItem<String>(value: opt['value'], child: Text(opt['label']!));
                        }).toList(),
                        validator: (val) => (val == null || val.isEmpty) ? 'User type required' : null,
                        onChanged: (val) {
                          if (val != null) controller.selectedUserType.value = val;
                        },
                      );
                    }),
                    second: Obx(() {
                      final currentValue = controller.selectedPaymentType.value;
                      final bool isMatch = controller.paymentTypeOptions.any((opt) => opt['value'] == currentValue);

                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: isMatch ? currentValue : null,
                        hint: const Text('Select Payment Type *', style: TextStyle(fontSize: 13)),
                        decoration: _buildInputDecoration(context, 'Payment Type *', '', Icons.payment_rounded),
                        dropdownColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
                        items: controller.paymentTypeOptions.map((opt) {
                          return DropdownMenuItem<String>(value: opt['value'], child: Text(opt['label']!));
                        }).toList(),
                        validator: (val) => (val == null || val.isEmpty) ? 'Payment type required' : null,
                        onChanged: (val) {
                          if (val != null) controller.selectedPaymentType.value = val;
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Start Date & End Date
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.startAtController,
                      readOnly: true,
                      onTap: () => controller.pickDateTime(context: context, isStart: true),
                      decoration: _buildInputDecoration(context, 'Start Date & Time *', 'YYYY-MM-DD HH:mm:ss', Icons.calendar_today_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Start date & time required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.endAtController,
                      readOnly: true,
                      onTap: () => controller.pickDateTime(context: context, isStart: false),
                      decoration: _buildInputDecoration(context, 'End Date & Time *', 'YYYY-MM-DD HH:mm:ss', Icons.event_available_rounded),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'End date & time required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // APPLICABLE TO ALL TOGGLE STRIP
                  Obx(() {
                    final bool isAll = controller.applicableAll.value == 1;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAll
                              ? AppColors.primaryRed.withValues(alpha: 0.5)
                              : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(value: isAll, activeColor: AppColors.primaryRed, onChanged: (val) => controller.toggleApplicableAll(val ?? false)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Applicable to All (Universal Coupon)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                                  ),
                                ),
                                Text(
                                  'When enabled, this coupon applies storewide. Specific groups and brands will be disabled.',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // APPLICABLE GROUPS & BRANDS SELECTORS
                  Obx(() {
                    final bool isAll = controller.applicableAll.value == 1;
                    final int groupCount = controller.selectedGroupCodes.length;
                    final int brandCount = controller.selectedBrandCodes.length;

                    return _buildAdaptiveFieldsRow(
                      isMobile: isMobile,
                      first: _buildSelectorTile(
                        context: context,
                        title: 'Applicable Groups',
                        icon: Icons.grid_view_rounded,
                        isDisabled: isAll,
                        selectedCount: groupCount,
                        onTap: isAll ? null : () => _openGroupSelectionDialog(context),
                      ),
                      second: _buildSelectorTile(
                        context: context,
                        title: 'Applicable Brands',
                        icon: Icons.branding_watermark_rounded,
                        isDisabled: isAll,
                        selectedCount: brandCount,
                        onTap: isAll ? null : () => _openBrandSelectionDialog(context),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Status Toggle
                  Obx(() {
                    final isActive = controller.couponStatus.value == 1;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                          ),
                        ),
                        StatusBadge(
                          isEditable: true,
                          isActive: isActive,
                          activeLabel: 'Active',
                          inactiveLabel: 'Inactive',
                          onToggle: (val) => controller.couponStatus.value = val ? 1 : 0,
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),

                  // Submit Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final success = await controller.submitAddCoupon();
                                  if (success) Get.back();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: AppColors.onPrimaryWhite,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Text('Save Coupon', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // SELECTOR TILE BUILDER
  Widget _buildSelectorTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isDisabled,
    required int selectedCount,
    required VoidCallback? onTap,
  }) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDisabled
                ? (isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate)
                : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
          ),
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: isDisabled ? 0.45 : 1.0,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: isDisabled ? Colors.grey : AppColors.primaryRed),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isDisabled ? 'Disabled (Applicable to All)' : (selectedCount > 0 ? '$selectedCount selected' : 'Click to select'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: (!isDisabled && selectedCount > 0) ? FontWeight.w600 : FontWeight.w400,
                        fontStyle: isDisabled ? FontStyle.italic : FontStyle.normal,
                        color: isDisabled
                            ? (isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate)
                            : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 13, color: isDisabled ? Colors.transparent : Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openGroupSelectionDialog(BuildContext context) {
    final isDark = context.isDark;
    controller.groupSearchController.clear();
    controller.filteredGroups.assignAll(controller.allGroups);

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 480,
          height: 520,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Applicable Groups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.groupSearchController,
                onChanged: controller.filterGroups,
                decoration: InputDecoration(
                  hintText: 'Search group by name or code...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final groups = controller.filteredGroups;
                  final Set<String> selectedSet = controller.selectedGroupCodes.toSet();

                  if (groups.isEmpty) {
                    return const Center(child: Text('No dashboard groups found.'));
                  }

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final isSelected = selectedSet.contains(group.dgCode);

                      return CheckboxListTile(
                        dense: true,
                        title: Text(group.dgName, style: const TextStyle(fontSize: 13)),
                        subtitle: Text('Group Code: ${group.dgCode} | ID: ${group.id}', style: const TextStyle(fontSize: 11)),
                        value: isSelected,
                        onChanged: (_) => controller.toggleGroupSelection(group.dgCode),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBrandSelectionDialog(BuildContext context) {
    final isDark = context.isDark;
    controller.brandSearchController.clear();
    controller.filteredBrands.assignAll(controller.allBrands);

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 480,
          height: 520,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Applicable Brands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.brandSearchController,
                onChanged: controller.filterBrands,
                decoration: InputDecoration(
                  hintText: 'Search brand by name or company code...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final brands = controller.filteredBrands;
                  final Set<String> selectedSet = controller.selectedBrandCodes.toSet();

                  if (brands.isEmpty) {
                    return const Center(child: Text('No brands found.'));
                  }

                  return ListView.builder(
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      final brand = brands[index];
                      final String brandCode = brand.mcCompCode.trim();
                      final isSelected = selectedSet.contains(brandCode);

                      return CheckboxListTile(
                        dense: true,
                        title: Text(brand.mcCompName, style: const TextStyle(fontSize: 13)),
                        subtitle: Text('Brand Code: ${brand.mcCompCode}', style: const TextStyle(fontSize: 11)),
                        value: isSelected,
                        onChanged: (_) => controller.toggleBrandSelection(brandCode),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCouponDetails(BuildContext context, ViewCouponListDatum coupon) {
    final bool isPercentage = coupon.discountType.toLowerCase().contains('percent');
    final bool isUniversal = coupon.applicableAll.toString().trim() == '1' || (coupon.applicableGroup.isEmpty && coupon.applicableBrand.isEmpty);

    EntityDetailsDialogHelper.show(
      context: context,
      title: coupon.title.isNotEmpty ? coupon.title.trim() : coupon.code,
      subtitle: 'Details for Coupon Code: ${coupon.code}',
      headerIcon: Icons.confirmation_number_rounded,
      sections: [
        DetailSection(
          title: '1. Identification & Nomenclature',
          items: [
            DetailItem(label: 'Coupon ID', value: coupon.id.toString(), isCopyable: true),
            DetailItem(label: 'Coupon Code', value: coupon.code, isCopyable: true),
            DetailItem(label: 'Title', value: coupon.title),
            DetailItem(label: 'Discount Type', value: coupon.discountType.toUpperCase()),
            DetailItem(label: 'User Type', value: coupon.userType),
            DetailItem(label: 'Payment Type', value: coupon.paymentType),
          ],
        ),
        DetailSection(
          title: '2. Value & Order Rules',
          items: [
            DetailItem(label: 'Discount Value', value: isPercentage ? '${coupon.discountValue}%' : '₹${coupon.discountValue}'),
            DetailItem(label: 'Max Discount Amount', value: '₹${coupon.maxDiscount}'),
            DetailItem(label: 'Min Order Amount', value: '₹${coupon.minOrderAmount}'),
          ],
        ),
        DetailSection(
          title: '3. Limits & Usage Quotas',
          items: [
            DetailItem(label: 'Usage Limit', value: '${coupon.usageLimit}'),
            DetailItem(label: 'Limit Per Customer', value: '${coupon.usagePerCustomer}'),
            DetailItem(label: 'Used Count', value: '${coupon.usedCount}'),
            DetailItem(label: 'Applicability Rule', value: isUniversal ? 'Applicable to All (Universal)' : 'Targeted Specific Groups / Brands'),
            if (coupon.applicableGroup.isNotEmpty) DetailItem(label: 'Assigned Groups (Codes)', value: coupon.applicableGroup.join(', ')),
            if (coupon.applicableBrand.isNotEmpty) DetailItem(label: 'Assigned Brands (Codes)', value: coupon.applicableBrand.join(', ')),
          ],
        ),
        DetailSection(
          title: '4. Validity & Timestamps',
          items: [
            DetailItem(label: 'Valid From', value: _formatDate(coupon.startAt)),
            DetailItem(label: 'Valid Until', value: _formatDate(coupon.endAt)),
            DetailItem(label: 'Created At', value: _formatDate(coupon.createdAt)),
            DetailItem(label: 'Updated At', value: _formatDate(coupon.updatedAt)),
          ],
        ),
      ],
    );
  }

  // HELPER WIDGETS & UTILITIES
  InputDecoration _buildInputDecoration(BuildContext context, String label, String hint, IconData icon) {
    final isDark = context.isDark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildAdaptiveFieldsRow({required bool isMobile, required Widget first, required Widget second}) {
    if (isMobile) {
      return Column(children: [first, const SizedBox(height: 14), second]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 14),
        Expanded(child: second),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
    } catch (_) {
      return date.toString().split(' ')[0];
    }
  }
}
