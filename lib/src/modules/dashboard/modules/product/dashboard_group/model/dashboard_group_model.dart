class ViewDashboardGroupModel {
  ViewDashboardGroupModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final List<ViewDashboardGroupDatum> data;

  ViewDashboardGroupModel copyWith({bool? success, String? message, List<ViewDashboardGroupDatum>? data}) {
    return ViewDashboardGroupModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewDashboardGroupModel.fromJson(Map<String, dynamic> json) {
    return ViewDashboardGroupModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<ViewDashboardGroupDatum>.from(json["data"]!.map((x) => ViewDashboardGroupDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class ViewDashboardGroupDatum {
  ViewDashboardGroupDatum({
    required this.groupId,
    required this.groupName,
    required this.groupCode,
    this.gImgM,
    this.gImgW,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int groupId;
  final String groupName;
  final String groupCode;
  final String? gImgM;
  final String? gImgW;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ViewDashboardGroupDatum copyWith({
    int? groupId,
    String? groupName,
    String? groupCode,
    String? gImgM,
    String? gImgW,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ViewDashboardGroupDatum(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupCode: groupCode ?? this.groupCode,
      gImgM: gImgM ?? this.gImgM,
      gImgW: gImgW ?? this.gImgW,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ViewDashboardGroupDatum.fromJson(Map<String, dynamic> json) {
    return ViewDashboardGroupDatum(
      groupId: json["group_id"] ?? 0,
      groupName: json["group_name"] ?? "",
      groupCode: json["group_code"] ?? "",
      gImgM: json["g_img_m"]?.toString() ?? "",
      gImgW: json["g_img_w"]?.toString() ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "group_id": groupId,
    "group_name": groupName,
    "group_code": groupCode,
    "g_img_m": gImgM,
    "g_img_w": gImgW,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$groupId, $groupName, $groupCode,$gImgM,$gImgW, $status, $createdAt, $updatedAt, ";
  }
}
