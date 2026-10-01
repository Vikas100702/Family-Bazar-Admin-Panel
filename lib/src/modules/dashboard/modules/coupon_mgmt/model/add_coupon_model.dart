class AddCouponModel {
  AddCouponModel({required this.status, required this.message, required this.data});

  final bool status;
  final String message;
  final AddCouponData? data;

  AddCouponModel copyWith({bool? status, String? message, AddCouponData? data}) {
    return AddCouponModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddCouponModel.fromJson(Map<String, dynamic> json) {
    return AddCouponModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : AddCouponData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$status, $message, $data, ";
  }
}

class AddCouponData {
  AddCouponData({required this.success, required this.insertId});

  final bool success;
  final int insertId;

  AddCouponData copyWith({bool? success, int? insertId}) {
    return AddCouponData(success: success ?? this.success, insertId: insertId ?? this.insertId);
  }

  factory AddCouponData.fromJson(Map<String, dynamic> json) {
    return AddCouponData(success: json["success"] ?? false, insertId: json["insertId"] ?? 0);
  }

  Map<String, dynamic> toJson() => {"success": success, "insertId": insertId};

  @override
  String toString() {
    return "$success, $insertId, ";
  }
}
