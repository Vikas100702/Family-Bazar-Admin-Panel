class AddGroupModel {
  AddGroupModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final AddGroupModelData? data;

  AddGroupModel copyWith({bool? success, String? message, AddGroupModelData? data}) {
    return AddGroupModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddGroupModel.fromJson(Map<String, dynamic> json) {
    return AddGroupModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : AddGroupModelData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class AddGroupModelData {
  AddGroupModelData({required this.status, required this.data, required this.action});

  final bool status;
  final DataData? data;
  final String action;

  AddGroupModelData copyWith({bool? status, DataData? data, String? action}) {
    return AddGroupModelData(status: status ?? this.status, data: data ?? this.data, action: action ?? this.action);
  }

  factory AddGroupModelData.fromJson(Map<String, dynamic> json) {
    return AddGroupModelData(
      status: json["status"] ?? false,
      data: json["data"] == null ? null : DataData.fromJson(json["data"]),
      action: json["action"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "data": data?.toJson(), "action": action};

  @override
  String toString() {
    return "$status, $data, $action, ";
  }
}

class DataData {
  DataData({
    required this.id,
    required this.dgName,
    required this.dgCode,
    required this.dgStatus,
    required this.dgCreatedAt,
    required this.dgUpdatedAt,
  });

  final int id;
  final String dgName;
  final String dgCode;
  final int dgStatus;
  final DateTime? dgCreatedAt;
  final DateTime? dgUpdatedAt;

  DataData copyWith({int? id, String? dgName, String? dgCode, int? dgStatus, DateTime? dgCreatedAt, DateTime? dgUpdatedAt}) {
    return DataData(
      id: id ?? this.id,
      dgName: dgName ?? this.dgName,
      dgCode: dgCode ?? this.dgCode,
      dgStatus: dgStatus ?? this.dgStatus,
      dgCreatedAt: dgCreatedAt ?? this.dgCreatedAt,
      dgUpdatedAt: dgUpdatedAt ?? this.dgUpdatedAt,
    );
  }

  factory DataData.fromJson(Map<String, dynamic> json) {
    return DataData(
      id: json["id"] ?? 0,
      dgName: json["DG_Name"] ?? "",
      dgCode: json["DG_Code"] ?? "",
      dgStatus: json["DG_Status"] ?? 0,
      dgCreatedAt: DateTime.tryParse(json["DG_CreatedAt"] ?? ""),
      dgUpdatedAt: DateTime.tryParse(json["DG_UpdatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "DG_Name": dgName,
    "DG_Code": dgCode,
    "DG_Status": dgStatus,
    "DG_CreatedAt": dgCreatedAt?.toIso8601String(),
    "DG_UpdatedAt": dgUpdatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $dgName, $dgCode, $dgStatus, $dgCreatedAt, $dgUpdatedAt, ";
  }
}
