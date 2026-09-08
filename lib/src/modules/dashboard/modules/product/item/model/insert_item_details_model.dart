class InsertItemDetailsModel {
  InsertItemDetailsModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final InsertItemDetailsData? data;

  InsertItemDetailsModel copyWith({bool? success, String? message, InsertItemDetailsData? data}) {
    return InsertItemDetailsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory InsertItemDetailsModel.fromJson(Map<String, dynamic> json) {
    return InsertItemDetailsModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : InsertItemDetailsData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class InsertItemDetailsData {
  InsertItemDetailsData({required this.id, required this.iCode, required this.iName, required this.mImg, required this.wImg, required this.action});

  final int id;
  final String iCode;
  final String iName;
  final String mImg;
  final String wImg;
  final String action;

  InsertItemDetailsData copyWith({int? id, String? iCode, String? iName, String? mImg, String? wImg, String? action}) {
    return InsertItemDetailsData(
      id: id ?? this.id,
      iCode: iCode ?? this.iCode,
      iName: iName ?? this.iName,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
      action: action ?? this.action,
    );
  }

  factory InsertItemDetailsData.fromJson(Map<String, dynamic> json) {
    return InsertItemDetailsData(
      id: json["id"] ?? 0,
      iCode: json["I_Code"] ?? "",
      iName: json["I_Name"] ?? "",
      mImg: json["m_img"] ?? "",
      wImg: json["w_img"] ?? "",
      action: json["action"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "I_Code": iCode, "I_Name": iName, "m_img": mImg, "w_img": wImg, "action": action};

  @override
  String toString() {
    return "$id, $iCode, $iName, $mImg, $wImg, $action, ";
  }
}
