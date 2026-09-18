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
