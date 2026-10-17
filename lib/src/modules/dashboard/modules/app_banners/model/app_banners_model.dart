import 'package:flutter/foundation.dart';

@immutable
class AppBannerResponseModel {
  final bool success;
  final String message;
  final BannerPagination? pagination;
  final List<AppBannerDatum> data;

  const AppBannerResponseModel({this.success = false, this.message = '', this.pagination, this.data = const <AppBannerDatum>[]});

  factory AppBannerResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppBannerResponseModel();

    return AppBannerResponseModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: json['message']?.toString().trim() ?? '',
      pagination: json['pagination'] is Map<String, dynamic> ? BannerPagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data:
          (json['data'] as List<dynamic>?)?.whereType<Map<String, dynamic>>().map(AppBannerDatum.fromJson).toList(growable: false) ??
          const <AppBannerDatum>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'pagination': pagination?.toJson(),
    'data': data.map((e) => e.toJson()).toList(growable: false),
  };

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final String clean = val.toString().trim().toLowerCase();
    return clean == '1' || clean == 'true' || clean == 'success';
  }
}

/// Strongly-typed immutable pagination model.
@immutable
class BannerPagination {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int limit;

  const BannerPagination({this.totalRecords = 0, this.totalPages = 1, this.currentPage = 1, this.limit = 50});

  factory BannerPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BannerPagination();

    return BannerPagination(
      totalRecords: _parseInt(json['total_records'] ?? json['total']),
      totalPages: _parseInt(json['total_pages'], fallback: 1),
      currentPage: _parseInt(json['current_page'] ?? json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 50),
    );
  }

  Map<String, dynamic> toJson() => {'total_records': totalRecords, 'total_pages': totalPages, 'current_page': currentPage, 'limit': limit};

  static int _parseInt(dynamic val, {int fallback = 0}) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString().trim()) ?? fallback;
  }
}

/// Represents an individual banner entity with strict type defense.
@immutable
class AppBannerDatum {
  final int id;
  final String bnrType;
  final String bnrImg;
  final int status;
  final String? startDate;
  final String? endDate;
  final String created;
  final String updated;

  const AppBannerDatum({
    this.id = 0,
    this.bnrType = '',
    this.bnrImg = '',
    this.status = 1,
    this.startDate,
    this.endDate,
    this.created = '',
    this.updated = '',
  });

  const AppBannerDatum.empty() : id = 0, bnrType = '', bnrImg = '', status = 1, startDate = null, endDate = null, created = '', updated = '';

  factory AppBannerDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppBannerDatum.empty();

    return AppBannerDatum(
      id: _parseInt(json['id']),
      bnrType: _parseCleanString(json['bnr_type'] ?? json['type']),
      bnrImg: _parseCleanString(json['bnr_img'] ?? json['image']),
      status: _parseStatus(json['status']),
      startDate: _parseNullableDate(json['start_date']),
      endDate: _parseNullableDate(json['end_date']),
      created: _parseCleanString(json['created'] ?? json['created_at']),
      updated: _parseCleanString(json['updated'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bnr_type': bnrType,
    'bnr_img': bnrImg,
    'status': status,
    'start_date': startDate,
    'end_date': endDate,
    'created': created,
    'updated': updated,
  };

  AppBannerDatum copyWith({int? id, String? bnrType, String? bnrImg, int? status, String? startAt, String? endAt, String? created, String? updated}) {
    return AppBannerDatum(
      id: id ?? this.id,
      bnrType: bnrType ?? this.bnrType,
      bnrImg: bnrImg ?? this.bnrImg,
      status: status ?? this.status,
      startDate: startAt ?? this.startDate,
      endDate: endAt ?? this.endDate,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  static int _parseInt(dynamic val, {int fallback = 0}) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString().trim()) ?? fallback;
  }

  static int _parseStatus(dynamic val) {
    if (val == null) return 0;
    if (val is int) return (val == 1) ? 1 : 0;
    if (val is bool) return val ? 1 : 0;
    final String clean = val.toString().trim().toLowerCase();
    if (clean == '1' || clean == 'true' || clean == 'active' || clean == 'y') {
      return 1;
    }
    return 0;
  }

  static String _parseCleanString(dynamic val) {
    if (val == null) return '';
    final String str = val.toString().trim();
    if (str == 'null' || str == 'undefined') return '';
    return str;
  }

  static String? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    final String str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'undefined' || str.startsWith('0000-00-00')) {
      return null;
    }
    return str;
  }
}

/// Response contract for banner create/update mutations.
@immutable
class SaveBannerResponseModel {
  final bool success;
  final String message;
  final AppBannerDatum? data;

  const SaveBannerResponseModel({this.success = false, this.message = '', this.data});

  factory SaveBannerResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SaveBannerResponseModel();

    return SaveBannerResponseModel(
      success:
          json['success'] == true ||
          json['success'] == 1 ||
          json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] is Map<String, dynamic> ? AppBannerDatum.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, 'data': data?.toJson()};
}
