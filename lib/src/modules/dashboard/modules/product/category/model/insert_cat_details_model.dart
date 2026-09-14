class AddCatDetailsModel {
  AddCatDetailsModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final AddCatDetailsData? data;

  AddCatDetailsModel copyWith({bool? success, String? message, AddCatDetailsData? data}) {
    return AddCatDetailsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddCatDetailsModel.fromJson(Map<String, dynamic> json) {
    return AddCatDetailsModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : AddCatDetailsData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class AddCatDetailsData {
  AddCatDetailsData({required this.id, required this.catCode, required this.catName, required this.mImg, required this.wImg, required this.action});

  final int id;
  final String catCode;
  final String catName;
  final String mImg;
  final String wImg;
  final String action;

  AddCatDetailsData copyWith({int? id, String? catCode, String? catName, String? mImg, String? wImg, String? action}) {
    return AddCatDetailsData(
      id: id ?? this.id,
      catCode: catCode ?? this.catCode,
      catName: catName ?? this.catName,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
      action: action ?? this.action,
    );
  }

  factory AddCatDetailsData.fromJson(Map<String, dynamic> json) {
    return AddCatDetailsData(
      id: json["id"] ?? 0,
      catCode: json["cat_code"] ?? "",
      catName: json["cat_name"] ?? "",
      mImg: json["m_img"] ?? "",
      wImg: json["w_img"] ?? "",
      action: json["action"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "cat_code": catCode, "cat_name": catName, "m_img": mImg, "w_img": wImg, "action": action};

  @override
  String toString() {
    return "$id, $catCode, $catName, $mImg, $wImg, $action, ";
  }
}
