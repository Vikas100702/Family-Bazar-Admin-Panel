import 'package:flutter/foundation.dart';

@immutable
class DeliveryRuleDetailsModel {
  final bool status;
  final String message;
  final DeliveryRuleDetailsData? data;

  const DeliveryRuleDetailsModel({required this.status, required this.message, this.data});

  factory DeliveryRuleDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRuleDetailsModel(status: false, message: 'Empty response payload received.');
    }
    return DeliveryRuleDetailsModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DeliveryRuleDetailsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'data': data?.toJson()};
}

@immutable
class DeliveryRuleDetailsData {
  final int id;
  final String ruleName;
  final String description;
  final int priority;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<RulePincodeItem> pincodes;
  final List<RuleDistanceItem> distanceRules;

  const DeliveryRuleDetailsData({
    required this.id,
    required this.ruleName,
    required this.description,
    required this.priority,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.pincodes = const [],
    this.distanceRules = const [],
  });

  /// Convenience getter for pin code ids array required by save Rule API
  List<int> get pincodeIds => pincodes.map((e) => e.pincodeId).where((id) => id > 0).toList();

  factory DeliveryRuleDetailsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRuleDetailsData(id: 0, ruleName: '', description: '', priority: 0, status: 0);
    }

    final List<RulePincodeItem> parsedPins = [];
    if (json['pincodes'] is List) {
      for (final item in json['pincodes'] as List) {
        if (item is Map<String, dynamic>) {
          parsedPins.add(RulePincodeItem.fromJson(item));
        }
      }
    }

    final List<RuleDistanceItem> parsedDistances = [];
    final dynamic rawDist = json['distance_rules'] ?? json['distance_slabs'];
    if (rawDist is List) {
      for (final item in rawDist) {
        if (item is Map<String, dynamic>) {
          parsedDistances.add(RuleDistanceItem.fromJson(item));
        }
      }
    }

    return DeliveryRuleDetailsData(
      id: _parseInt(json['id']),
      ruleName: json['rule_name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      priority: _parseInt(json['priority']),
      status: _parseInt(json['status']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      pincodes: List.unmodifiable(parsedPins),
      distanceRules: List.unmodifiable(parsedDistances),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rule_name': ruleName,
    'description': description,
    'priority': priority,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'pincodes': pincodes.map((e) => e.toJson()).toList(),
    'distance_rules': distanceRules.map((e) => e.toJson()).toList(),
  };
}

@immutable
class RulePincodeItem {
  final int id;
  final int pincodeId;
  final String pincode;
  final int priority;
  final int status;

  const RulePincodeItem({required this.id, required this.pincodeId, required this.pincode, required this.priority, required this.status});

  factory RulePincodeItem.fromJson(Map<String, dynamic> json) {
    return RulePincodeItem(
      id: _parseInt(json['id']),
      pincodeId: _parseInt(json['pincode_id']),
      pincode: json['pincode']?.toString().trim() ?? '',
      priority: _parseInt(json['priority']),
      status: _parseInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'pincode_id': pincodeId, 'pincode': pincode, 'priority': priority, 'status': status};
}

@immutable
class RuleDistanceItem {
  final int id;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double minOrderAmount;
  final double maxOrderAmount;
  final double baseCharge;
  final double perKmCharge;
  final int priority;
  final int status;

  const RuleDistanceItem({
    required this.id,
    required this.minDistanceKm,
    required this.maxDistanceKm,
    required this.minOrderAmount,
    required this.maxOrderAmount,
    required this.baseCharge,
    required this.perKmCharge,
    required this.priority,
    required this.status,
  });

  factory RuleDistanceItem.fromJson(Map<String, dynamic> json) {
    return RuleDistanceItem(
      id: _parseInt(json['id']),
      minDistanceKm: _parseDouble(json['min_distance_km']),
      maxDistanceKm: _parseDouble(json['max_distance_km']),
      minOrderAmount: _parseDouble(json['min_order_amount']),
      maxOrderAmount: _parseDouble(json['max_order_amount']),
      baseCharge: _parseDouble(json['base_charge']),
      perKmCharge: _parseDouble(json['per_km_charge']),
      priority: _parseInt(json['priority']),
      status: _parseInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'min_distance_km': minDistanceKm,
    'max_distance_km': maxDistanceKm,
    'min_order_amount': minOrderAmount,
    'max_order_amount': maxOrderAmount,
    'base_charge': baseCharge,
    'per_km_charge': perKmCharge,
    'priority': priority,
    'status': status,
  };
}

// Decimal-safe helper functions
int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  return int.tryParse(str) ?? double.tryParse(str)?.toInt() ?? defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final String str = value.toString().trim();
  return double.tryParse(str) ?? defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim());
}
