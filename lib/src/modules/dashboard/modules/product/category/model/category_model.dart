class ViewCategoryModel {
  ViewCategoryModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final List<ViewCategoryDatum> data;

  ViewCategoryModel copyWith({bool? success, String? message, List<ViewCategoryDatum>? data}) {
    return ViewCategoryModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewCategoryModel.fromJson(Map<String, dynamic> json) {
    return ViewCategoryModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<ViewCategoryDatum>.from(json["data"]!.map((x) => ViewCategoryDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class ViewCategoryDatum {
  ViewCategoryDatum({
    required this.igCode,
    required this.igName,
    required this.igEucode,
    required this.igMucode,
    required this.igEdate,
    required this.igMdate,
    required this.igLock,
    required this.igOldCode,
    required this.igNegativeStockBilling,
    required this.igNewCode,
    required this.igType,
    required this.igOnPos,
    required this.igPosINdex,
    required this.igPosName,
    required this.igMrpRateSlabLessThanOrEqualTo,
    required this.igMrpRateSlabF1,
    required this.igMrpRateSlabU1,
    required this.igMrpRateSlabF2,
    required this.igMrpRateSlabU2,
    required this.igMrpRateSlabF3,
    required this.igMrpRateSlabU3,
    required this.igMrpRateSlabGreaterThanOrEqualTo,
    required this.igStateTaxSlabLessThanOrEqualTo,
    required this.igExStateTaxSlabLessThanOrEqualTo,
    required this.igStateTaxSlab1,
    required this.igExStateTaxSlab1,
    required this.igStateTaxSlab2,
    required this.igExStateTaxSlab2,
    required this.igStateTaxSlab3,
    required this.igExStateTaxSlab3,
    required this.igStateTaxSlabGreaterThanOrEqualTo,
    required this.igExStateTaxSlabGreaterThanOrEqualTo,
    required this.igRateWiseTax,
    required this.igRateWiseTaxRateType,
    required this.igPointValuePer,
    required this.igPrintSrNo,
    required this.igRateDiffDaysLessThanOrEqualTo,
    required this.igRateDiffDaysSlabF1,
    required this.igRateDiffDaysSlabU1,
    required this.igRateDiffDaysSlabF2,
    required this.igRateDiffDaysSlabU2,
    required this.igRateDiffDaysSlabF3,
    required this.igRateDiffDaysSlabU3,
    required this.igRateDiffDaysGreaterThanOrEqualTo,
    required this.igRateDiffRateLessThanOrEqualTo,
    required this.igRateDiffRateSlab1,
    required this.igRateDiffRateSlab2,
    required this.igRateDiffRateSlab3,
    required this.igRateDiffRateGreaterThanOrEqualTo,
    required this.igSyncDate,
    required this.igCmCode,
  });

  final String igCode;
  final String igName;
  final String igEucode;
  final String igMucode;
  final DateTime? igEdate;
  final DateTime? igMdate;
  final bool igLock;
  final dynamic igOldCode;
  final bool igNegativeStockBilling;
  final dynamic igNewCode;
  final String igType;
  final bool igOnPos;
  final dynamic igPosINdex;
  final dynamic igPosName;
  final dynamic igMrpRateSlabLessThanOrEqualTo;
  final dynamic igMrpRateSlabF1;
  final dynamic igMrpRateSlabU1;
  final dynamic igMrpRateSlabF2;
  final dynamic igMrpRateSlabU2;
  final dynamic igMrpRateSlabF3;
  final dynamic igMrpRateSlabU3;
  final dynamic igMrpRateSlabGreaterThanOrEqualTo;
  final dynamic igStateTaxSlabLessThanOrEqualTo;
  final dynamic igExStateTaxSlabLessThanOrEqualTo;
  final dynamic igStateTaxSlab1;
  final dynamic igExStateTaxSlab1;
  final dynamic igStateTaxSlab2;
  final dynamic igExStateTaxSlab2;
  final dynamic igStateTaxSlab3;
  final dynamic igExStateTaxSlab3;
  final dynamic igStateTaxSlabGreaterThanOrEqualTo;
  final dynamic igExStateTaxSlabGreaterThanOrEqualTo;
  final bool igRateWiseTax;
  final dynamic igRateWiseTaxRateType;
  final dynamic igPointValuePer;
  final dynamic igPrintSrNo;
  final dynamic igRateDiffDaysLessThanOrEqualTo;
  final dynamic igRateDiffDaysSlabF1;
  final dynamic igRateDiffDaysSlabU1;
  final dynamic igRateDiffDaysSlabF2;
  final dynamic igRateDiffDaysSlabU2;
  final dynamic igRateDiffDaysSlabF3;
  final dynamic igRateDiffDaysSlabU3;
  final dynamic igRateDiffDaysGreaterThanOrEqualTo;
  final dynamic igRateDiffRateLessThanOrEqualTo;
  final dynamic igRateDiffRateSlab1;
  final dynamic igRateDiffRateSlab2;
  final dynamic igRateDiffRateSlab3;
  final dynamic igRateDiffRateGreaterThanOrEqualTo;
  final dynamic igSyncDate;
  final String igCmCode;

  ViewCategoryDatum copyWith({
    String? igCode,
    String? igName,
    String? igEucode,
    String? igMucode,
    DateTime? igEdate,
    DateTime? igMdate,
    bool? igLock,
    dynamic? igOldCode,
    bool? igNegativeStockBilling,
    dynamic? igNewCode,
    String? igType,
    bool? igOnPos,
    dynamic? igPosINdex,
    dynamic? igPosName,
    dynamic? igMrpRateSlabLessThanOrEqualTo,
    dynamic? igMrpRateSlabF1,
    dynamic? igMrpRateSlabU1,
    dynamic? igMrpRateSlabF2,
    dynamic? igMrpRateSlabU2,
    dynamic? igMrpRateSlabF3,
    dynamic? igMrpRateSlabU3,
    dynamic? igMrpRateSlabGreaterThanOrEqualTo,
    dynamic? igStateTaxSlabLessThanOrEqualTo,
    dynamic? igExStateTaxSlabLessThanOrEqualTo,
    dynamic? igStateTaxSlab1,
    dynamic? igExStateTaxSlab1,
    dynamic? igStateTaxSlab2,
    dynamic? igExStateTaxSlab2,
    dynamic? igStateTaxSlab3,
    dynamic? igExStateTaxSlab3,
    dynamic? igStateTaxSlabGreaterThanOrEqualTo,
    dynamic? igExStateTaxSlabGreaterThanOrEqualTo,
    bool? igRateWiseTax,
    dynamic? igRateWiseTaxRateType,
    dynamic? igPointValuePer,
    dynamic? igPrintSrNo,
    dynamic? igRateDiffDaysLessThanOrEqualTo,
    dynamic? igRateDiffDaysSlabF1,
    dynamic? igRateDiffDaysSlabU1,
    dynamic? igRateDiffDaysSlabF2,
    dynamic? igRateDiffDaysSlabU2,
    dynamic? igRateDiffDaysSlabF3,
    dynamic? igRateDiffDaysSlabU3,
    dynamic? igRateDiffDaysGreaterThanOrEqualTo,
    dynamic? igRateDiffRateLessThanOrEqualTo,
    dynamic? igRateDiffRateSlab1,
    dynamic? igRateDiffRateSlab2,
    dynamic? igRateDiffRateSlab3,
    dynamic? igRateDiffRateGreaterThanOrEqualTo,
    dynamic? igSyncDate,
    String? igCmCode,
  }) {
    return ViewCategoryDatum(
      igCode: igCode ?? this.igCode,
      igName: igName ?? this.igName,
      igEucode: igEucode ?? this.igEucode,
      igMucode: igMucode ?? this.igMucode,
      igEdate: igEdate ?? this.igEdate,
      igMdate: igMdate ?? this.igMdate,
      igLock: igLock ?? this.igLock,
      igOldCode: igOldCode ?? this.igOldCode,
      igNegativeStockBilling: igNegativeStockBilling ?? this.igNegativeStockBilling,
      igNewCode: igNewCode ?? this.igNewCode,
      igType: igType ?? this.igType,
      igOnPos: igOnPos ?? this.igOnPos,
      igPosINdex: igPosINdex ?? this.igPosINdex,
      igPosName: igPosName ?? this.igPosName,
      igMrpRateSlabLessThanOrEqualTo: igMrpRateSlabLessThanOrEqualTo ?? this.igMrpRateSlabLessThanOrEqualTo,
      igMrpRateSlabF1: igMrpRateSlabF1 ?? this.igMrpRateSlabF1,
      igMrpRateSlabU1: igMrpRateSlabU1 ?? this.igMrpRateSlabU1,
      igMrpRateSlabF2: igMrpRateSlabF2 ?? this.igMrpRateSlabF2,
      igMrpRateSlabU2: igMrpRateSlabU2 ?? this.igMrpRateSlabU2,
      igMrpRateSlabF3: igMrpRateSlabF3 ?? this.igMrpRateSlabF3,
      igMrpRateSlabU3: igMrpRateSlabU3 ?? this.igMrpRateSlabU3,
      igMrpRateSlabGreaterThanOrEqualTo: igMrpRateSlabGreaterThanOrEqualTo ?? this.igMrpRateSlabGreaterThanOrEqualTo,
      igStateTaxSlabLessThanOrEqualTo: igStateTaxSlabLessThanOrEqualTo ?? this.igStateTaxSlabLessThanOrEqualTo,
      igExStateTaxSlabLessThanOrEqualTo: igExStateTaxSlabLessThanOrEqualTo ?? this.igExStateTaxSlabLessThanOrEqualTo,
      igStateTaxSlab1: igStateTaxSlab1 ?? this.igStateTaxSlab1,
      igExStateTaxSlab1: igExStateTaxSlab1 ?? this.igExStateTaxSlab1,
      igStateTaxSlab2: igStateTaxSlab2 ?? this.igStateTaxSlab2,
      igExStateTaxSlab2: igExStateTaxSlab2 ?? this.igExStateTaxSlab2,
      igStateTaxSlab3: igStateTaxSlab3 ?? this.igStateTaxSlab3,
      igExStateTaxSlab3: igExStateTaxSlab3 ?? this.igExStateTaxSlab3,
      igStateTaxSlabGreaterThanOrEqualTo: igStateTaxSlabGreaterThanOrEqualTo ?? this.igStateTaxSlabGreaterThanOrEqualTo,
      igExStateTaxSlabGreaterThanOrEqualTo: igExStateTaxSlabGreaterThanOrEqualTo ?? this.igExStateTaxSlabGreaterThanOrEqualTo,
      igRateWiseTax: igRateWiseTax ?? this.igRateWiseTax,
      igRateWiseTaxRateType: igRateWiseTaxRateType ?? this.igRateWiseTaxRateType,
      igPointValuePer: igPointValuePer ?? this.igPointValuePer,
      igPrintSrNo: igPrintSrNo ?? this.igPrintSrNo,
      igRateDiffDaysLessThanOrEqualTo: igRateDiffDaysLessThanOrEqualTo ?? this.igRateDiffDaysLessThanOrEqualTo,
      igRateDiffDaysSlabF1: igRateDiffDaysSlabF1 ?? this.igRateDiffDaysSlabF1,
      igRateDiffDaysSlabU1: igRateDiffDaysSlabU1 ?? this.igRateDiffDaysSlabU1,
      igRateDiffDaysSlabF2: igRateDiffDaysSlabF2 ?? this.igRateDiffDaysSlabF2,
      igRateDiffDaysSlabU2: igRateDiffDaysSlabU2 ?? this.igRateDiffDaysSlabU2,
      igRateDiffDaysSlabF3: igRateDiffDaysSlabF3 ?? this.igRateDiffDaysSlabF3,
      igRateDiffDaysSlabU3: igRateDiffDaysSlabU3 ?? this.igRateDiffDaysSlabU3,
      igRateDiffDaysGreaterThanOrEqualTo: igRateDiffDaysGreaterThanOrEqualTo ?? this.igRateDiffDaysGreaterThanOrEqualTo,
      igRateDiffRateLessThanOrEqualTo: igRateDiffRateLessThanOrEqualTo ?? this.igRateDiffRateLessThanOrEqualTo,
      igRateDiffRateSlab1: igRateDiffRateSlab1 ?? this.igRateDiffRateSlab1,
      igRateDiffRateSlab2: igRateDiffRateSlab2 ?? this.igRateDiffRateSlab2,
      igRateDiffRateSlab3: igRateDiffRateSlab3 ?? this.igRateDiffRateSlab3,
      igRateDiffRateGreaterThanOrEqualTo: igRateDiffRateGreaterThanOrEqualTo ?? this.igRateDiffRateGreaterThanOrEqualTo,
      igSyncDate: igSyncDate ?? this.igSyncDate,
      igCmCode: igCmCode ?? this.igCmCode,
    );
  }

  factory ViewCategoryDatum.fromJson(Map<String, dynamic> json) {
    return ViewCategoryDatum(
      igCode: json["IG_CODE"] ?? "",
      igName: json["IG_NAME"] ?? "",
      igEucode: json["IG_EUCODE"] ?? "",
      igMucode: json["IG_MUCODE"] ?? "",
      igEdate: DateTime.tryParse(json["IG_Edate"] ?? ""),
      igMdate: DateTime.tryParse(json["IG_Mdate"] ?? ""),
      igLock: json["IG_Lock"] ?? false,
      igOldCode: json["IG_OLD_Code"],
      igNegativeStockBilling: json["IG_Negative_Stock_Billing"] ?? false,
      igNewCode: json["IG_New_Code"],
      igType: json["IG_Type"] ?? "",
      igOnPos: json["IG_On_POS"] ?? false,
      igPosINdex: json["IG_Pos_INdex"],
      igPosName: json["IG_Pos_Name"],
      igMrpRateSlabLessThanOrEqualTo: json["IG_MrpRateSlabLessThanOrEqualTo"],
      igMrpRateSlabF1: json["IG_MrpRateSlabF1"],
      igMrpRateSlabU1: json["IG_MrpRateSlabU1"],
      igMrpRateSlabF2: json["IG_MrpRateSlabF2"],
      igMrpRateSlabU2: json["IG_MrpRateSlabU2"],
      igMrpRateSlabF3: json["IG_MrpRateSlabF3"],
      igMrpRateSlabU3: json["IG_MrpRateSlabU3"],
      igMrpRateSlabGreaterThanOrEqualTo: json["IG_MrpRateSlabGreaterThanOrEqualTo"],
      igStateTaxSlabLessThanOrEqualTo: json["IG_StateTaxSlabLessThanOrEqualTo"],
      igExStateTaxSlabLessThanOrEqualTo: json["IG_ExStateTaxSlabLessThanOrEqualTo"],
      igStateTaxSlab1: json["IG_StateTaxSlab1"],
      igExStateTaxSlab1: json["IG_ExStateTaxSlab1"],
      igStateTaxSlab2: json["IG_StateTaxSlab2"],
      igExStateTaxSlab2: json["IG_ExStateTaxSlab2"],
      igStateTaxSlab3: json["IG_StateTaxSlab3"],
      igExStateTaxSlab3: json["IG_ExStateTaxSlab3"],
      igStateTaxSlabGreaterThanOrEqualTo: json["IG_StateTaxSlabGreaterThanOrEqualTo"],
      igExStateTaxSlabGreaterThanOrEqualTo: json["IG_ExStateTaxSlabGreaterThanOrEqualTo"],
      igRateWiseTax: json["IG_RateWiseTax"] ?? false,
      igRateWiseTaxRateType: json["IG_RateWiseTaxRateType"],
      igPointValuePer: json["IG_Point_Value_Per"],
      igPrintSrNo: json["IG_Print_SrNo"],
      igRateDiffDaysLessThanOrEqualTo: json["IG_RateDiffDaysLessThanOrEqualTo"],
      igRateDiffDaysSlabF1: json["IG_RateDiffDaysSlabF1"],
      igRateDiffDaysSlabU1: json["IG_RateDiffDaysSlabU1"],
      igRateDiffDaysSlabF2: json["IG_RateDiffDaysSlabF2"],
      igRateDiffDaysSlabU2: json["IG_RateDiffDaysSlabU2"],
      igRateDiffDaysSlabF3: json["IG_RateDiffDaysSlabF3"],
      igRateDiffDaysSlabU3: json["IG_RateDiffDaysSlabU3"],
      igRateDiffDaysGreaterThanOrEqualTo: json["IG_RateDiffDaysGreaterThanOrEqualTo"],
      igRateDiffRateLessThanOrEqualTo: json["IG_RateDiffRateLessThanOrEqualTo"],
      igRateDiffRateSlab1: json["IG_RateDiffRateSlab1"],
      igRateDiffRateSlab2: json["IG_RateDiffRateSlab2"],
      igRateDiffRateSlab3: json["IG_RateDiffRateSlab3"],
      igRateDiffRateGreaterThanOrEqualTo: json["IG_RateDiffRateGreaterThanOrEqualTo"],
      igSyncDate: json["IG_Sync_Date"],
      igCmCode: json["IG_CM_CODE"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "IG_CODE": igCode,
    "IG_NAME": igName,
    "IG_EUCODE": igEucode,
    "IG_MUCODE": igMucode,
    "IG_Edate": igEdate?.toIso8601String(),
    "IG_Mdate": igMdate?.toIso8601String(),
    "IG_Lock": igLock,
    "IG_OLD_Code": igOldCode,
    "IG_Negative_Stock_Billing": igNegativeStockBilling,
    "IG_New_Code": igNewCode,
    "IG_Type": igType,
    "IG_On_POS": igOnPos,
    "IG_Pos_INdex": igPosINdex,
    "IG_Pos_Name": igPosName,
    "IG_MrpRateSlabLessThanOrEqualTo": igMrpRateSlabLessThanOrEqualTo,
    "IG_MrpRateSlabF1": igMrpRateSlabF1,
    "IG_MrpRateSlabU1": igMrpRateSlabU1,
    "IG_MrpRateSlabF2": igMrpRateSlabF2,
    "IG_MrpRateSlabU2": igMrpRateSlabU2,
    "IG_MrpRateSlabF3": igMrpRateSlabF3,
    "IG_MrpRateSlabU3": igMrpRateSlabU3,
    "IG_MrpRateSlabGreaterThanOrEqualTo": igMrpRateSlabGreaterThanOrEqualTo,
    "IG_StateTaxSlabLessThanOrEqualTo": igStateTaxSlabLessThanOrEqualTo,
    "IG_ExStateTaxSlabLessThanOrEqualTo": igExStateTaxSlabLessThanOrEqualTo,
    "IG_StateTaxSlab1": igStateTaxSlab1,
    "IG_ExStateTaxSlab1": igExStateTaxSlab1,
    "IG_StateTaxSlab2": igStateTaxSlab2,
    "IG_ExStateTaxSlab2": igExStateTaxSlab2,
    "IG_StateTaxSlab3": igStateTaxSlab3,
    "IG_ExStateTaxSlab3": igExStateTaxSlab3,
    "IG_StateTaxSlabGreaterThanOrEqualTo": igStateTaxSlabGreaterThanOrEqualTo,
    "IG_ExStateTaxSlabGreaterThanOrEqualTo": igExStateTaxSlabGreaterThanOrEqualTo,
    "IG_RateWiseTax": igRateWiseTax,
    "IG_RateWiseTaxRateType": igRateWiseTaxRateType,
    "IG_Point_Value_Per": igPointValuePer,
    "IG_Print_SrNo": igPrintSrNo,
    "IG_RateDiffDaysLessThanOrEqualTo": igRateDiffDaysLessThanOrEqualTo,
    "IG_RateDiffDaysSlabF1": igRateDiffDaysSlabF1,
    "IG_RateDiffDaysSlabU1": igRateDiffDaysSlabU1,
    "IG_RateDiffDaysSlabF2": igRateDiffDaysSlabF2,
    "IG_RateDiffDaysSlabU2": igRateDiffDaysSlabU2,
    "IG_RateDiffDaysSlabF3": igRateDiffDaysSlabF3,
    "IG_RateDiffDaysSlabU3": igRateDiffDaysSlabU3,
    "IG_RateDiffDaysGreaterThanOrEqualTo": igRateDiffDaysGreaterThanOrEqualTo,
    "IG_RateDiffRateLessThanOrEqualTo": igRateDiffRateLessThanOrEqualTo,
    "IG_RateDiffRateSlab1": igRateDiffRateSlab1,
    "IG_RateDiffRateSlab2": igRateDiffRateSlab2,
    "IG_RateDiffRateSlab3": igRateDiffRateSlab3,
    "IG_RateDiffRateGreaterThanOrEqualTo": igRateDiffRateGreaterThanOrEqualTo,
    "IG_Sync_Date": igSyncDate,
    "IG_CM_CODE": igCmCode,
  };

  @override
  String toString() {
    return "$igCode, $igName, $igEucode, $igMucode, $igEdate, $igMdate, $igLock, $igOldCode, $igNegativeStockBilling, $igNewCode, $igType, $igOnPos, $igPosINdex, $igPosName, $igMrpRateSlabLessThanOrEqualTo, $igMrpRateSlabF1, $igMrpRateSlabU1, $igMrpRateSlabF2, $igMrpRateSlabU2, $igMrpRateSlabF3, $igMrpRateSlabU3, $igMrpRateSlabGreaterThanOrEqualTo, $igStateTaxSlabLessThanOrEqualTo, $igExStateTaxSlabLessThanOrEqualTo, $igStateTaxSlab1, $igExStateTaxSlab1, $igStateTaxSlab2, $igExStateTaxSlab2, $igStateTaxSlab3, $igExStateTaxSlab3, $igStateTaxSlabGreaterThanOrEqualTo, $igExStateTaxSlabGreaterThanOrEqualTo, $igRateWiseTax, $igRateWiseTaxRateType, $igPointValuePer, $igPrintSrNo, $igRateDiffDaysLessThanOrEqualTo, $igRateDiffDaysSlabF1, $igRateDiffDaysSlabU1, $igRateDiffDaysSlabF2, $igRateDiffDaysSlabU2, $igRateDiffDaysSlabF3, $igRateDiffDaysSlabU3, $igRateDiffDaysGreaterThanOrEqualTo, $igRateDiffRateLessThanOrEqualTo, $igRateDiffRateSlab1, $igRateDiffRateSlab2, $igRateDiffRateSlab3, $igRateDiffRateGreaterThanOrEqualTo, $igSyncDate, $igCmCode, ";
  }
}
