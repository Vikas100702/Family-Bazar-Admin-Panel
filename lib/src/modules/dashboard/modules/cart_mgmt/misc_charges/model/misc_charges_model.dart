import 'package:flutter/foundation.dart';

@immutable
class MiscChargesResponseModel {
  final bool status;
  final bool success;
  final String message;
  final int? id;
  final List<MiscChargeItem> data;
  final MiscChargesPagination? pagination;

  const MiscChargesResponseModel({
    required this.status,
    this.success = true,
    required this.message,
    this.id,
    this.data = const <MiscChargeItem>[],
    this.pagination,
  });

  factory MiscChargesResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MiscChargesResponseModel(status: false, success: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'];
    final bool parsedStatus = _parseBool(rawStatus);

    final dynamic rawSuccess = json['success'];
    final bool parsedSuccess = rawSuccess == null ? parsedStatus : _parseBool(rawSuccess);

    final List<MiscChargeItem> parsedList = <MiscChargeItem>[];
    final dynamic rawData = json['data'];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedList.add(MiscChargeItem.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedList.add(MiscChargeItem.fromJson(rawData));
    }

    return MiscChargesResponseModel(
      status: parsedStatus,
      success: parsedSuccess,
      message: _parseCleanString(json['message']),
      id: _parseNullableInt(json['id']),
      data: List<MiscChargeItem>.unmodifiable(parsedList),
      pagination: json['pagination'] is Map<String, dynamic> ? MiscChargesPagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status ? 1 : 0,
    'success': success,
    'message': message,
    if (id != null) 'id': id,
    'data': data.map((item) => item.toJson()).toList(growable: false),
    if (pagination != null) 'pagination': pagination?.toJson(),
  };
}

@immutable
class MiscChargesPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const MiscChargesPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory MiscChargesPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MiscChargesPagination(currentPage: 1, perPage: 20, total: 0, totalPages: 1, hasNextPage: false, hasPreviousPage: false);
    }

    return MiscChargesPagination(
      currentPage: _parseInt(json['current_page'] ?? json['page'], defaultValue: 1),
      perPage: _parseInt(json['per_page'] ?? json['limit'], defaultValue: 20),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages'], defaultValue: 1),
      hasNextPage: _parseBool(json['hasNextPage'] ?? json['has_next_page']),
      hasPreviousPage: _parseBool(json['hasPreviousPage'] ?? json['has_previous_page']),
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

@immutable
class MiscChargeItem {
  final int id;
  final double handlingFee;
  final double smallCartCharge;
  final double smallCartMinAmount;
  final int status; // 1 = Active, 0 = Inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MiscChargeItem({
    required this.id,
    required this.handlingFee,
    required this.smallCartCharge,
    required this.smallCartMinAmount,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  MiscChargeItem copyWith({
    int? id,
    double? handlingFee,
    double? smallCartCharge,
    double? smallCartMinAmount,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MiscChargeItem(
      id: id ?? this.id,
      handlingFee: handlingFee ?? this.handlingFee,
      smallCartCharge: smallCartCharge ?? this.smallCartCharge,
      smallCartMinAmount: smallCartMinAmount ?? this.smallCartMinAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MiscChargeItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MiscChargeItem(id: 0, handlingFee: 0.0, smallCartCharge: 0.0, smallCartMinAmount: 0.0, status: 0);
    }

    return MiscChargeItem(
      id: _parseInt(json['id']),
      handlingFee: _parseDouble(json['handling_fee']),
      smallCartCharge: _parseDouble(json['small_cart_charge']),
      smallCartMinAmount: _parseDouble(json['small_cart_min_amount']),
      status: _parseInt(json['status'], defaultValue: 1),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'handling_fee': handlingFee.toStringAsFixed(2),
    'small_cart_charge': smallCartCharge.toStringAsFixed(2),
    'small_cart_min_amount': smallCartMinAmount.toStringAsFixed(2),
    'status': status.toString(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
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

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'undefined') {
    return null;
  }
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return null;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final String str = value.toString().trim();
  return double.tryParse(str) ?? defaultValue;
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
