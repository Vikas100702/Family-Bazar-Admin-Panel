class InsertSubCatDetailsModel {
  InsertSubCatDetailsModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final InsertSubCatDetailsData? data;

  InsertSubCatDetailsModel copyWith({bool? success, String? message, InsertSubCatDetailsData? data}) {
    return InsertSubCatDetailsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory InsertSubCatDetailsModel.fromJson(Map<String, dynamic> json) {
    return InsertSubCatDetailsModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : InsertSubCatDetailsData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class InsertSubCatDetailsData {
  InsertSubCatDetailsData({
    required this.id,
    required this.subcatCode,
    required this.subcatName,
    required this.mImg,
    required this.wImg,
    required this.action,
  });

  final int id;
  final String subcatCode;
  final String subcatName;
  final String mImg;
  final String wImg;
  final String action;

  InsertSubCatDetailsData copyWith({int? id, String? subcatCode, String? subcatName, String? mImg, String? wImg, String? action}) {
    return InsertSubCatDetailsData(
      id: id ?? this.id,
      subcatCode: subcatCode ?? this.subcatCode,
      subcatName: subcatName ?? this.subcatName,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
      action: action ?? this.action,
    );
  }

  factory InsertSubCatDetailsData.fromJson(Map<String, dynamic> json) {
    return InsertSubCatDetailsData(
      id: json["id"] ?? 0,
      subcatCode: json["subcat_code"] ?? "",
      subcatName: json["subcat_name"] ?? "",
      mImg: json["m_img"] ?? "",
      wImg: json["w_img"] ?? "",
      action: json["action"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "subcat_code": subcatCode, "subcat_name": subcatName, "m_img": mImg, "w_img": wImg, "action": action};

  @override
  String toString() {
    return "$id, $subcatCode, $subcatName, $mImg, $wImg, $action, ";
  }
}
