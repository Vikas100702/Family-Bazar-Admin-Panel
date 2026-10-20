import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/paginated_table_container.dart';
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
                controller.openCreateDialog();
                _showCouponFormDialog(context, isEdit: false);
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Coupon', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.onPrimaryWhite,
                padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(14, 16), vertical: context.responsiveHeight(12, 14)),
                shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(16, 20)),
        Expanded(
          child: Obx(
            () => PaginatedTableContainer<ViewCouponListDatum>(
              isLoading: controller.isLoading.value,
              loadingMessage: 'Loading Coupons...',
              items: controller.pagedList,
              horizontalScrollController: controller.horizontalScrollController,
              verticalScrollController: controller.verticalScrollController,
              emptyTitle: 'No Coupons Found',
              emptySubtitle: 'Click "Add Coupon" above to configure promotional offers.',
              emptyIcon: Icons.discount_outlined,
              currentPage: controller.currentPage.value,
              totalItems: controller.totalRecords.value,
              itemsPerPage: controller.itemsPerPage.value,
              itemsPerPageOptions: controller.pageSizeOptions,
              onPageChanged: controller.changePage,
              onItemsPerPageChanged: controller.changePageSize,
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
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, ViewCouponListDatum coupon) {
    final bool isDark = context.isDark;
    final bool isPercentage = coupon.discountType.toLowerCase().contains('percent');

    return DataRow(
      cells: [
        DataCell(
          AppTableCellText(
            text: coupon.code,
            isSelectable: true,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        DataCell(
          AppTableCellText(
            text: coupon.title,
            maxWidth: 200,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
              borderRadius: context.responsiveRadius(4, 6),
              border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
            ),
            child: Text(
              coupon.discountType.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.accentGoldAmber : AppColors.statusAmberWarning),
            ),
          ),
        ),
        DataCell(
          Text(
            isPercentage ? '${coupon.discountValue}%' : coupon.discountValue.toString().toPrice(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.accentAzureBlue : AppColors.statusBlueInfo),
          ),
        ),
        DataCell(Text(coupon.minOrderAmount.toString().toPrice(), style: const TextStyle(fontSize: 12))),
        DataCell(Text(coupon.maxDiscount.toString().toPrice(), style: const TextStyle(fontSize: 12))),
        DataCell(Text('${_formatDate(coupon.startAt)} - ${_formatDate(coupon.endAt)}', style: const TextStyle(fontSize: 11))),
        DataCell(StatusBadge(isEditable: false, statusValue: coupon.status, activeLabel: 'Active', inactiveLabel: 'Inactive')),
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
                icon: const Icon(Icons.edit_outlined, size: 18),
                mouseCursor: SystemMouseCursors.click,
                color: AppColors.statusBlueInfo,
                tooltip: 'Edit Coupon Parameters',
                splashRadius: 18,
                onPressed: () {
                  controller.openEditDialog(coupon);
                  _showCouponFormDialog(context, isEdit: true);
                },
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
                  onConfirm: () => controller.deleteCoupon(coupon),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCouponDetails(BuildContext context, ViewCouponListDatum coupon) {
    final bool isPercentage = coupon.discountType.toLowerCase().contains('percent');
    final bool isUniversal = coupon.applicableAll.trim() == '1' || (coupon.applicableGroup.isEmpty && coupon.applicableBrand.isEmpty);

    EntityDetailsDialogHelper.show(
      context: context,
      title: 'Coupon: ${coupon.code}',
      subtitle: 'Promotional Specifications & Eligibility Bounds',
      headerIcon: Icons.discount_rounded,
      sections: [
        DetailSection(
          title: 'Basic Information',
          items: [
            DetailItem(label: 'Coupon Code', value: coupon.code, isCopyable: true),
            DetailItem(label: 'Title', value: coupon.title),
            DetailItem(label: 'Discount Type', value: coupon.discountType.toUpperCase()),
            DetailItem(label: 'User Eligibility', value: coupon.userType),
            DetailItem(label: 'Payment Mode', value: coupon.paymentType),
          ],
          flags: [DetailFlag(label: 'Active (Live)', value: coupon.status == 1)],
        ),
        DetailSection(
          title: 'Value & Bounds',
          items: [
            DetailItem(label: 'Discount Value', value: isPercentage ? '${coupon.discountValue}%' : coupon.discountValue.toString().toPrice()),
            DetailItem(label: 'Max Discount Cap', value: coupon.maxDiscount.toString().toPrice()),
            DetailItem(label: 'Min Order Amount', value: coupon.minOrderAmount.toString().toPrice()),
          ],
        ),
        DetailSection(
          title: 'Limits & Scope',
          items: [
            DetailItem(label: 'Total Usage Cap', value: '${coupon.usageLimit}'),
            DetailItem(label: 'Per Customer Cap', value: '${coupon.usagePerCustomer}'),
            DetailItem(label: 'Total Used Count', value: '${coupon.usedCount}'),
            DetailItem(label: 'Applicability', value: isUniversal ? 'Universal (All Groups & Brands)' : 'Restricted Groups and Brands'),
            if (coupon.applicableGroup.isNotEmpty) DetailItem(label: 'Allowed Groups', value: coupon.applicableGroup.join(', ')),
            if (coupon.applicableBrand.isNotEmpty) DetailItem(label: 'Allowed Brands', value: coupon.applicableBrand.join(', ')),
          ],
        ),
        DetailSection(
          title: 'Validity & Lifecycle',
          items: [
            DetailItem(label: 'Valid From', value: _formatDate(coupon.startAt)),
            DetailItem(label: 'Valid Until', value: _formatDate(coupon.endAt)),
            DetailItem(
              label: 'Created At',
              value: coupon.createdAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(coupon.createdAt!.toLocal()) : '—',
            ),
            DetailItem(
              label: 'Last Updated',
              value: coupon.updatedAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(coupon.updatedAt!.toLocal()) : '—',
            ),
          ],
        ),
      ],
    );
  }

  void _showCouponFormDialog(BuildContext context, {required bool isEdit}) {
    final bool isDark = context.isDark;
    final bool isMobile = context.isMobile;
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
            borderRadius: context.responsiveRadius(12, 14),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Form(
              key: controller.couponFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEdit ? 'Edit Coupon' : 'Add New Coupon', style: context.titleStyleActive.copyWith(fontSize: 18)),
                      IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Get.back()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure promotional codes, eligibility bounds, and group/brand restrictions.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                  ),
                  const SizedBox(height: 20),
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.codeController,
                      decoration: const InputDecoration(
                        labelText: 'Coupon Code *',
                        hintText: 'e.g., SAVE10',
                        prefixIcon: Icon(Icons.qr_code_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Code is required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'e.g., ₹100 Off',
                        prefixIcon: Icon(Icons.title_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: Obx(() {
                      final currentValue = controller.selectedDiscountType.value;
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: currentValue,
                        hint: const Text('Select Discount Type *', style: TextStyle(fontSize: 13)),
                        decoration: const InputDecoration(
                          labelText: 'Discount Type *',
                          prefixIcon: Icon(Icons.percent_rounded, size: 18),
                          isDense: true,
                        ),
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
                      decoration: const InputDecoration(
                        labelText: 'Discount Value *',
                        hintText: 'e.g., 100',
                        prefixIcon: Icon(Icons.discount_outlined, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Discount value required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.maxDiscountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Max Discount *',
                        hintText: 'e.g., 200',
                        prefixIcon: Icon(Icons.money_off_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Max discount required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.minOrderAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Min Order Amount *',
                        hintText: 'e.g., 500',
                        prefixIcon: Icon(Icons.shopping_cart_outlined, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Min order required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.usageLimitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Usage Limit *',
                        hintText: 'e.g., 10000',
                        prefixIcon: Icon(Icons.group_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Usage limit required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.usagePerCustomerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Usage Per Customer *',
                        hintText: 'e.g., 1',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Usage per customer required' : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: Obx(() {
                      final currentValue = controller.selectedUserType.value;
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: currentValue,
                        hint: const Text('Select User Type *', style: TextStyle(fontSize: 13)),
                        decoration: const InputDecoration(
                          labelText: 'User Type *',
                          prefixIcon: Icon(Icons.people_outline_rounded, size: 18),
                          isDense: true,
                        ),
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
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: currentValue,
                        hint: const Text('Select Payment Type *', style: TextStyle(fontSize: 13)),
                        decoration: const InputDecoration(
                          labelText: 'Payment Type *',
                          prefixIcon: Icon(Icons.payment_rounded, size: 18),
                          isDense: true,
                        ),
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
                  _buildAdaptiveFieldsRow(
                    isMobile: isMobile,
                    first: TextFormField(
                      controller: controller.startAtController,
                      readOnly: true,
                      onTap: () => _pickDateTime(context, isStart: true),
                      decoration: const InputDecoration(
                        labelText: 'Start Date & Time *',
                        hintText: 'YYYY-MM-DD HH:mm:ss',
                        prefixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Start date & time required' : null,
                    ),
                    second: TextFormField(
                      controller: controller.endAtController,
                      readOnly: true,
                      onTap: () => _pickDateTime(context, isStart: false),
                      decoration: const InputDecoration(
                        labelText: 'End Date & Time *',
                        hintText: 'YYYY-MM-DD HH:mm:ss',
                        prefixIcon: Icon(Icons.event_available_rounded, size: 18),
                        isDense: true,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'End date & time required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final bool isAll = controller.applicableAll.value == 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                        borderRadius: context.responsiveRadius(6, 8),
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
                                  'When enabled, specific groups and brands will be disabled.',
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
                  Obx(() {
                    final bool isAll = controller.applicableAll.value == 1;
                    return _buildAdaptiveFieldsRow(
                      isMobile: isMobile,
                      first: _buildSelectorTile(
                        context: context,
                        title: 'Applicable Groups',
                        icon: Icons.grid_view_rounded,
                        isDisabled: isAll,
                        selectedCount: controller.selectedGroupCodes.length,
                        onTap: isAll ? null : () => _openGroupSelectionDialog(context),
                      ),
                      second: _buildSelectorTile(
                        context: context,
                        title: 'Applicable Brands',
                        icon: Icons.branding_watermark_rounded,
                        isDisabled: isAll,
                        selectedCount: controller.selectedBrandCodes.length,
                        onTap: isAll ? null : () => _openBrandSelectionDialog(context),
                      ),
                    );
                  }),
                  if (isEdit) ...[
                    const SizedBox(height: 16),
                    Obx(() {
                      final bool isActive = controller.couponStatus.value == 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                          borderRadius: context.responsiveRadius(6, 8),
                          border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coupon Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                                  ),
                                ),
                                Text(
                                  isActive ? 'Active (Visible & Redeemable)' : 'Inactive (Disabled)',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                                ),
                              ],
                            ),
                            StatusBadge(
                              isEditable: true,
                              isActive: isActive,
                              activeLabel: 'Active',
                              inactiveLabel: 'Inactive',
                              onToggle: (val) => controller.couponStatus.value = val ? 1 : 0,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final bool success = await controller.submitCoupon();
                                  if (success) Get.back();
                                },
                          icon: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(
                            controller.isSubmitting.value ? 'Saving...' : (isEdit ? 'Update Coupon' : 'Save Coupon'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: AppColors.onPrimaryWhite,
                            padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(18, 22), vertical: context.responsiveHeight(10, 12)),
                            shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                          ),
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

  Widget _buildSelectorTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isDisabled,
    required int selectedCount,
    required VoidCallback? onTap,
  }) {
    final bool isDark = context.isDark;

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
            borderRadius: context.responsiveRadius(6, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                borderRadius: context.responsiveRadius(6, 8),
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
    final bool isDark = context.isDark;
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
                decoration: const InputDecoration(
                  hintText: 'Search group by name or code...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
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
                        activeColor: AppColors.primaryRed,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                  ),
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
    final bool isDark = context.isDark;
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
                decoration: const InputDecoration(
                  hintText: 'Search brand by name or company code...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
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
                        activeColor: AppColors.primaryRed,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(6, 8)),
                  ),
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

  Future<void> _pickDateTime(BuildContext context, {required bool isStart}) async {
    final DateTime initialDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? initialDate : initialDate.add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? const TimeOfDay(hour: 0, minute: 0) : const TimeOfDay(hour: 23, minute: 59),
    );

    if (pickedTime == null) return;

    final DateTime combined = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute, isStart ? 0 : 59);

    final String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
    controller.setDateTime(formattedDateTime: formatted, isStart: isStart);
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
