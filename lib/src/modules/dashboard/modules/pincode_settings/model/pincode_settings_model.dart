class PincodeModel {
  PincodeModel({required this.status, required this.message, required this.pagination, required this.data});

  final bool status;
  final String message;
  final Pagination? pagination;
  final List<Datum> data;

  PincodeModel copyWith({bool? status, String? message, Pagination? pagination, List<Datum>? data}) {
    return PincodeModel(
      status: status ?? this.status,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory PincodeModel.fromJson(Map<String, dynamic> json) {
    return PincodeModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$status, $message, $pagination, $data, ";
  }
}

class Datum {
  Datum({
    required this.id,
    required this.userName,
    required this.pFirmCode,
    required this.pFirmName,
    required this.pPinCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String userName;
  final String pFirmCode;
  final String pFirmName;
  final String pPinCode;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Datum copyWith({
    int? id,
    String? userName,
    String? pFirmCode,
    String? pFirmName,
    String? pPinCode,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Datum(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      pFirmCode: pFirmCode ?? this.pFirmCode,
      pFirmName: pFirmName ?? this.pFirmName,
      pPinCode: pPinCode ?? this.pPinCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"] ?? 0,
      userName: json["user_name"] ?? "",
      pFirmCode: json["P_FirmCode"] ?? "",
      pFirmName: json["P_FirmName"] ?? "",
      pPinCode: json["P_PinCode"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_name": userName,
    "P_FirmCode": pFirmCode,
    "P_FirmName": pFirmName,
    "P_PinCode": pPinCode,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $userName, $pFirmCode, $pFirmName, $pPinCode, $status, $createdAt, $updatedAt, ";
  }
}

class Pagination {
  Pagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  final int currentPage;
  final int limit;
  final int totalRecords;
  final int totalPages;

  Pagination copyWith({int? currentPage, int? limit, int? totalRecords, int? totalPages}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      limit: json["limit"] ?? 0,
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
