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
      success: json['success'] == true || json['success'] == 1 || json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? BannerPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      data:
          (json['data'] as List<dynamic>?)?.whereType<Map<String, dynamic>>().map((e) => AppBannerDatum.fromJson(e)).toList() ??
          const <AppBannerDatum>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'pagination': pagination?.toJson(),
    'data': data.map((e) => e.toJson()).toList(),
  };
}

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
      totalPages: _parseInt(json['total_pages']),
      currentPage: _parseInt(json['current_page'] ?? json['page']),
      limit: _parseInt(json['limit']),
    );
  }

  Map<String, dynamic> toJson() => {'total_records': totalRecords, 'total_pages': totalPages, 'current_page': currentPage, 'limit': limit};

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    return int.tryParse(val?.toString() ?? '') ?? 0;
  }
}

@immutable
class AppBannerDatum {
  final int id;
  final String bnrType;
  final String bnrImg;
  final int status;
  final String? startAt;
  final String? endAt;
  final String created;
  final String updated;

  const AppBannerDatum({
    this.id = 0,
    this.bnrType = '',
    this.bnrImg = '',
    this.status = 1,
    this.startAt,
    this.endAt,
    this.created = '',
    this.updated = '',
  });

  factory AppBannerDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppBannerDatum();
    return AppBannerDatum(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      bnrType: json['bnr_type']?.toString().trim() ?? '',
      bnrImg: json['bnr_img']?.toString().trim() ?? '',
      status: json['status'] is int ? json['status'] as int : (int.tryParse(json['status']?.toString() ?? '') ?? (json['status'] == true ? 1 : 0)),
      startAt: json['start_at']?.toString().trim(),
      endAt: json['end_at']?.toString().trim(),
      created: json['created']?.toString().trim() ?? json['created_at']?.toString().trim() ?? '',
      updated: json['updated']?.toString().trim() ?? json['updated_at']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bnr_type': bnrType,
    'bnr_img': bnrImg,
    'status': status,
    'start_at': startAt,
    'end_at': endAt,
    'created': created,
    'updated': updated,
  };

  AppBannerDatum copyWith({int? id, String? bnrType, String? bnrImg, int? status, String? startAt, String? endAt, String? created, String? updated}) {
    return AppBannerDatum(
      id: id ?? this.id,
      bnrType: bnrType ?? this.bnrType,
      bnrImg: bnrImg ?? this.bnrImg,
      status: status ?? this.status,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}

@immutable
class SaveBannerResponseModel {
  final bool success;
  final String message;
  final AppBannerDatum? data;

  const SaveBannerResponseModel({this.success = false, this.message = '', this.data});

  factory SaveBannerResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SaveBannerResponseModel();
    return SaveBannerResponseModel(
      success: json['success'] == true || json['success'] == 1 || json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? AppBannerDatum.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, 'data': data?.toJson()};
}
