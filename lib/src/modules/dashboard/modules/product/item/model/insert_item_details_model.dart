import 'package:flutter/foundation.dart';

@immutable
class InsertItemDetailsModel {
  final bool success;
  final String message;
  final InsertItemDetailsData? data;

  const InsertItemDetailsModel({required this.success, required this.message, this.data});

  InsertItemDetailsModel copyWith({bool? success, String? message, InsertItemDetailsData? data}) {
    return InsertItemDetailsModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory InsertItemDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const InsertItemDetailsModel(success: false, message: 'Empty response payload received.', data: null);
    }

    return InsertItemDetailsModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? InsertItemDetailsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, if (data != null) 'data': data?.toJson()};

  @override
  String toString() => 'InsertItemDetailsModel(success: $success, message: $message, data: $data)';
}

@immutable
class InsertItemDetailsData {
  final int id;
  final String iCode;
  final String iName;
  final String mImg;
  final String wImg;
  final String action;

  const InsertItemDetailsData({
    required this.id,
    required this.iCode,
    required this.iName,
    required this.mImg,
    required this.wImg,
    required this.action,
  });

  InsertItemDetailsData copyWith({int? id, String? iCode, String? iName, String? mImg, String? wImg, String? action}) {
    return InsertItemDetailsData(
      id: id ?? this.id,
      iCode: iCode ?? this.iCode,
      iName: iName ?? this.iName,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
      action: action ?? this.action,
    );
  }

  factory InsertItemDetailsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const InsertItemDetailsData(id: 0, iCode: '', iName: '', mImg: '', wImg: '', action: '');
    }

    return InsertItemDetailsData(
      id: _parseInt(json['id']),
      iCode: _parseCleanString(json['I_Code'] ?? json['i_code'] ?? json['item_code']),
      iName: _parseCleanString(json['I_Name'] ?? json['i_name'] ?? json['item_name']),
      mImg: _parseCleanString(json['m_img']),
      wImg: _parseCleanString(json['w_img']),
      action: _parseCleanString(json['action']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'I_Code': iCode, 'I_Name': iName, 'm_img': mImg, 'w_img': wImg, 'action': action};

  @override
  String toString() => 'InsertItemDetailsData(id: $id, iCode: $iCode, iName: $iName, action: $action)';
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
