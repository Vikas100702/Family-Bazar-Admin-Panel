class ViewSubCategoryModel {
  ViewSubCategoryModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final List<ViewSubCategoryDatum> data;

  ViewSubCategoryModel copyWith({bool? success, String? message, List<ViewSubCategoryDatum>? data}) {
    return ViewSubCategoryModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return ViewSubCategoryModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<ViewSubCategoryDatum>.from(json["data"]!.map((x) => ViewSubCategoryDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class ViewSubCategoryDatum {
  ViewSubCategoryDatum({
    required this.ogCode,
    required this.ogName,
    required this.ogEucode,
    required this.ogMucode,
    required this.ogEdate,
    required this.ogMdate,
    required this.ogLock,
    required this.ogOldCode,
    required this.ogNegativeStockBilling,
    required this.ogNewCode,
    required this.ogOnPos,
    required this.ogPosIndex,
    required this.ogPosName,
    required this.ogPrintSrNo,
    required this.ogScCode,
  });

  final String ogCode;
  final String ogName;
  final String ogEucode;
  final String ogMucode;
  final DateTime? ogEdate;
  final DateTime? ogMdate;
  final bool ogLock;
  final dynamic ogOldCode;
  final bool ogNegativeStockBilling;
  final dynamic ogNewCode;
  final bool ogOnPos;
  final dynamic ogPosIndex;
  final dynamic ogPosName;
  final dynamic ogPrintSrNo;
  final dynamic ogScCode;

  ViewSubCategoryDatum copyWith({
    String? ogCode,
    String? ogName,
    String? ogEucode,
    String? ogMucode,
    DateTime? ogEdate,
    DateTime? ogMdate,
    bool? ogLock,
    dynamic? ogOldCode,
    bool? ogNegativeStockBilling,
    dynamic? ogNewCode,
    bool? ogOnPos,
    dynamic? ogPosIndex,
    dynamic? ogPosName,
    dynamic? ogPrintSrNo,
    dynamic? ogScCode,
  }) {
    return ViewSubCategoryDatum(
      ogCode: ogCode ?? this.ogCode,
      ogName: ogName ?? this.ogName,
      ogEucode: ogEucode ?? this.ogEucode,
      ogMucode: ogMucode ?? this.ogMucode,
      ogEdate: ogEdate ?? this.ogEdate,
      ogMdate: ogMdate ?? this.ogMdate,
      ogLock: ogLock ?? this.ogLock,
      ogOldCode: ogOldCode ?? this.ogOldCode,
      ogNegativeStockBilling: ogNegativeStockBilling ?? this.ogNegativeStockBilling,
      ogNewCode: ogNewCode ?? this.ogNewCode,
      ogOnPos: ogOnPos ?? this.ogOnPos,
      ogPosIndex: ogPosIndex ?? this.ogPosIndex,
      ogPosName: ogPosName ?? this.ogPosName,
      ogPrintSrNo: ogPrintSrNo ?? this.ogPrintSrNo,
      ogScCode: ogScCode ?? this.ogScCode,
    );
  }

  factory ViewSubCategoryDatum.fromJson(Map<String, dynamic> json) {
    return ViewSubCategoryDatum(
      ogCode: json["OG_CODE"] ?? "",
      ogName: json["OG_NAME"] ?? "",
      ogEucode: json["OG_EUCODE"] ?? "",
      ogMucode: json["OG_MUCODE"] ?? "",
      ogEdate: DateTime.tryParse(json["OG_Edate"] ?? ""),
      ogMdate: DateTime.tryParse(json["OG_Mdate"] ?? ""),
      ogLock: json["OG_Lock"] ?? false,
      ogOldCode: json["OG_OLD_Code"],
      ogNegativeStockBilling: json["OG_Negative_Stock_Billing"] ?? false,
      ogNewCode: json["OG_New_Code"],
      ogOnPos: json["OG_On_Pos"] ?? false,
      ogPosIndex: json["OG_POS_Index"],
      ogPosName: json["OG_POS_Name"],
      ogPrintSrNo: json["OG_Print_SrNo"],
      ogScCode: json["OG_SC_CODE"],
    );
  }

  Map<String, dynamic> toJson() => {
    "OG_CODE": ogCode,
    "OG_NAME": ogName,
    "OG_EUCODE": ogEucode,
    "OG_MUCODE": ogMucode,
    "OG_Edate": ogEdate?.toIso8601String(),
    "OG_Mdate": ogMdate?.toIso8601String(),
    "OG_Lock": ogLock,
    "OG_OLD_Code": ogOldCode,
    "OG_Negative_Stock_Billing": ogNegativeStockBilling,
    "OG_New_Code": ogNewCode,
    "OG_On_Pos": ogOnPos,
    "OG_POS_Index": ogPosIndex,
    "OG_POS_Name": ogPosName,
    "OG_Print_SrNo": ogPrintSrNo,
    "OG_SC_CODE": ogScCode,
  };

  @override
  String toString() {
    return "$ogCode, $ogName, $ogEucode, $ogMucode, $ogEdate, $ogMdate, $ogLock, $ogOldCode, $ogNegativeStockBilling, $ogNewCode, $ogOnPos, $ogPosIndex, $ogPosName, $ogPrintSrNo, $ogScCode, ";
  }
}
