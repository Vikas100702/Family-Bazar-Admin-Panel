class ViewSubCategoryModel {
  ViewSubCategoryModel({required this.success, required this.message, required this.pagination, required this.data});

  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewSubCategoryDatum> data;

  ViewSubCategoryModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewSubCategoryDatum>? data}) {
    return ViewSubCategoryModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return ViewSubCategoryModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null ? [] : List<ViewSubCategoryDatum>.from(json["data"]!.map((x) => ViewSubCategoryDatum.fromJson(x))),
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

class ViewSubCategoryDatum {
  ViewSubCategoryDatum({
    required this.id,
    required this.ogCode,
    required this.ogName,
    required this.ogEucode,
    required this.ogMucode,
    required this.ogScCode,
    required this.ogStatus,
    required this.ogCreatedBy,
    required this.ogModifyBy,
    required this.ogCreatedTimeStamp,
    required this.ogModifyTimeStamp,
    required this.imImageMob,
    required this.imImageWeb,
  });

  final int id;
  final String ogCode;
  final String ogName;
  final String ogEucode;
  final String ogMucode;
  final String ogScCode;
  final String ogStatus;
  final String ogCreatedBy;
  final String ogModifyBy;
  final DateTime? ogCreatedTimeStamp;
  final DateTime? ogModifyTimeStamp;
  final String imImageMob;
  final String imImageWeb;

  bool get isStatusActive => ogStatus == '1' || ogStatus == 'true' || ogStatus.toLowerCase() == 'active';

  ViewSubCategoryDatum copyWith({
    int? id,
    String? ogCode,
    String? ogName,
    String? ogEucode,
    String? ogMucode,
    String? ogScCode,
    String? ogStatus,
    String? ogCreatedBy,
    String? ogModifyBy,
    DateTime? ogCreatedTimeStamp,
    DateTime? ogModifyTimeStamp,
    String? imImageMob,
    String? imImageWeb,
  }) {
    return ViewSubCategoryDatum(
      id: id ?? this.id,
      ogCode: ogCode ?? this.ogCode,
      ogName: ogName ?? this.ogName,
      ogEucode: ogEucode ?? this.ogEucode,
      ogMucode: ogMucode ?? this.ogMucode,
      ogScCode: ogScCode ?? this.ogScCode,
      ogStatus: ogStatus ?? this.ogStatus,
      ogCreatedBy: ogCreatedBy ?? this.ogCreatedBy,
      ogModifyBy: ogModifyBy ?? this.ogModifyBy,
      ogCreatedTimeStamp: ogCreatedTimeStamp ?? this.ogCreatedTimeStamp,
      ogModifyTimeStamp: ogModifyTimeStamp ?? this.ogModifyTimeStamp,
      imImageMob: imImageMob ?? this.imImageMob,
      imImageWeb: imImageWeb ?? this.imImageWeb,
    );
  }

  factory ViewSubCategoryDatum.fromJson(Map<String, dynamic> json) {
    return ViewSubCategoryDatum(
      id: json["id"] ?? 0,
      ogCode: json["OG_CODE"] ?? "",
      ogName: json["OG_NAME"] ?? "",
      ogEucode: json["OG_EUCODE"] ?? "",
      ogMucode: json["OG_MUCODE"] ?? "",
      ogScCode: json["OG_SC_CODE"] ?? "",
      ogStatus: json["OG_Status"] ?? "",
      ogCreatedBy: json["OG_CreatedBy"] ?? "",
      ogModifyBy: json["OG_ModifyBy"] ?? "",
      ogCreatedTimeStamp: DateTime.tryParse(json["OG_CreatedTimeStamp"] ?? ""),
      ogModifyTimeStamp: DateTime.tryParse(json["OG_ModifyTimeStamp"] ?? ""),
      imImageMob: json["IM_ImageMob"] ?? "",
      imImageWeb: json["IM_ImageWeb"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "OG_CODE": ogCode,
    "OG_NAME": ogName,
    "OG_EUCODE": ogEucode,
    "OG_MUCODE": ogMucode,
    "OG_SC_CODE": ogScCode,
    "OG_Status": ogStatus,
    "OG_CreatedBy": ogCreatedBy,
    "OG_ModifyBy": ogModifyBy,
    "OG_CreatedTimeStamp": ogCreatedTimeStamp?.toIso8601String(),
    "OG_ModifyTimeStamp": ogModifyTimeStamp?.toIso8601String(),
    "IM_ImageMob": imImageMob,
    "IM_ImageWeb": imImageWeb,
  };

  @override
  String toString() {
    return "$id, $ogCode, $ogName, $ogEucode, $ogMucode, $ogScCode, $ogStatus, $ogCreatedBy, $ogModifyBy, $ogCreatedTimeStamp, $ogModifyTimeStamp, $imImageMob, $imImageWeb, ";
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
