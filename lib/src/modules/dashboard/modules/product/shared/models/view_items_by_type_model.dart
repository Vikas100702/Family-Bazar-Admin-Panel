/*
class ViewItemByTypeModel {
  ViewItemByTypeModel({required this.success, required this.message, required this.pagination, required this.data});

  final bool success;
  final String message;
  final Pagination? pagination;
  final ViewItemByTypeData? data;

  ViewItemByTypeModel copyWith({bool? success, String? message, Pagination? pagination, ViewItemByTypeData? data}) {
    return ViewItemByTypeModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewItemByTypeModel.fromJson(Map<String, dynamic> json) {
    return ViewItemByTypeModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null ? null : ViewItemByTypeData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "pagination": pagination?.toJson(), "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $pagination, $data, ";
  }
}

class ViewItemByTypeData {
  ViewItemByTypeData({required this.groupId, required this.items});

  final int groupId;
  final List<Item> items;

  ViewItemByTypeData copyWith({int? groupId, List<Item>? items}) {
    return ViewItemByTypeData(groupId: groupId ?? this.groupId, items: items ?? this.items);
  }

  factory ViewItemByTypeData.fromJson(Map<String, dynamic> json) {
    return ViewItemByTypeData(
      groupId: json["group_id"] ?? 0,
      items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"group_id": groupId, "items": items.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$groupId, $items, ";
  }
}

class Item {
  Item({
    required this.id,
    required this.iItemGroup,
    required this.iOtherGroup,
    required this.iCode,
    required this.iEuCode,
    required this.iFirmCode,
    required this.eanCode,
    required this.iName,
    required this.iImgM,
    required this.iImgW,
    required this.status,
    required this.insertedOn,
    required this.createdAt,
    required this.updatedAt,
    required this.sbMRate,
    required this.sbRateA,
    required this.sbSaleableStock,
  });

  final int id;
  final String iItemGroup;
  final String iOtherGroup;
  final String iCode;
  final String iEuCode;
  final String iFirmCode;
  final String eanCode;
  final String iName;
  final dynamic iImgM;
  final dynamic iImgW;
  final int status;
  final DateTime? insertedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sbMRate;
  final int sbRateA;
  final int sbSaleableStock;

  Item copyWith({
    int? id,
    String? iItemGroup,
    String? iOtherGroup,
    String? iCode,
    String? iEuCode,
    String? iFirmCode,
    String? eanCode,
    String? iName,
    dynamic? iImgM,
    dynamic? iImgW,
    int? status,
    DateTime? insertedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sbMRate,
    int? sbRateA,
    int? sbSaleableStock,
  }) {
    return Item(
      id: id ?? this.id,
      iItemGroup: iItemGroup ?? this.iItemGroup,
      iOtherGroup: iOtherGroup ?? this.iOtherGroup,
      iCode: iCode ?? this.iCode,
      iEuCode: iEuCode ?? this.iEuCode,
      iFirmCode: iFirmCode ?? this.iFirmCode,
      eanCode: eanCode ?? this.eanCode,
      iName: iName ?? this.iName,
      iImgM: iImgM ?? this.iImgM,
      iImgW: iImgW ?? this.iImgW,
      status: status ?? this.status,
      insertedOn: insertedOn ?? this.insertedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json["id"] ?? 0,
      iItemGroup: json["I_ItemGroup"] ?? "",
      iOtherGroup: json["I_OtherGroup"] ?? "",
      iCode: json["I_Code"] ?? "",
      iEuCode: json["I_EUCode"] ?? "",
      iFirmCode: json["I_FirmCode"] ?? "",
      eanCode: json["EANCode"] ?? "",
      iName: json["I_Name"] ?? "",
      iImgM: json["I_img_m"],
      iImgW: json["I_img_w"],
      status: json["status"] ?? 0,
      insertedOn: DateTime.tryParse(json["inserted_on"] ?? ""),
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      sbMRate: json["sb_m_Rate"] ?? 0,
      sbRateA: json["SB_Rate_A"] ?? 0,
      sbSaleableStock: json["SB_Saleable_Stock"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "I_ItemGroup": iItemGroup,
    "I_OtherGroup": iOtherGroup,
    "I_Code": iCode,
    "I_EUCode": iEuCode,
    "I_FirmCode": iFirmCode,
    "EANCode": eanCode,
    "I_Name": iName,
    "I_img_m": iImgM,
    "I_img_w": iImgW,
    "status": status,
    "inserted_on": insertedOn?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "sb_m_Rate": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
  };

  @override
  String toString() {
    return "$id, $iItemGroup, $iOtherGroup, $iCode, $iEuCode, $iFirmCode, $eanCode, $iName, $iImgM, $iImgW, $status, $insertedOn, $createdAt, $updatedAt, $sbMRate, $sbRateA, $sbSaleableStock, ";
  }
}

class Pagination {
  Pagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  final int currentPage;
  final int limit;
  final int totalRecords;
  final int totalPages;

  Pagination copyWith({int? currentPage, int? limit, int? totalRecords, int? totalPages}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      limit: json["limit"] ?? 0,
      totalRecords: json["total_records"] ?? 0,
      totalPages: json["total_pages"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"current_page": currentPage, "limit": limit, "total_records": totalRecords, "total_pages": totalPages};

  @override
  String toString() {
    return "$currentPage, $limit, $totalRecords, $totalPages, ";
  }
}
*/
/*


import 'package:flutter/foundation.dart';

@immutable
class ViewItemByTypeModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<Item> data;

  const ViewItemByTypeModel({required this.success, required this.message, this.pagination, this.data = const <Item>[]});

  /// Defensive alias to support controllers reading either `data` or `items`
  List<Item> get items => data;

  ViewItemByTypeModel copyWith({bool? success, String? message, Pagination? pagination, List<Item>? data}) {
    return ViewItemByTypeModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewItemByTypeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewItemByTypeModel(success: false, message: 'Empty response payload received', data: <Item>[]);
    }

    // Defensive parsing for the direct items array in "data"
    final List<Item> parsedItems = [];
    if (json["data"] is List) {
      for (final rawItem in json["data"] as List) {
        if (rawItem is Map<String, dynamic>) {
          parsedItems.add(Item.fromJson(rawItem));
        }
      }
    }

    return ViewItemByTypeModel(
      success: _parseBool(json["success"]),
      message: _parseString(json["message"]),
      pagination: json["pagination"] != null && json["pagination"] is Map<String, dynamic>
          ? Pagination.fromJson(json["pagination"] as Map<String, dynamic>)
          : null,
      data: parsedItems,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() => "ViewItemByTypeModel(success: $success, message: $message, totalItems:${data.length})";
}

@immutable
class Item {
  final int id;
  final String iItemGroup;
  final String iOtherGroup;
  final String iCode;
  final String iEuCode;
  final String iFirmCode;
  final String eanCode;
  final String iName;
  final String? iImgM;
  final String? iImgW;
  final int status;
  final DateTime? insertedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String iMfgComp;
  final double sbMRate;
  final double sbRateA;
  final int sbSaleableStock;
  final String groupName;
  final String groupCode;

  const Item({
    required this.id,
    required this.iItemGroup,
    required this.iOtherGroup,
    required this.iCode,
    required this.iEuCode,
    required this.iFirmCode,
    required this.eanCode,
    required this.iName,
    this.iImgM,
    this.iImgW,
    required this.status,
    this.insertedOn,
    this.createdAt,
    this.updatedAt,
    this.iMfgComp = '',
    this.sbMRate = 0.0,
    this.sbRateA = 0.0,
    this.sbSaleableStock = 0,
    this.groupName = '',
    this.groupCode = '',
  });

  // Presentation Convenience Getters
  String get safeImgW => iImgW ?? '';
  String get safeImgM => iImgM ?? '';
  String get trimmedName => iName.trim();
  bool get isActive => status == 1;

  Item copyWith({
    int? id,
    String? iItemGroup,
    String? iOtherGroup,
    String? iCode,
    String? iEuCode,
    String? iFirmCode,
    String? eanCode,
    String? iName,
    String? iImgM,
    String? iImgW,
    int? status,
    DateTime? insertedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? iMfgComp,
    double? sbMRate,
    double? sbRateA,
    int? sbSaleableStock,
    String? groupName,
    String? groupCode,
  }) {
    return Item(
      id: id ?? this.id,
      iItemGroup: iItemGroup ?? this.iItemGroup,
      iOtherGroup: iOtherGroup ?? this.iOtherGroup,
      iCode: iCode ?? this.iCode,
      iEuCode: iEuCode ?? this.iEuCode,
      iFirmCode: iFirmCode ?? this.iFirmCode,
      eanCode: eanCode ?? this.eanCode,
      iName: iName ?? this.iName,
      iImgM: iImgM ?? this.iImgM,
      iImgW: iImgW ?? this.iImgW,
      status: status ?? this.status,
      insertedOn: insertedOn ?? this.insertedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iMfgComp: iMfgComp ?? this.iMfgComp,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
      groupName: groupName ?? this.groupName,
      groupCode: groupCode ?? this.groupCode,
    );
  }

  factory Item.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Item(id: 0, iItemGroup: '', iOtherGroup: '', iCode: '', iEuCode: '', iFirmCode: '', eanCode: '', iName: '', status: 0);
    }

    return Item(
      id: _parseInt(json["id"]),
      iItemGroup: _parseString(json["I_ItemGroup"]),
      iOtherGroup: _parseString(json["I_OtherGroup"]),
      iCode: _parseString(json["I_Code"]),
      iEuCode: _parseString(json["I_EUCode"]),
      iFirmCode: _parseString(json["I_FirmCode"]),
      eanCode: _parseString(json["EANCode"]),
      iName: _parseString(json["I_Name"]),
      iImgM: _parseNullableString(json["I_img_m"]),
      iImgW: _parseNullableString(json["I_img_w"]),
      status: _parseInt(json["status"]),
      insertedOn: _parseDateTime(json["inserted_on"]),
      createdAt: _parseDateTime(json["created_at"]),
      updatedAt: _parseDateTime(json["updated_at"]),
      iMfgComp: _parseString(json["I_MfgComp"]),
      sbMRate: _parseDouble(json["sb_m_Rate"]),
      sbRateA: _parseDouble(json["SB_Rate_A"]),
      sbSaleableStock: _parseInt(json["SB_Saleable_Stock"]),
      groupName: _parseString(json["group_name"]),
      groupCode: _parseString(json["group_code"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "I_ItemGroup": iItemGroup,
    "I_OtherGroup": iOtherGroup,
    "I_Code": iCode,
    "I_EUCode": iEuCode,
    "I_FirmCode": iFirmCode,
    "EANCode": eanCode,
    "I_Name": iName,
    "I_img_m": iImgM,
    "I_img_w": iImgW,
    "status": status,
    "inserted_on": insertedOn?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "I_MfgComp": iMfgComp,
    "sb_m_Rate": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
    "group_name": groupName,
    "group_code": groupCode,
  };

  @override
  String toString() => "Item(id: $id, iCode: $iCode, iName:$iName, rate: $sbMRate, stock:$sbSaleableStock)";
}

@immutable
class Pagination {
  final int currentPage;
  final int? limit;
  final int totalRecords;
  final int totalPages;

  const Pagination({required this.currentPage, this.limit, required this.totalRecords, required this.totalPages});

  Pagination copyWith({int? currentPage, int? limit, int? totalRecords, int? totalPages}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Pagination(currentPage: 1, limit: null, totalRecords: 0, totalPages: 1);
    }

    return Pagination(
      currentPage: _parseInt(json["current_page"], 1),
      limit: json["limit"] != null ? _parseInt(json["limit"]) : null,
      totalRecords: _parseInt(json["total_records"]),
      totalPages: _parseInt(json["total_pages"], 1),
    );
  }

  Map<String, dynamic> toJson() => {"current_page": currentPage, "limit": limit, "total_records": totalRecords, "total_pages": totalPages};

  @override
  String toString() => "Pagination(page: $currentPage, limit:$limit, totalRecords: $totalRecords, totalPages:$totalPages)";
}

// ===========================================================================
// DEFENSIVE DATA PARSING UTILITIES (Cross-Platform Web Safe)
// ===========================================================================

int _parseInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? double.tryParse(val.trim())?.toInt() ?? fallback;
  }
  return fallback;
}

double _parseDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

String _parseString(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  return val.toString().trim();
}

String? _parseNullableString(dynamic val) {
  if (val == null) return null;
  final str = val.toString().trim();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  final str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true';
}

DateTime? _parseDateTime(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  return DateTime.tryParse(val.toString().trim());
}
*/

import 'package:flutter/foundation.dart';

@immutable
class ViewItemByTypeModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<Item> data;

  const ViewItemByTypeModel({required this.success, required this.message, this.pagination, this.data = const <Item>[]});

  /// Controllers ke backward-compatibility ke liye helper getter
  List<Item> get items => data;

  ViewItemByTypeModel copyWith({bool? success, String? message, Pagination? pagination, List<Item>? data}) {
    return ViewItemByTypeModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewItemByTypeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewItemByTypeModel(success: false, message: 'Empty response payload received', data: <Item>[]);
    }

    final List<Item> parsedItems = [];
    if (json["data"] is List) {
      for (final rawItem in json["data"] as List) {
        if (rawItem is Map<String, dynamic>) {
          parsedItems.add(Item.fromJson(rawItem));
        }
      }
    }

    return ViewItemByTypeModel(
      success: _parseBool(json["success"]),
      message: _parseString(json["message"]),
      pagination: json["pagination"] != null && json["pagination"] is Map<String, dynamic>
          ? Pagination.fromJson(json["pagination"] as Map<String, dynamic>)
          : null,
      data: parsedItems,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() => "ViewItemByTypeModel(success: $success, message: $message, totalRecords: ${data.length})";
}

@immutable
class Item {
  // 1. Common Catalog Fields (Har request mein aate hain)
  final int id;
  final String iItemGroup;
  final String iOtherGroup;
  final String iCode;
  final String iEuCode;
  final String iFirmCode;
  final String eanCode;
  final String iName;
  final String? iImgM;
  final String? iImgW;
  final int status;
  final DateTime? insertedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? iMfgComp;
  final double sbMRate;
  final double sbRateA;
  final int sbSaleableStock;

  // 2. Group Specific Fields (GROUP response mein aate hain)
  final String groupName;
  final String groupCode;

  // 3. Brand Specific Fields (BRAND response mein aate hain)
  final String brandName;
  final String itemGroup; // Descriptive Category Name ("ItemGroup")
  final String otherGroup; // Descriptive Sub-Category Name ("OtherGroup")

  const Item({
    required this.id,
    required this.iItemGroup,
    required this.iOtherGroup,
    required this.iCode,
    required this.iEuCode,
    required this.iFirmCode,
    required this.eanCode,
    required this.iName,
    this.iImgM,
    this.iImgW,
    required this.status,
    this.insertedOn,
    this.createdAt,
    this.updatedAt,
    this.iMfgComp,
    this.sbMRate = 0.0,
    this.sbRateA = 0.0,
    this.sbSaleableStock = 0,
    this.groupName = '',
    this.groupCode = '',
    this.brandName = '',
    this.itemGroup = '',
    this.otherGroup = '',
  });

  // UI Presentation Convenience Getters
  String get safeImgW => iImgW ?? '';
  String get safeImgM => iImgM ?? '';
  String get trimmedName => iName.trim();
  bool get isActive => status == 1;

  /// Agar Brand API se descriptive name mila hai toh wo use hoga, warna code return karega
  String get categoryDisplayName => itemGroup.isNotEmpty ? itemGroup : iItemGroup;
  String get subCategoryDisplayName => otherGroup.isNotEmpty ? otherGroup : iOtherGroup;

  Item copyWith({
    int? id,
    String? iItemGroup,
    String? iOtherGroup,
    String? iCode,
    String? iEuCode,
    String? iFirmCode,
    String? eanCode,
    String? iName,
    String? iImgM,
    String? iImgW,
    int? status,
    DateTime? insertedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? iMfgComp,
    double? sbMRate,
    double? sbRateA,
    int? sbSaleableStock,
    String? groupName,
    String? groupCode,
    String? brandName,
    String? itemGroup,
    String? otherGroup,
  }) {
    return Item(
      id: id ?? this.id,
      iItemGroup: iItemGroup ?? this.iItemGroup,
      iOtherGroup: iOtherGroup ?? this.iOtherGroup,
      iCode: iCode ?? this.iCode,
      iEuCode: iEuCode ?? this.iEuCode,
      iFirmCode: iFirmCode ?? this.iFirmCode,
      eanCode: eanCode ?? this.eanCode,
      iName: iName ?? this.iName,
      iImgM: iImgM ?? this.iImgM,
      iImgW: iImgW ?? this.iImgW,
      status: status ?? this.status,
      insertedOn: insertedOn ?? this.insertedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iMfgComp: iMfgComp ?? this.iMfgComp,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
      groupName: groupName ?? this.groupName,
      groupCode: groupCode ?? this.groupCode,
      brandName: brandName ?? this.brandName,
      itemGroup: itemGroup ?? this.itemGroup,
      otherGroup: otherGroup ?? this.otherGroup,
    );
  }

  factory Item.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Item(id: 0, iItemGroup: '', iOtherGroup: '', iCode: '', iEuCode: '', iFirmCode: '', eanCode: '', iName: '', status: 0);
    }

    return Item(
      id: _parseInt(json["id"]),
      iItemGroup: _parseString(json["I_ItemGroup"]),
      iOtherGroup: _parseString(json["I_OtherGroup"]),
      iCode: _parseString(json["I_Code"]),
      iEuCode: _parseString(json["I_EUCode"]),
      iFirmCode: _parseString(json["I_FirmCode"]),
      eanCode: _parseString(json["EANCode"]),
      iName: _parseString(json["I_Name"]),
      iImgM: _parseNullableString(json["I_img_m"]),
      iImgW: _parseNullableString(json["I_img_w"]),
      status: _parseInt(json["status"]),
      insertedOn: _parseDateTime(json["inserted_on"]),
      createdAt: _parseDateTime(json["created_at"]),
      updatedAt: _parseDateTime(json["updated_at"]),
      iMfgComp: _parseNullableString(json["I_MfgComp"]),
      sbMRate: _parseDouble(json["sb_m_Rate"]),
      sbRateA: _parseDouble(json["SB_Rate_A"]),
      sbSaleableStock: _parseInt(json["SB_Saleable_Stock"]),
      // Group fields
      groupName: _parseString(json["group_name"]),
      groupCode: _parseString(json["group_code"]),
      // Brand fields
      brandName: _parseString(json["brand_name"]),
      itemGroup: _parseString(json["ItemGroup"]),
      otherGroup: _parseString(json["OtherGroup"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "I_ItemGroup": iItemGroup,
    "I_OtherGroup": iOtherGroup,
    "I_Code": iCode,
    "I_EUCode": iEuCode,
    "I_FirmCode": iFirmCode,
    "EANCode": eanCode,
    "I_Name": iName,
    "I_img_m": iImgM,
    "I_img_w": iImgW,
    "status": status,
    "inserted_on": insertedOn?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "I_MfgComp": iMfgComp,
    "sb_m_Rate": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
    "group_name": groupName,
    "group_code": groupCode,
    "brand_name": brandName,
    "ItemGroup": itemGroup,
    "OtherGroup": otherGroup,
  };

  @override
  String toString() => "Item(id: $id, iCode: $iCode, iName: $iName, rate: $sbMRate, stock: $sbSaleableStock)";
}

@immutable
class Pagination {
  final int currentPage;
  final int? limit;
  final int totalRecords;
  final int totalPages;

  const Pagination({required this.currentPage, this.limit, required this.totalRecords, required this.totalPages});

  Pagination copyWith({int? currentPage, int? limit, int? totalRecords, int? totalPages}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Pagination(currentPage: 1, limit: null, totalRecords: 0, totalPages: 1);
    }

    return Pagination(
      currentPage: _parseInt(json["current_page"], 1),
      limit: json["limit"] != null ? _parseInt(json["limit"]) : null,
      totalRecords: _parseInt(json["total_records"]),
      totalPages: _parseInt(json["total_pages"], 1),
    );
  }

  Map<String, dynamic> toJson() => {"current_page": currentPage, "limit": limit, "total_records": totalRecords, "total_pages": totalPages};

  @override
  String toString() => "Pagination(page: $currentPage, limit: $limit, totalRecords: $totalRecords, totalPages: $totalPages)";
}

// ===========================================================================
// DEFENSIVE DATA PARSING UTILITIES (Cross-Platform Web-Safe)
// ===========================================================================

int _parseInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? double.tryParse(val.trim())?.toInt() ?? fallback;
  }
  return fallback;
}

double _parseDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

String _parseString(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  return val.toString().trim();
}

String? _parseNullableString(dynamic val) {
  if (val == null) return null;
  final str = val.toString().trim();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  final str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true';
}

DateTime? _parseDateTime(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  return DateTime.tryParse(val.toString().trim());
}
