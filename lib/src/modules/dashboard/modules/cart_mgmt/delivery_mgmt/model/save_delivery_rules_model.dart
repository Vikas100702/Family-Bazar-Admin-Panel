import 'package:flutter/foundation.dart';

@immutable
class SaveDeliveryRulesModel {
  final bool status;
  final String message;
  final SaveDeliveryRuleData? data;

  const SaveDeliveryRulesModel({required this.status, required this.message, this.data});

  SaveDeliveryRulesModel copyWith({bool? status, String? message, SaveDeliveryRuleData? data}) {
    return SaveDeliveryRulesModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory SaveDeliveryRulesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaveDeliveryRulesModel(status: false, message: 'Empty response payload received.');
    }

    return SaveDeliveryRulesModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? SaveDeliveryRuleData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'data': data?.toJson()};

  @override
  String toString() => 'SaveDeliveryRulesModel(status: $status, message: $message, data: $data)';
}

@immutable
class SaveDeliveryRuleData {
  final int ruleId;
  final String ruleName;
  final String description;
  final int priority;
  final int status;
  final List<int> pincodeIds;

  const SaveDeliveryRuleData({
    required this.ruleId,
    required this.ruleName,
    required this.description,
    required this.priority,
    required this.status,
    required this.pincodeIds,
  });

  SaveDeliveryRuleData copyWith({int? ruleId, String? ruleName, String? description, int? priority, int? status, List<int>? pincodeIds}) {
    return SaveDeliveryRuleData(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      pincodeIds: pincodeIds ?? this.pincodeIds,
    );
  }

  factory SaveDeliveryRuleData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaveDeliveryRuleData(ruleId: 0, ruleName: '', description: '', priority: 0, status: 0, pincodeIds: <int>[]);
    }

    // Defensive parsing for IDs and numeric flags
    final dynamic rawRuleId = json['rule_id'] ?? json['id'];
    final int parsedRuleId = rawRuleId is int ? rawRuleId : int.tryParse(rawRuleId?.toString() ?? '') ?? 0;

    final dynamic rawPriority = json['priority'];
    final int parsedPriority = rawPriority is int ? rawPriority : int.tryParse(rawPriority?.toString() ?? '') ?? 0;

    final dynamic rawStatus = json['status'];
    final int parsedStatus = rawStatus is int ? rawStatus : int.tryParse(rawStatus?.toString() ?? '') ?? 0;

    // Type-safe extraction of pin code ID list
    final List<int> parsedPincodeIds = <int>[];
    if (json['pincode_ids'] is List) {
      for (final item in json['pincode_ids'] as List) {
        if (item is int) {
          parsedPincodeIds.add(item);
        } else if (item != null) {
          final int? converted = int.tryParse(item.toString());
          if (converted != null) {
            parsedPincodeIds.add(converted);
          }
        }
      }
    }

    return SaveDeliveryRuleData(
      ruleId: parsedRuleId,
      ruleName: json['rule_name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      priority: parsedPriority,
      status: parsedStatus,
      pincodeIds: List<int>.unmodifiable(parsedPincodeIds),
    );
  }

  Map<String, dynamic> toJson() => {
    'rule_id': ruleId,
    'rule_name': ruleName,
    'description': description,
    'priority': priority,
    'status': status,
    'pincode_ids': pincodeIds,
  };

  @override
  String toString() =>
      'SaveDeliveryRuleData(ruleId: $ruleId, ruleName: $ruleName, description: $description, priority: $priority, status: $status, pincodeIds: $pincodeIds)';
}
