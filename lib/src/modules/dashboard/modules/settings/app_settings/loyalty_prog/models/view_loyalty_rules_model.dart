import 'package:flutter/foundation.dart';

@immutable
class ViewLoyaltyRulesModel {
  final bool success;
  final String message;
  final LoyaltyPagination? pagination;
  final List<LoyaltyRuleDatum> data;

  const ViewLoyaltyRulesModel({required this.success, required this.message, this.pagination, this.data = const []});

  factory ViewLoyaltyRulesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewLoyaltyRulesModel(success: false, message: 'Empty payload');
    }

    // Defensive parsing: Handle both List (GetAll) and Map (GetById) structures safely
    List<LoyaltyRuleDatum> parsedData = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        parsedData = (json['data'] as List).whereType<Map<String, dynamic>>().map((x) => LoyaltyRuleDatum.fromJson(x)).toList();
      } else if (json['data'] is Map<String, dynamic>) {
        parsedData = [LoyaltyRuleDatum.fromJson(json['data'] as Map<String, dynamic>)];
      }
    }

    return ViewLoyaltyRulesModel(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString().trim() ?? '',
      pagination: json['pagination'] is Map<String, dynamic> ? LoyaltyPagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List.unmodifiable(parsedData),
    );
  }
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
    this.brands = const [],
    this.categories = const [],
  });

  bool get isActive => status == 1;

  factory LoyaltyRuleDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LoyaltyRuleDatum(id: 0, ruleName: '', minOrderAmt: 0, pointsValue: 0, status: 0);
    }
    return LoyaltyRuleDatum(
      id: _parseInt(json['id']),
      ruleName: json['rule_name']?.toString().trim() ?? '',
      minOrderAmt: _parseDouble(json['min_order_amt']),
      maxOrderAmt: _parseNullableDouble(json['max_order_amt']),
      pointsValue: _parseDouble(json['points_value']),
      status: _parseInt(json['status']),
      expiryDate: _parseDate(json['expiry_date']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      brands: json['brands'] is List ? (json['brands'] as List).whereType<Map<String, dynamic>>().map((x) => LoyaltyBrand.fromJson(x)).toList() : [],
      categories: json['categories'] is List
          ? (json['categories'] as List).whereType<Map<String, dynamic>>().map((x) => LoyaltyCategory.fromJson(x)).toList()
          : [],
    );
  }
}

@immutable
class AvailableItemsModel {
  final bool success;
  final String message;
  final List<LoyaltyBrand> brands;
  final List<LoyaltyCategory> categories;

  const AvailableItemsModel({required this.success, required this.message, this.brands = const [], this.categories = const []});

  factory AvailableItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AvailableItemsModel(success: false, message: 'Empty payload');

    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : {};
    return AvailableItemsModel(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString().trim() ?? '',
      brands: data['brands'] is List ? (data['brands'] as List).whereType<Map<String, dynamic>>().map((x) => LoyaltyBrand.fromJson(x)).toList() : [],
      categories: data['categories'] is List
          ? (data['categories'] as List).whereType<Map<String, dynamic>>().map((x) => LoyaltyCategory.fromJson(x)).toList()
          : [],
    );
  }
}

@immutable
class SaveLoyaltyRuleModel {
  final bool success;
  final String message;
  final LoyaltyRuleDatum? data;

  const SaveLoyaltyRuleModel({required this.success, required this.message, this.data});

  factory SaveLoyaltyRuleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SaveLoyaltyRuleModel(success: false, message: 'Empty payload');
    return SaveLoyaltyRuleModel(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] is Map<String, dynamic> ? LoyaltyRuleDatum.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

@immutable
class LoyaltyBrand {
  final int id;
  final int? ruleId;
  final int brandId;
  final String brandCode;
  final String brandName;
  final int isSelected; // Used in dropdown
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

  factory LoyaltyBrand.fromJson(Map<String, dynamic> json) {
    return LoyaltyBrand(
      id: _parseInt(json['id']),
      ruleId: json['rule_id'] != null ? _parseInt(json['rule_id']) : null,
      brandId: _parseInt(json['brand_id']),
      brandCode: json['brand_code']?.toString().trim() ?? '',
      brandName: json['brand_name']?.toString().trim() ?? '',
      isSelected: _parseInt(json['is_selected'] ?? json['status']),
      status: _parseInt(json['status'] ?? json['is_selected']),
    );
  }

  Map<String, dynamic> toJson() => {'brand_id': brandId};
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

  factory LoyaltyCategory.fromJson(Map<String, dynamic> json) {
    return LoyaltyCategory(
      id: _parseInt(json['id']),
      ruleId: json['rule_id'] != null ? _parseInt(json['rule_id']) : null,
      categoryId: _parseInt(json['category_id'] ?? json['id']),
      categoryCode: json['category_code']?.toString().trim() ?? '',
      categoryName: json['category_name']?.toString().trim() ?? '',
      isSelected: _parseInt(json['is_selected'] ?? json['status']),
      status: _parseInt(json['status'] ?? json['is_selected']),
    );
  }

  Map<String, dynamic> toJson() => {'category_id': categoryId};
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
      totalRecords: _parseInt(json['total_records']),
      totalPages: _parseInt(json['total_pages']),
      currentPage: _parseInt(json['current_page']),
      limit: _parseInt(json['limit']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? 0.0;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  final String str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  return double.tryParse(str);
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final String dateStr = value.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000')) return null;
  return DateTime.tryParse(dateStr);
}
