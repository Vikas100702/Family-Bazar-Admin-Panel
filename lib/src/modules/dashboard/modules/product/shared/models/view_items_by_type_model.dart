import 'package:flutter/foundation.dart';

@immutable
class ViewItemByTypeModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<ViewItemByTypeDatum> data;

  const ViewItemByTypeModel({required this.success, required this.message, this.pagination, required this.data});

  ViewItemByTypeModel copyWith({bool? success, String? message, Pagination? pagination, List<ViewItemByTypeDatum>? data}) {
    return ViewItemByTypeModel(
      success: success ?? this.success,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory ViewItemByTypeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewItemByTypeModel(success: false, message: 'Empty response payload received.', pagination: null, data: <ViewItemByTypeDatum>[]);
    }

    final dynamic rawData = json['data'];
    final List<ViewItemByTypeDatum> parsedData = <ViewItemByTypeDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(ViewItemByTypeDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(ViewItemByTypeDatum.fromJson(rawData));
    }

    return ViewItemByTypeModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<ViewItemByTypeDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'ViewItemByTypeModel(success: $success, message: $message, dataCount: ${data.length})';
}

@immutable
class ViewItemByTypeDatum {
  final int id;
  final String iCode;
  final String iBarCode;
  final String iName;
  final String iMfgComp;
  final String iItemGroup;
  final String iFirmCode;
  final String iOtherGroup;
  final String iCreatedBy;
  final String iModifyBy;
  final DateTime? iCreatedTimeStamp;
  final DateTime? iModifyTimeStamp;
  final String iStatus;
  final String sbBarCode;
  final String batchNo;
  final String sbMRate;
  final String sbRateA;
  final String sbSaleableStock;
  final String brandName;
  final String imImageMob;
  final String imImageWeb;
  final String imSecondryImage;
  final String imImformation;
  final String itemGroupName;
  final String otherGroupName;

  const ViewItemByTypeDatum({
    required this.id,
    required this.iCode,
    required this.iBarCode,
    required this.iName,
    required this.iMfgComp,
    required this.iItemGroup,
    required this.iFirmCode,
    required this.iOtherGroup,
    required this.iCreatedBy,
    required this.iModifyBy,
    this.iCreatedTimeStamp,
    this.iModifyTimeStamp,
    required this.iStatus,
    required this.sbBarCode,
    required this.batchNo,
    required this.sbMRate,
    required this.sbRateA,
    required this.sbSaleableStock,
    required this.brandName,
    required this.imImageMob,
    required this.imImageWeb,
    required this.imSecondryImage,
    required this.imImformation,
    required this.itemGroupName,
    required this.otherGroupName,
  });

  bool get isStatusActive => iStatus == '1' || iStatus == 'true' || iStatus.toLowerCase() == 'active';

  ViewItemByTypeDatum copyWith({
    int? id,
    String? iCode,
    String? iBarCode,
    String? iName,
    String? iMfgComp,
    String? iItemGroup,
    String? iFirmCode,
    String? iOtherGroup,
    String? iCreatedBy,
    String? iModifyBy,
    DateTime? iCreatedTimeStamp,
    DateTime? iModifyTimeStamp,
    String? iStatus,
    String? sbBarCode,
    String? batchNo,
    String? sbMRate,
    String? sbRateA,
    String? sbSaleableStock,
    String? brandName,
    String? imImageMob,
    String? imImageWeb,
    String? imSecondryImage,
    String? imImformation,
    String? itemGroupName,
    String? otherGroupName,
  }) {
    return ViewItemByTypeDatum(
      id: id ?? this.id,
      iCode: iCode ?? this.iCode,
      iBarCode: iBarCode ?? this.iBarCode,
      iName: iName ?? this.iName,
      iMfgComp: iMfgComp ?? this.iMfgComp,
      iItemGroup: iItemGroup ?? this.iItemGroup,
      iFirmCode: iFirmCode ?? this.iFirmCode,
      iOtherGroup: iOtherGroup ?? this.iOtherGroup,
      iCreatedBy: iCreatedBy ?? this.iCreatedBy,
      iModifyBy: iModifyBy ?? this.iModifyBy,
      iCreatedTimeStamp: iCreatedTimeStamp ?? this.iCreatedTimeStamp,
      iModifyTimeStamp: iModifyTimeStamp ?? this.iModifyTimeStamp,
      iStatus: iStatus ?? this.iStatus,
      sbBarCode: sbBarCode ?? this.sbBarCode,
      batchNo: batchNo ?? this.batchNo,
      sbMRate: sbMRate ?? this.sbMRate,
      sbRateA: sbRateA ?? this.sbRateA,
      sbSaleableStock: sbSaleableStock ?? this.sbSaleableStock,
      brandName: brandName ?? this.brandName,
      imImageMob: imImageMob ?? this.imImageMob,
      imImageWeb: imImageWeb ?? this.imImageWeb,
      imSecondryImage: imSecondryImage ?? this.imSecondryImage,
      imImformation: imImformation ?? this.imImformation,
      itemGroupName: itemGroupName ?? this.itemGroupName,
      otherGroupName: otherGroupName ?? this.otherGroupName,
    );
  }

  factory ViewItemByTypeDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewItemByTypeDatum(
        id: 0,
        iCode: '',
        iBarCode: '',
        iName: '',
        iMfgComp: '',
        iItemGroup: '',
        iFirmCode: '',
        iOtherGroup: '',
        iCreatedBy: '',
        iModifyBy: '',
        iStatus: '0',
        sbBarCode: '',
        batchNo: '',
        sbMRate: '0.00',
        sbRateA: '0.00',
        sbSaleableStock: '0',
        brandName: '',
        imImageMob: '',
        imImageWeb: '',
        imSecondryImage: '',
        imImformation: '',
        itemGroupName: '',
        otherGroupName: '',
      );
    }

    return ViewItemByTypeDatum(
      id: _parseInt(json['id']),
      iCode: _parseCleanString(json['I_Code'] ?? json['i_code'] ?? json['item_code']),
      iBarCode: _parseCleanString(json['I_Bar_Code'] ?? json['i_bar_code'] ?? json['ean']),
      iName: _parseCleanString(json['I_Name'] ?? json['i_name'] ?? json['item_name']),
      iMfgComp: _parseCleanString(json['I_MfgComp'] ?? json['i_mfg_comp']),
      iItemGroup: _parseCleanString(json['I_ItemGroup'] ?? json['i_item_group']),
      iFirmCode: _parseCleanString(json['I_FirmCode'] ?? json['i_firm_code']),
      iOtherGroup: _parseCleanString(json['I_OtherGroup'] ?? json['i_other_group']),
      iCreatedBy: _parseCleanString(json['I_CreatedBy'] ?? json['i_created_by']),
      iModifyBy: _parseCleanString(json['I_ModifyBy'] ?? json['i_modify_by']),
      iCreatedTimeStamp: _parseDate(json['I_CreatedTimeStamp'] ?? json['created_at']),
      iModifyTimeStamp: _parseDate(json['I_ModifyTimeStamp'] ?? json['updated_at']),
      iStatus: _parseCleanString(json['I_Status'] ?? json['status'] ?? json['i_status'], fallback: '0'),
      sbBarCode: _parseCleanString(json['SB_BAR_CODE'] ?? json['sb_bar_code']),
      batchNo: _parseCleanString(json['batch_no'] ?? json['batchNo']),
      sbMRate: _parseCleanString(json['SB_M_RATE'] ?? json['sb_m_rate'], fallback: '0.00'),
      sbRateA: _parseCleanString(json['SB_Rate_A'] ?? json['sb_rate_a'], fallback: '0.00'),
      sbSaleableStock: _parseCleanString(json['SB_Saleable_Stock'] ?? json['sb_saleable_stock'], fallback: '0'),
      brandName: _parseCleanString(json['MC_CompName'] ?? json['brand_name']),
      imImageMob: _parseCleanString(json['IM_ImageMob'] ?? json['m_img']),
      imImageWeb: _parseCleanString(json['IM_ImageWeb'] ?? json['w_img']),
      imSecondryImage: _parseCleanString(json['IM_SecondryImage'] ?? json['secondry_image']),
      imImformation: _parseCleanString(json['IM_Imformation'] ?? json['information_image']),
      itemGroupName: _parseCleanString(json['item_group_name'] ?? json['category_name']),
      otherGroupName: _parseCleanString(json['other_group_name'] ?? json['sub_category_name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'I_Code': iCode,
    'I_Bar_Code': iBarCode,
    'I_Name': iName,
    'I_MfgComp': iMfgComp,
    'I_ItemGroup': iItemGroup,
    'I_FirmCode': iFirmCode,
    'I_OtherGroup': iOtherGroup,
    'I_CreatedBy': iCreatedBy,
    'I_ModifyBy': iModifyBy,
    'I_CreatedTimeStamp': iCreatedTimeStamp?.toIso8601String(),
    'I_ModifyTimeStamp': iModifyTimeStamp?.toIso8601String(),
    'I_Status': iStatus,
    'SB_BAR_CODE': sbBarCode,
    'batch_no': batchNo,
    'SB_M_RATE': sbMRate,
    'SB_Rate_A': sbRateA,
    'SB_Saleable_Stock': sbSaleableStock,
    'MC_CompName': brandName,
    'IM_ImageMob': imImageMob,
    'IM_ImageWeb': imImageWeb,
    'IM_SecondryImage': imSecondryImage,
    'IM_Imformation': imImformation,
    'item_group_name': itemGroupName,
    'other_group_name': otherGroupName,
  };

  @override
  String toString() => 'ViewItemByTypeDatum(id: $id, iCode: $iCode, iName: $iName, rateA: $sbRateA, stock: $sbSaleableStock)';
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
