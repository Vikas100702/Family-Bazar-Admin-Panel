class AddGroupModel {
  AddGroupModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final AddGroupData? data;

  AddGroupModel copyWith({bool? success, String? message, AddGroupData? data}) {
    return AddGroupModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddGroupModel.fromJson(Map<String, dynamic> json) {
    return AddGroupModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : AddGroupData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class AddGroupData {
  AddGroupData({
    required this.groupId,
    required this.groupName,
    required this.groupCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.action,
  });

  final int groupId;
  final String groupName;
  final String groupCode;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String action;

  AddGroupData copyWith({
    int? groupId,
    String? groupName,
    String? groupCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? action,
  }) {
    return AddGroupData(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupCode: groupCode ?? this.groupCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      action: action ?? this.action,
    );
  }

  factory AddGroupData.fromJson(Map<String, dynamic> json) {
    return AddGroupData(
      groupId: json["group_id"] ?? 0,
      groupName: json["group_name"] ?? "",
      groupCode: json["group_code"] ?? "",
      status: json["status"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      action: json["action"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "group_id": groupId,
    "group_name": groupName,
    "group_code": groupCode,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "action": action,
  };

  @override
  String toString() {
    return "$groupId, $groupName, $groupCode, $status, $createdAt, $updatedAt, $action, ";
  }
}
