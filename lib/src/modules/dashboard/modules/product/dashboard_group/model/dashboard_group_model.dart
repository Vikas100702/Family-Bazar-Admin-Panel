import 'package:flutter/foundation.dart';

@immutable
class ViewDashboardGroupModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewDashboardGroupDatum> data;

  const ViewDashboardGroupModel({required this.success, required this.message, this.pagination, required this.data});

  ViewDashboardGroupModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewDashboardGroupDatum>? data}) {
    return ViewDashboardGroupModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewDashboardGroupModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewDashboardGroupModel(
        success: false,
        message: 'Empty response payload received.',
        pagination: null,
        data: <ViewDashboardGroupDatum>[],
      );
    }

    final dynamic rawData = json['data'];
    final List<ViewDashboardGroupDatum> parsedData = <ViewDashboardGroupDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(ViewDashboardGroupDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(ViewDashboardGroupDatum.fromJson(rawData));
    }

    return ViewDashboardGroupModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<ViewDashboardGroupDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewDashboardGroupModel(success: $success, message: $message, records: ${data.length})';
}

@immutable
class ViewDashboardGroupDatum {
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

  const ViewDashboardGroupDatum({
    required this.id,
    required this.dgName,
    required this.dgCode,
    required this.dgStatus,
    this.dgCreatedAt,
    this.dgUpdatedAt,
    required this.imItemCode,
    required this.imItemType,
    required this.imImageMob,
    required this.imImageWeb,
    this.imRecCreDate,
    required this.imRecCreTime,
    required this.imCreBy,
  });

  bool get isActive => dgStatus == 1;

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

  factory ViewDashboardGroupDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewDashboardGroupDatum(
        id: 0,
        dgName: '',
        dgCode: '',
        dgStatus: 0,
        imItemCode: '',
        imItemType: '',
        imImageMob: '',
        imImageWeb: '',
        imRecCreTime: '',
        imCreBy: '',
      );
    }

    return ViewDashboardGroupDatum(
      id: _parseInt(json['id']),
      dgName: _parseCleanString(json['DG_Name'] ?? json['dg_name']),
      dgCode: _parseCleanString(json['DG_Code'] ?? json['dg_code']),
      dgStatus: _parseInt(json['DG_Status'] ?? json['status'] ?? json['dg_status'], defaultValue: 1),
      dgCreatedAt: _parseDate(json['DG_CreatedAt'] ?? json['created_at']),
      dgUpdatedAt: _parseDate(json['DG_UpdatedAt'] ?? json['updated_at']),
      imItemCode: _parseCleanString(json['IM_ItemCode'] ?? json['item_code']),
      imItemType: _parseCleanString(json['IM_ItemType'] ?? json['item_type']),
      imImageMob: _parseCleanString(json['IM_ImageMob'] ?? json['m_img']),
      imImageWeb: _parseCleanString(json['IM_ImageWeb'] ?? json['w_img']),
      imRecCreDate: _parseDate(json['IM_RecCreDate']),
      imRecCreTime: _parseCleanString(json['IM_RecCreTime']),
      imCreBy: _parseCleanString(json['IM_CreBy']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'DG_Name': dgName,
    'DG_Code': dgCode,
    'DG_Status': dgStatus,
    'DG_CreatedAt': dgCreatedAt?.toIso8601String(),
    'DG_UpdatedAt': dgUpdatedAt?.toIso8601String(),
    'IM_ItemCode': imItemCode,
    'IM_ItemType': imItemType,
    'IM_ImageMob': imImageMob,
    'IM_ImageWeb': imImageWeb,
    'IM_RecCreDate': imRecCreDate != null
        ? '${imRecCreDate!.year.toString().padLeft(4, '0')}-${imRecCreDate!.month.toString().padLeft(2, '0')}-${imRecCreDate!.day.toString().padLeft(2, '0')}'
        : null,
    'IM_RecCreTime': imRecCreTime,
    'IM_CreBy': imCreBy,
  };

  @override
  String toString() => 'ViewDashboardGroupDatum(id: $id, dgName: $dgName, dgCode: $dgCode, status: $dgStatus)';
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
class AddGroupModel {
  final bool success;
  final String message;
  final AddGroupModelData? data;

  const AddGroupModel({required this.success, required this.message, this.data});

  factory AddGroupModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddGroupModel(success: false, message: 'Empty response payload received.');
    }

    return AddGroupModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] is Map<String, dynamic> ? AddGroupModelData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};

  @override
  String toString() => 'AddGroupModel(success: $success, message: $message)';
}

@immutable
class AddGroupModelData {
  final bool status;
  final DataData? data;
  final String action;

  const AddGroupModelData({required this.status, required this.data, required this.action});

  factory AddGroupModelData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddGroupModelData(status: false, data: null, action: '');
    }

    return AddGroupModelData(
      status: _parseBool(json['status']),
      data: json['data'] is Map<String, dynamic> ? DataData.fromJson(json['data'] as Map<String, dynamic>) : null,
      action: _parseCleanString(json['action']),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, if (data != null) 'data': data?.toJson(), 'action': action};
}

@immutable
class DataData {
  final int id;
  final String dgName;
  final String dgCode;
  final int dgStatus;
  final DateTime? dgCreatedAt;
  final DateTime? dgUpdatedAt;

  const DataData({required this.id, required this.dgName, required this.dgCode, required this.dgStatus, this.dgCreatedAt, this.dgUpdatedAt});

  factory DataData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DataData(id: 0, dgName: '', dgCode: '', dgStatus: 0);
    }

    return DataData(
      id: _parseInt(json['id']),
      dgName: _parseCleanString(json['DG_Name'] ?? json['dg_name']),
      dgCode: _parseCleanString(json['DG_Code'] ?? json['dg_code']),
      dgStatus: _parseInt(json['DG_Status'] ?? json['status'], defaultValue: 1),
      dgCreatedAt: _parseDate(json['DG_CreatedAt'] ?? json['created_at']),
      dgUpdatedAt: _parseDate(json['DG_UpdatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'DG_Name': dgName,
    'DG_Code': dgCode,
    'DG_Status': dgStatus,
    'DG_CreatedAt': dgCreatedAt?.toIso8601String(),
    'DG_UpdatedAt': dgUpdatedAt?.toIso8601String(),
  };
}

@immutable
class AddGroupItemsModel {
  final bool success;
  final String message;
  final AddGroupItemsData? data;

  const AddGroupItemsModel({required this.success, required this.message, this.data});

  factory AddGroupItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddGroupItemsModel(success: false, message: 'Empty response payload received.');
    }

    return AddGroupItemsModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] is Map<String, dynamic> ? AddGroupItemsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};
}

@immutable
class AddGroupItemsData {
  final String type;
  final int id;
  final int groupId;
  final List<int> itemIds;

  const AddGroupItemsData({required this.type, required this.id, required this.groupId, this.itemIds = const <int>[]});

  factory AddGroupItemsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddGroupItemsData(type: '', id: 0, groupId: 0, itemIds: <int>[]);
    }

    final List<int> parsedItemIds = <int>[];
    if (json['item_ids'] is List) {
      for (final rawId in json['item_ids'] as List) {
        final int parsed = _parseInt(rawId);
        if (parsed != 0) parsedItemIds.add(parsed);
      }
    }

    return AddGroupItemsData(
      type: _parseCleanString(json['type']),
      id: _parseInt(json['id']),
      groupId: _parseInt(json['group_id']),
      itemIds: List<int>.unmodifiable(parsedItemIds),
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'group_id': groupId, 'item_ids': itemIds.toList(growable: false)};
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
