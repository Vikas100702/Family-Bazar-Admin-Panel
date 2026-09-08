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
  });

  final int id;
  final String iItemGroup;
  final String iOtherGroup;
  final String iCode;
  final String iEuCode;
  final String iFirmCode;
  final dynamic eanCode;
  final String iName;
  final dynamic iImgM;
  final dynamic iImgW;
  final int status;
  final DateTime? insertedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ViewItemDatum copyWith({
    int? id,
    String? iItemGroup,
    String? iOtherGroup,
    String? iCode,
    String? iEuCode,
    String? iFirmCode,
    dynamic? eanCode,
    String? iName,
    dynamic? iImgM,
    dynamic? iImgW,
    int? status,
    DateTime? insertedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    );
  }

  factory ViewItemDatum.fromJson(Map<String, dynamic> json) {
    return ViewItemDatum(
      id: json["id"] ?? 0,
      iItemGroup: json["I_ItemGroup"] ?? "",
      iOtherGroup: json["I_OtherGroup"] ?? "",
      iCode: json["I_Code"] ?? "",
      iEuCode: json["I_EUCode"] ?? "",
      iFirmCode: json["I_FirmCode"] ?? "",
      eanCode: json["EANCode"],
      iName: json["I_Name"] ?? "",
      iImgM: json["I_img_m"],
      iImgW: json["I_img_w"],
      status: json["status"] ?? 0,
      insertedOn: DateTime.tryParse(json["inserted_on"] ?? ""),
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
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
  };

  @override
  String toString() {
    return "$id, $iItemGroup, $iOtherGroup, $iCode, $iEuCode, $iFirmCode, $eanCode, $iName, $iImgM, $iImgW, $status, $insertedOn, $createdAt, $updatedAt, ";
  }
}
