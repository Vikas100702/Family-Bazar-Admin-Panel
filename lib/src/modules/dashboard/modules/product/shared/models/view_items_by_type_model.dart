class ViewItemByTypeModel {
  ViewItemByTypeModel({required this.success, required this.message, required this.pagination, required this.data});

  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewItemByTypeDatum> data;

  ViewItemByTypeModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewItemByTypeDatum>? data}) {
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
      data: json["data"] == null ? [] : List<ViewItemByTypeDatum>.from(json["data"]!.map((x) => ViewItemByTypeDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$success, $message, $pagination, $data, ";
  }
}

class ViewItemByTypeDatum {
  ViewItemByTypeDatum({
    required this.id,
    required this.iCode,
    required this.iBarCode,
    required this.iMfgComp,
    required this.iName,
    required this.iItemGroup,
    required this.iFirmCode,
    required this.iOtherGroup,
    required this.iStatus,
    required this.iCreatedBy,
    required this.iModifyBy,
    required this.iCreatedTimeStamp,
    required this.iModifyTimeStamp,
    required this.sbBarCode,
    required this.batchNo,
    required this.sbMRate,
    required this.sbRateA,
    required this.sbSaleableStock,
    required this.brandName,
    required this.imageMob,
    required this.imageWeb,
    required this.itemGroupName,
    required this.otherGroupName,
  });

  final int id;
  final String iCode;
  final String iBarCode;
  final String iMfgComp;
  final String iName;
  final String iItemGroup;
  final String iFirmCode;
  final String iOtherGroup;
  final String iStatus;
  final String iCreatedBy;
  final String iModifyBy;
  final DateTime? iCreatedTimeStamp;
  final DateTime? iModifyTimeStamp;
  final dynamic sbBarCode;
  final dynamic batchNo;
  final dynamic sbMRate;
  final dynamic sbRateA;
  final dynamic sbSaleableStock;
  final String brandName;
  final String imageMob;
  final String imageWeb;
  final String itemGroupName;
  final dynamic otherGroupName;

  ViewItemByTypeDatum copyWith({
    int? id,
    String? iCode,
    String? iBarCode,
    String? iMfgComp,
    String? iName,
    String? iItemGroup,
    String? iFirmCode,
    String? iOtherGroup,
    String? iStatus,
    String? iCreatedBy,
    String? iModifyBy,
    DateTime? iCreatedTimeStamp,
    DateTime? iModifyTimeStamp,
    dynamic sbBarCode,
    dynamic batchNo,
    dynamic sbMRate,
    dynamic sbRateA,
    dynamic sbSaleableStock,
    String? brandName,
    String? imageMob,
    String? imageWeb,
    String? itemGroupName,
    dynamic otherGroupName,
  }) {
    return ViewItemByTypeDatum(
      id: id ?? this.id,
      iCode: iCode ?? this.iCode,
      iBarCode: iBarCode ?? this.iBarCode,
      iMfgComp: iMfgComp ?? this.iMfgComp,
      iName: iName ?? this.iName,
      iItemGroup: iItemGroup ?? this.iItemGroup,
      iFirmCode: iFirmCode ?? this.iFirmCode,
      iOtherGroup: iOtherGroup ?? this.iOtherGroup,
      iStatus: iStatus ?? this.iStatus,
      iCreatedBy: iCreatedBy ?? this.iCreatedBy,
      iModifyBy: iModifyBy ?? this.iModifyBy,
      iCreatedTimeStamp: iCreatedTimeStamp ?? this.iCreatedTimeStamp,
      iModifyTimeStamp: iModifyTimeStamp ?? this.iModifyTimeStamp,
      sbBarCode: sbBarCode ?? this.sbBarCode,
      batchNo: batchNo ?? this.batchNo,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
      brandName: brandName ?? this.brandName,
      imageMob: imageMob ?? this.imageMob,
      imageWeb: imageWeb ?? this.imageWeb,
      itemGroupName: itemGroupName ?? this.itemGroupName,
      otherGroupName: otherGroupName ?? this.otherGroupName,
    );
  }

  factory ViewItemByTypeDatum.fromJson(Map<String, dynamic> json) {
    return ViewItemByTypeDatum(
      id: json["id"] ?? 0,
      iCode: json["I_Code"] ?? "",
      iBarCode: json["I_Bar_Code"] ?? "",
      iMfgComp: json["I_MfgComp"] ?? "",
      iName: json["I_Name"] ?? "",
      iItemGroup: json["I_ItemGroup"] ?? "",
      iFirmCode: json["I_FirmCode"] ?? "",
      iOtherGroup: json["I_OtherGroup"] ?? "",
      iStatus: json["I_Status"] ?? "",
      iCreatedBy: json["I_CreatedBy"] ?? "",
      iModifyBy: json["I_ModifyBy"] ?? "",
      iCreatedTimeStamp: DateTime.tryParse(json["I_CreatedTimeStamp"] ?? ""),
      iModifyTimeStamp: DateTime.tryParse(json["I_ModifyTimeStamp"] ?? ""),
      sbBarCode: json["SB_BAR_CODE"],
      batchNo: json["batch_no"],
      sbMRate: json["sb_m_Rate"],
      sbRateA: json["SB_Rate_A"],
      sbSaleableStock: json["SB_Saleable_Stock"],
      brandName: json["brand_name"] ?? "",
      imageMob: json["IM_ImageMob"] ?? "",
      imageWeb: json["IM_ImageWeb"] ?? "",
      itemGroupName: json["item_group_name"] ?? "",
      otherGroupName: json["other_group_name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "I_Code": iCode,
    "I_Bar_Code": iBarCode,
    "I_MfgComp": iMfgComp,
    "I_Name": iName,
    "I_ItemGroup": iItemGroup,
    "I_FirmCode": iFirmCode,
    "I_OtherGroup": iOtherGroup,
    "I_Status": iStatus,
    "I_CreatedBy": iCreatedBy,
    "I_ModifyBy": iModifyBy,
    "I_CreatedTimeStamp": iCreatedTimeStamp?.toIso8601String(),
    "I_ModifyTimeStamp": iModifyTimeStamp?.toIso8601String(),
    "SB_BAR_CODE": sbBarCode,
    "batch_no": batchNo,
    "sb_m_Rate": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
    "brand_name": brandName,
    "IM_ImageMob": imageMob,
    "IM_ImageWeb": imageWeb,
    "item_group_name": itemGroupName,
    "other_group_name": otherGroupName,
  };

  @override
  String toString() {
    return "$id, $iCode, $iBarCode, $iMfgComp, $iName, $iItemGroup, $iFirmCode, $iOtherGroup, $iStatus, $iCreatedBy, $iModifyBy, $iCreatedTimeStamp, $iModifyTimeStamp, $sbBarCode, $batchNo, $sbMRate, $sbRateA, $sbSaleableStock, $brandName, $imageMob, $imageWeb, $itemGroupName, $otherGroupName, ";
  }
}

class Pagination {
  Pagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  final int currentPage;
  final dynamic limit;
  final int totalRecords;
  final int totalPages;

  Pagination copyWith({int? currentPage, dynamic limit, int? totalRecords, int? totalPages}) {
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
      limit: json["limit"],
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
