import 'package:flutter/foundation.dart';

@immutable
class TimeSlotResponseModel {
  final bool status;
  final String message;
  final List<TimeSlotItem> data;
  final TimeSlotPagination? pagination;

  const TimeSlotResponseModel({required this.status, required this.message, this.data = const <TimeSlotItem>[], this.pagination});

  factory TimeSlotResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimeSlotResponseModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = _parseBool(rawStatus);

    final List<TimeSlotItem> parsedList = <TimeSlotItem>[];
    final dynamic rawData = json['data'];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedList.add(TimeSlotItem.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      // Handles single slot object payload defensively (e.g. from addUpdateSlot)
      parsedList.add(TimeSlotItem.fromJson(rawData));
    }

    return TimeSlotResponseModel(
      status: parsedStatus,
      message: _parseCleanString(json['message']),
      data: List<TimeSlotItem>.unmodifiable(parsedList),
      pagination: json['pagination'] is Map<String, dynamic> ? TimeSlotPagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((item) => item.toJson()).toList(growable: false),
    if (pagination != null) 'pagination': pagination?.toJson(),
  };
}

@immutable
class TimeSlotPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const TimeSlotPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory TimeSlotPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimeSlotPagination(currentPage: 1, perPage: 20, total: 0, totalPages: 1, hasNextPage: false, hasPreviousPage: false);
    }

    return TimeSlotPagination(
      currentPage: _parseInt(json['current_page'] ?? json['page'], defaultValue: 1),
      perPage: _parseInt(json['per_page'] ?? json['limit'], defaultValue: 20),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['total_pages'] ?? json['totalPages'], defaultValue: 1),
      hasNextPage: _parseBool(json['has_next_page'] ?? json['hasNextPage']),
      hasPreviousPage: _parseBool(json['has_previous_page'] ?? json['hasPreviousPage']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'per_page': perPage,
    'total': total,
    'total_pages': totalPages,
    'has_next_page': hasNextPage,
    'has_previous_page': hasPreviousPage,
  };
}

@immutable
class TimeSlotItem {
  final int id;
  final String startTimeSlot;
  final String endTimeSlot;
  final String softDelete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TimeSlotItem({
    required this.id,
    required this.startTimeSlot,
    required this.endTimeSlot,
    this.softDelete = '0',
    this.createdAt,
    this.updatedAt,
  });

  bool get isDeleted => softDelete == '1';

  TimeSlotItem copyWith({int? id, String? startTimeSlot, String? endTimeSlot, String? softDelete, DateTime? createdAt, DateTime? updatedAt}) {
    return TimeSlotItem(
      id: id ?? this.id,
      startTimeSlot: startTimeSlot ?? this.startTimeSlot,
      endTimeSlot: endTimeSlot ?? this.endTimeSlot,
      softDelete: softDelete ?? this.softDelete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TimeSlotItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimeSlotItem(id: 0, startTimeSlot: '', endTimeSlot: '');
    }

    return TimeSlotItem(
      id: _parseInt(json['id']),
      startTimeSlot: _parseCleanString(json['starttimeslot'] ?? json['startTimeSlot']),
      endTimeSlot: _parseCleanString(json['endtimeslot'] ?? json['endTimeSlot']),
      softDelete: _parseCleanString(json['softdelete'] ?? json['softDelete'], fallback: '0'),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'starttimeslot': startTimeSlot,
    'endtimeslot': endTimeSlot,
    'softdelete': softDelete,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value == 1;
  final String str = value.toString().trim().toLowerCase();
  return str == '1' || str == 'true' || str == 'active' || str == 'y';
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String str = value.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return defaultValue;
}

String _parseCleanString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final String str = value.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return fallback;
  return str;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) {
    return value.year >= 1970 ? value : null;
  }
  final String dateStr = value.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00') || dateStr == 'null' || dateStr == 'undefined') {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }
  return parsed;
}
