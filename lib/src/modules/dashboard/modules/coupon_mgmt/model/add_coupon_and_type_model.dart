import 'package:flutter/foundation.dart';

@immutable
class AddCouponAndTypeModel {
  final bool status;
  final String message;
  final AddCouponAndTypeData? data;

  const AddCouponAndTypeModel({required this.status, required this.message, this.data});

  AddCouponAndTypeModel copyWith({bool? status, String? message, AddCouponAndTypeData? data}) {
    return AddCouponAndTypeModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddCouponAndTypeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCouponAndTypeModel(status: false, message: 'Empty response payload received from server.', data: null);
    }

    return AddCouponAndTypeModel(
      status: _parseBool(json['status']),
      message: _parseString(json['message']),
      data: json['data'] is Map<String, dynamic> ? AddCouponAndTypeData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'data': data?.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddCouponAndTypeModel && runtimeType == other.runtimeType && status == other.status && message == other.message && data == other.data;

  @override
  int get hashCode => Object.hash(status, message, data);

  @override
  String toString() => 'AddCouponAndTypeModel(status: $status, message: $message, data: $data)';
}

@immutable
class AddCouponAndTypeData {
  final bool success;
  final int insertId;

  const AddCouponAndTypeData({required this.success, required this.insertId});

  AddCouponAndTypeData copyWith({bool? success, int? insertId}) {
    return AddCouponAndTypeData(success: success ?? this.success, insertId: insertId ?? this.insertId);
  }

  factory AddCouponAndTypeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCouponAndTypeData(success: false, insertId: 0);
    }

    return AddCouponAndTypeData(success: _parseBool(json['success']), insertId: _parseInt(json['insertId'] ?? json['insert_id']));
  }

  Map<String, dynamic> toJson() => {'success': success, 'insertId': insertId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddCouponAndTypeData && runtimeType == other.runtimeType && success == other.success && insertId == other.insertId;

  @override
  int get hashCode => Object.hash(success, insertId);

  @override
  String toString() => 'AddCouponAndTypeData(success: $success, insertId: $insertId)';
}

int _parseInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? double.tryParse(val.trim())?.toInt() ?? fallback;
  }
  return fallback;
}

String _parseString(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  return val.toString().trim();
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  final str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true';
}
