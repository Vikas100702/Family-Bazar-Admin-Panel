import 'package:flutter/foundation.dart';

@immutable
class ViewSubCategoryModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewSubCategoryDatum> data;

  const ViewSubCategoryModel({required this.success, required this.message, this.pagination, required this.data});

  ViewSubCategoryModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewSubCategoryDatum>? data}) {
    return ViewSubCategoryModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewSubCategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewSubCategoryModel(
        success: false,
        message: 'Empty response payload received.',
        pagination: null,
        data: <ViewSubCategoryDatum>[],
      );
    }

    final dynamic rawData = json['data'];
    final List<ViewSubCategoryDatum> parsedData = <ViewSubCategoryDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(ViewSubCategoryDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(ViewSubCategoryDatum.fromJson(rawData));
    }

    return ViewSubCategoryModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<ViewSubCategoryDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewSubCategoryModel(success: $success, message: $message, records: ${data.length})';
}

@immutable
class ViewSubCategoryDatum {
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

  const ViewSubCategoryDatum({
    required this.id,
    required this.ogCode,
    required this.ogName,
    required this.ogEucode,
    required this.ogMucode,
    required this.ogScCode,
    required this.ogStatus,
    required this.ogCreatedBy,
    required this.ogModifyBy,
    this.ogCreatedTimeStamp,
    this.ogModifyTimeStamp,
    required this.imImageMob,
    required this.imImageWeb,
  });

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

  factory ViewSubCategoryDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewSubCategoryDatum(
        id: 0,
        ogCode: '',
        ogName: '',
        ogEucode: '',
        ogMucode: '',
        ogScCode: '',
        ogStatus: '0',
        ogCreatedBy: '',
        ogModifyBy: '',
        imImageMob: '',
        imImageWeb: '',
      );
    }

    return ViewSubCategoryDatum(
      id: _parseInt(json['id']),
      ogCode: _parseCleanString(json['OG_CODE'] ?? json['og_code'] ?? json['subcat_code']),
      ogName: _parseCleanString(json['OG_NAME'] ?? json['og_name'] ?? json['subcat_name']),
      ogEucode: _parseCleanString(json['OG_EUCODE'] ?? json['og_eucode']),
      ogMucode: _parseCleanString(json['OG_MUCODE'] ?? json['og_mucode']),
      ogScCode: _parseCleanString(json['OG_SC_CODE'] ?? json['og_sc_code']),
      ogStatus: _parseCleanString(json['OG_Status'] ?? json['status'] ?? json['og_status'], fallback: '0'),
      ogCreatedBy: _parseCleanString(json['OG_CreatedBy'] ?? json['og_created_by']),
      ogModifyBy: _parseCleanString(json['OG_ModifyBy'] ?? json['og_modify_by']),
      ogCreatedTimeStamp: _parseDate(json['OG_CreatedTimeStamp'] ?? json['created_at']),
      ogModifyTimeStamp: _parseDate(json['OG_ModifyTimeStamp'] ?? json['updated_at']),
      imImageMob: _parseCleanString(json['IM_ImageMob'] ?? json['m_img']),
      imImageWeb: _parseCleanString(json['IM_ImageWeb'] ?? json['w_img']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'OG_CODE': ogCode,
    'OG_NAME': ogName,
    'OG_EUCODE': ogEucode,
    'OG_MUCODE': ogMucode,
    'OG_SC_CODE': ogScCode,
    'OG_Status': ogStatus,
    'OG_CreatedBy': ogCreatedBy,
    'OG_ModifyBy': ogModifyBy,
    'OG_CreatedTimeStamp': ogCreatedTimeStamp?.toIso8601String(),
    'OG_ModifyTimeStamp': ogModifyTimeStamp?.toIso8601String(),
    'IM_ImageMob': imImageMob,
    'IM_ImageWeb': imImageWeb,
  };

  @override
  String toString() => 'ViewSubCategoryDatum(ogCode: $ogCode, ogName: $ogName, status: $ogStatus)';
}

@immutable
class Pagination {
  final int currentPage;
  final int limit;
  final int totalRecords;
  final int totalPages;

  const Pagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  Pagination copyWith({int? currentPage, int? limit, int? totalRecords, int? totalPages}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Pagination(currentPage: 1, limit: 20, totalRecords: 0, totalPages: 1);
    }

    return Pagination(
      currentPage: _parseInt(json['current_page'] ?? json['page'], defaultValue: 1),
      limit: _parseInt(json['limit'] ?? json['per_page'], defaultValue: 20),
      totalRecords: _parseInt(json['total_records'] ?? json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() => {'current_page': currentPage, 'limit': limit, 'total_records': totalRecords, 'total_pages': totalPages};

  @override
  String toString() => 'Pagination(currentPage: $currentPage, totalRecords: $totalRecords)';
}

@immutable
class InsertSubCatDetailsModel {
  final bool success;
  final String message;
  final InsertSubCatDetailsData? data;

  const InsertSubCatDetailsModel({required this.success, required this.message, this.data});

  factory InsertSubCatDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const InsertSubCatDetailsModel(success: false, message: 'Empty response payload received.');
    }

    return InsertSubCatDetailsModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] is Map<String, dynamic> ? InsertSubCatDetailsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class InsertSubCatDetailsData {
  final int id;
  final String subcatCode;
  final String subcatName;
  final String mImg;
  final String wImg;
  final String action;

  const InsertSubCatDetailsData({
    required this.id,
    required this.subcatCode,
    required this.subcatName,
    required this.mImg,
    required this.wImg,
    required this.action,
  });

  factory InsertSubCatDetailsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const InsertSubCatDetailsData(id: 0, subcatCode: '', subcatName: '', mImg: '', wImg: '', action: '');
    }

    return InsertSubCatDetailsData(
      id: _parseInt(json['id']),
      subcatCode: _parseCleanString(json['subcat_code'] ?? json['subcatCode']),
      subcatName: _parseCleanString(json['subcat_name'] ?? json['subcatName']),
      mImg: _parseCleanString(json['m_img']),
      wImg: _parseCleanString(json['w_img']),
      action: _parseCleanString(json['action']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'subcat_code': subcatCode, 'subcat_name': subcatName, 'm_img': mImg, 'w_img': wImg, 'action': action};
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val == 1;
  final String str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true' || str == 'active' || str == 'y';
}

int _parseInt(dynamic val, {int defaultValue = 0}) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final String str = val.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return defaultValue;
}

String _parseCleanString(dynamic val, {String fallback = ''}) {
  if (val == null) return fallback;
  final String str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return fallback;
  return str;
}

DateTime? _parseDate(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) {
    return val.year >= 1970 ? val : null;
  }
  final String dateStr = val.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00') || dateStr == 'null' || dateStr == 'undefined') {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }
  return parsed;
}
