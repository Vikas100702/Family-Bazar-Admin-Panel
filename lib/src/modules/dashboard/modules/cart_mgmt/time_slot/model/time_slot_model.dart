import 'package:flutter/foundation.dart';

@immutable
class TimeSlotResponseModel {
  final bool status;
  final String message;
  final List<TimeSlotItem> data;
  final TimeSlotPagination? pagination;

  const TimeSlotResponseModel({required this.status, required this.message, this.data = const [], this.pagination});

  factory TimeSlotResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimeSlotResponseModel(status: false, message: 'Empty response payload received.');
    }

    final dynamic rawStatus = json['status'] ?? json['success'];
    final bool parsedStatus = rawStatus == true || rawStatus == 1 || rawStatus?.toString().trim().toLowerCase() == 'true';

    final List<TimeSlotItem> parsedList = <TimeSlotItem>[];
    final dynamic rawData = json['data'];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedList.add(TimeSlotItem.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      // Handles single slot object payload defensively (e.g., from addUpdateSlot response)
      parsedList.add(TimeSlotItem.fromJson(rawData));
    }

    return TimeSlotResponseModel(
      status: parsedStatus,
      message: json['message']?.toString().trim() ?? '',
      data: List<TimeSlotItem>.unmodifiable(parsedList),
      pagination: json['pagination'] == null ? null : TimeSlotPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((item) => item.toJson()).toList(),
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
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '20') ?? 20,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: int.tryParse(json['total_pages']?.toString() ?? '1') ?? 1,
      hasNextPage: json['has_next_page'] == true || json['has_next_page']?.toString() == 'true',
      hasPreviousPage: json['has_previous_page'] == true || json['has_previous_page']?.toString() == 'true',
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

  factory TimeSlotItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimeSlotItem(id: 0, startTimeSlot: '', endTimeSlot: '');
    }

    return TimeSlotItem(
      id: int.tryParse(json['id']?.toString().trim() ?? '') ?? 0,
      startTimeSlot: (json['starttimeslot'] ?? json['startTimeSlot'] ?? '').toString().trim(),
      endTimeSlot: (json['endtimeslot'] ?? json['endTimeSlot'] ?? '').toString().trim(),
      softDelete: (json['softdelete'] ?? json['softDelete'] ?? '0').toString().trim(),
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

/// Defensive parser for timestamp strings handling zero timestamps (0000-00-00)
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) {
    return value.year >= 1970 ? value : null;
  }

  final String dateStr = value.toString().trim();
  if (dateStr.isEmpty || dateStr.startsWith('0000-00-00')) {
    return null;
  }

  final DateTime? parsed = DateTime.tryParse(dateStr);
  if (parsed == null || parsed.year < 1970) {
    return null;
  }

  return parsed;
}
