class ViewItemModel {
  ViewItemModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final List<ViewItemDatum> data;

  ViewItemModel copyWith({bool? success, String? message, List<ViewItemDatum>? data}) {
    return ViewItemModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewItemModel.fromJson(Map<String, dynamic> json) {
    return ViewItemModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<ViewItemDatum>.from(json["data"]!.map((x) => ViewItemDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class ViewItemDatum {
  ViewItemDatum({
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
    required this.itemGroup,
    required this.otherGroup,
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
  final String iImgM;
  final String iImgW;
  final int status;
  final DateTime? insertedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String itemGroup;
  final String otherGroup;
  final int sbMRate;
  final int sbRateA;
  final int sbSaleableStock;

  ViewItemDatum copyWith({
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
    String? itemGroup,
    String? otherGroup,
    int? sbMRate,
    int? sbRateA,
    int? sbSaleableStock,
  }) {
    return ViewItemDatum(
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
      itemGroup: itemGroup ?? this.itemGroup,
      otherGroup: otherGroup ?? this.otherGroup,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
    );
  }

  factory ViewItemDatum.fromJson(Map<String, dynamic> json) {
    return ViewItemDatum(
      id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
      iItemGroup: json["I_ItemGroup"]?.toString() ?? "",
      iOtherGroup: json["I_OtherGroup"]?.toString() ?? "",
      iCode: json["I_Code"]?.toString() ?? "",
      iEuCode: json["I_EUCode"]?.toString() ?? "",
      iFirmCode: json["I_FirmCode"]?.toString() ?? "",
      eanCode: json["EANCode"]?.toString() ?? "",
      iName: json["I_Name"]?.toString() ?? "",
      iImgM: json["I_img_m"]?.toString() ?? "",
      iImgW: json["I_img_w"]?.toString() ?? "",
      status: int.tryParse(json["status"]?.toString() ?? '') ?? 0,
      insertedOn: DateTime.tryParse(json["inserted_on"]?.toString() ?? ""),
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
      itemGroup: json["ItemGroup"]?.toString() ?? "",
      otherGroup: json["OtherGroup"]?.toString() ?? "",
      sbMRate: int.tryParse(json["sb_m_Rate"]?.toString() ?? '') ?? 0,
      sbRateA: int.tryParse(json["SB_Rate_A"]?.toString() ?? '') ?? 0,
      sbSaleableStock: int.tryParse(json["SB_Saleable_Stock"]?.toString() ?? '') ?? 0,
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
    "ItemGroup": itemGroup,
    "OtherGroup": otherGroup,
    "sb_m_Rate": sbMRate,
    "SB_Rate_A": sbRateA,
    "SB_Saleable_Stock": sbSaleableStock,
  };

  @override
  String toString() {
    return "$id, $iItemGroup, $iOtherGroup, $iCode, $iEuCode, $iFirmCode, $eanCode, $iName, $iImgM, $iImgW, $status, $insertedOn, $createdAt, $updatedAt, $itemGroup, $otherGroup, $sbMRate, $sbRateA, $sbSaleableStock";
  }
}
