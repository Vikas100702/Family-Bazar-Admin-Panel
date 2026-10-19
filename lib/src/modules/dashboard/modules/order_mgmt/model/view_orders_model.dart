import 'package:flutter/foundation.dart';

@immutable
class ViewOrdersModel {
  final bool success;
  final OrderPagination? pagination;
  final List<OrderDatum> data;

  const ViewOrdersModel({required this.success, this.pagination, this.data = const <OrderDatum>[]});

  ViewOrdersModel copyWith({bool? success, OrderPagination? pagination, List<OrderDatum>? data}) {
    return ViewOrdersModel(success: success ?? this.success, pagination: pagination ?? this.pagination, data: data ?? this.data);
  }

  factory ViewOrdersModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewOrdersModel(success: false, pagination: null, data: <OrderDatum>[]);
    }

    final dynamic rawData = json['data'];
    final List<OrderDatum> parsedData = <OrderDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(OrderDatum.fromJson(item));
        }
      }
    }

    return ViewOrdersModel(
      success: _parseBool(json['success'] ?? json['status']),
      pagination: json['pagination'] is Map<String, dynamic> ? OrderPagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<OrderDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewOrdersModel(success: $success, count: ${data.length})';
}

@immutable
class OrderDatum {
  final int id;
  final String orderNumber;
  final int customerId;
  final int addressId;
  final int deliverySlotId;
  final String? couponCode;
  final double subtotal;
  final double discountAmount;
  final double deliveryCharge;
  final double smallCartCharge;
  final double handlingCharge;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String loyaltyCredited;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String paymentTxnStatus;
  final String? razorpayPaymentId;
  final String addLine1;
  final String addLine2;
  final String addType;
  final String state;
  final String city;
  final String zipCode;
  final String countryCode;
  final String latitude;
  final String longitude;
  final String isPrimary;

  const OrderDatum({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.addressId,
    required this.deliverySlotId,
    this.couponCode,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryCharge,
    required this.smallCartCharge,
    required this.handlingCharge,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.loyaltyCredited,
    this.createdAt,
    this.updatedAt,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.paymentTxnStatus,
    this.razorpayPaymentId,
    required this.addLine1,
    required this.addLine2,
    required this.addType,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
  });

  String get customerFullName {
    final String name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Unnamed Customer';
  }

  String get formattedAddress {
    final List<String> parts = <String>[
      addLine1,
      addLine2,
      city,
      state,
      zipCode,
      countryCode,
    ].where((part) => part.trim().isNotEmpty).toList(growable: false);
    return parts.isNotEmpty ? parts.join(', ') : 'No Address Specified';
  }

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  factory OrderDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderDatum(
        id: 0,
        orderNumber: '',
        customerId: 0,
        addressId: 0,
        deliverySlotId: 0,
        subtotal: 0.0,
        discountAmount: 0.0,
        deliveryCharge: 0.0,
        smallCartCharge: 0.0,
        handlingCharge: 0.0,
        totalAmount: 0.0,
        paymentMethod: 'COD',
        paymentStatus: 'PENDING',
        orderStatus: 'PLACED',
        loyaltyCredited: '0',
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        paymentTxnStatus: '',
        addLine1: '',
        addLine2: '',
        addType: 'Home',
        state: '',
        city: '',
        zipCode: '',
        countryCode: 'IN',
        latitude: '',
        longitude: '',
        isPrimary: '0',
      );
    }

    return OrderDatum(
      id: _parseInt(json['id']),
      orderNumber: _parseCleanString(json['order_number']),
      customerId: _parseInt(json['customer_id']),
      addressId: _parseInt(json['address_id']),
      deliverySlotId: _parseInt(json['delivery_slot_id']),
      couponCode: _parseNullableString(json['coupon_code']),
      subtotal: _parseDouble(json['subtotal']),
      discountAmount: _parseDouble(json['discount_amount']),
      deliveryCharge: _parseDouble(json['delivery_charge']),
      smallCartCharge: _parseDouble(json['small_cart_charge']),
      handlingCharge: _parseDouble(json['handling_charge']),
      totalAmount: _parseDouble(json['total_amount']),
      paymentMethod: _parseCleanString(json['payment_method'], fallback: 'COD'),
      paymentStatus: _parseCleanString(json['payment_status'], fallback: 'PENDING'),
      orderStatus: _parseCleanString(json['order_status'], fallback: 'PLACED'),
      loyaltyCredited: _parseCleanString(json['loyalty_credited'], fallback: '0'),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      firstName: _parseCleanString(json['first_name']),
      lastName: _parseCleanString(json['last_name']),
      phone: _parseCleanString(json['phone']),
      email: _parseCleanString(json['email']),
      paymentTxnStatus: _parseCleanString(json['payment_txn_status']),
      razorpayPaymentId: _parseNullableString(json['razorpay_payment_id']),
      addLine1: _parseCleanString(json['add_line_1']),
      addLine2: _parseCleanString(json['add_line_2']),
      addType: _parseCleanString(json['add_type'], fallback: 'Home'),
      state: _parseCleanString(json['state']),
      city: _parseCleanString(json['city']),
      zipCode: _parseCleanString(json['zip_code']),
      countryCode: _parseCleanString(json['country_code'], fallback: 'IN'),
      latitude: _parseCleanString(json['latitude']),
      longitude: _parseCleanString(json['longitude']),
      isPrimary: _parseCleanString(json['isPrimary'], fallback: '0'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'customer_id': customerId,
    'address_id': addressId,
    'delivery_slot_id': deliverySlotId,
    'coupon_code': couponCode,
    'subtotal': subtotal.toStringAsFixed(2),
    'discount_amount': discountAmount.toStringAsFixed(2),
    'delivery_charge': deliveryCharge.toStringAsFixed(2),
    'small_cart_charge': smallCartCharge.toStringAsFixed(2),
    'handling_charge': handlingCharge.toStringAsFixed(2),
    'total_amount': totalAmount.toStringAsFixed(2),
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'order_status': orderStatus,
    'loyalty_credited': loyaltyCredited,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'email': email,
    'payment_txn_status': paymentTxnStatus,
    'razorpay_payment_id': razorpayPaymentId,
    'add_line_1': addLine1,
    'add_line_2': addLine2,
    'add_type': addType,
    'state': state,
    'city': city,
    'zip_code': zipCode,
    'country_code': countryCode,
    'latitude': latitude,
    'longitude': longitude,
    'isPrimary': isPrimary,
  };

  @override
  String toString() => 'OrderDatum(id: $id, orderNo: $orderNumber, customer: $customerFullName, total: ₹$totalAmount, status: $orderStatus)';
}

@immutable
class OrderPagination {
  final int currentPage;
  final int limit;
  final int totalRecords;
  final int totalPages;

  const OrderPagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  factory OrderPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderPagination(currentPage: 1, limit: 20, totalRecords: 0, totalPages: 1);
    }

    return OrderPagination(
      currentPage: _parseInt(json['current_page'] ?? json['page'], defaultValue: 1),
      limit: _parseInt(json['limit'] ?? json['per_page'], defaultValue: 20),
      totalRecords: _parseInt(json['total_records'] ?? json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() => {'current_page': currentPage, 'limit': limit, 'total_records': totalRecords, 'total_pages': totalPages};
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val == 1;
  final String str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true';
}

int _parseInt(dynamic val, {int defaultValue = 0}) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final String str = val.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return defaultValue;
}

double _parseDouble(dynamic val, {double defaultValue = 0.0}) {
  if (val == null) return defaultValue;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  final String str = val.toString().trim();
  return double.tryParse(str) ?? defaultValue;
}

String _parseCleanString(dynamic val, {String fallback = ''}) {
  if (val == null) return fallback;
  final String str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return fallback;
  return str;
}

String? _parseNullableString(dynamic val) {
  if (val == null) return null;
  final String str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return null;
  return str;
}

DateTime? _parseDate(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) {
    return val.year >= 1970 ? val : null;
  }
  final String dateStr = val.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00') || dateStr == 'null') {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }
  return parsed;
}
