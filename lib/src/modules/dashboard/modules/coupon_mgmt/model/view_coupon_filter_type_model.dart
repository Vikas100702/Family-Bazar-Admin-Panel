import 'package:flutter/foundation.dart';

@immutable
class ViewCouponFilterTypeModel {
  final bool status;
  final String message;
  final ViewCouponFilterTypeData? data;

  const ViewCouponFilterTypeModel({required this.status, required this.message, this.data});

  ViewCouponFilterTypeModel copyWith({bool? status, String? message, ViewCouponFilterTypeData? data}) {
    return ViewCouponFilterTypeModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewCouponFilterTypeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewCouponFilterTypeModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];

    return ViewCouponFilterTypeModel(
      status: _parseBool(rawStatus),
      message: _parseCleanString(json['message']),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ViewCouponFilterTypeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, if (data != null) 'data': data?.toJson()};

  @override
  String toString() => 'ViewCouponFilterTypeModel(status: $status, message: $message, data:$data)';
}

@immutable
class ViewCouponFilterTypeData {
  final List<CouponFilterOptionItem> discountType;
  final List<CouponFilterOptionItem> userType;
  final List<CouponFilterOptionItem> paymentType;
  final List<CouponFilterStatusItem> status;

  const ViewCouponFilterTypeData({
    this.discountType = const <CouponFilterOptionItem>[],
    this.userType = const <CouponFilterOptionItem>[],
    this.paymentType = const <CouponFilterOptionItem>[],
    this.status = const <CouponFilterStatusItem>[],
  });

  ViewCouponFilterTypeData copyWith({
    List<CouponFilterOptionItem>? discountType,
    List<CouponFilterOptionItem>? userType,
    List<CouponFilterOptionItem>? paymentType,
    List<CouponFilterStatusItem>? status,
  }) {
    return ViewCouponFilterTypeData(
      discountType: discountType ?? this.discountType,
      userType: userType ?? this.userType,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
    );
  }

  factory ViewCouponFilterTypeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ViewCouponFilterTypeData();

    return ViewCouponFilterTypeData(
      discountType: _parseList(json['discount_type'], CouponFilterOptionItem.fromJson),
      userType: _parseList(json['user_type'], CouponFilterOptionItem.fromJson),
      paymentType: _parseList(json['payment_type'], CouponFilterOptionItem.fromJson),
      status: _parseList(json['status'], CouponFilterStatusItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'discount_type': discountType.map((x) => x.toJson()).toList(growable: false),
    'user_type': userType.map((x) => x.toJson()).toList(growable: false),
    'payment_type': paymentType.map((x) => x.toJson()).toList(growable: false),
    'status': status.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() =>
      'ViewCouponFilterTypeData(discountType: ${discountType.length}, userType:${userType.length}, paymentType: ${paymentType.length}, status:${status.length})';
}

@immutable
class CouponFilterOptionItem {
  final String value;
  final String name;

  const CouponFilterOptionItem({required this.value, required this.name});

  CouponFilterOptionItem copyWith({String? value, String? name}) {
    return CouponFilterOptionItem(value: value ?? this.value, name: name ?? this.name);
  }

  factory CouponFilterOptionItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CouponFilterOptionItem(value: '', name: '');
    }

    return CouponFilterOptionItem(value: _parseCleanString(json['value']), name: _parseCleanString(json['name']));
  }

  Map<String, dynamic> toJson() => {'value': value, 'name': name};

  @override
  String toString() => 'CouponFilterOptionItem(value: $value, name:$name)';
}

@immutable
class CouponFilterStatusItem {
  final int value;
  final String name;

  const CouponFilterStatusItem({required this.value, required this.name});

  CouponFilterStatusItem copyWith({int? value, String? name}) {
    return CouponFilterStatusItem(value: value ?? this.value, name: name ?? this.name);
  }

  factory CouponFilterStatusItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CouponFilterStatusItem(value: 0, name: '');
    }

    return CouponFilterStatusItem(value: _parseInt(json['value']), name: _parseCleanString(json['name']));
  }

  Map<String, dynamic> toJson() => {'value': value, 'name': name};

  @override
  String toString() => 'CouponFilterStatusItem(value: $value, name:$name)';
}

typedef CouponType = CouponFilterOptionItem;
typedef CouponStatus = CouponFilterStatusItem;

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

List<T> _parseList<T>(dynamic jsonList, T Function(Map<String, dynamic>) fromJson) {
  if (jsonList is! List) return const [];
  return List<T>.unmodifiable(jsonList.whereType<Map<String, dynamic>>().map((item) => fromJson(item)).toList());
}
