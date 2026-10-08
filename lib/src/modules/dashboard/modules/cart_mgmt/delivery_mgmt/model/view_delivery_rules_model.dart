import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/model/add_distance_rule_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class ViewDeliveryRulesModel {
  final bool status;
  final String message;
  final ViewDeliveryRulesData? data;

  const ViewDeliveryRulesModel({required this.status, required this.message, this.data});

  ViewDeliveryRulesModel copyWith({bool? status, String? message, ViewDeliveryRulesData? data}) {
    return ViewDeliveryRulesModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewDeliveryRulesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewDeliveryRulesModel(status: false, message: 'Empty response received from server.');
    }

    return ViewDeliveryRulesModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ViewDeliveryRulesData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'data': data?.toJson()};

  @override
  String toString() => 'ViewDeliveryRulesModel(status: $status, message: $message, data: $data)';
}

@immutable
class ViewDeliveryRulesData {
  final List<Rule> rules;
  final Pagination? pagination;

  const ViewDeliveryRulesData({required this.rules, this.pagination});

  ViewDeliveryRulesData copyWith({List<Rule>? rules, Pagination? pagination}) {
    return ViewDeliveryRulesData(rules: rules ?? this.rules, pagination: pagination ?? this.pagination);
  }

  factory ViewDeliveryRulesData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewDeliveryRulesData(rules: <Rule>[]);
    }

    final List<Rule> parsedRules = <Rule>[];
    if (json['rules'] is List) {
      for (final item in json['rules'] as List) {
        if (item is Map<String, dynamic>) {
          parsedRules.add(Rule.fromJson(item));
        }
      }
    }

    return ViewDeliveryRulesData(
      rules: List<Rule>.unmodifiable(parsedRules),
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'rules': rules.map((x) => x.toJson()).toList(), 'pagination': pagination?.toJson()};

  @override
  String toString() => 'ViewDeliveryRulesData(rules: $rules, pagination: $pagination)';
}

@immutable
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const Pagination({required this.page, required this.limit, required this.total, required this.totalPages});

  Pagination copyWith({int? page, int? limit, int? total, int? totalPages}) {
    return Pagination(page: page ?? this.page, limit: limit ?? this.limit, total: total ?? this.total, totalPages: totalPages ?? this.totalPages);
  }

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Pagination(page: 1, limit: 20, total: 0, totalPages: 0);
    }

    return Pagination(
      page: _parseInt(json['page'], defaultValue: 1),
      limit: _parseInt(json['limit'], defaultValue: 20),
      total: _parseInt(json['total'], defaultValue: 0),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages'], defaultValue: 0),
    );
  }

  Map<String, dynamic> toJson() => {'page': page, 'limit': limit, 'total': total, 'total_pages': totalPages};

  @override
  String toString() => 'Pagination(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}

@immutable
class Rule {
  final int id;
  final String ruleName;
  final String description;
  final int priority;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int pincodeCount;
  final List<int> pincodeIds;
  final List<String> pincodes;
  final List<DistanceSlabData> distanceSlabs;

  const Rule({
    required this.id,
    required this.ruleName,
    required this.description,
    required this.priority,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.pincodeCount,
    this.pincodeIds = const <int>[],
    this.pincodes = const <String>[],
    this.distanceSlabs = const <DistanceSlabData>[],
  });

  bool get isActive => status == 1;
  bool get ruleStatus => status == 1;
  bool get hasSlabs => distanceSlabs.isNotEmpty;

  Rule copyWith({
    int? id,
    String? ruleName,
    String? description,
    int? priority,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? pincodeCount,
    List<int>? pincodeIds,
    List<String>? pincodes,
    List<DistanceSlabData>? distanceSlabs,
  }) {
    return Rule(
      id: id ?? this.id,
      ruleName: ruleName ?? this.ruleName,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pincodeCount: pincodeCount ?? this.pincodeCount,
      pincodeIds: pincodeIds ?? this.pincodeIds,
      pincodes: pincodes ?? this.pincodes,
      distanceSlabs: distanceSlabs ?? this.distanceSlabs,
    );
  }

  factory Rule.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Rule(id: 0, ruleName: '', description: '', priority: 0, status: 0, pincodeCount: 0);
    }

    final int parsedId = _parseInt(json['id'] ?? json['rule_id'], defaultValue: 0);
    final int parsedPriority = _parseInt(json['priority'], defaultValue: 0);
    final int parsedStatus = _parseInt(json['status'], defaultValue: 0);

    // Defensive parsing of pincode IDs
    final List<int> parsedPincodeIds = <int>[];
    final dynamic rawPincodeIds = json['pincode_ids'] ?? json['pincodes_ids'];
    if (rawPincodeIds is List) {
      for (final item in rawPincodeIds) {
        final int val = _parseInt(item, defaultValue: -1);
        if (val != -1) parsedPincodeIds.add(val);
      }
    } else if (rawPincodeIds is String && rawPincodeIds.trim().isNotEmpty) {
      for (final segment in rawPincodeIds.split(',')) {
        final int val = _parseInt(segment.trim(), defaultValue: -1);
        if (val != -1) parsedPincodeIds.add(val);
      }
    }

    // Defensive parsing of pincode strings
    final List<String> parsedPincodes = <String>[];
    final dynamic rawPincodes = json['pincodes'] ?? json['pincode_list'];
    if (rawPincodes is List) {
      for (final item in rawPincodes) {
        if (item != null) {
          final String pinStr = item.toString().trim();
          if (pinStr.isNotEmpty) parsedPincodes.add(pinStr);
        }
      }
    } else if (rawPincodes is String && rawPincodes.trim().isNotEmpty) {
      for (final segment in rawPincodes.split(',')) {
        final String pinStr = segment.trim();
        if (pinStr.isNotEmpty) parsedPincodes.add(pinStr);
      }
    }

    // Defensive parsing of Distance Slabs attached to this rule
    final List<DistanceSlabData> parsedSlabs = <DistanceSlabData>[];
    final dynamic rawSlabs = json['distance_slabs'] ?? json['slabs'] ?? json['distance_rules'] ?? json['distanceSlabs'];
    if (rawSlabs is List) {
      for (final item in rawSlabs) {
        if (item is Map<String, dynamic>) {
          parsedSlabs.add(DistanceSlabData.fromJson(item));
        }
      }
    }

    final int rawCount = _parseInt(json['pincode_count'], defaultValue: 0);
    final int resolvedPincodeCount = rawCount > 0 ? rawCount : (parsedPincodeIds.isNotEmpty ? parsedPincodeIds.length : parsedPincodes.length);

    return Rule(
      id: parsedId,
      ruleName: json['rule_name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      priority: parsedPriority,
      status: parsedStatus,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      pincodeCount: resolvedPincodeCount,
      pincodeIds: List<int>.unmodifiable(parsedPincodeIds),
      pincodes: List<String>.unmodifiable(parsedPincodes),
      distanceSlabs: List<DistanceSlabData>.unmodifiable(parsedSlabs),
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
    'pincode_count': pincodeCount,
    'pincode_ids': pincodeIds,
    'pincodes': pincodes,
    'distance_slabs': distanceSlabs.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() =>
      'Rule(id: $id, ruleName: $ruleName, priority: $priority, status: $status, pincodeCount: $pincodeCount, slabs: ${distanceSlabs.length})';
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim());
}
