import 'package:flutter/foundation.dart';

@immutable
class AddCouponModel {
  final bool status;
  final String message;
  final AddCouponData? data;

  const AddCouponModel({required this.status, required this.message, this.data});

  AddCouponModel copyWith({bool? status, String? message, AddCouponData? data}) {
    return AddCouponModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddCouponModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCouponModel(status: false, message: 'Empty response payload received.');
    }
    final dynamic rawStatus = json['status'] ?? json['success'];

    return AddCouponModel(
      status: _parseBool(rawStatus),
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? AddCouponData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, if (data != null) 'data': data?.toJson()};

  @override
  String toString() => 'AddCouponModel(status: $status, message: $message, data: $data)';
}

@immutable
class AddCouponData {
  final bool success;
  final int insertId;

  const AddCouponData({required this.success, required this.insertId});

  AddCouponData copyWith({bool? success, int? insertId}) {
    return AddCouponData(success: success ?? this.success, insertId: insertId ?? this.insertId);
  }

  factory AddCouponData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCouponData(success: false, insertId: 0);
    }

    final dynamic rawSuccess = json['success'];

    return AddCouponData(success: _parseBool(rawSuccess), insertId: _parseInt(json['insertId'] ?? json['insert_id'] ?? json['id']));
  }

  Map<String, dynamic> toJson() => {'success': success, 'insertId': insertId};

  @override
  String toString() => 'AddCouponData(success: $success, insertId: $insertId)';
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
