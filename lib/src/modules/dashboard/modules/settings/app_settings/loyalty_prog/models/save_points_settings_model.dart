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
      return const SavePointsSettingsModel(success: false, message: 'Empty payload received from server.', data: null);
    }

    return SavePointsSettingsModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? PointsSettingsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};

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

  bool get isCategoryPrecedence => loyaltyConflictPriority.toLowerCase() == 'category';

  bool get isBrandPrecedence => loyaltyConflictPriority.toLowerCase() == 'brand';

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
        id: null,
        rupeesPerPoint: 0.50,
        pointsPerRupee: 2.00,
        loyaltyConflictPriority: 'category',
        newCustReward: 100,
        custReffReward: 50,
        updatedAt: null,
      );
    }

    return PointsSettingsData(
      id: _parseNullableInt(json['id']),
      rupeesPerPoint: _parseDouble(json['rupees_per_point'], defaultValue: 0.50),
      pointsPerRupee: _parseDouble(json['points_per_rupee'], defaultValue: 2.00),
      loyaltyConflictPriority: _parseCleanString(json['loyalty_conflict_priority'], fallback: 'category'),
      newCustReward: _parseNum(json['new_cust_reward'], defaultValue: 100),
      custReffReward: _parseNum(json['cust_reff_reward'], defaultValue: 50),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'rupees_per_point': rupeesPerPoint,
    'points_per_rupee': pointsPerRupee,
    'loyalty_conflict_priority': loyaltyConflictPriority,
    'new_cust_reward': newCustReward,
    'cust_reff_reward': custReffReward,
    if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
  };

  @override
  String toString() =>
      'PointsSettingsData(id: $id, rupeesPerPoint: $rupeesPerPoint, pointsPerRupee: $pointsPerRupee, priority: $loyaltyConflictPriority, newCust: $newCustReward, referral: $custReffReward)';
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val == 1;
  final String str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true' || str == 'active' || str == 'y';
}

int? _parseNullableInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final String str = val.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  return int.tryParse(str);
}

double _parseDouble(dynamic val, {double defaultValue = 0.0}) {
  if (val == null) return defaultValue;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  final String str = val.toString().trim();
  final double? parsed = double.tryParse(str);
  return parsed ?? defaultValue;
}

num _parseNum(dynamic val, {num defaultValue = 0}) {
  if (val == null) return defaultValue;
  if (val is num) return val;
  final String str = val.toString().trim();
  final num? parsed = num.tryParse(str);
  return parsed ?? defaultValue;
}

String _parseCleanString(dynamic val, {String fallback = ''}) {
  if (val == null) return fallback;
  final String str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return fallback;
  return str;
}

DateTime? _parseDate(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) {
    return val.year >= 1970 ? val : null;
  }
  final String dateStr = val.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00') || dateStr == 'null' || dateStr == 'undefined') {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }
  return parsed;
}
