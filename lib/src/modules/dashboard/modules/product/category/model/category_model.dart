import 'package:flutter/foundation.dart';

@immutable
class ViewCategoryModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewCategoryDatum> data;

  const ViewCategoryModel({required this.success, required this.message, this.pagination, required this.data});

  ViewCategoryModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewCategoryDatum>? data}) {
    return ViewCategoryModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewCategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewCategoryModel(success: false, message: 'Empty response payload received.', pagination: null, data: <ViewCategoryDatum>[]);
    }

    final dynamic rawData = json['data'];
    final List<ViewCategoryDatum> parsedData = <ViewCategoryDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(ViewCategoryDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(ViewCategoryDatum.fromJson(rawData));
    }

    return ViewCategoryModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<ViewCategoryDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewCategoryModel(success: $success, message: $message, records: ${data.length})';
}

@immutable
class ViewCategoryDatum {
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

  const ViewCategoryDatum({
    required this.id,
    required this.igCode,
    required this.igName,
    required this.igEucode,
    required this.igMucode,
    required this.igCmCode,
    required this.igStatus,
    required this.igCreatedBy,
    required this.igModifyBy,
    this.igCreatedTimeStamp,
    this.igModifyTimeStamp,
    required this.imImageMob,
    required this.imImageWeb,
  });

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

  factory ViewCategoryDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewCategoryDatum(
        id: 0,
        igCode: '',
        igName: '',
        igEucode: '',
        igMucode: '',
        igCmCode: '',
        igStatus: '0',
        igCreatedBy: '',
        igModifyBy: '',
        imImageMob: '',
        imImageWeb: '',
      );
    }

    return ViewCategoryDatum(
      id: _parseInt(json['id']),
      igCode: _parseCleanString(json['IG_CODE'] ?? json['ig_code'] ?? json['cat_code']),
      igName: _parseCleanString(json['IG_NAME'] ?? json['ig_name'] ?? json['cat_name']),
      igEucode: _parseCleanString(json['IG_EUCODE'] ?? json['ig_eucode']),
      igMucode: _parseCleanString(json['IG_MUCODE'] ?? json['ig_mucode']),
      igCmCode: _parseCleanString(json['IG_CM_CODE'] ?? json['ig_cm_code']),
      igStatus: _parseCleanString(json['IG_Status'] ?? json['status'] ?? json['ig_status'], fallback: '0'),
      igCreatedBy: _parseCleanString(json['IG_CreatedBy'] ?? json['ig_created_by']),
      igModifyBy: _parseCleanString(json['IG_ModifyBy'] ?? json['ig_modify_by']),
      igCreatedTimeStamp: _parseDate(json['IG_CreatedTimeStamp'] ?? json['created_at']),
      igModifyTimeStamp: _parseDate(json['IG_ModifyTimeStamp'] ?? json['updated_at']),
      imImageMob: _parseCleanString(json['IM_ImageMob'] ?? json['m_img']),
      imImageWeb: _parseCleanString(json['IM_ImageWeb'] ?? json['w_img']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'IG_CODE': igCode,
    'IG_NAME': igName,
    'IG_EUCODE': igEucode,
    'IG_MUCODE': igMucode,
    'IG_CM_CODE': igCmCode,
    'IG_Status': igStatus,
    'IG_CreatedBy': igCreatedBy,
    'IG_ModifyBy': igModifyBy,
    'IG_CreatedTimeStamp': igCreatedTimeStamp?.toIso8601String(),
    'IG_ModifyTimeStamp': igModifyTimeStamp?.toIso8601String(),
    'IM_ImageMob': imImageMob,
    'IM_ImageWeb': imImageWeb,
  };

  @override
  String toString() => 'ViewCategoryDatum(igCode: $igCode, igName: $igName, status: $igStatus)';
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
class AddCatDetailsModel {
  final bool success;
  final String message;
  final AddCatDetailsData? data;

  const AddCatDetailsModel({required this.success, required this.message, this.data});

  factory AddCatDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCatDetailsModel(success: false, message: 'Empty response payload received.');
    }

    return AddCatDetailsModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] is Map<String, dynamic> ? AddCatDetailsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class AddCatDetailsData {
  final int id;
  final String catCode;
  final String catName;
  final String mImg;
  final String wImg;
  final String action;

  const AddCatDetailsData({
    required this.id,
    required this.catCode,
    required this.catName,
    required this.mImg,
    required this.wImg,
    required this.action,
  });

  factory AddCatDetailsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCatDetailsData(id: 0, catCode: '', catName: '', mImg: '', wImg: '', action: '');
    }

    return AddCatDetailsData(
      id: _parseInt(json['id']),
      catCode: _parseCleanString(json['cat_code'] ?? json['catCode']),
      catName: _parseCleanString(json['cat_name'] ?? json['catName']),
      mImg: _parseCleanString(json['m_img']),
      wImg: _parseCleanString(json['w_img']),
      action: _parseCleanString(json['action']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'cat_code': catCode, 'cat_name': catName, 'm_img': mImg, 'w_img': wImg, 'action': action};
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
