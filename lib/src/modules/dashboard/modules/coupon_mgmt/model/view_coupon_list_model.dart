import 'package:flutter/foundation.dart';

@immutable
class ViewCouponListModel {
  final bool status;
  final String message;
  final List<ViewCouponListDatum> data;
  final Pagination? pagination;

  const ViewCouponListModel({required this.status, required this.message, this.data = const <ViewCouponListDatum>[], this.pagination});

  ViewCouponListModel copyWith({bool? status, String? message, List<ViewCouponListDatum>? data, Pagination? pagination}) {
    return ViewCouponListModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }

  factory ViewCouponListModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewCouponListModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = _parseBool(rawStatus);

    final List<ViewCouponListDatum> parsedList = <ViewCouponListDatum>[];
    final dynamic rawData = json['data'];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedList.add(ViewCouponListDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedList.add(ViewCouponListDatum.fromJson(rawData));
    }

    return ViewCouponListModel(
      status: parsedStatus,
      message: _parseCleanString(json['message']),
      data: List<ViewCouponListDatum>.unmodifiable(parsedList),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((x) => x.toJson()).toList(growable: false),
    if (pagination != null) 'pagination': pagination?.toJson(),
  };

  @override
  String toString() => 'ViewCouponListModel(status: $status, message: $message, data: ${data.length})';
}

@immutable
class ViewCouponListDatum {
  final int id;
  final String code;
  final String discountType;
  final String title;
  final String discountValue;
  final String maxDiscount;
  final String minOrderAmount;
  final int usageLimit;
  final int usagePerCustomer;
  final String applicableAll;
  final List<String> applicableGroup;
  final List<String> applicableBrand;
  final int usedCount;
  final String userType;
  final String paymentType;
  final DateTime? startAt;
  final DateTime? endAt;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ViewCouponListDatum({
    required this.id,
    required this.code,
    required this.discountType,
    required this.title,
    required this.discountValue,
    required this.maxDiscount,
    required this.minOrderAmount,
    required this.usageLimit,
    required this.usagePerCustomer,
    required this.applicableAll,
    this.applicableGroup = const <String>[],
    this.applicableBrand = const <String>[],
    required this.usedCount,
    required this.userType,
    required this.paymentType,
    this.startAt,
    this.endAt,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  ViewCouponListDatum copyWith({
    int? id,
    String? code,
    String? discountType,
    String? title,
    String? discountValue,
    String? maxDiscount,
    String? minOrderAmount,
    int? usageLimit,
    int? usagePerCustomer,
    String? applicableAll,
    List<String>? applicableGroup,
    List<String>? applicableBrand,
    int? usedCount,
    String? userType,
    String? paymentType,
    DateTime? startAt,
    DateTime? endAt,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ViewCouponListDatum(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      title: title ?? this.title,
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usagePerCustomer: usagePerCustomer ?? this.usagePerCustomer,
      applicableAll: applicableAll ?? this.applicableAll,
      applicableGroup: applicableGroup ?? this.applicableGroup,
      applicableBrand: applicableBrand ?? this.applicableBrand,
      usedCount: usedCount ?? this.usedCount,
      userType: userType ?? this.userType,
      paymentType: paymentType ?? this.paymentType,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ViewCouponListDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewCouponListDatum(
        id: 0,
        code: '',
        discountType: '',
        title: '',
        discountValue: '0',
        maxDiscount: '0',
        minOrderAmount: '0',
        usageLimit: 0,
        usagePerCustomer: 0,
        applicableAll: '1',
        usedCount: 0,
        userType: '',
        paymentType: '',
        status: 1,
      );
    }

    final List<String> parsedGroups = <String>[];
    final dynamic rawGroups = json['applicable_group'];
    if (rawGroups is List) {
      for (final item in rawGroups) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedGroups.add(item.toString().trim());
        }
      }
    }

    final List<String> parsedBrands = <String>[];
    final dynamic rawBrands = json['applicable_brand'];
    if (rawBrands is List) {
      for (final item in rawBrands) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedBrands.add(item.toString().trim());
        }
      }
    }

    return ViewCouponListDatum(
      id: _parseInt(json['id']),
      code: _parseCleanString(json['code']),
      discountType: _parseCleanString(json['discount_type']),
      title: _parseCleanString(json['title']),
      discountValue: _parseCleanString(json['discount_value'], fallback: '0'),
      maxDiscount: _parseCleanString(json['max_discount'], fallback: '0'),
      minOrderAmount: _parseCleanString(json['min_order_amount'], fallback: '0'),
      usageLimit: _parseInt(json['usage_limit']),
      usagePerCustomer: _parseInt(json['usage_per_customer']),
      applicableAll: _parseCleanString(json['applicable_all'], fallback: '1'),
      applicableGroup: List<String>.unmodifiable(parsedGroups),
      applicableBrand: List<String>.unmodifiable(parsedBrands),
      usedCount: _parseInt(json['used_count']),
      userType: _parseCleanString(json['user_type']),
      paymentType: _parseCleanString(json['payment_type']),
      startAt: _parseDate(json['start_at']),
      endAt: _parseDate(json['end_at']),
      status: _parseInt(json['status'], defaultValue: 1),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'discount_type': discountType,
    'title': title,
    'discount_value': discountValue,
    'max_discount': maxDiscount,
    'min_order_amount': minOrderAmount,
    'usage_limit': usageLimit,
    'usage_per_customer': usagePerCustomer,
    'applicable_all': applicableAll,
    'applicable_group': applicableGroup.toList(growable: false),
    'applicable_brand': applicableBrand.toList(growable: false),
    'used_count': usedCount,
    'user_type': userType,
    'payment_type': paymentType,
    'start_at': startAt?.toIso8601String(),
    'end_at': endAt?.toIso8601String(),
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

@immutable
class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  Pagination copyWith({int? currentPage, int? perPage, int? total, int? totalPages, bool? hasNextPage, bool? hasPreviousPage}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Pagination(currentPage: 0, perPage: 0, total: 0, totalPages: 0, hasNextPage: false, hasPreviousPage: false);
    }

    return Pagination(
      currentPage: _parseInt(json['current_page'] ?? json['page']),
      perPage: _parseInt(json['per_page'] ?? json['limit'], defaultValue: 20),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages']),
      hasNextPage: _parseBool(json['has_next_page']),
      hasPreviousPage: _parseBool(json['has_previous_page']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'per_page': perPage,
    'total': total,
    'total_pages': totalPages,
    'has_next_page': hasNextPage,
    'has_previous_page': hasPreviousPage,
  };
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value == 1;
  final String str = value.toString().trim().toLowerCase();
  return str == '1' || str == 'true' || str == 'active' || str == 'y';
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return defaultValue;
}

String _parseCleanString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final String str = value.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return fallback;
  return str;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) {
    return value.year >= 1970 ? value : null;
  }
  final String dateStr = value.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00') || dateStr == 'null' || dateStr == 'undefined') {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }
  return parsed;
}
