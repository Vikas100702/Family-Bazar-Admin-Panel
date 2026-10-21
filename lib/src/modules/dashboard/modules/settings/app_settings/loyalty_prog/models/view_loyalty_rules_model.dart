import 'package:flutter/foundation.dart';

@immutable
class ViewLoyaltyRulesModel {
  final bool success;
  final String message;
  final LoyaltyPagination? pagination;
  final List<LoyaltyRuleDatum> data;

  const ViewLoyaltyRulesModel({required this.success, required this.message, this.pagination, this.data = const <LoyaltyRuleDatum>[]});

  ViewLoyaltyRulesModel copyWith({bool? success, String? message, LoyaltyPagination? pagination, List<LoyaltyRuleDatum>? data}) {
    return ViewLoyaltyRulesModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewLoyaltyRulesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewLoyaltyRulesModel(
        success: false,
        message: 'Empty payload received from server.',
        pagination: null,
        data: <LoyaltyRuleDatum>[],
      );
    }

    final dynamic rawData = json['data'];
    final List<LoyaltyRuleDatum> parsedData = <LoyaltyRuleDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(LoyaltyRuleDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(LoyaltyRuleDatum.fromJson(rawData));
    }

    return ViewLoyaltyRulesModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? LoyaltyPagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<LoyaltyRuleDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewLoyaltyRulesModel(success: $success, message: $message, count: ${data.length})';
}

@immutable
class LoyaltyRuleDatum {
  final int id;
  final String ruleName;
  final double minOrderAmt;
  final double? maxOrderAmt;
  final double pointsValue;
  final int status;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<LoyaltyBrand> brands;
  final List<LoyaltyCategory> categories;

  const LoyaltyRuleDatum({
    required this.id,
    required this.ruleName,
    required this.minOrderAmt,
    this.maxOrderAmt,
    required this.pointsValue,
    required this.status,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.brands = const <LoyaltyBrand>[],
    this.categories = const <LoyaltyCategory>[],
  });

  bool get isActive => status == 1;

  LoyaltyRuleDatum copyWith({
    int? id,
    String? ruleName,
    double? minOrderAmt,
    double? maxOrderAmt,
    double? pointsValue,
    int? status,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LoyaltyBrand>? brands,
    List<LoyaltyCategory>? categories,
  }) {
    return LoyaltyRuleDatum(
      id: id ?? this.id,
      ruleName: ruleName ?? this.ruleName,
      minOrderAmt: minOrderAmt ?? this.minOrderAmt,
      maxOrderAmt: maxOrderAmt ?? this.maxOrderAmt,
      pointsValue: pointsValue ?? this.pointsValue,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brands: brands ?? this.brands,
      categories: categories ?? this.categories,
    );
  }

  factory LoyaltyRuleDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LoyaltyRuleDatum(id: 0, ruleName: '', minOrderAmt: 0.0, pointsValue: 0.0, status: 0);
    }

    final List<LoyaltyBrand> parsedBrands = <LoyaltyBrand>[];
    if (json['brands'] is List) {
      for (final item in json['brands'] as List) {
        if (item is Map<String, dynamic>) {
          parsedBrands.add(LoyaltyBrand.fromJson(item));
        }
      }
    }

    final List<LoyaltyCategory> parsedCats = <LoyaltyCategory>[];
    if (json['categories'] is List) {
      for (final item in json['categories'] as List) {
        if (item is Map<String, dynamic>) {
          parsedCats.add(LoyaltyCategory.fromJson(item));
        }
      }
    }

    return LoyaltyRuleDatum(
      id: _parseInt(json['id']),
      ruleName: _parseCleanString(json['rule_name'] ?? json['ruleName']),
      minOrderAmt: _parseDouble(json['min_order_amt'] ?? json['minOrderAmt']),
      maxOrderAmt: _parseNullableDouble(json['max_order_amt'] ?? json['maxOrderAmt']),
      pointsValue: _parseDouble(json['points_value'] ?? json['pointsValue']),
      status: _parseInt(json['status'], defaultValue: 1),
      expiryDate: _parseDate(json['expiry_date'] ?? json['expiryDate']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      brands: List<LoyaltyBrand>.unmodifiable(parsedBrands),
      categories: List<LoyaltyCategory>.unmodifiable(parsedCats),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rule_name': ruleName,
    'min_order_amt': minOrderAmt,
    if (maxOrderAmt != null) 'max_order_amt': maxOrderAmt,
    'points_value': pointsValue,
    'status': status,
    if (expiryDate != null)
      'expiry_date':
          '${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}',
    if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    'brands': brands.map((x) => x.toJson()).toList(growable: false),
    'categories': categories.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'LoyaltyRuleDatum(id: $id, ruleName: $ruleName, minAmt: $minOrderAmt, points: $pointsValue, status: $status)';
}

@immutable
class AvailableItemsModel {
  final bool success;
  final String message;
  final List<LoyaltyBrand> brands;
  final List<LoyaltyCategory> categories;

  const AvailableItemsModel({
    required this.success,
    required this.message,
    this.brands = const <LoyaltyBrand>[],
    this.categories = const <LoyaltyCategory>[],
  });

  factory AvailableItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AvailableItemsModel(success: false, message: 'Empty options payload received.');
    }

    final dynamic data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final List<LoyaltyBrand> parsedBrands = <LoyaltyBrand>[];
    if (data['brands'] is List) {
      for (final item in data['brands'] as List) {
        if (item is Map<String, dynamic>) {
          parsedBrands.add(LoyaltyBrand.fromJson(item));
        }
      }
    }

    final List<LoyaltyCategory> parsedCats = <LoyaltyCategory>[];
    if (data['categories'] is List) {
      for (final item in data['categories'] as List) {
        if (item is Map<String, dynamic>) {
          parsedCats.add(LoyaltyCategory.fromJson(item));
        }
      }
    }

    return AvailableItemsModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      brands: List<LoyaltyBrand>.unmodifiable(parsedBrands),
      categories: List<LoyaltyCategory>.unmodifiable(parsedCats),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': {
      'brands': brands.map((x) => x.toJson()).toList(growable: false),
      'categories': categories.map((x) => x.toJson()).toList(growable: false),
    },
  };
}

@immutable
class SaveLoyaltyRuleModel {
  final bool success;
  final String message;
  final LoyaltyRuleDatum? data;

  const SaveLoyaltyRuleModel({required this.success, required this.message, this.data});

  factory SaveLoyaltyRuleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaveLoyaltyRuleModel(success: false, message: 'Empty response payload received.');
    }

    return SaveLoyaltyRuleModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] is Map<String, dynamic> ? LoyaltyRuleDatum.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class LoyaltyBrand {
  final int id;
  final int? ruleId;
  final int brandId;
  final String brandCode;
  final String brandName;
  final int isSelected;
  final int status;

  const LoyaltyBrand({
    required this.id,
    this.ruleId,
    required this.brandId,
    required this.brandCode,
    required this.brandName,
    this.isSelected = 0,
    this.status = 1,
  });

  LoyaltyBrand copyWith({int? id, int? ruleId, int? brandId, String? brandCode, String? brandName, int? isSelected, int? status}) {
    return LoyaltyBrand(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      brandId: brandId ?? this.brandId,
      brandCode: brandCode ?? this.brandCode,
      brandName: brandName ?? this.brandName,
      isSelected: isSelected ?? this.isSelected,
      status: status ?? this.status,
    );
  }

  factory LoyaltyBrand.fromJson(Map<String, dynamic> json) {
    return LoyaltyBrand(
      id: _parseInt(json['id']),
      ruleId: _parseNullableInt(json['rule_id'] ?? json['ruleId']),
      brandId: _parseInt(json['brand_id'] ?? json['brandId'] ?? json['id']),
      brandCode: _parseCleanString(json['brand_code'] ?? json['brandCode']),
      brandName: _parseCleanString(json['brand_name'] ?? json['brandName']),
      isSelected: _parseInt(json['is_selected'] ?? json['isSelected']),
      status: _parseInt(json['status'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (ruleId != null) 'rule_id': ruleId,
    'brand_id': brandId,
    'brand_code': brandCode,
    'brand_name': brandName,
    'is_selected': isSelected,
    'status': status,
  };
}

@immutable
class LoyaltyCategory {
  final int id;
  final int? ruleId;
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final int isSelected;
  final int status;

  const LoyaltyCategory({
    required this.id,
    this.ruleId,
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    this.isSelected = 0,
    this.status = 1,
  });

  LoyaltyCategory copyWith({int? id, int? ruleId, int? categoryId, String? categoryCode, String? categoryName, int? isSelected, int? status}) {
    return LoyaltyCategory(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      categoryId: categoryId ?? this.categoryId,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      isSelected: isSelected ?? this.isSelected,
      status: status ?? this.status,
    );
  }

  factory LoyaltyCategory.fromJson(Map<String, dynamic> json) {
    return LoyaltyCategory(
      id: _parseInt(json['id']),
      ruleId: _parseNullableInt(json['rule_id'] ?? json['ruleId']),
      categoryId: _parseInt(json['category_id'] ?? json['categoryId'] ?? json['id']),
      categoryCode: _parseCleanString(json['category_code'] ?? json['categoryCode']),
      categoryName: _parseCleanString(json['category_name'] ?? json['categoryName']),
      isSelected: _parseInt(json['is_selected'] ?? json['isSelected']),
      status: _parseInt(json['status'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (ruleId != null) 'rule_id': ruleId,
    'category_id': categoryId,
    'category_code': categoryCode,
    'category_name': categoryName,
    'is_selected': isSelected,
    'status': status,
  };
}

@immutable
class LoyaltyPagination {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int limit;

  const LoyaltyPagination({required this.totalRecords, required this.totalPages, required this.currentPage, required this.limit});

  factory LoyaltyPagination.fromJson(Map<String, dynamic> json) {
    return LoyaltyPagination(
      totalRecords: _parseInt(json['total_records'] ?? json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages'], defaultValue: 1),
      currentPage: _parseInt(json['current_page'] ?? json['page'], defaultValue: 1),
      limit: _parseInt(json['limit'] ?? json['per_page'], defaultValue: 20),
    );
  }

  Map<String, dynamic> toJson() => {'total_records': totalRecords, 'total_pages': totalPages, 'current_page': currentPage, 'limit': limit};
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val == 1;
  final String str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true' || str == 'active' || str == 'y';
}

int _parseInt(dynamic val, {int defaultValue = 0}) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final String str = val.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return defaultValue;
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

double? _parseNullableDouble(dynamic val) {
  if (val == null) return null;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  final String str = val.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  return double.tryParse(str);
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
