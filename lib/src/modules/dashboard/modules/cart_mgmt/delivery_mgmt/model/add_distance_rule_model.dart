import 'package:flutter/foundation.dart';

@immutable
class AddDistanceRulesModel {
  final bool status;
  final String message;
  final DistanceSlabData? data;

  const AddDistanceRulesModel({required this.status, required this.message, this.data});

  AddDistanceRulesModel copyWith({bool? status, String? message, DistanceSlabData? data}) {
    return AddDistanceRulesModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddDistanceRulesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddDistanceRulesModel(status: false, message: 'Empty response payload received.');
    }

    return AddDistanceRulesModel(
      status: json['status'] == true || json['status'] == 1 || json['status'].toString().trim().toLowerCase() == 'true',
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? DistanceSlabData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'data': data?.toJson()};

  @override
  String toString() => 'AddDistanceRulesModel(status: $status, message: $message, data: $data)';
}

@immutable
class DistanceSlabData {
  final int id;
  final int ruleId;
  final int minDistanceKm;
  final int maxDistanceKm;
  final int minOrderAmount;
  final int? maxOrderAmount;
  final int baseCharge;
  final int perKmCharge;
  final int priority;
  final int status;

  const DistanceSlabData({
    required this.id,
    required this.ruleId,
    required this.minDistanceKm,
    required this.maxDistanceKm,
    required this.minOrderAmount,
    this.maxOrderAmount,
    required this.baseCharge,
    required this.perKmCharge,
    required this.priority,
    required this.status,
  });

  DistanceSlabData copyWith({
    int? id,
    int? ruleId,
    int? minDistanceKm,
    int? maxDistanceKm,
    int? minOrderAmount,
    int? maxOrderAmount,
    int? baseCharge,
    int? perKmCharge,
    int? priority,
    int? status,
  }) {
    return DistanceSlabData(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      minDistanceKm: minDistanceKm ?? this.minDistanceKm,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxOrderAmount: maxOrderAmount ?? this.maxOrderAmount,
      baseCharge: baseCharge ?? this.baseCharge,
      perKmCharge: perKmCharge ?? this.perKmCharge,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  factory DistanceSlabData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DistanceSlabData(
        id: 0,
        ruleId: 0,
        minDistanceKm: 0,
        maxDistanceKm: 0,
        minOrderAmount: 0,
        maxOrderAmount: null,
        baseCharge: 0,
        perKmCharge: 0,
        priority: 0,
        status: 0,
      );
    }

    return DistanceSlabData(
      id: _parseInt(json['id']),
      ruleId: _parseInt(json['rule_id']),
      minDistanceKm: _parseInt(json['min_distance_km']),
      maxDistanceKm: _parseInt(json['max_distance_km']),
      minOrderAmount: _parseInt(json['min_order_amount']),
      maxOrderAmount: _parseNullableInt(json['max_order_amount']),
      baseCharge: _parseInt(json['base_charge']),
      perKmCharge: _parseInt(json['per_km_charge']),
      priority: _parseInt(json['priority']),
      status: _parseInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rule_id': ruleId,
    'min_distance_km': minDistanceKm,
    'max_distance_km': maxDistanceKm,
    'min_order_amount': minOrderAmount,
    'max_order_amount': maxOrderAmount,
    'base_charge': baseCharge,
    'per_km_charge': perKmCharge,
    'priority': priority,
    'status': status,
  };

  @override
  String toString() =>
      'DistanceSlabData(id: $id, ruleId: $ruleId, minDistance: $minDistanceKm, maxDistance: $maxDistanceKm, minAmount: $minOrderAmount, maxAmount: $maxOrderAmount, baseCharge: $baseCharge, perKm: $perKmCharge, priority: $priority, status: $status)';
}

/// Helper that safely converts integer, double, or decimal strings (e.g. "40.00") into an int
int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return defaultValue;
}

/// Helper that parses nullable decimal string or returns null for empty/null values
int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return null;
}
