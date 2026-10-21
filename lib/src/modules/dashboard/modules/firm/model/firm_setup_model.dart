import 'package:flutter/foundation.dart';

@immutable
class ViewFirmModel {
  final bool success;
  final String message;
  final String key;
  final List<ViewFirmDatum> data;

  const ViewFirmModel({this.success = false, this.message = '', this.key = '', this.data = const <ViewFirmDatum>[]});

  ViewFirmModel copyWith({bool? success, String? message, String? key, List<ViewFirmDatum>? data}) {
    return ViewFirmModel(success: success ?? this.success, message: message ?? this.message, key: key ?? this.key, data: data ?? this.data);
  }

  factory ViewFirmModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewFirmModel(success: false, message: 'Empty response payload received', key: '', data: <ViewFirmDatum>[]);
    }

    final dynamic rawData = json['data'];
    final List<ViewFirmDatum> parsedData = <ViewFirmDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(ViewFirmDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(ViewFirmDatum.fromJson(rawData));
    }

    return ViewFirmModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      key: _parseCleanString(json['key']),
      data: List<ViewFirmDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (key.isNotEmpty) 'key': key,
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewFirmModel(success: $success, message: $message, key: $key, dataCount: ${data.length})';
}

@immutable
class ViewFirmDatum {
  final int id;
  final String fFirmCode;
  final String fFirmName;
  final String fFirmAdd1;
  final String fFirmAdd2;
  final String fFirmAdd3;
  final String fCeRegNo;
  final String fPinCode;
  final String fGstNumber;
  final String? fCity;
  final String fPFirmCode;
  final String fCreatedBy;
  final String fModifyBy;
  final DateTime? fCreatedTimeStamp;
  final DateTime? fModifyTimeStamp;

  const ViewFirmDatum({
    this.id = 0,
    this.fFirmCode = '',
    this.fFirmName = '',
    this.fFirmAdd1 = '',
    this.fFirmAdd2 = '',
    this.fFirmAdd3 = '',
    this.fCeRegNo = '',
    this.fPinCode = '',
    this.fGstNumber = '',
    this.fCity,
    this.fPFirmCode = '',
    this.fCreatedBy = '',
    this.fModifyBy = '',
    this.fCreatedTimeStamp,
    this.fModifyTimeStamp,
  });

  ViewFirmDatum copyWith({
    int? id,
    String? fFirmCode,
    String? fFirmName,
    String? fFirmAdd1,
    String? fFirmAdd2,
    String? fFirmAdd3,
    String? fCeRegNo,
    String? fPinCode,
    String? fGstNumber,
    String? fCity,
    String? fPFirmCode,
    String? fCreatedBy,
    String? fModifyBy,
    DateTime? fCreatedTimeStamp,
    DateTime? fModifyTimeStamp,
  }) {
    return ViewFirmDatum(
      id: id ?? this.id,
      fFirmCode: fFirmCode ?? this.fFirmCode,
      fFirmName: fFirmName ?? this.fFirmName,
      fFirmAdd1: fFirmAdd1 ?? this.fFirmAdd1,
      fFirmAdd2: fFirmAdd2 ?? this.fFirmAdd2,
      fFirmAdd3: fFirmAdd3 ?? this.fFirmAdd3,
      fCeRegNo: fCeRegNo ?? this.fCeRegNo,
      fPinCode: fPinCode ?? this.fPinCode,
      fGstNumber: fGstNumber ?? this.fGstNumber,
      fCity: fCity ?? this.fCity,
      fPFirmCode: fPFirmCode ?? this.fPFirmCode,
      fCreatedBy: fCreatedBy ?? this.fCreatedBy,
      fModifyBy: fModifyBy ?? this.fModifyBy,
      fCreatedTimeStamp: fCreatedTimeStamp ?? this.fCreatedTimeStamp,
      fModifyTimeStamp: fModifyTimeStamp ?? this.fModifyTimeStamp,
    );
  }

  factory ViewFirmDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ViewFirmDatum();
    return ViewFirmDatum(
      id: _parseInt(json['id']),
      fFirmCode: _parseCleanString(json['f_FirmCode']),
      fFirmName: _parseCleanString(json['f_FirmName']),
      fFirmAdd1: _parseCleanString(json['f_FirmAdd1']),
      fFirmAdd2: _parseCleanString(json['f_FirmAdd2']),
      fFirmAdd3: _parseCleanString(json['f_FirmAdd3']),
      fCeRegNo: _parseCleanString(json['f_CE_RegNo']),
      fPinCode: _parseCleanString(json['f_Pin_Code']),
      fGstNumber: _parseCleanString(json['f_GST_Number']),
      fCity: _parseNullableString(json['f_City']),
      fPFirmCode: _parseCleanString(json['f_PFirmCode']),
      fCreatedBy: _parseCleanString(json['f_CreatedBy']),
      fModifyBy: _parseCleanString(json['f_ModifyBy']),
      fCreatedTimeStamp: _parseDate(json['f_CreatedTimeStamp']),
      fModifyTimeStamp: _parseDate(json['f_ModifyTimeStamp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'f_FirmCode': fFirmCode,
    'f_FirmName': fFirmName,
    'f_FirmAdd1': fFirmAdd1,
    'f_FirmAdd2': fFirmAdd2,
    'f_FirmAdd3': fFirmAdd3,
    'f_CE_RegNo': fCeRegNo,
    'f_Pin_Code': fPinCode,
    'f_GST_Number': fGstNumber,
    if (fCity != null) 'f_City': fCity,
    'f_PFirmCode': fPFirmCode,
    'f_CreatedBy': fCreatedBy,
    'f_ModifyBy': fModifyBy,
    if (fCreatedTimeStamp != null) 'f_CreatedTimeStamp': fCreatedTimeStamp?.toIso8601String(),
    if (fModifyTimeStamp != null) 'f_ModifyTimeStamp': fModifyTimeStamp?.toIso8601String(),
  };

  @override
  String toString() => 'ViewFirmDatum(id: $id, fFirmCode: $fFirmCode, fFirmName: $fFirmName, fGstNumber: $fGstNumber)';
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val == 1;
  final String str = val.toString().trim().toLowerCase();
  return str == '1' || str == 'true' || str == 'active' || str == 'y';
}

int _parseInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final String str = val.toString().trim();
  final num? parsedNum = num.tryParse(str);
  if (parsedNum != null) return parsedNum.toInt();
  return fallback;
}

String _parseCleanString(dynamic val, {String fallback = ''}) {
  if (val == null) return fallback;
  final String str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return fallback;
  return str;
}

String? _parseNullableString(dynamic val) {
  if (val == null) return null;
  final String str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'undefined') return null;
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
