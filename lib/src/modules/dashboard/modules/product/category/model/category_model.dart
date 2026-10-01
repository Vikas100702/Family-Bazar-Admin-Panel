class ViewCategoryModel {
  ViewCategoryModel({required this.success, required this.message, required this.pagination, required this.data});

  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewCategoryDatum> data;

  ViewCategoryModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewCategoryDatum>? data}) {
    return ViewCategoryModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewCategoryModel.fromJson(Map<String, dynamic> json) {
    return ViewCategoryModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null ? [] : List<ViewCategoryDatum>.from(json["data"]!.map((x) => ViewCategoryDatum.fromJson(x))),
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

class ViewCategoryDatum {
  ViewCategoryDatum({
    required this.id,
    required this.igCode,
    required this.igName,
    required this.igEucode,
    required this.igMucode,
    required this.igCmCode,
    required this.igStatus,
    required this.igCreatedBy,
    required this.igModifyBy,
    required this.igCreatedTimeStamp,
    required this.igModifyTimeStamp,
    required this.imImageMob,
    required this.imImageWeb,
  });

  final int id;
  final String igCode;
  final String igName;
  final String igEucode;
  final String igMucode;
  final String igCmCode;
  final String igStatus;
  final String igCreatedBy;
  final String igModifyBy;
  final DateTime? igCreatedTimeStamp;
  final DateTime? igModifyTimeStamp;
  final String imImageMob;
  final String imImageWeb;

  bool get isStatusActive => igStatus == '1' || igStatus == 'true' || igStatus.toLowerCase() == 'active';

  ViewCategoryDatum copyWith({
    int? id,
    String? igCode,
    String? igName,
    String? igEucode,
    String? igMucode,
    String? igCmCode,
    String? igStatus,
    String? igCreatedBy,
    String? igModifyBy,
    DateTime? igCreatedTimeStamp,
    DateTime? igModifyTimeStamp,
    String? imImageMob,
    String? imImageWeb,
  }) {
    return ViewCategoryDatum(
      id: id ?? this.id,
      igCode: igCode ?? this.igCode,
      igName: igName ?? this.igName,
      igEucode: igEucode ?? this.igEucode,
      igMucode: igMucode ?? this.igMucode,
      igCmCode: igCmCode ?? this.igCmCode,
      igStatus: igStatus ?? this.igStatus,
      igCreatedBy: igCreatedBy ?? this.igCreatedBy,
      igModifyBy: igModifyBy ?? this.igModifyBy,
      igCreatedTimeStamp: igCreatedTimeStamp ?? this.igCreatedTimeStamp,
      igModifyTimeStamp: igModifyTimeStamp ?? this.igModifyTimeStamp,
      imImageMob: imImageMob ?? this.imImageMob,
      imImageWeb: imImageWeb ?? this.imImageWeb,
    );
  }

  factory ViewCategoryDatum.fromJson(Map<String, dynamic> json) {
    return ViewCategoryDatum(
      id: json["id"] ?? 0,
      igCode: json["IG_CODE"] ?? "",
      igName: json["IG_NAME"] ?? "",
      igEucode: json["IG_EUCODE"] ?? "",
      igMucode: json["IG_MUCODE"] ?? "",
      igCmCode: json["IG_CM_CODE"] ?? "",
      igStatus: json["IG_Status"] ?? "",
      igCreatedBy: json["IG_CreatedBy"] ?? "",
      igModifyBy: json["IG_ModifyBy"] ?? "",
      igCreatedTimeStamp: DateTime.tryParse(json["IG_CreatedTimeStamp"] ?? ""),
      igModifyTimeStamp: DateTime.tryParse(json["IG_ModifyTimeStamp"] ?? ""),
      imImageMob: json["IM_ImageMob"] ?? "",
      imImageWeb: json["IM_ImageWeb"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "IG_CODE": igCode,
    "IG_NAME": igName,
    "IG_EUCODE": igEucode,
    "IG_MUCODE": igMucode,
    "IG_CM_CODE": igCmCode,
    "IG_Status": igStatus,
    "IG_CreatedBy": igCreatedBy,
    "IG_ModifyBy": igModifyBy,
    "IG_CreatedTimeStamp": igCreatedTimeStamp?.toIso8601String(),
    "IG_ModifyTimeStamp": igModifyTimeStamp?.toIso8601String(),
    "IM_ImageMob": imImageMob,
    "IM_ImageWeb": imImageWeb,
  };

  @override
  String toString() {
    return "$id, $igCode, $igName, $igEucode, $igMucode, $igCmCode, $igStatus, $igCreatedBy, $igModifyBy, $igCreatedTimeStamp, $igModifyTimeStamp, $imImageMob, $imImageWeb, ";
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
