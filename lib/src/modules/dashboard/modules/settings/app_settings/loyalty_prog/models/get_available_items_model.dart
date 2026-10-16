class AvailableItemsModel {
  AvailableItemsModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final Data? data;

  AvailableItemsModel copyWith({bool? success, String? message, Data? data}) {
    return AvailableItemsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory AvailableItemsModel.fromJson(Map<String, dynamic> json) {
    return AvailableItemsModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class Data {
  Data({required this.brands, required this.categories});

  final List<Brand> brands;
  final List<Category> categories;

  Data copyWith({List<Brand>? brands, List<Category>? categories}) {
    return Data(brands: brands ?? this.brands, categories: categories ?? this.categories);
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      brands: json["brands"] == null ? [] : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
      categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"brands": brands.map((x) => x?.toJson()).toList(), "categories": categories.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$brands, $categories, ";
  }
}

class Brand {
  Brand({required this.id, required this.brandCode, required this.brandName, required this.isSelected});

  final int id;
  final String brandCode;
  final String brandName;
  final int isSelected;

  Brand copyWith({int? id, String? brandCode, String? brandName, int? isSelected}) {
    return Brand(
      id: id ?? this.id,
      brandCode: brandCode ?? this.brandCode,
      brandName: brandName ?? this.brandName,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(id: json["id"] ?? 0, brandCode: json["brand_code"] ?? "", brandName: json["brand_name"] ?? "", isSelected: json["is_selected"] ?? 0);
  }

  Map<String, dynamic> toJson() => {"id": id, "brand_code": brandCode, "brand_name": brandName, "is_selected": isSelected};

  @override
  String toString() {
    return "$id, $brandCode, $brandName, $isSelected, ";
  }
}

class Category {
  Category({required this.id, required this.categoryCode, required this.categoryName, required this.isSelected});

  final int id;
  final String categoryCode;
  final String categoryName;
  final int isSelected;

  Category copyWith({int? id, String? categoryCode, String? categoryName, int? isSelected}) {
    return Category(
      id: id ?? this.id,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"] ?? 0,
      categoryCode: json["category_code"] ?? "",
      categoryName: json["category_name"] ?? "",
      isSelected: json["is_selected"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "category_code": categoryCode, "category_name": categoryName, "is_selected": isSelected};

  @override
  String toString() {
    return "$id, $categoryCode, $categoryName, $isSelected, ";
  }
}
