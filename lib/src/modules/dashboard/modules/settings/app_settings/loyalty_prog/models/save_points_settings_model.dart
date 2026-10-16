import 'package:flutter/foundation.dart';

@immutable
class SavePointsSettingsModel {
  final bool success;
  final String message;
  final PointsSettingsData? data;

  const SavePointsSettingsModel({required this.success, required this.message, this.data});

  SavePointsSettingsModel copyWith({bool? success, String? message, PointsSettingsData? data}) {
    return SavePointsSettingsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory SavePointsSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SavePointsSettingsModel(success: false, message: 'Empty payload received');
    }

    return SavePointsSettingsModel(
      success: json['success'] == true || json['status'] == 1 || json['status'] == true,
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? PointsSettingsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, 'data': data?.toJson()};

  @override
  String toString() => 'SavePointsSettingsModel(success: $success, message: $message, data: $data)';
}

@immutable
class PointsSettingsData {
  final int? id;
  final double rupeesPerPoint;
  final double pointsPerRupee;
  final String loyaltyConflictPriority;
  final num newCustReward;
  final num custReffReward;
  final DateTime? updatedAt;

  const PointsSettingsData({
    this.id,
    required this.rupeesPerPoint,
    required this.pointsPerRupee,
    required this.loyaltyConflictPriority,
    required this.newCustReward,
    required this.custReffReward,
    this.updatedAt,
  });

  PointsSettingsData copyWith({
    int? id,
    double? rupeesPerPoint,
    double? pointsPerRupee,
    String? loyaltyConflictPriority,
    num? newCustReward,
    num? custReffReward,
    DateTime? updatedAt,
  }) {
    return PointsSettingsData(
      id: id ?? this.id,
      rupeesPerPoint: rupeesPerPoint ?? this.rupeesPerPoint,
      pointsPerRupee: pointsPerRupee ?? this.pointsPerRupee,
      loyaltyConflictPriority: loyaltyConflictPriority ?? this.loyaltyConflictPriority,
      newCustReward: newCustReward ?? this.newCustReward,
      custReffReward: custReffReward ?? this.custReffReward,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PointsSettingsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PointsSettingsData(
        rupeesPerPoint: 0.0,
        pointsPerRupee: 0.0,
        loyaltyConflictPriority: 'category',
        newCustReward: 0,
        custReffReward: 0,
      );
    }

    return PointsSettingsData(
      id: _parseNullableInt(json['id']),
      rupeesPerPoint: _parseDouble(json['rupees_per_point']),
      pointsPerRupee: _parseDouble(json['points_per_rupee']),
      loyaltyConflictPriority: json['loyalty_conflict_priority']?.toString().trim() ?? 'category',
      newCustReward: _parseNum(json['new_cust_reward']),
      custReffReward: _parseNum(json['cust_reff_reward']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'rupees_per_point': rupeesPerPoint,
    'points_per_rupee': pointsPerRupee,
    'loyalty_conflict_priority': loyaltyConflictPriority,
    'new_cust_reward': newCustReward,
    'cust_reff_reward': custReffReward,
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  @override
  String toString() =>
      'PointsSettingsData(id: $id, rupeesPerPoint: $rupeesPerPoint, pointsPerRupee: $pointsPerRupee, priority: $loyaltyConflictPriority, newCustReward: $newCustReward, custReffReward: $custReffReward)';
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  return int.tryParse(str);
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? 0.0;
}

num _parseNum(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  return num.tryParse(value.toString().trim()) ?? 0;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final String str = value.toString().trim();
  if (str.isEmpty || str.startsWith('0000')) return null;
  return DateTime.tryParse(str);
}
