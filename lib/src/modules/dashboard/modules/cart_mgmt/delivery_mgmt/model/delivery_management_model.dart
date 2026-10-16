import 'package:flutter/foundation.dart';

@immutable
class DeliveryRulesResponseModel {
  final bool status;
  final String message;
  final DeliveryRuleDataWrapper? data;

  const DeliveryRulesResponseModel({required this.status, required this.message, this.data});

  factory DeliveryRulesResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRulesResponseModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = rawStatus == true || rawStatus == 1 || rawStatus?.toString().trim().toLowerCase() == 'true';

    return DeliveryRulesResponseModel(
      status: parsedStatus,
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DeliveryRuleDataWrapper.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class DeliveryRuleDataWrapper {
  // Populated in list mode (without ID)
  final List<DeliveryRuleItem> rules;
  final DeliveryRulePagination? pagination;

  // Populated in detail mode (with ID)
  final int? singleId;
  final String? singleRuleName;
  final String? singleRuleType;
  final String? singleDescription;
  final int? singlePriority;
  final int? singleStatus;
  final DateTime? singleCreatedAt;
  final DateTime? singleUpdatedAt;
  final List<RuleAssignedPincodeItem> pincodes;
  final List<DeliveryRuleSlabItem> deliveryRules;

  const DeliveryRuleDataWrapper({
    this.rules = const [],
    this.pagination,
    this.singleId,
    this.singleRuleName,
    this.singleRuleType,
    this.singleDescription,
    this.singlePriority,
    this.singleStatus,
    this.singleCreatedAt,
    this.singleUpdatedAt,
    this.pincodes = const [],
    this.deliveryRules = const [],
  });

  bool get isSingleDetail => singleId != null && singleId! > 0;

  factory DeliveryRuleDataWrapper.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeliveryRuleDataWrapper();

    // Check if response is multiple rules list or single detail
    final dynamic rawRules = json['rules'];
    final List<DeliveryRuleItem> parsedRules = <DeliveryRuleItem>[];
    if (rawRules is List) {
      for (final item in rawRules) {
        if (item is Map<String, dynamic>) {
          parsedRules.add(DeliveryRuleItem.fromJson(item));
        }
      }
    }

    // Detail mode collections
    final List<RuleAssignedPincodeItem> parsedPins = <RuleAssignedPincodeItem>[];
    if (json['pincodes'] is List) {
      for (final item in json['pincodes'] as List) {
        if (item is Map<String, dynamic>) {
          parsedPins.add(RuleAssignedPincodeItem.fromJson(item));
        }
      }
    }

    final List<DeliveryRuleSlabItem> parsedSlabs = <DeliveryRuleSlabItem>[];
    final dynamic rawSlabs = json['delivery_rules'] ?? json['distance_rules'];
    if (rawSlabs is List) {
      for (final item in rawSlabs) {
        if (item is Map<String, dynamic>) {
          parsedSlabs.add(DeliveryRuleSlabItem.fromJson(item));
        }
      }
    }

    return DeliveryRuleDataWrapper(
      rules: List.unmodifiable(parsedRules),
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? DeliveryRulePagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      singleId: _parseNullableInt(json['id']),
      singleRuleName: json['rule_name']?.toString().trim(),
      singleRuleType: json['rule_type']?.toString().trim(),
      singleDescription: json['description']?.toString().trim(),
      singlePriority: _parseNullableInt(json['priority']),
      singleStatus: _parseNullableInt(json['status']),
      singleCreatedAt: _parseDate(json['created_at']),
      singleUpdatedAt: _parseDate(json['updated_at']),
      pincodes: List.unmodifiable(parsedPins),
      deliveryRules: List.unmodifiable(parsedSlabs),
    );
  }

  Map<String, dynamic> toJson() => {
    if (rules.isNotEmpty) 'rules': rules.map((x) => x.toJson()).toList(),
    if (pagination != null) 'pagination': pagination?.toJson(),
    if (singleId != null) 'id': singleId,
    if (singleRuleName != null) 'rule_name': singleRuleName,
    if (singleRuleType != null) 'rule_type': singleRuleType,
    if (singleDescription != null) 'description': singleDescription,
    if (singlePriority != null) 'priority': singlePriority,
    if (singleStatus != null) 'status': singleStatus,
    if (pincodes.isNotEmpty) 'pincodes': pincodes.map((x) => x.toJson()).toList(),
    if (deliveryRules.isNotEmpty) 'delivery_rules': deliveryRules.map((x) => x.toJson()).toList(),
  };
}

@immutable
class DeliveryRuleItem {
  final int id;
  final String ruleName;
  final String ruleType;
  final String description;
  final int priority;
  final int status;
  final int pincodeCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryRuleItem({
    required this.id,
    required this.ruleName,
    required this.ruleType,
    required this.description,
    required this.priority,
    required this.status,
    required this.pincodeCount,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  factory DeliveryRuleItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRuleItem(id: 0, ruleName: '', ruleType: 'amount', description: '', priority: 1, status: 1, pincodeCount: 0);
    }

    return DeliveryRuleItem(
      id: _parseInt(json['id']),
      ruleName: json['rule_name']?.toString().trim() ?? '',
      ruleType: json['rule_type']?.toString().trim() ?? 'amount',
      description: json['description']?.toString().trim() ?? '',
      priority: _parseInt(json['priority'], defaultValue: 1),
      status: _parseInt(json['status'], defaultValue: 1),
      pincodeCount: _parseInt(json['pincode_count']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rule_name': ruleName,
    'rule_type': ruleType,
    'description': description,
    'priority': priority,
    'status': status,
    'pincode_count': pincodeCount,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

@immutable
class RuleAssignedPincodeItem {
  final int id;
  final int pincodeId;
  final String pincode;
  final int priority;
  final int status;

  const RuleAssignedPincodeItem({required this.id, required this.pincodeId, required this.pincode, required this.priority, required this.status});

  factory RuleAssignedPincodeItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RuleAssignedPincodeItem(id: 0, pincodeId: 0, pincode: '', priority: 1, status: 1);
    }
    return RuleAssignedPincodeItem(
      id: _parseInt(json['id']),
      pincodeId: _parseInt(json['pincode_id']),
      pincode: json['pincode']?.toString().trim() ?? '',
      priority: _parseInt(json['priority'], defaultValue: 1),
      status: _parseInt(json['status'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'pincode_id': pincodeId, 'pincode': pincode, 'priority': priority, 'status': status};
}

@immutable
class DeliveryRuleSlabItem {
  final int? id;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double minOrderAmount;
  final double? maxOrderAmount;
  final double baseCharge;
  final double perKmCharge;
  final int priority;
  final int status;

  const DeliveryRuleSlabItem({
    this.id,
    this.minDistanceKm = 0.0,
    this.maxDistanceKm = 0.0,
    this.minOrderAmount = 0.0,
    this.maxOrderAmount,
    this.baseCharge = 0.0,
    this.perKmCharge = 0.0,
    this.priority = 1,
    this.status = 1,
  });

  factory DeliveryRuleSlabItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeliveryRuleSlabItem();

    return DeliveryRuleSlabItem(
      id: _parseNullableInt(json['id']),
      minDistanceKm: _parseDouble(json['min_distance'] ?? json['min_distance_km']),
      maxDistanceKm: _parseDouble(json['max_distance'] ?? json['max_distance_km']),
      minOrderAmount: _parseDouble(json['min_amount'] ?? json['min_order_amount']),
      maxOrderAmount: _parseNullableDouble(json['max_amount'] ?? json['max_order_amount']),
      baseCharge: _parseDouble(json['base_charge'] ?? json['charge']),
      perKmCharge: _parseDouble(json['per_km_charge']),
      priority: _parseInt(json['priority'], defaultValue: 1),
      status: _parseInt(json['status'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toSavePayloadJson({required String ruleType}) {
    final String cleanType = ruleType.trim().toLowerCase();

    // TYPE 1: DISTANCE => min_amount: 0, max_amount: 0
    // TYPE 2: AMOUNT => min_distance: 0, max_distance: 0, per_km_charge: 0
    // TYPE 3: BOTH / DISTANCE_AMOUNT => Send all actual fields
    final bool isDistanceOnly = cleanType == 'distance';
    final bool isAmountOnly = cleanType == 'amount';

    return {
      'min_distance': isAmountOnly ? 0 : minDistanceKm,
      'max_distance': isAmountOnly ? 0 : maxDistanceKm,
      'min_amount': isDistanceOnly ? 0 : minOrderAmount,
      'max_amount': isDistanceOnly ? 0 : (maxOrderAmount ?? 0),
      'base_charge': baseCharge,
      'per_km_charge': isAmountOnly ? 0 : perKmCharge,
      'priority': priority,
    };
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'min_distance': minDistanceKm,
    'max_distance': maxDistanceKm,
    'min_amount': minOrderAmount,
    'max_amount': maxOrderAmount,
    'base_charge': baseCharge,
    'per_km_charge': perKmCharge,
    'priority': priority,
    'status': status,
  };
}

@immutable
class DeliveryRulePagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const DeliveryRulePagination({required this.page, required this.limit, required this.total, required this.totalPages});

  factory DeliveryRulePagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRulePagination(page: 1, limit: 20, total: 0, totalPages: 1);
    }
    return DeliveryRulePagination(
      page: _parseInt(json['page'], defaultValue: 1),
      limit: _parseInt(json['limit'], defaultValue: 20),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['total_pages'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() => {'page': page, 'limit': limit, 'total': total, 'total_pages': totalPages};
}

// 2. PINCODES LOOKUP ENVELOPE (With & Without rule_id)
@immutable
class DeliveryRulePincodeListResponse {
  final bool status;
  final String message;
  final DeliveryRulePincodeData? data;

  const DeliveryRulePincodeListResponse({required this.status, required this.message, this.data});

  factory DeliveryRulePincodeListResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRulePincodeListResponse(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = rawStatus == true || rawStatus == 1 || rawStatus?.toString().trim().toLowerCase() == 'true';

    return DeliveryRulePincodeListResponse(
      status: parsedStatus,
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DeliveryRulePincodeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class DeliveryRulePincodeData {
  final int? ruleId;
  final String? ruleName;
  final int totalCount;
  final int selectedCount;
  final int freeCount;
  final List<DeliveryRulePincodeItem> pincodes;

  const DeliveryRulePincodeData({
    this.ruleId,
    this.ruleName,
    this.totalCount = 0,
    this.selectedCount = 0,
    this.freeCount = 0,
    this.pincodes = const [],
  });

  factory DeliveryRulePincodeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeliveryRulePincodeData();

    final List<DeliveryRulePincodeItem> parsedList = <DeliveryRulePincodeItem>[];
    if (json['pincodes'] is List) {
      for (final item in json['pincodes'] as List) {
        if (item is Map<String, dynamic>) {
          parsedList.add(DeliveryRulePincodeItem.fromJson(item));
        }
      }
    }

    return DeliveryRulePincodeData(
      ruleId: _parseNullableInt(json['rule_id']),
      ruleName: json['rule_name']?.toString().trim(),
      totalCount: _parseInt(json['total_count']),
      selectedCount: _parseInt(json['selected_count']),
      freeCount: _parseInt(json['free_count']),
      pincodes: List.unmodifiable(parsedList),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ruleId != null) 'rule_id': ruleId,
    if (ruleName != null) 'rule_name': ruleName,
    'total_count': totalCount,
    'selected_count': selectedCount,
    'free_count': freeCount,
    'pincodes': pincodes.map((e) => e.toJson()).toList(),
  };
}

@immutable
class DeliveryRulePincodeItem {
  final int id;
  final String pincode;
  final String firmName;
  final bool isSelected;
  final bool isAvailable;
  final int? assignedRuleId;
  final String? assignedRuleName;
  final String? assignedRuleType;

  const DeliveryRulePincodeItem({
    required this.id,
    required this.pincode,
    required this.firmName,
    required this.isSelected,
    required this.isAvailable,
    this.assignedRuleId,
    this.assignedRuleName,
    this.assignedRuleType,
  });

  DeliveryRulePincodeItem copyWith({
    int? id,
    String? pincode,
    String? firmName,
    bool? isSelected,
    bool? isAvailable,
    int? assignedRuleId,
    String? assignedRuleName,
    String? assignedRuleType,
  }) {
    return DeliveryRulePincodeItem(
      id: id ?? this.id,
      pincode: pincode ?? this.pincode,
      firmName: firmName ?? this.firmName,
      isSelected: isSelected ?? this.isSelected,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedRuleId: assignedRuleId ?? this.assignedRuleId,
      assignedRuleName: assignedRuleName ?? this.assignedRuleName,
      assignedRuleType: assignedRuleType ?? this.assignedRuleType,
    );
  }

  factory DeliveryRulePincodeItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryRulePincodeItem(id: 0, pincode: '', firmName: '', isSelected: false, isAvailable: true);
    }

    final dynamic rawSelected = json['is_selected'];
    final bool parsedSelected = rawSelected == true || rawSelected == 1 || rawSelected?.toString().trim().toLowerCase() == 'true';

    final dynamic rawAvailable = json['is_available'];
    final bool parsedAvailable = rawAvailable == true || rawAvailable == 1 || rawAvailable?.toString().trim().toLowerCase() == 'true';

    return DeliveryRulePincodeItem(
      id: _parseInt(json['id']),
      pincode: json['pincode']?.toString().trim() ?? '',
      firmName: json['firm_name']?.toString().trim() ?? '',
      isSelected: parsedSelected,
      isAvailable: parsedAvailable,
      assignedRuleId: _parseNullableInt(json['assigned_rule_id']),
      assignedRuleName: json['assigned_rule_name']?.toString().trim(),
      assignedRuleType: json['assigned_rule_type']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pincode': pincode,
    'firm_name': firmName,
    'is_selected': isSelected,
    'is_available': isAvailable,
    if (assignedRuleId != null) 'assigned_rule_id': assignedRuleId,
    if (assignedRuleName != null) 'assigned_rule_name': assignedRuleName,
    if (assignedRuleType != null) 'assigned_rule_type': assignedRuleType,
  };
}

// 3. SAVE RULE RESPONSE MODEL
@immutable
class SaveDeliveryRuleResponseModel {
  final bool status;
  final String message;
  final SaveDeliveryRuleData? data;

  const SaveDeliveryRuleResponseModel({required this.status, required this.message, this.data});

  factory SaveDeliveryRuleResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaveDeliveryRuleResponseModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = rawStatus == true || rawStatus == 1 || rawStatus?.toString().trim().toLowerCase() == 'true';

    return SaveDeliveryRuleResponseModel(
      status: parsedStatus,
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? SaveDeliveryRuleData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class SaveDeliveryRuleData {
  final int ruleId;
  final String ruleName;
  final String ruleType;
  final String description;
  final int priority;
  final int status;
  final int pincodeCount;
  final List<int> pincodeIds;
  final List<DeliveryRuleSlabItem> deliveryRules;

  const SaveDeliveryRuleData({
    required this.ruleId,
    required this.ruleName,
    required this.ruleType,
    required this.description,
    required this.priority,
    required this.status,
    required this.pincodeCount,
    this.pincodeIds = const [],
    this.deliveryRules = const [],
  });

  factory SaveDeliveryRuleData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaveDeliveryRuleData(ruleId: 0, ruleName: '', ruleType: 'amount', description: '', priority: 1, status: 1, pincodeCount: 0);
    }

    final List<int> parsedPinIds = <int>[];
    if (json['pincode_ids'] is List) {
      for (final e in json['pincode_ids'] as List) {
        final int? id = _parseNullableInt(e);
        if (id != null) parsedPinIds.add(id);
      }
    }

    final List<DeliveryRuleSlabItem> parsedSlabs = <DeliveryRuleSlabItem>[];
    if (json['delivery_rules'] is List) {
      for (final e in json['delivery_rules'] as List) {
        if (e is Map<String, dynamic>) {
          parsedSlabs.add(DeliveryRuleSlabItem.fromJson(e));
        }
      }
    }

    return SaveDeliveryRuleData(
      ruleId: _parseInt(json['rule_id'] ?? json['id']),
      ruleName: json['rule_name']?.toString().trim() ?? '',
      ruleType: json['rule_type']?.toString().trim() ?? 'amount',
      description: json['description']?.toString().trim() ?? '',
      priority: _parseInt(json['priority'], defaultValue: 1),
      status: _parseInt(json['status'], defaultValue: 1),
      pincodeCount: _parseInt(json['pincode_count']),
      pincodeIds: List.unmodifiable(parsedPinIds),
      deliveryRules: List.unmodifiable(parsedSlabs),
    );
  }

  Map<String, dynamic> toJson() => {
    'rule_id': ruleId,
    'rule_name': ruleName,
    'rule_type': ruleType,
    'description': description,
    'priority': priority,
    'status': status,
    'pincode_count': pincodeCount,
    'pincode_ids': pincodeIds,
    'delivery_rules': deliveryRules.map((e) => e.toJson()).toList(),
  };
}

// HELPER CONVERTERS
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
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
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

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final String str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  return double.tryParse(str);
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) {
    return value.year >= 1970 ? value : null;
  }
  final String dateStr = value.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00')) {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }
  return parsed;
}
