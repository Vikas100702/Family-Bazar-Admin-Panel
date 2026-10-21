import 'package:flutter/foundation.dart';

@immutable
class PincodeModel {
  final bool status;
  final String message;
  final Pagination? pagination;
  final List<Datum> data;

  const PincodeModel({required this.status, required this.message, this.pagination, this.data = const <Datum>[]});

  PincodeModel copyWith({bool? status, String? message, Pagination? pagination, List<Datum>? data}) {
    return PincodeModel(
      status: status ?? this.status,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory PincodeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PincodeModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = _parseBool(rawStatus);

    final List<Datum> parsedList = <Datum>[];
    final dynamic rawData = json['data'];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedList.add(Datum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedList.add(Datum.fromJson(rawData));
    }

    return PincodeModel(
      status: parsedStatus,
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<Datum>.unmodifiable(parsedList),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'PincodeModel(status: $status, message: $message, dataCount: ${data.length})';
}

@immutable
class Datum {
  final int id;
  final String userName;
  final String pFirmCode;
  final String pFirmName;
  final String pPinCode;
  final int status;
  final String isScheduleSlot;
  final String isRegularSlot;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Datum({
    required this.id,
    required this.userName,
    required this.pFirmCode,
    required this.pFirmName,
    required this.pPinCode,
    required this.status,
    required this.isScheduleSlot,
    required this.isRegularSlot,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  Datum copyWith({
    int? id,
    String? userName,
    String? pFirmCode,
    String? pFirmName,
    String? pPinCode,
    int? status,
    String? isScheduleSlot,
    String? isRegularSlot,
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
      isScheduleSlot: isScheduleSlot ?? this.isScheduleSlot,
      isRegularSlot: isRegularSlot ?? this.isRegularSlot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Datum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Datum(id: 0, userName: '', pFirmCode: '', pFirmName: '', pPinCode: '', status: 0, isScheduleSlot: '', isRegularSlot: '');
    }

    return Datum(
      id: _parseInt(json['id']),
      userName: _parseCleanString(json['user_name'] ?? json['userName']),
      pFirmCode: _parseCleanString(json['P_FirmCode'] ?? json['pFirmCode'] ?? json['firm_code']),
      pFirmName: _parseCleanString(json['P_FirmName'] ?? json['pFirmName'] ?? json['firm_name']),
      pPinCode: _parseCleanString(json['P_PinCode'] ?? json['pPinCode'] ?? json['pincode']),
      status: _parseInt(json['status'], defaultValue: 0),
      isScheduleSlot: _parseCleanString(json['IsScheduleSlot'] ?? json['isScheduleSlot'] ?? json['IsScheduledSlot'] ?? json['isScheduledSlot']),
      isRegularSlot: _parseCleanString(json['IsRegularSlot'] ?? json['isRegularSlot']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_name': userName,
    'P_FirmCode': pFirmCode,
    'P_FirmName': pFirmName,
    'P_PinCode': pPinCode,
    'status': status,
    'IsScheduleSlot': isScheduleSlot,
    'IsRegularSlot': isRegularSlot,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  @override
  String toString() =>
      'Datum(id: $id, pFirmCode: $pFirmCode, pFirmName: $pFirmName, pPinCode: $pPinCode, status: $status, isScheduleSlot: $isScheduleSlot, isRegularSlot: $isRegularSlot)';
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
  String toString() => 'Pagination(currentPage: $currentPage, limit: $limit, totalRecords: $totalRecords, totalPages: $totalPages)';
}

@immutable
class AddPincodeModel {
  final bool success;
  final int status;
  final String message;
  final int id;

  const AddPincodeModel({this.success = false, this.status = 0, this.message = '', this.id = 0});

  AddPincodeModel copyWith({bool? success, int? status, String? message, int? id}) {
    return AddPincodeModel(success: success ?? this.success, status: status ?? this.status, message: message ?? this.message, id: id ?? this.id);
  }

  factory AddPincodeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AddPincodeModel();

    final dynamic rawSuccess = json['success'];
    return AddPincodeModel(
      success: _parseBool(rawSuccess),
      status: _parseInt(json['status']),
      message: _parseCleanString(json['message']),
      id: _parseInt(json['id'] ?? json['insertId'] ?? json['insert_id']),
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'status': status, 'message': message, 'id': id};

  @override
  String toString() => 'AddPincodeModel(success: $success, status: $status, message: $message, id: $id)';
}

@immutable
class UnmapAndAssignPincodeModel {
  final bool success;
  final int status;
  final String message;
  final Assignment? oldAssignment;
  final Assignment? newAssignment;

  const UnmapAndAssignPincodeModel({this.success = false, this.status = 0, this.message = '', this.oldAssignment, this.newAssignment});

  UnmapAndAssignPincodeModel copyWith({bool? success, int? status, String? message, Assignment? oldAssignment, Assignment? newAssignment}) {
    return UnmapAndAssignPincodeModel(
      success: success ?? this.success,
      status: status ?? this.status,
      message: message ?? this.message,
      oldAssignment: oldAssignment ?? this.oldAssignment,
      newAssignment: newAssignment ?? this.newAssignment,
    );
  }

  factory UnmapAndAssignPincodeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnmapAndAssignPincodeModel();

    final dynamic rawSuccess = json['success'];

    return UnmapAndAssignPincodeModel(
      success: _parseBool(rawSuccess),
      status: _parseInt(json['status']),
      message: _parseCleanString(json['message']),
      oldAssignment: json['old_assignment'] is Map<String, dynamic> ? Assignment.fromJson(json['old_assignment'] as Map<String, dynamic>) : null,
      newAssignment: json['new_assignment'] is Map<String, dynamic> ? Assignment.fromJson(json['new_assignment'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'status': status,
    'message': message,
    if (oldAssignment != null) 'old_assignment': oldAssignment?.toJson(),
    if (newAssignment != null) 'new_assignment': newAssignment?.toJson(),
  };

  @override
  String toString() => 'UnmapAndAssignPincodeModel(success: $success, status: $status, message: $message)';
}

@immutable
class Assignment {
  final int id;
  final String userName;
  final String pFirmCode;
  final String pPinCode;
  final int status;

  const Assignment({this.id = 0, this.userName = '', this.pFirmCode = '', this.pPinCode = '', this.status = 0});

  Assignment copyWith({int? id, String? userName, String? pFirmCode, String? pPinCode, int? status}) {
    return Assignment(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      pFirmCode: pFirmCode ?? this.pFirmCode,
      pPinCode: pPinCode ?? this.pPinCode,
      status: status ?? this.status,
    );
  }

  factory Assignment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Assignment();

    return Assignment(
      id: _parseInt(json['id']),
      userName: _parseCleanString(json['user_name'] ?? json['userName']),
      pFirmCode: _parseCleanString(json['P_FirmCode'] ?? json['pFirmCode']),
      pPinCode: _parseCleanString(json['P_PinCode'] ?? json['pPinCode']),
      status: _parseInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'user_name': userName, 'P_FirmCode': pFirmCode, 'P_PinCode': pPinCode, 'status': status};

  @override
  String toString() => 'Assignment(id: $id, userName: $userName, pFirmCode: $pFirmCode, pPinCode: $pPinCode, status: $status)';
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
