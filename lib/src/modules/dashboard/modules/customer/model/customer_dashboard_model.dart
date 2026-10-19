import 'package:flutter/foundation.dart';

@immutable
class CustomerDashboardModel {
  final bool status;
  final String message;
  final CustomerDashboardData? data;

  const CustomerDashboardModel({required this.status, required this.message, this.data});

  factory CustomerDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CustomerDashboardModel(status: false, message: 'Empty response', data: null);
    }
    return CustomerDashboardModel(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic> ? CustomerDashboardData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

@immutable
class CustomerDashboardData {
  final CustomerProfile profile;
  final DeviceAppMeta deviceMeta;
  final FinancialWalletSummary financialSummary;
  final List<WalletTransactionItem> recentTransactions;
  final OrdersMetrics ordersMetrics;
  final List<CustomerOrderSummary> recentOrders;
  final List<CustomerAddressItem> addresses;
  final CustomerActiveCart? activeCart;
  final List<WishlistItem> wishlistItems;
  final BehaviorAndPreferences preferences;
  final CustomerSupportMeta support;

  const CustomerDashboardData({
    required this.profile,
    required this.deviceMeta,
    required this.financialSummary,
    required this.recentTransactions,
    required this.ordersMetrics,
    required this.recentOrders,
    required this.addresses,
    this.activeCart,
    required this.wishlistItems,
    required this.preferences,
    required this.support,
  });

  factory CustomerDashboardData.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardData(
      profile: CustomerProfile.fromJson(json['profile'] as Map<String, dynamic>?),
      deviceMeta: DeviceAppMeta.fromJson(json['device_and_app_meta'] as Map<String, dynamic>?),
      financialSummary: FinancialWalletSummary.fromJson(json['financial_and_wallet_summary'] as Map<String, dynamic>?),
      recentTransactions:
          (json['recent_wallet_transactions'] as List<dynamic>?)
              ?.map((e) => WalletTransactionItem.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      ordersMetrics: OrdersMetrics.fromJson(json['orders_metrics'] as Map<String, dynamic>?),
      recentOrders:
          (json['recent_orders'] as List<dynamic>?)?.map((e) => CustomerOrderSummary.fromJson(e as Map<String, dynamic>)).toList(growable: false) ??
          const [],
      addresses:
          (json['addresses'] as List<dynamic>?)?.map((e) => CustomerAddressItem.fromJson(e as Map<String, dynamic>)).toList(growable: false) ??
          const [],
      activeCart: json['active_cart'] is Map<String, dynamic> ? CustomerActiveCart.fromJson(json['active_cart'] as Map<String, dynamic>) : null,
      wishlistItems:
          (json['saved_wishlist_items'] as List<dynamic>?)?.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>)).toList(growable: false) ??
          const [],
      preferences: BehaviorAndPreferences.fromJson(json['behavior_and_preferences'] as Map<String, dynamic>?),
      support: CustomerSupportMeta.fromJson(json['customer_support_and_tickets'] as Map<String, dynamic>?),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. PROFILE & DEVICE Info
// ---------------------------------------------------------------------------
@immutable
class CustomerProfile {
  final int id;
  final String fullName;
  final String phone;
  final String email;
  final String gender;
  final String dob;
  final String referralCode;
  final String referredBy;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String accountStatus;
  final String kycStatus;
  final String profileImageUrl;
  final String loginIp;
  final String loginLocation;
  final String lastLoginAt;
  final String createdAt;

  const CustomerProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
    required this.referralCode,
    required this.referredBy,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.accountStatus,
    required this.kycStatus,
    required this.profileImageUrl,
    required this.loginIp,
    required this.loginLocation,
    required this.lastLoginAt,
    required this.createdAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CustomerProfile(
        id: 0,
        fullName: '—',
        phone: '—',
        email: '—',
        gender: '—',
        dob: '—',
        referralCode: '—',
        referredBy: '—',
        isPhoneVerified: false,
        isEmailVerified: false,
        accountStatus: 'INACTIVE',
        kycStatus: 'PENDING',
        profileImageUrl: '',
        loginIp: '—',
        loginLocation: '—',
        lastLoginAt: '—',
        createdAt: '—',
      );
    }
    return CustomerProfile(
      id: _parseInt(json['id']),
      fullName: json['full_name']?.toString() ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      phone: json['phone']?.toString() ?? '—',
      email: json['email']?.toString() ?? '—',
      gender: json['gender']?.toString() ?? '—',
      dob: json['dob']?.toString() ?? '—',
      referralCode: json['referral_code']?.toString() ?? '—',
      referredBy: json['referred_by']?.toString() ?? '—',
      isPhoneVerified: json['is_phone_verified'] == true || json['is_phone_verified'] == 1,
      isEmailVerified: json['is_email_verified'] == true || json['is_email_verified'] == 1,
      accountStatus: json['account_status']?.toString() ?? 'ACTIVE',
      kycStatus: json['kyc_status']?.toString() ?? 'VERIFIED',
      profileImageUrl: json['profile_image_url']?.toString() ?? '',
      loginIp: json['login_ip']?.toString() ?? '—',
      loginLocation: json['login_location']?.toString() ?? '—',
      lastLoginAt: json['last_login_at']?.toString() ?? '—',
      createdAt: json['created_at']?.toString() ?? '—',
    );
  }
}

@immutable
class DeviceAppMeta {
  final String appVersion;
  final String platform;
  final String osVersion;
  final String deviceModel;
  final String appLanguage;
  final bool pushNotificationsEnabled;
  final bool locationPermissionGranted;

  const DeviceAppMeta({
    required this.appVersion,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.appLanguage,
    required this.pushNotificationsEnabled,
    required this.locationPermissionGranted,
  });

  factory DeviceAppMeta.fromJson(Map<String, dynamic>? json) {
    return DeviceAppMeta(
      appVersion: json?['app_version']?.toString() ?? '—',
      platform: json?['platform']?.toString() ?? '—',
      osVersion: json?['os_version']?.toString() ?? '—',
      deviceModel: json?['device_model']?.toString() ?? '—',
      appLanguage: json?['app_language']?.toString() ?? 'English',
      pushNotificationsEnabled: json?['push_notifications_enabled'] == true,
      locationPermissionGranted: json?['location_permission_granted'] == true,
    );
  }
}

// ---------------------------------------------------------------------------
// 2. FINANCIAL, WALLET & TRANSACTIONS
// ---------------------------------------------------------------------------
@immutable
class FinancialWalletSummary {
  final String currentWalletBalance;
  final String totalCredited;
  final String totalDebited;
  final String totalCashbackEarned;
  final int loyaltyCoinsBalance;
  final String loyaltyCoinsRupeeValue;
  final String loyaltyTier;
  final String totalCompletedOrdersValue;
  final String totalRefundProcessed;
  final String averageOrderValue;

  const FinancialWalletSummary({
    required this.currentWalletBalance,
    required this.totalCredited,
    required this.totalDebited,
    required this.totalCashbackEarned,
    required this.loyaltyCoinsBalance,
    required this.loyaltyCoinsRupeeValue,
    required this.loyaltyTier,
    required this.totalCompletedOrdersValue,
    required this.totalRefundProcessed,
    required this.averageOrderValue,
  });

  factory FinancialWalletSummary.fromJson(Map<String, dynamic>? json) {
    return FinancialWalletSummary(
      currentWalletBalance: json?['current_wallet_balance']?.toString() ?? '0.00',
      totalCredited: json?['total_credited']?.toString() ?? '0.00',
      totalDebited: json?['total_debited']?.toString() ?? '0.00',
      totalCashbackEarned: json?['total_cashback_earned']?.toString() ?? '0.00',
      loyaltyCoinsBalance: _parseInt(json?['loyalty_coins_balance']),
      loyaltyCoinsRupeeValue: json?['loyalty_coins_rupee_value']?.toString() ?? '0.00',
      loyaltyTier: json?['loyalty_tier']?.toString() ?? 'Standard',
      totalCompletedOrdersValue: json?['total_completed_orders_value']?.toString() ?? '0.00',
      totalRefundProcessed: json?['total_refund_processed']?.toString() ?? '0.00',
      averageOrderValue: json?['average_order_value']?.toString() ?? '0.00',
    );
  }
}

@immutable
class WalletTransactionItem {
  final String txnId;
  final String? orderId;
  final String type;
  final String amount;
  final String closingBalance;
  final String mode;
  final String description;
  final String status;
  final String createdAt;

  const WalletTransactionItem({
    required this.txnId,
    this.orderId,
    required this.type,
    required this.amount,
    required this.closingBalance,
    required this.mode,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    return WalletTransactionItem(
      txnId: json['txn_id']?.toString() ?? '—',
      orderId: json['order_id']?.toString(),
      type: json['type']?.toString() ?? 'DEBIT',
      amount: json['amount']?.toString() ?? '0.00',
      closingBalance: json['closing_balance']?.toString() ?? '0.00',
      mode: json['mode']?.toString() ?? '—',
      description: json['description']?.toString() ?? '—',
      status: json['status']?.toString() ?? 'SUCCESS',
      createdAt: json['created_at']?.toString() ?? '—',
    );
  }
}

// ---------------------------------------------------------------------------
// 3. ORDERS & ITEM DETAILS
// ---------------------------------------------------------------------------
@immutable
class OrdersMetrics {
  final int totalOrders;
  final int deliveredOrders;
  final int activeOrders;
  final int cancelledOrders;
  final int returnedItems;
  final String favoriteDeliverySlot;
  final String favoritePaymentMode;
  final int repeatOrderFrequencyDays;

  const OrdersMetrics({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.activeOrders,
    required this.cancelledOrders,
    required this.returnedItems,
    required this.favoriteDeliverySlot,
    required this.favoritePaymentMode,
    required this.repeatOrderFrequencyDays,
  });

  factory OrdersMetrics.fromJson(Map<String, dynamic>? json) {
    return OrdersMetrics(
      totalOrders: _parseInt(json?['total_orders_count']),
      deliveredOrders: _parseInt(json?['delivered_orders_count']),
      activeOrders: _parseInt(json?['active_in_transit_orders_count']),
      cancelledOrders: _parseInt(json?['cancelled_orders_count']),
      returnedItems: _parseInt(json?['returned_items_count']),
      favoriteDeliverySlot: json?['favorite_delivery_slot']?.toString() ?? '—',
      favoritePaymentMode: json?['favorite_payment_mode']?.toString() ?? '—',
      repeatOrderFrequencyDays: _parseInt(json?['repeat_order_frequency_days'], defaultValue: 0),
    );
  }
}

@immutable
class CustomerOrderSummary {
  final int orderId;
  final String orderNumber;
  final String orderDate;
  final String deliverySlot;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMode;
  final int itemCount;
  final String subtotal;
  final String discount;
  final String deliveryCharges;
  final String totalAmount;
  final String? couponCode;
  final String shippingAddressLabel;
  final String? deliveryPersonName;
  final String? deliveredAt;
  final String? cancellationReason;
  final List<OrderItemDetail> orderItems;

  const CustomerOrderSummary({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.deliverySlot,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMode,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharges,
    required this.totalAmount,
    this.couponCode,
    required this.shippingAddressLabel,
    this.deliveryPersonName,
    this.deliveredAt,
    this.cancellationReason,
    required this.orderItems,
  });

  factory CustomerOrderSummary.fromJson(Map<String, dynamic> json) {
    return CustomerOrderSummary(
      orderId: _parseInt(json['order_id']),
      orderNumber: json['order_number']?.toString() ?? '—',
      orderDate: json['order_date']?.toString() ?? '—',
      deliverySlot: json['delivery_slot']?.toString() ?? '—',
      orderStatus: json['order_status']?.toString() ?? 'DELIVERED',
      paymentStatus: json['payment_status']?.toString() ?? 'PAID',
      paymentMode: json['payment_mode']?.toString() ?? '—',
      itemCount: _parseInt(json['item_count']),
      subtotal: json['subtotal']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      deliveryCharges: json['delivery_charges']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      couponCode: json['coupon_code']?.toString(),
      shippingAddressLabel: json['shipping_address_label']?.toString() ?? 'Home',
      deliveryPersonName: json['delivery_person_name']?.toString(),
      deliveredAt: json['delivered_at']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      orderItems:
          (json['order_items'] as List<dynamic>?)?.map((e) => OrderItemDetail.fromJson(e as Map<String, dynamic>)).toList(growable: false) ??
          const [],
    );
  }
}

@immutable
class OrderItemDetail {
  final String itemCode;
  final String itemName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;

  const OrderItemDetail({required this.itemCode, required this.itemName, required this.quantity, required this.unitPrice, required this.totalPrice});

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      itemCode: json['item_code']?.toString() ?? '—',
      itemName: json['item_name']?.toString() ?? '—',
      quantity: _parseInt(json['quantity'], defaultValue: 1),
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalPrice: json['total_price']?.toString() ?? '0.00',
    );
  }
}

// ---------------------------------------------------------------------------
// 4. ADDRESSES & CART
// ---------------------------------------------------------------------------
@immutable
class CustomerAddressItem {
  final int addressId;
  final String type;
  final bool isPrimary;
  final String receiverName;
  final String receiverPhone;
  final String completeAddress;

  const CustomerAddressItem({
    required this.addressId,
    required this.type,
    required this.isPrimary,
    required this.receiverName,
    required this.receiverPhone,
    required this.completeAddress,
  });

  factory CustomerAddressItem.fromJson(Map<String, dynamic> json) {
    final house = json['house_flat_no']?.toString() ?? '';
    final street = json['street_landmark']?.toString() ?? '';
    final city = json['city']?.toString() ?? '';
    final state = json['state']?.toString() ?? '';
    final pincode = json['pincode']?.toString() ?? '';

    final parts = [house, street, city, state, pincode].where((p) => p.trim().isNotEmpty).toList(growable: false);

    return CustomerAddressItem(
      addressId: _parseInt(json['address_id']),
      type: json['type']?.toString() ?? 'Home',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
      receiverName: json['receiver_name']?.toString() ?? '—',
      receiverPhone: json['receiver_phone']?.toString() ?? '—',
      completeAddress: parts.isNotEmpty ? parts.join(', ') : '—',
    );
  }
}

@immutable
class CustomerActiveCart {
  final int itemCount;
  final String totalMrp;
  final String totalSalePrice;
  final String savings;
  final String lastUpdated;
  final List<CartProductItem> items;

  const CustomerActiveCart({
    required this.itemCount,
    required this.totalMrp,
    required this.totalSalePrice,
    required this.savings,
    required this.lastUpdated,
    required this.items,
  });

  factory CustomerActiveCart.fromJson(Map<String, dynamic> json) {
    return CustomerActiveCart(
      itemCount: _parseInt(json['item_count']),
      totalMrp: json['cart_total_mrp']?.toString() ?? '0.00',
      totalSalePrice: json['cart_total_sale_price']?.toString() ?? '0.00',
      savings: json['cart_savings']?.toString() ?? '0.00',
      lastUpdated: json['last_updated']?.toString() ?? '—',
      items: (json['items'] as List<dynamic>?)?.map((e) => CartProductItem.fromJson(e as Map<String, dynamic>)).toList(growable: false) ?? const [],
    );
  }
}

@immutable
class CartProductItem {
  final String itemCode;
  final String itemName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final String? imageUrl;

  const CartProductItem({
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.imageUrl,
  });

  factory CartProductItem.fromJson(Map<String, dynamic> json) {
    return CartProductItem(
      itemCode: json['item_code']?.toString() ?? '—',
      itemName: json['item_name']?.toString() ?? '—',
      quantity: _parseInt(json['quantity'], defaultValue: 1),
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalPrice: json['total_price']?.toString() ?? '0.00',
      imageUrl: json['image_url']?.toString(),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. WISHLIST, PREFERENCES & SUPPORT TICKETS
// ---------------------------------------------------------------------------
@immutable
class WishlistItem {
  final String itemCode;
  final String itemName;
  final String mrp;
  final String salePrice;
  final bool inStock;
  final int availableStock;
  final String? imageUrl;

  const WishlistItem({
    required this.itemCode,
    required this.itemName,
    required this.mrp,
    required this.salePrice,
    required this.inStock,
    required this.availableStock,
    this.imageUrl,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      itemCode: json['item_code']?.toString() ?? '—',
      itemName: json['item_name']?.toString() ?? '—',
      mrp: json['mrp']?.toString() ?? '0.00',
      salePrice: json['sale_price']?.toString() ?? '0.00',
      inStock: json['in_stock'] == true,
      availableStock: _parseInt(json['available_stock']),
      imageUrl: json['image_url']?.toString(),
    );
  }
}

@immutable
class BehaviorAndPreferences {
  final String foodPreference;
  final String preferredDeliveryType;
  final String deliveryInstructions;
  final List<CategoryFrequency> frequentlyBoughtCategories;
  final List<RecentlyViewedProduct> recentlyViewed;
  final List<AppliedCouponItem> appliedCoupons;
  final List<AvailableVoucherItem> availableVouchers;

  const BehaviorAndPreferences({
    required this.foodPreference,
    required this.preferredDeliveryType,
    required this.deliveryInstructions,
    required this.frequentlyBoughtCategories,
    required this.recentlyViewed,
    required this.appliedCoupons,
    required this.availableVouchers,
  });

  factory BehaviorAndPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BehaviorAndPreferences(
        foodPreference: '—',
        preferredDeliveryType: '—',
        deliveryInstructions: '—',
        frequentlyBoughtCategories: [],
        recentlyViewed: [],
        appliedCoupons: [],
        availableVouchers: [],
      );
    }
    return BehaviorAndPreferences(
      foodPreference: json['food_preference']?.toString() ?? '—',
      preferredDeliveryType: json['preferred_delivery_type']?.toString() ?? '—',
      deliveryInstructions: json['delivery_instructions']?.toString() ?? '—',
      frequentlyBoughtCategories:
          (json['frequently_bought_categories'] as List<dynamic>?)
              ?.map((e) => CategoryFrequency.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      recentlyViewed:
          (json['recently_viewed_products'] as List<dynamic>?)
              ?.map((e) => RecentlyViewedProduct.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      appliedCoupons:
          (json['applied_coupons_history'] as List<dynamic>?)
              ?.map((e) => AppliedCouponItem.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      availableVouchers:
          (json['available_vouchers'] as List<dynamic>?)
              ?.map((e) => AvailableVoucherItem.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
    );
  }
}

@immutable
class CategoryFrequency {
  final String categoryName;
  final int ordersCount;

  const CategoryFrequency({required this.categoryName, required this.ordersCount});

  factory CategoryFrequency.fromJson(Map<String, dynamic> json) {
    return CategoryFrequency(categoryName: json['category_name']?.toString() ?? '—', ordersCount: _parseInt(json['orders_count']));
  }
}

@immutable
class RecentlyViewedProduct {
  final String itemCode;
  final String itemName;
  final String price;
  final String viewedAt;

  const RecentlyViewedProduct({required this.itemCode, required this.itemName, required this.price, required this.viewedAt});

  factory RecentlyViewedProduct.fromJson(Map<String, dynamic> json) {
    return RecentlyViewedProduct(
      itemCode: json['item_code']?.toString() ?? '—',
      itemName: json['item_name']?.toString() ?? '—',
      price: json['price']?.toString() ?? '0.00',
      viewedAt: json['viewed_at']?.toString() ?? '—',
    );
  }
}

@immutable
class AppliedCouponItem {
  final String couponCode;
  final String discountAvailed;
  final String usedAt;

  const AppliedCouponItem({required this.couponCode, required this.discountAvailed, required this.usedAt});

  factory AppliedCouponItem.fromJson(Map<String, dynamic> json) {
    return AppliedCouponItem(
      couponCode: json['coupon_code']?.toString() ?? '—',
      discountAvailed: json['discount_availed']?.toString() ?? '0.00',
      usedAt: json['used_at']?.toString() ?? '—',
    );
  }
}

@immutable
class AvailableVoucherItem {
  final String voucherCode;
  final String title;
  final String expiryDate;
  final String minCartValue;

  const AvailableVoucherItem({required this.voucherCode, required this.title, required this.expiryDate, required this.minCartValue});

  factory AvailableVoucherItem.fromJson(Map<String, dynamic> json) {
    return AvailableVoucherItem(
      voucherCode: json['voucher_code']?.toString() ?? '—',
      title: json['title']?.toString() ?? '—',
      expiryDate: json['expiry_date']?.toString() ?? '—',
      minCartValue: json['min_cart_value']?.toString() ?? '0.00',
    );
  }
}

@immutable
class CustomerSupportMeta {
  final int totalTickets;
  final int openTickets;
  final int resolvedTickets;
  final List<SupportTicketItem> recentTickets;

  const CustomerSupportMeta({required this.totalTickets, required this.openTickets, required this.resolvedTickets, required this.recentTickets});

  factory CustomerSupportMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CustomerSupportMeta(totalTickets: 0, openTickets: 0, resolvedTickets: 0, recentTickets: []);
    }
    return CustomerSupportMeta(
      totalTickets: _parseInt(json['total_tickets']),
      openTickets: _parseInt(json['open_tickets']),
      resolvedTickets: _parseInt(json['resolved_tickets']),
      recentTickets:
          (json['recent_tickets'] as List<dynamic>?)?.map((e) => SupportTicketItem.fromJson(e as Map<String, dynamic>)).toList(growable: false) ??
          const [],
    );
  }
}

@immutable
class SupportTicketItem {
  final String ticketId;
  final String subject;
  final String status;
  final String priority;
  final String createdAt;
  final String? resolutionNotes;

  const SupportTicketItem({
    required this.ticketId,
    required this.subject,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.resolutionNotes,
  });

  factory SupportTicketItem.fromJson(Map<String, dynamic> json) {
    return SupportTicketItem(
      ticketId: json['ticket_id']?.toString() ?? '—',
      subject: json['subject']?.toString() ?? '—',
      status: json['status']?.toString() ?? 'OPEN',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      createdAt: json['created_at']?.toString() ?? '—',
      resolutionNotes: json['resolution_notes']?.toString(),
    );
  }
}

int _parseInt(dynamic val, {int defaultValue = 0}) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString().trim()) ?? defaultValue;
}
