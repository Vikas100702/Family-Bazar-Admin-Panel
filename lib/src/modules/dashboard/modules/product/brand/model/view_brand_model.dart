import 'package:flutter/foundation.dart';

@immutable
class ViewBrandModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewBrandDatum> data;

  const ViewBrandModel({required this.success, required this.message, this.pagination, required this.data});

  ViewBrandModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewBrandDatum>? data}) {
    return ViewBrandModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewBrandModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewBrandModel(success: false, message: 'Empty response payload received', pagination: null, data: <ViewBrandDatum>[]);
    }

    final dynamic rawData = json['data'];
    final List<ViewBrandDatum> parsedData = <ViewBrandDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(ViewBrandDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(ViewBrandDatum.fromJson(rawData));
    }

    return ViewBrandModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<ViewBrandDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewBrandModel(success: $success, message: $message, records: ${data.length})';
}

@immutable
class ViewBrandDatum {
  final int id;
  final String mcCompCode;
  final String mcCompName;
  final String mcMuCode;
  final int mcLock;
  final String mcCpCompCode;
  final String mcFeaturedBrand;
  final String mcStatus;
  final String mcCreatedBy;
  final String mcModifyBy;
  final DateTime? mcCreatedTimeStamp;
  final DateTime? mcModifyTimeStamp;
  final int imageId;
  final String imItemCode;
  final String imItemType;
  final String imImageMob;
  final String imImageWeb;
  final String imCreBy;
  final String imModBy;

  const ViewBrandDatum({
    required this.id,
    required this.mcCompCode,
    required this.mcCompName,
    required this.mcMuCode,
    required this.mcLock,
    required this.mcCpCompCode,
    required this.mcFeaturedBrand,
    required this.mcStatus,
    required this.mcCreatedBy,
    required this.mcModifyBy,
    this.mcCreatedTimeStamp,
    this.mcModifyTimeStamp,
    required this.imageId,
    required this.imItemCode,
    required this.imItemType,
    required this.imImageMob,
    required this.imImageWeb,
    required this.imCreBy,
    required this.imModBy,
  });

  bool get isFeatured => mcFeaturedBrand == '1' || mcFeaturedBrand == 'true' || mcFeaturedBrand.toLowerCase() == 'yes';

  bool get isStatusActive => mcStatus == '1' || mcStatus == 'true' || mcStatus.toLowerCase() == 'active';

  ViewBrandDatum copyWith({
    int? id,
    String? mcCompCode,
    String? mcCompName,
    String? mcMuCode,
    int? mcLock,
    String? mcCpCompCode,
    String? mcFeaturedBrand,
    String? mcStatus,
    String? mcCreatedBy,
    String? mcModifyBy,
    DateTime? mcCreatedTimeStamp,
    DateTime? mcModifyTimeStamp,
    int? imageId,
    String? imItemCode,
    String? imItemType,
    String? imImageMob,
    String? imImageWeb,
    String? imCreBy,
    String? imModBy,
  }) {
    return ViewBrandDatum(
      id: id ?? this.id,
      mcCompCode: mcCompCode ?? this.mcCompCode,
      mcCompName: mcCompName ?? this.mcCompName,
      mcMuCode: mcMuCode ?? this.mcMuCode,
      mcLock: mcLock ?? this.mcLock,
      mcCpCompCode: mcCpCompCode ?? this.mcCpCompCode,
      mcFeaturedBrand: mcFeaturedBrand ?? this.mcFeaturedBrand,
      mcStatus: mcStatus ?? this.mcStatus,
      mcCreatedBy: mcCreatedBy ?? this.mcCreatedBy,
      mcModifyBy: mcModifyBy ?? this.mcModifyBy,
      mcCreatedTimeStamp: mcCreatedTimeStamp ?? this.mcCreatedTimeStamp,
      mcModifyTimeStamp: mcModifyTimeStamp ?? this.mcModifyTimeStamp,
      imageId: imageId ?? this.imageId,
      imItemCode: imItemCode ?? this.imItemCode,
      imItemType: imItemType ?? this.imItemType,
      imImageMob: imImageMob ?? this.imImageMob,
      imImageWeb: imImageWeb ?? this.imImageWeb,
      imCreBy: imCreBy ?? this.imCreBy,
      imModBy: imModBy ?? this.imModBy,
    );
  }

  factory ViewBrandDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewBrandDatum(
        id: 0,
        mcCompCode: '',
        mcCompName: '',
        mcMuCode: '',
        mcLock: 0,
        mcCpCompCode: '',
        mcFeaturedBrand: '0',
        mcStatus: '0',
        mcCreatedBy: '',
        mcModifyBy: '',
        imageId: 0,
        imItemCode: '',
        imItemType: '',
        imImageMob: '',
        imImageWeb: '',
        imCreBy: '',
        imModBy: '',
      );
    }

    return ViewBrandDatum(
      id: _parseInt(json['id']),
      mcCompCode: _parseCleanString(json['MC_CompCode']),
      mcCompName: _parseCleanString(json['MC_CompName']),
      mcMuCode: _parseCleanString(json['MC_MUCode']),
      mcLock: _parseInt(json['MC_Lock']),
      mcCpCompCode: _parseCleanString(json['MC_CPCompCode']),
      mcFeaturedBrand: _parseCleanString(json['MC_Featured_Brand'] ?? json['featured_brand'], fallback: '0'),
      mcStatus: _parseCleanString(json['MC_Status'] ?? json['status'], fallback: '0'),
      mcCreatedBy: _parseCleanString(json['MC_CreatedBy']),
      mcModifyBy: _parseCleanString(json['MC_ModifyBy']),
      mcCreatedTimeStamp: _parseDate(json['MC_CreatedTimeStamp']),
      mcModifyTimeStamp: _parseDate(json['MC_ModifyTimeStamp']),
      imageId: _parseInt(json['image_id']),
      imItemCode: _parseCleanString(json['IM_ItemCode']),
      imItemType: _parseCleanString(json['IM_ItemType']),
      imImageMob: _parseCleanString(json['IM_ImageMob'] ?? json['m_img']),
      imImageWeb: _parseCleanString(json['IM_ImageWeb'] ?? json['w_img']),
      imCreBy: _parseCleanString(json['IM_CreBy']),
      imModBy: _parseCleanString(json['IM_ModBy']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'MC_CompCode': mcCompCode,
    'MC_CompName': mcCompName,
    'MC_MUCode': mcMuCode,
    'MC_Lock': mcLock,
    'MC_CPCompCode': mcCpCompCode,
    'MC_Featured_Brand': mcFeaturedBrand,
    'MC_Status': mcStatus,
    'MC_CreatedBy': mcCreatedBy,
    'MC_ModifyBy': mcModifyBy,
    'MC_CreatedTimeStamp': mcCreatedTimeStamp?.toIso8601String(),
    'MC_ModifyTimeStamp': mcModifyTimeStamp?.toIso8601String(),
    'image_id': imageId,
    'IM_ItemCode': imItemCode,
    'IM_ItemType': imItemType,
    'IM_ImageMob': imImageMob,
    'IM_ImageWeb': imImageWeb,
    'IM_CreBy': imCreBy,
    'IM_ModBy': imModBy,
  };

  @override
  String toString() => 'ViewBrandDatum(mcCompCode: $mcCompCode, mcCompName: $mcCompName, featured: $mcFeaturedBrand, status: $mcStatus)';
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
      return const Pagination(currentPage: 0, limit: 0, totalRecords: 0, totalPages: 0);
    }

    return Pagination(
      currentPage: _parseInt(json['current_page'] ?? json['page']),
      limit: _parseInt(json['limit'] ?? json['per_page'], defaultValue: 20),
      totalRecords: _parseInt(json['total_records'] ?? json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages']),
    );
  }

  Map<String, dynamic> toJson() => {'current_page': currentPage, 'limit': limit, 'total_records': totalRecords, 'total_pages': totalPages};

  @override
  String toString() => 'Pagination(currentPage: $currentPage, totalRecords: $totalRecords)';
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
