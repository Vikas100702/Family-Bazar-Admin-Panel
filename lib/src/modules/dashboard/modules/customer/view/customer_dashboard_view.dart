import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_table_cell_text.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/entity_details_dialog.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/status_badge.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_dashboard_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/controller/customer_details_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/model/customer_dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDashboardView extends GetView<CustomerDashboardController> {
  const CustomerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    final customerDetailsCtrl = Get.find<CustomerDetailsController>();

    return Obx(() {
      if (controller.isLoading.value && controller.dashboardData.value == null) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: context.defaultDecoration,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                SizedBox(height: 16),
                Text('Loading Customer dashboard Insights...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }

      final CustomerDashboardData? data = controller.dashboardData.value;
      if (data == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No Customer dashboard Data Available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: customerDetailsCtrl.closeCustomerDashboard,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to List'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: controller.refreshDashboard,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry Fetch'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(4, 8), vertical: context.responsiveHeight(4, 8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderSection(context, data.profile, customerDetailsCtrl.closeCustomerDashboard, isDark),
            SizedBox(height: context.responsiveHeight(14, 18)),
            _buildKpiRibbon(context, data, isDark),
            SizedBox(height: context.responsiveHeight(14, 18)),
            _buildTabSelector(context, isDark),
            SizedBox(height: context.responsiveHeight(14, 18)),
            _buildActiveTabContent(context, data, isDark),
          ],
        ),
      );
    });
  }

  // 1. TOP HEADER & PROFILE CARD
  Widget _buildHeaderSection(BuildContext context, CustomerProfile profile, VoidCallback onBack, bool isDark) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16, 20)),
      decoration: context.defaultDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, size: 20), tooltip: 'Back to Customers Table', splashRadius: 20),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryRed.withValues(alpha: 0.12),
            child: Text(
              profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'C',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.fullName,
                        style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        'ID: #${profile.id}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(profile.phone, style: context.captionStyle),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(profile.email, style: context.captionStyle),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(profile.loginLocation, style: context.captionStyle),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge(isActive: profile.isPhoneVerified, activeLabel: 'Phone Verified', inactiveLabel: 'Unverified Phone'),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Refresh Customer Data',
                splashRadius: 18,
                onPressed: controller.refreshDashboard,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRibbon(BuildContext context, CustomerDashboardData data, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 750;
        final double cardWidth = isMobile ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricTile(
                context,
                title: 'Wallet Balance',
                value: data.financialSummary.currentWalletBalance.toPrice(),
                subtitle: 'Credited: ${data.financialSummary.totalCredited.toPrice()}',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.statusGreenSuccess,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricTile(
                context,
                title: 'Loyalty Coins',
                value: '${data.financialSummary.loyaltyCoinsBalance} Pts',
                subtitle: 'Worth: ${data.financialSummary.loyaltyCoinsRupeeValue.toPrice()} (${data.financialSummary.loyaltyTier})',
                icon: Icons.stars_rounded,
                iconColor: AppColors.accentGoldAmber,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricTile(
                context,
                title: 'Total Grocery Orders',
                value: '${data.ordersMetrics.totalOrders}',
                subtitle: 'Delivered: ${data.ordersMetrics.deliveredOrders} | Active: ${data.ordersMetrics.activeOrders}',
                icon: Icons.shopping_bag_outlined,
                iconColor: AppColors.statusBlueInfo,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricTile(
                context,
                title: 'Active Live Cart',
                value: '${data.activeCart?.itemCount ?? 0} Items',
                subtitle: 'Value: ${(data.activeCart?.totalSalePrice ?? "0.00").toPrice()}',
                icon: Icons.shopping_cart_outlined,
                iconColor: AppColors.primaryRed,
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: context.defaultDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: context.captionStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.responsiveSize(15, 17),
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. TAB SELECTOR TOOLBAR
  Widget _buildTabSelector(BuildContext context, bool isDark) {
    final List<Map<String, dynamic>> tabs = [
      {'label': 'Overview & Telemetry', 'icon': Icons.badge_outlined},
      {'label': 'Preferences & Habits', 'icon': Icons.tune_rounded},
      {'label': 'Live Cart & Orders', 'icon': Icons.receipt_long_outlined},
      {'label': 'Wallet Ledger', 'icon': Icons.account_balance_wallet_outlined},
      {'label': 'Saved Wishlist', 'icon': Icons.favorite_border_rounded},
    ];

    return Obx(() {
      final int currentTab = controller.activeTabIndex.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceSubtleGray,
          borderRadius: context.responsiveRadius(8, 10),
          border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final bool isSelected = currentTab == index;
              final tab = tabs[index];

              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: InkWell(
                  onTap: () => controller.switchTab(index),
                  borderRadius: BorderRadius.circular(6),
                  mouseCursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: isSelected ? AppColors.primaryRed : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : (isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  // 4. ACTIVE TAB CONTENT
  Widget _buildActiveTabContent(BuildContext context, CustomerDashboardData data, bool isDark) {
    return Obx(() {
      switch (controller.activeTabIndex.value) {
        case 1:
          return _buildPreferencesTab(context, data, isDark);
        case 2:
          return _buildLiveCartAndOrdersTab(context, data, isDark);
        case 3:
          return _buildWalletLedgerTab(context, data, isDark);
        case 4:
          return _buildWishlistTab(context, data, isDark);
        case 0:
        default:
          return _buildOverviewTab(context, data, isDark);
      }
    });
  }

  // --- TAB 0: RE-ARCHITECTED OVERVIEW (CLEAN STRUCTURED TILES) ---
  Widget _buildOverviewTab(BuildContext context, CustomerDashboardData data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section A: Personal & Account Identity (Structured 4-Column Grid)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.person_pin_rounded, color: AppColors.primaryRed, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Personal & Account Identity', style: context.titleStyleActive.copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int columns = constraints.maxWidth < 650 ? 2 : (constraints.maxWidth < 1050 ? 3 : 4);
                  final double tileWidth = (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(context, label: 'Gender', value: data.profile.gender, icon: Icons.wc_outlined, isDark: isDark),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(context, label: 'Date of Birth', value: data.profile.dob, icon: Icons.cake_outlined, isDark: isDark),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Referral Code',
                          value: data.profile.referralCode,
                          icon: Icons.card_giftcard_outlined,
                          isDark: isDark,
                          isCopyable: true,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Referred By',
                          value: data.profile.referredBy,
                          icon: Icons.supervised_user_circle_outlined,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'KYC Status',
                          value: data.profile.kycStatus,
                          icon: Icons.verified_user_outlined,
                          isDark: isDark,
                          statusColor: AppColors.statusGreenSuccess,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Account Status',
                          value: data.profile.accountStatus,
                          icon: Icons.shield_outlined,
                          isDark: isDark,
                          statusColor: data.profile.accountStatus == 'ACTIVE' ? AppColors.statusGreenSuccess : AppColors.statusRedError,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Joined On',
                          value: EntityDetailsDialogHelper.formatDate(DateTime.tryParse(data.profile.createdAt)),
                          icon: Icons.calendar_today_outlined,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Last Login',
                          value: EntityDetailsDialogHelper.formatDate(DateTime.tryParse(data.profile.lastLoginAt)),
                          icon: Icons.login_outlined,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section B: Device & Application Telemetry
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.statusBlueInfo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.phone_android_rounded, color: AppColors.statusBlueInfo, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Device Hardware & App Telemetry', style: context.titleStyleActive.copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int columns = constraints.maxWidth < 650 ? 2 : (constraints.maxWidth < 1050 ? 3 : 5);
                  final double tileWidth = (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'App Version',
                          value: data.deviceMeta.appVersion,
                          icon: Icons.code_rounded,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Platform & OS',
                          value: '${data.deviceMeta.platform} (${data.deviceMeta.osVersion})',
                          icon: Icons.devices_outlined,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Device Model',
                          value: data.deviceMeta.deviceModel,
                          icon: Icons.smartphone_rounded,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Push Notifications',
                          value: data.deviceMeta.pushNotificationsEnabled ? 'Enabled' : 'Disabled',
                          icon: Icons.notifications_active_outlined,
                          isDark: isDark,
                          statusColor: data.deviceMeta.pushNotificationsEnabled ? AppColors.statusGreenSuccess : AppColors.statusAmberWarning,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Location Permission',
                          value: data.deviceMeta.locationPermissionGranted ? 'Granted' : 'Denied',
                          icon: Icons.my_location_rounded,
                          isDark: isDark,
                          statusColor: data.deviceMeta.locationPermissionGranted ? AppColors.statusGreenSuccess : AppColors.statusRedError,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section C: Registered Delivery Addresses
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.accentGoldAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.accentGoldAmber, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Registered Delivery Addresses (${data.addresses.length})', style: context.titleStyleActive.copyWith(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (data.addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No delivery addresses configured for this customer.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 750;
                    final double cardWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: data.addresses
                          .map((address) {
                            return Container(
                              width: cardWidth,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: address.isPrimary
                                      ? AppColors.primaryRed
                                      : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                                  width: address.isPrimary ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            address.isPrimary ? Icons.home_rounded : Icons.business_rounded,
                                            color: address.isPrimary ? AppColors.primaryRed : Colors.grey,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${address.type} Address',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: address.isPrimary
                                                  ? AppColors.primaryRed
                                                  : (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (address.isPrimary)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryRed.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(color: AppColors.primaryRed, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(address.completeAddress, style: const TextStyle(fontSize: 12.5, height: 1.4)),
                                  const SizedBox(height: 8),
                                  const Divider(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${address.receiverName} (${address.receiverPhone})', style: context.captionStyle),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          })
                          .toList(growable: false),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: RE-ARCHITECTED PREFERENCES (CLEAN METRICS & INSTRUCTIONS) ---
  Widget _buildPreferencesTab(BuildContext context, CustomerDashboardData data, bool isDark) {
    final prefs = data.preferences;
    final support = data.support;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section A: Shopping Habits (Cardlet Grid)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.accentGoldAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.shopping_basket_rounded, color: AppColors.accentGoldAmber, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Grocery Habits & Purchase Behavior', style: context.titleStyleActive.copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int columns = constraints.maxWidth < 650 ? 2 : (constraints.maxWidth < 1050 ? 3 : 5);
                  final double tileWidth = (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Dietary Preference',
                          value: prefs.foodPreference,
                          icon: Icons.restaurant_menu_rounded,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Delivery Mode',
                          value: prefs.preferredDeliveryType,
                          icon: Icons.local_shipping_outlined,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Preferred Slot',
                          value: data.ordersMetrics.favoriteDeliverySlot,
                          icon: Icons.access_time_rounded,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Payment Mode',
                          value: data.ordersMetrics.favoritePaymentMode,
                          icon: Icons.payment_rounded,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildInfoCardlet(
                          context,
                          label: 'Repeat Cycle',
                          value: 'Every ${data.ordersMetrics.repeatOrderFrequencyDays} Days',
                          icon: Icons.repeat_rounded,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dispatch Delivery Instructions Call out
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.statusBlueInfo, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PERMANENT DELIVERY INSTRUCTIONS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(prefs.deliveryInstructions.withDashFallback, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'FREQUENTLY PURCHASED CATEGORIES:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prefs.frequentlyBoughtCategories.map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.categoryName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '${c.ordersCount}x',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section B: Recently Viewed Products & Vouchers
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 850;
            final double colWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: colWidth,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: context.defaultDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recently Viewed Products', style: context.titleStyleActive.copyWith(fontSize: 14)),
                        const SizedBox(height: 12),
                        if (prefs.recentlyViewed.isEmpty)
                          const Text('No recently viewed items.', style: TextStyle(fontSize: 12, color: Colors.grey))
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: prefs.recentlyViewed.length,
                            separatorBuilder: (_, _) => const Divider(height: 12),
                            itemBuilder: (context, idx) {
                              final p = prefs.recentlyViewed[idx];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                                ),
                                title: Text(p.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  'SKU: ${p.itemCode} | Viewed: ${EntityDetailsDialogHelper.formatDate(DateTime.tryParse(p.viewedAt))}',
                                  style: context.captionStyle,
                                ),
                                trailing: Text(
                                  p.price.toPrice(),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: colWidth,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: context.defaultDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vouchers & Coupon Analytics', style: context.titleStyleActive.copyWith(fontSize: 14)),
                        const SizedBox(height: 12),
                        if (prefs.availableVouchers.isNotEmpty) ...[
                          const Text(
                            'AVAILABLE VOUCHERS:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: prefs.availableVouchers.map((v) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.statusGreenSuccess.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.statusGreenSuccess.withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.voucherCode,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.statusGreenSuccess),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(v.title, style: context.captionStyle),
                                      ],
                                    ),
                                    Text('Min Cart: ${v.minCartValue.toPrice()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const Text(
                          'REDEEMED COUPON HISTORY:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: prefs.appliedCoupons.map((c) {
                            return Chip(
                              label: Text(
                                '${c.couponCode} (Saved: ${c.discountAvailed.toPrice()})',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                              ),
                              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.08),
                              side: BorderSide(color: AppColors.primaryRed.withValues(alpha: 0.25)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Section C: Customer Support & Tickets
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.statusGreenSuccess.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.support_agent_rounded, color: AppColors.statusGreenSuccess, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Customer Support Tickets (${support.totalTickets})', style: context.titleStyleActive.copyWith(fontSize: 14)),
                    ],
                  ),
                  Text(
                    'Open: ${support.openTickets} | Resolved: ${support.resolvedTickets}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusGreenSuccess),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (support.recentTickets.isEmpty)
                const Text('No support complaints or tickets raised.', style: TextStyle(fontSize: 12, color: Colors.grey))
              else
                Column(
                  children: support.recentTickets.map((t) {
                    final bool isResolved = t.status == 'RESOLVED';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.headset_mic_outlined, color: isResolved ? AppColors.statusGreenSuccess : AppColors.statusRedError, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('${t.ticketId}: ${t.subject}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (t.priority == 'HIGH' ? AppColors.statusRedError : AppColors.accentGoldAmber).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        t.priority,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: t.priority == 'HIGH' ? AppColors.statusRedError : AppColors.accentGoldAmber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(t.resolutionNotes ?? 'Ticket recorded on ${t.createdAt}', style: context.captionStyle),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isResolved ? AppColors.statusGreenSuccess : AppColors.statusAmberWarning).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isResolved ? AppColors.statusGreenSuccess : AppColors.statusAmberWarning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: LIVE CART & DETAILED ORDERS HISTORY ---
  Widget _buildLiveCartAndOrdersTab(BuildContext context, CustomerDashboardData data, bool isDark) {
    final cart = data.activeCart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Active Cart with Items List
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryRed, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Customer Live Active Cart (${cart?.itemCount ?? 0} Items)', style: context.titleStyleActive.copyWith(fontSize: 14)),
                    ],
                  ),
                  if (cart != null)
                    Text(
                      'Total: ${cart.totalSalePrice.toPrice()} | MRP: ${cart.totalMrp.toPrice()} | Saved: ${cart.savings.toPrice()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.statusGreenSuccess),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (cart == null || cart.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Customer cart is currently empty.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const Icon(Icons.shopping_basket_outlined, size: 24),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.quantity}x',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryRed),
                              ),
                            ),
                      title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(
                        'SKU: ${item.itemCode} | Qty: ${item.quantity} | Unit: ${item.unitPrice.toPrice()}',
                        style: context.captionStyle,
                      ),
                      trailing: Text(item.totalPrice.toPrice(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Recent Orders with Order Item Breakdown
        Container(
          padding: const EdgeInsets.all(18),
          decoration: context.defaultDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.statusBlueInfo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.statusBlueInfo, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Grocery Orders History & Item Breakdowns', style: context.titleStyleActive.copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 14),
              if (data.recentOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No orders found for this customer.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.recentOrders.length,
                  separatorBuilder: (_, _) => const Divider(height: 14),
                  itemBuilder: (context, index) {
                    final order = data.recentOrders[index];
                    final bool isDelivered = order.orderStatus == 'DELIVERED';
                    final bool isCancelled = order.orderStatus == 'CANCELLED';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        (isDelivered
                                                ? AppColors.statusGreenSuccess
                                                : (isCancelled ? AppColors.statusRedError : AppColors.accentGoldAmber))
                                            .withValues(alpha: 0.1),
                                    child: Icon(
                                      isDelivered
                                          ? Icons.check_circle_outline_rounded
                                          : (isCancelled ? Icons.cancel_outlined : Icons.delivery_dining_outlined),
                                      size: 16,
                                      color: isDelivered
                                          ? AppColors.statusGreenSuccess
                                          : (isCancelled ? AppColors.statusRedError : AppColors.accentGoldAmber),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Text('(${EntityDetailsDialogHelper.formatDate(DateTime.tryParse(order.orderDate))})', style: context.captionStyle),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    order.totalAmount.toPrice(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryRed),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          (isDelivered
                                                  ? AppColors.statusGreenSuccess
                                                  : (isCancelled ? AppColors.statusRedError : AppColors.accentGoldAmber))
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order.orderStatus,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDelivered
                                            ? AppColors.statusGreenSuccess
                                            : (isCancelled ? AppColors.statusRedError : AppColors.accentGoldAmber),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text('Slot: ${order.deliverySlot}', style: context.captionStyle),
                              Text('Payment: ${order.paymentMode} (${order.paymentStatus})', style: context.captionStyle),
                              if (order.couponCode != null) Text('Coupon: ${order.couponCode}', style: context.captionStyle),
                              if (order.deliveryPersonName != null) Text('Rider: ${order.deliveryPersonName}', style: context.captionStyle),
                              if (order.cancellationReason != null)
                                Text(
                                  'Cancelled Reason: ${order.cancellationReason}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.statusRedError, fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                          if (order.orderItems.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 8),
                            Column(
                              children: order.orderItems.map((oi) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${oi.quantity}x ${oi.itemName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      Text(oi.totalPrice.toPrice(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 3: WALLET LEDGER ---
  Widget _buildWalletLedgerTab(BuildContext context, CustomerDashboardData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: context.defaultDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wallet Transactions & Ledger History', style: context.titleStyleActive.copyWith(fontSize: 14)),
              Text(
                'Available Balance: ${data.financialSummary.currentWalletBalance.toPrice()}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.statusGreenSuccess),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No wallet transactions recorded.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.recentTransactions.length,
              separatorBuilder: (_, _) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final txn = data.recentTransactions[index];
                final bool isCredit = txn.type == 'CREDIT';

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: (isCredit ? AppColors.statusGreenSuccess : AppColors.statusRedError).withValues(alpha: 0.1),
                    child: Icon(
                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 16,
                      color: isCredit ? AppColors.statusGreenSuccess : AppColors.statusRedError,
                    ),
                  ),
                  title: Text(txn.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(
                    '${EntityDetailsDialogHelper.formatDate(DateTime.tryParse(txn.createdAt))} | Ref: ${txn.txnId}${txn.orderId != null ? " | Order: ${txn.orderId}" : ""}',
                    style: context.captionStyle,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isCredit ? "+" : "-"}${txn.amount.toPrice()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isCredit ? AppColors.statusGreenSuccess : AppColors.statusRedError,
                        ),
                      ),
                      Text('Bal: ${txn.closingBalance.toPrice()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- TAB 4: SAVED WISH-LIST ---
  Widget _buildWishlistTab(BuildContext context, CustomerDashboardData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: context.defaultDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Saved Wishlist (${data.wishlistItems.length})', style: context.titleStyleActive.copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          if (data.wishlistItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Customer wishlist is empty.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.wishlistItems
                  .map((item) {
                    return Container(
                      width: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorWidget: (_, _, _) => const Center(child: Icon(Icons.broken_image_rounded, size: 32, color: Colors.grey)),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          AppTableCellText(text: item.itemName, maxWidth: 240, maxLines: 2),
                          const SizedBox(height: 4),
                          Text('SKU: ${item.itemCode}', style: context.captionStyle),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(item.salePrice.toPrice(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (item.mrp != item.salePrice) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      item.mrp.toPrice(),
                                      style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey),
                                    ),
                                  ],
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (item.inStock ? AppColors.statusGreenSuccess : AppColors.statusRedError).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.inStock ? 'IN STOCK (${item.availableStock})' : 'OUT OF STOCK',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: item.inStock ? AppColors.statusGreenSuccess : AppColors.statusRedError,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCardlet(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    Color? statusColor,
    bool isCopyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: statusColor ?? (isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                isCopyable
                    ? SelectableText(
                        value.withDashFallback,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: statusColor ?? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                        ),
                      )
                    : Text(
                        value.withDashFallback,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: statusColor ?? (isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
