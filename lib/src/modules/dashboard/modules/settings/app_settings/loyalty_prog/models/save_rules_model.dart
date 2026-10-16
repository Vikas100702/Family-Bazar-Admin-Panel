class SaveRulesModel {
  SaveRulesModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final SaveRulesData? data;

  SaveRulesModel copyWith({bool? success, String? message, SaveRulesData? data}) {
    return SaveRulesModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory SaveRulesModel.fromJson(Map<String, dynamic> json) {
    return SaveRulesModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : SaveRulesData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class SaveRulesData {
  SaveRulesData({
    required this.id,
    required this.ruleName,
    required this.minOrderAmt,
    required this.maxOrderAmt,
    required this.pointsValue,
    required this.status,
    required this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.brands,
    required this.categories,
  });

  final int id;
  final String ruleName;
  final String minOrderAmt;
  final String maxOrderAmt;
  final String pointsValue;
  final int status;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Brand> brands;
  final List<Category> categories;

  SaveRulesData copyWith({
    int? id,
    String? ruleName,
    String? minOrderAmt,
    String? maxOrderAmt,
    String? pointsValue,
    int? status,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Brand>? brands,
    List<Category>? categories,
  }) {
    return SaveRulesData(
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

  factory SaveRulesData.fromJson(Map<String, dynamic> json) {
    return SaveRulesData(
      id: json["id"] ?? 0,
      ruleName: json["rule_name"] ?? "",
      minOrderAmt: json["min_order_amt"] ?? "",
      maxOrderAmt: json["max_order_amt"],
      pointsValue: json["points_value"] ?? "",
      status: json["status"] ?? 0,
      expiryDate: DateTime.tryParse(json["expiry_date"] ?? ""),
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      brands: json["brands"] == null ? [] : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
      categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "rule_name": ruleName,
    "min_order_amt": minOrderAmt,
    "max_order_amt": maxOrderAmt,
    "points_value": pointsValue,
    "status": status,
    "expiry_date": expiryDate == null
        ? null
        : "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}",
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "brands": brands.map((x) => x.toJson()).toList(),
    "categories": categories.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $ruleName, $minOrderAmt, $maxOrderAmt, $pointsValue, $status, $expiryDate, $createdAt, $updatedAt, $brands, $categories, ";
  }
}

class Brand {
  Brand({required this.id, required this.brandId, required this.brandCode, required this.brandName, required this.status});

  final int id;
  final int brandId;
  final String brandCode;
  final String brandName;
  final int status;

  Brand copyWith({int? id, int? brandId, String? brandCode, String? brandName, int? status}) {
    return Brand(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      brandCode: brandCode ?? this.brandCode,
      brandName: brandName ?? this.brandName,
      status: status ?? this.status,
    );
  }

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json["id"] ?? 0,
      brandId: json["brand_id"] ?? 0,
      brandCode: json["brand_code"] ?? "",
      brandName: json["brand_name"] ?? "",
      status: json["status"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "brand_id": brandId, "brand_code": brandCode, "brand_name": brandName, "status": status};

  @override
  String toString() {
    return "$id, $brandId, $brandCode, $brandName, $status, ";
  }
}

class Category {
  Category({required this.id, required this.categoryId, required this.categoryCode, required this.categoryName, required this.status});

  final int id;
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final int status;

  Category copyWith({int? id, int? categoryId, String? categoryCode, String? categoryName, int? status}) {
    return Category(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"] ?? 0,
      categoryId: json["category_id"] ?? 0,
      categoryCode: json["category_code"] ?? "",
      categoryName: json["category_name"] ?? "",
      status: json["status"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "category_code": categoryCode,
    "category_name": categoryName,
    "status": status,
  };

  @override
  String toString() {
    return "$id, $categoryId, $categoryCode, $categoryName, $status, ";
  }
}
