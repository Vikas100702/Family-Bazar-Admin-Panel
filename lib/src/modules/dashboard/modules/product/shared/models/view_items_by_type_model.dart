class ViewItemByTypeModel {
  ViewItemByTypeModel({required this.success, required this.message, required this.pagination, required this.data});

  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewItemByTypeDatum> data;

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
    required this.iName,
    required this.iMfgComp,
    required this.iItemGroup,
    required this.iFirmCode,
    required this.iOtherGroup,
    required this.iCreatedBy,
    required this.iModifyBy,
    required this.iCreatedTimeStamp,
    required this.iModifyTimeStamp,
    required this.iStatus,
    required this.sbBarCode,
    required this.batchNo,
    required this.sbMRate,
    required this.sbRateA,
    required this.sbSaleableStock,
    required this.brandName,
    required this.imImageMob,
    required this.imImageWeb,
    required this.imSecondryImage,
    required this.imImformation,
    required this.itemGroupName,
    required this.otherGroupName,
  });

  final int id;
  final String iCode;
  final String iBarCode;
  final String iName;
  final String iMfgComp;
  final String iItemGroup;
  final String iFirmCode;
  final String iOtherGroup;
  final String iCreatedBy;
  final String iModifyBy;
  final DateTime? iCreatedTimeStamp;
  final DateTime? iModifyTimeStamp;
  final String iStatus;
  final String sbBarCode;
  final String batchNo;
  final String sbMRate;
  final String sbRateA;
  final String sbSaleableStock;
  final String brandName;
  final String imImageMob;
  final String imImageWeb;
  final String imSecondryImage;
  final String imImformation;
  final String itemGroupName;
  final String otherGroupName;

  factory ViewItemByTypeDatum.fromJson(Map<String, dynamic> json) {
    return ViewItemByTypeDatum(
      id: json["id"] ?? 0,
      iCode: json["I_Code"] ?? "",
      iBarCode: json["I_Bar_Code"] ?? "",
      iName: json["I_Name"] ?? "",
      iMfgComp: json["I_MfgComp"] ?? "",
      iItemGroup: json["I_ItemGroup"] ?? "",
      iFirmCode: json["I_FirmCode"] ?? "",
      iOtherGroup: json["I_OtherGroup"] ?? "",
      iCreatedBy: json["I_CreatedBy"] ?? "",
      iModifyBy: json["I_ModifyBy"] ?? "",
      iCreatedTimeStamp: DateTime.tryParse(json["I_CreatedTimeStamp"] ?? ""),
      iModifyTimeStamp: DateTime.tryParse(json["I_ModifyTimeStamp"] ?? ""),
      iStatus: json["I_Status"] ?? "",
      sbBarCode: json["SB_BAR_CODE"] ?? "",
      batchNo: json["batch_no"] ?? "",
      sbMRate: json["SB_M_RATE"] ?? "",
      sbRateA: json["SB_Rate_A"] ?? "",
      sbSaleableStock: json["SB_Saleable_Stock"] ?? "",
      brandName: json["MC_CompName"] ?? "",
      imImageMob: json["IM_ImageMob"] ?? "",
      imImageWeb: json["IM_ImageWeb"] ?? "",
      imSecondryImage: json["IM_SecondryImage"] ?? "",
      imImformation: json["IM_Imformation"] ?? "",
      itemGroupName: json["item_group_name"] ?? "",
      otherGroupName: json["other_group_name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "I_Code": iCode,
    "I_Bar_Code": iBarCode,
    "I_Name": iName,
    "I_MfgComp": iMfgComp,
    "I_ItemGroup": iItemGroup,
    "I_FirmCode": iFirmCode,
    "I_OtherGroup": iOtherGroup,
    "I_CreatedBy": iCreatedBy,
    "I_ModifyBy": iModifyBy,
    "I_CreatedTimeStamp": iCreatedTimeStamp?.toIso8601String(),
    "I_ModifyTimeStamp": iModifyTimeStamp?.toIso8601String(),
    "I_Status": iStatus,
    "SB_BAR_CODE": sbBarCode,
    "batch_no": batchNo,
    "SB_M_RATE": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
    "MC_CompName": brandName,
    "IM_ImageMob": imImageMob,
    "IM_ImageWeb": imImageWeb,
    "IM_SecondryImage": imSecondryImage,
    "IM_Imformation": imImformation,
    "item_group_name": itemGroupName,
    "other_group_name": otherGroupName,
  };

  @override
  String toString() {
    return "$id, $iCode, $iBarCode, $iName, $iMfgComp, $iItemGroup, $iFirmCode, $iOtherGroup, $iCreatedBy, $iModifyBy, $iCreatedTimeStamp, $iModifyTimeStamp, $iStatus, $sbBarCode, $batchNo, $sbMRate, $sbRateA, $sbSaleableStock, $brandName, $imImageMob, $imImageWeb, $imSecondryImage, $imImformation, $itemGroupName, $otherGroupName, ";
  }
}

class Pagination {
  Pagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  final int currentPage;
  final dynamic limit;
  final int totalRecords;
  final int totalPages;

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
