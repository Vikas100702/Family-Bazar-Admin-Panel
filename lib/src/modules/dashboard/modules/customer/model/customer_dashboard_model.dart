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
  final FinancialWalletSummary financialSummary;
  final List<WalletTransactionItem> recentTransactions;
  final OrdersMetrics ordersMetrics;
  final List<CustomerOrderSummary> recentOrders;
  final List<CustomerAddressItem> addresses;
  final CustomerActiveCart? activeCart;
  final List<WishlistItem> wishlistItems;

  const CustomerDashboardData({
    required this.profile,
    required this.financialSummary,
    required this.recentTransactions,
    required this.ordersMetrics,
    required this.recentOrders,
    required this.addresses,
    this.activeCart,
    required this.wishlistItems,
  });

  factory CustomerDashboardData.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardData(
      profile: CustomerProfile.fromJson(json['profile'] as Map<String, dynamic>?),
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
    );
  }
}

@immutable
class CustomerProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phone;
  final String email;
  final String referralCode;
  final String referredBy;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String softDelete;
  final String createdAt;
  final String updatedAt;
  final String lastLoginAt;
  final String firebaseToken;
  final String loginLocation;

  const CustomerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.referralCode,
    required this.referredBy,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.softDelete,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    required this.firebaseToken,
    required this.loginLocation,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CustomerProfile(
        id: 0,
        firstName: '—',
        lastName: '',
        fullName: '—',
        phone: '—',
        email: '—',
        referralCode: '—',
        referredBy: '—',
        isPhoneVerified: false,
        isEmailVerified: false,
        softDelete: '0',
        createdAt: '—',
        updatedAt: '—',
        lastLoginAt: '—',
        firebaseToken: '',
        loginLocation: '—',
      );
    }

    final fName = json['first_name']?.toString() ?? '';
    final lName = json['last_name']?.toString() ?? '';
    final computedFullName = json['full_name']?.toString() ?? '$fName $lName'.trim();

    return CustomerProfile(
      id: _parseInt(json['id']),
      firstName: fName.isNotEmpty ? fName : '—',
      lastName: lName,
      fullName: computedFullName.isNotEmpty ? computedFullName : 'Unnamed Customer',
      phone: json['phone']?.toString() ?? '—',
      email: json['email']?.toString() ?? '—',
      referralCode: json['referral_code']?.toString() ?? '—',
      referredBy: json['referred_by']?.toString() ?? '—',
      isPhoneVerified: json['is_phone_verified'] == true || json['is_phone_verified'] == 1,
      isEmailVerified: json['is_email_verified'] == true || json['is_email_verified'] == 1,
      softDelete: json['soft_delete']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '—',
      updatedAt: json['updated_at']?.toString() ?? '—',
      lastLoginAt: json['last_login_at']?.toString() ?? '—',
      firebaseToken: json['firebase_token']?.toString() ?? '',
      loginLocation: json['login_location']?.toString() ?? '—',
    );
  }
}

@immutable
class FinancialWalletSummary {
  final String currentWalletBalance;
  final String totalCredited;
  final String totalDebited;
  final int loyaltyCoinsBalance;
  final String loyaltyCoinsRupeeValue;
  final String totalCompletedOrdersValue;
  final String averageOrderValue;

  const FinancialWalletSummary({
    required this.currentWalletBalance,
    required this.totalCredited,
    required this.totalDebited,
    required this.loyaltyCoinsBalance,
    required this.loyaltyCoinsRupeeValue,
    required this.totalCompletedOrdersValue,
    required this.averageOrderValue,
  });

  factory FinancialWalletSummary.fromJson(Map<String, dynamic>? json) {
    return FinancialWalletSummary(
      currentWalletBalance: json?['current_wallet_balance']?.toString() ?? '0.00',
      totalCredited: json?['total_credited']?.toString() ?? '0.00',
      totalDebited: json?['total_debited']?.toString() ?? '0.00',
      loyaltyCoinsBalance: _parseInt(json?['loyalty_coins_balance']),
      loyaltyCoinsRupeeValue: json?['loyalty_coins_rupee_value']?.toString() ?? '0.00',
      totalCompletedOrdersValue: json?['total_completed_orders_value']?.toString() ?? '0.00',
      averageOrderValue: json?['average_order_value']?.toString() ?? '0.00',
    );
  }
}

@immutable
class WalletTransactionItem {
  final int txnId;
  final int customerId;
  final String type;
  final String amount;
  final String description;
  final String? referBy;
  final String? referTo;
  final String createdAt;
  final String updatedAt;
  final String? expireDate;

  const WalletTransactionItem({
    required this.txnId,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.description,
    this.referBy,
    this.referTo,
    required this.createdAt,
    required this.updatedAt,
    this.expireDate,
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    return WalletTransactionItem(
      txnId: _parseInt(json['txn_id']),
      customerId: _parseInt(json['customer_id']),
      type: json['type']?.toString() ?? 'DEBIT',
      amount: json['amount']?.toString() ?? '0.00',
      description: json['description']?.toString() ?? 'Wallet Transaction',
      referBy: json['refer_by']?.toString(),
      referTo: json['refer_to']?.toString(),
      createdAt: json['created_at']?.toString() ?? '—',
      updatedAt: json['updated_at']?.toString() ?? '—',
      expireDate: json['expire_date']?.toString(),
    );
  }
}

@immutable
class OrdersMetrics {
  final int totalOrdersCount;
  final int deliveredOrdersCount;
  final int activeInTransitOrdersCount;
  final int cancelledOrdersCount;

  const OrdersMetrics({
    required this.totalOrdersCount,
    required this.deliveredOrdersCount,
    required this.activeInTransitOrdersCount,
    required this.cancelledOrdersCount,
  });

  factory OrdersMetrics.fromJson(Map<String, dynamic>? json) {
    return OrdersMetrics(
      totalOrdersCount: _parseInt(json?['total_orders_count']),
      deliveredOrdersCount: _parseInt(json?['delivered_orders_count']),
      activeInTransitOrdersCount: _parseInt(json?['active_in_transit_orders_count']),
      cancelledOrdersCount: _parseInt(json?['cancelled_orders_count']),
    );
  }
}

@immutable
class CustomerOrderSummary {
  final int orderId;
  final String orderNumber;
  final String orderDate;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMode;
  final String subtotal;
  final String discount;
  final String deliveryCharges;
  final String smallCartCharge;
  final String handlingCharge;
  final String? couponCode;
  final String totalAmount;
  final List<OrderItemDetail> orderItems;

  const CustomerOrderSummary({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMode,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharges,
    required this.smallCartCharge,
    required this.handlingCharge,
    this.couponCode,
    required this.totalAmount,
    required this.orderItems,
  });

  factory CustomerOrderSummary.fromJson(Map<String, dynamic> json) {
    return CustomerOrderSummary(
      orderId: _parseInt(json['order_id']),
      orderNumber: json['order_number']?.toString() ?? '—',
      orderDate: json['order_date']?.toString() ?? '—',
      orderStatus: json['order_status']?.toString() ?? 'PLACED',
      paymentStatus: json['payment_status']?.toString() ?? 'PENDING',
      paymentMode: json['payment_mode']?.toString() ?? 'COD',
      subtotal: json['subtotal']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      deliveryCharges: json['delivery_charges']?.toString() ?? '0.00',
      smallCartCharge: json['small_cart_charge']?.toString() ?? '0.00',
      handlingCharge: json['handling_charge']?.toString() ?? '0.00',
      couponCode: json['coupon_code']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      orderItems:
          (json['order_items'] as List<dynamic>?)?.map((e) => OrderItemDetail.fromJson(e as Map<String, dynamic>)).toList(growable: false) ??
          const [],
    );
  }
}

@immutable
class OrderItemDetail {
  final int quantity;
  final String unitPrice;
  final String totalPrice;

  const OrderItemDetail({required this.quantity, required this.unitPrice, required this.totalPrice});

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      quantity: _parseInt(json['quantity'], defaultValue: 1),
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalPrice: json['total_price']?.toString() ?? '0.00',
    );
  }
}

@immutable
class CustomerAddressItem {
  final int addressId;
  final String type;
  final bool isPrimary;
  final String houseFlatNo;
  final String streetLandmark;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String latitude;
  final String longitude;
  final int status;

  const CustomerAddressItem({
    required this.addressId,
    required this.type,
    required this.isPrimary,
    required this.houseFlatNo,
    required this.streetLandmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  String get completeAddress {
    final parts = [houseFlatNo, streetLandmark, city, state, pincode, country].where((p) => p.trim().isNotEmpty).toList(growable: false);
    return parts.isNotEmpty ? parts.join(', ') : '—';
  }

  factory CustomerAddressItem.fromJson(Map<String, dynamic> json) {
    return CustomerAddressItem(
      addressId: _parseInt(json['address_id']),
      type: json['type']?.toString() ?? 'Home',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
      houseFlatNo: json['house_flat_no']?.toString() ?? '',
      streetLandmark: json['street_landmark']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      status: _parseInt(json['status'], defaultValue: 1),
    );
  }
}

@immutable
class CustomerActiveCart {
  final int itemCount;
  final String cartTotalMrp;
  final String cartTotalSalePrice;
  final String cartSavings;
  final List<CartProductItem> items;

  const CustomerActiveCart({
    required this.itemCount,
    required this.cartTotalMrp,
    required this.cartTotalSalePrice,
    required this.cartSavings,
    required this.items,
  });

  factory CustomerActiveCart.fromJson(Map<String, dynamic> json) {
    return CustomerActiveCart(
      itemCount: _parseInt(json['item_count']),
      cartTotalMrp: json['cart_total_mrp']?.toString() ?? '0.00',
      cartTotalSalePrice: json['cart_total_sale_price']?.toString() ?? '0.00',
      cartSavings: json['cart_savings']?.toString() ?? '0.00',
      items: (json['items'] as List<dynamic>?)?.map((e) => CartProductItem.fromJson(e as Map<String, dynamic>)).toList(growable: false) ?? const [],
    );
  }
}

@immutable
class CartProductItem {
  final int cartId;
  final String itemCode;
  final String itemFirmCode;
  final String itemName;
  final String companyName;
  final String? imageMob;
  final String? imageWeb;
  final String cartQuantity;
  final String mrpRate;
  final String saleRate;
  final String saleableStock;
  final String itemGroupName;
  final String otherGroupName;

  const CartProductItem({
    required this.cartId,
    required this.itemCode,
    required this.itemFirmCode,
    required this.itemName,
    required this.companyName,
    this.imageMob,
    this.imageWeb,
    required this.cartQuantity,
    required this.mrpRate,
    required this.saleRate,
    required this.saleableStock,
    required this.itemGroupName,
    required this.otherGroupName,
  });

  String get displayImage => (imageMob != null && imageMob!.isNotEmpty) ? imageMob! : (imageWeb ?? '');

  factory CartProductItem.fromJson(Map<String, dynamic> json) {
    return CartProductItem(
      cartId: _parseInt(json['cart_id']),
      itemCode: json['I_Code']?.toString() ?? '—',
      itemFirmCode: json['I_FirmCode']?.toString() ?? '',
      itemName: (json['I_Name']?.toString() ?? 'Item').trim(),
      companyName: (json['MC_CompName']?.toString() ?? '').trim(),
      imageMob: json['IM_ImageMob']?.toString(),
      imageWeb: json['IM_ImageWeb']?.toString(),
      cartQuantity: json['cart_quantity']?.toString() ?? '1',
      mrpRate: json['SB_M_RATE']?.toString() ?? '0.00',
      saleRate: json['SB_Rate_A']?.toString() ?? '0.00',
      saleableStock: json['SB_Saleable_Stock']?.toString() ?? '0',
      itemGroupName: json['IG_NAME']?.toString() ?? '',
      otherGroupName: json['OG_NAME']?.toString() ?? '',
    );
  }
}

@immutable
class WishlistItem {
  final int id;
  final String itemCode;
  final String barCode;
  final String itemName;
  final String batchNo;
  final String mrpRate;
  final String saleRate;
  final String saleableStock;
  final String companyName;
  final String? imageMob;
  final String? imageWeb;
  final String itemGroupName;
  final String otherGroupName;

  const WishlistItem({
    required this.id,
    required this.itemCode,
    required this.barCode,
    required this.itemName,
    required this.batchNo,
    required this.mrpRate,
    required this.saleRate,
    required this.saleableStock,
    required this.companyName,
    this.imageMob,
    this.imageWeb,
    required this.itemGroupName,
    required this.otherGroupName,
  });

  String get displayImage => (imageMob != null && imageMob!.isNotEmpty) ? imageMob! : (imageWeb ?? '');

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: _parseInt(json['id']),
      itemCode: json['I_Code']?.toString() ?? '—',
      barCode: json['I_Bar_Code']?.toString() ?? '',
      itemName: (json['I_Name']?.toString() ?? 'Product').trim(),
      batchNo: (json['batch_no']?.toString() ?? '').trim(),
      mrpRate: json['SB_M_RATE']?.toString() ?? '0.00',
      saleRate: json['SB_Rate_A']?.toString() ?? '0.00',
      saleableStock: json['SB_Saleable_Stock']?.toString() ?? '0',
      companyName: (json['MC_CompName']?.toString() ?? '').trim(),
      imageMob: json['IM_ImageMob']?.toString(),
      imageWeb: json['IM_ImageWeb']?.toString(),
      itemGroupName: json['item_group_name']?.toString() ?? '',
      otherGroupName: json['other_group_name']?.toString() ?? '',
    );
  }
}

int _parseInt(dynamic val, {int defaultValue = 0}) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString().trim()) ?? defaultValue;
}
