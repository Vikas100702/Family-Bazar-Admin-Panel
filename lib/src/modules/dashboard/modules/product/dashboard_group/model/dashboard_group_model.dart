class ViewDashboardGroupModel {
  ViewDashboardGroupModel({required this.success, required this.message, required this.pagination, required this.data});

  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewDashboardGroupDatum> data;

  ViewDashboardGroupModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewDashboardGroupDatum>? data}) {
    return ViewDashboardGroupModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewDashboardGroupModel.fromJson(Map<String, dynamic> json) {
    return ViewDashboardGroupModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null ? [] : List<ViewDashboardGroupDatum>.from(json["data"]!.map((x) => ViewDashboardGroupDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$success, $message, $pagination, $data, ";
  }
}

class ViewDashboardGroupDatum {
  ViewDashboardGroupDatum({
    required this.id,
    required this.dgName,
    required this.dgCode,
    required this.dgStatus,
    required this.dgCreatedAt,
    required this.dgUpdatedAt,
    required this.imItemCode,
    required this.imItemType,
    required this.imImageMob,
    required this.imImageWeb,
    required this.imRecCreDate,
    required this.imRecCreTime,
    required this.imCreBy,
  });

  final int id;
  final String dgName;
  final String dgCode;
  final int dgStatus;
  final DateTime? dgCreatedAt;
  final DateTime? dgUpdatedAt;
  final String imItemCode;
  final String imItemType;
  final String imImageMob;
  final String imImageWeb;
  final DateTime? imRecCreDate;
  final String imRecCreTime;
  final String imCreBy;

  ViewDashboardGroupDatum copyWith({
    int? id,
    String? dgName,
    String? dgCode,
    int? dgStatus,
    DateTime? dgCreatedAt,
    DateTime? dgUpdatedAt,
    String? imItemCode,
    String? imItemType,
    String? imImageMob,
    String? imImageWeb,
    DateTime? imRecCreDate,
    String? imRecCreTime,
    String? imCreBy,
  }) {
    return ViewDashboardGroupDatum(
      id: id ?? this.id,
      dgName: dgName ?? this.dgName,
      dgCode: dgCode ?? this.dgCode,
      dgStatus: dgStatus ?? this.dgStatus,
      dgCreatedAt: dgCreatedAt ?? this.dgCreatedAt,
      dgUpdatedAt: dgUpdatedAt ?? this.dgUpdatedAt,
      imItemCode: imItemCode ?? this.imItemCode,
      imItemType: imItemType ?? this.imItemType,
      imImageMob: imImageMob ?? this.imImageMob,
      imImageWeb: imImageWeb ?? this.imImageWeb,
      imRecCreDate: imRecCreDate ?? this.imRecCreDate,
      imRecCreTime: imRecCreTime ?? this.imRecCreTime,
      imCreBy: imCreBy ?? this.imCreBy,
    );
  }

  factory ViewDashboardGroupDatum.fromJson(Map<String, dynamic> json) {
    return ViewDashboardGroupDatum(
      id: json["id"] ?? 0,
      dgName: json["DG_Name"] ?? "",
      dgCode: json["DG_Code"] ?? "",
      dgStatus: json["DG_Status"] ?? 0,
      dgCreatedAt: DateTime.tryParse(json["DG_CreatedAt"] ?? ""),
      dgUpdatedAt: DateTime.tryParse(json["DG_UpdatedAt"] ?? ""),
      imItemCode: json["IM_ItemCode"] ?? "",
      imItemType: json["IM_ItemType"] ?? "",
      imImageMob: json["IM_ImageMob"] ?? "",
      imImageWeb: json["IM_ImageWeb"] ?? "",
      imRecCreDate: DateTime.tryParse(json["IM_RecCreDate"] ?? ""),
      imRecCreTime: json["IM_RecCreTime"] ?? "",
      imCreBy: json["IM_CreBy"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "DG_Name": dgName,
    "DG_Code": dgCode,
    "DG_Status": dgStatus,
    "DG_CreatedAt": dgCreatedAt?.toIso8601String(),
    "DG_UpdatedAt": dgUpdatedAt?.toIso8601String(),
    "IM_ItemCode": imItemCode,
    "IM_ItemType": imItemType,
    "IM_ImageMob": imImageMob,
    "IM_ImageWeb": imImageWeb,
    "IM_RecCreDate":
        "${imRecCreDate?.year.toString().padLeft(4)}-${imRecCreDate?.month.toString().padLeft(2)}-${imRecCreDate?.day.toString().padLeft(2)}",
    "IM_RecCreTime": imRecCreTime,
    "IM_CreBy": imCreBy,
  };

  @override
  String toString() {
    return "$id, $dgName, $dgCode, $dgStatus, $dgCreatedAt, $dgUpdatedAt, $imItemCode, $imItemType, $imImageMob, $imImageWeb, $imRecCreDate, $imRecCreTime, $imCreBy, ";
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
