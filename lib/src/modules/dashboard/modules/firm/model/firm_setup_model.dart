class ViewFirmModel {
  ViewFirmModel({required this.success, required this.message, required this.data});

  final bool success;
  final String message;
  final List<Datum> data;

  ViewFirmModel copyWith({bool? success, String? message, List<Datum>? data}) {
    return ViewFirmModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewFirmModel.fromJson(Map<String, dynamic> json) {
    return ViewFirmModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data.map((x) => x?.toJson()).toList()};

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class Datum {
  Datum({
    required this.fFirmCode,
    required this.fFirmName,
    required this.fFirmAdd1,
    required this.fFirmAdd2,
    required this.fGodown,
    required this.fFirmPhone,
    required this.fAccNo,
    required this.fShortName,
    required this.fParentFirm,
    required this.fSaleAllow,
    required this.fMinimumCashSaleAmtInBill,
    required this.fMaximumCashSaleAmtInBill,
    required this.fMinimumCreditSaleAmtInBill,
    required this.fMaximumCreditSaleAmtInBill,
    required this.fUpttNumber,
    required this.fCstNumber,
    required this.fEuCode,
    required this.fMuCode,
    required this.fDrugLicNo1,
    required this.fDrugLicNo2,
    required this.fPanNo,
    required this.fNotInvoicePrint,
    required this.fTinNo,
    required this.fDesignationOfAssessingAuthority,
    required this.fCircleName,
    required this.fEccNumber,
    required this.fRange,
    required this.fDivision,
    required this.fCommissionerate,
    required this.fAuthSigName,
    required this.fAuthSigFatherName,
    required this.fAuthSigStatus,
    required this.fBankCode,
    required this.fFirmEmail,
    required this.fFirmWeb,
    required this.fFirmFax,
    required this.fFirmJurisdictionCity,
    required this.fTinHead,
    required this.fCstHead,
    required this.fTinDate,
    required this.fCstDate,
    required this.fFirmAdd3,
    required this.fBaseFirmCode,
    required this.fRangeAddress,
    required this.fDivisionAddress,
    required this.fLocationCode,
    required this.fCeRegNo,
    required this.fExportDetail,
    required this.fFirmPhone1,
    required this.fFirmMobile,
    required this.fUnitAccCode,
    required this.fPinCode,
    required this.fGstNumber,
    required this.fNotTransactionReq,
    required this.fSwLicenseNo,
    required this.fEwayApiUser,
    required this.fEwayApiPasswd,
    required this.fGstUserId,
    required this.fCity,
    required this.fBussinessType,
    required this.fShowStock,
    required this.fRateType,
    required this.fIsHo,
    required this.fRetailioDistCode,
    required this.fPharmarackDistCode,
    required this.fAiocdDataUploadFrequency,
    required this.fAiocdCode,
    required this.fAiocdDataType,
    required this.fAiocdCompanyList,
    required this.fAiocdImplementationDate,
    required this.fAiocdPasswd,
    required this.fImsDataUploadFrequency,
    required this.fImsCode,
    required this.fImsCompanyList,
    required this.fImsImplementationDate,
    required this.fImsUserCode,
    required this.fImsPasswd,
    required this.fImsSaleCompanyList,
    required this.fImsSaleFile,
    required this.fImsPriceFile,
    required this.fImsStockFile,
    required this.fTcsApplicable,
    required this.fStationCode,
    required this.fSyncDate,
    required this.fOrderFirm,
    required this.fIsShowRoom,
    required this.fRImsCode,
    required this.fRImsImplementationDate,
    required this.fRImsUserCode,
    required this.fRImsPasswd,
    required this.fRImsSaleFile,
    required this.fRImsPurchaseFile,
    required this.fRImsStockFile,
    required this.fRImsDataUploadFrequency,
    required this.fUpiMerchantName,
    required this.fUpiMid,
    required this.fUpiKey,
    required this.fUpiVpa,
    required this.fUpiMerchantCode,
    required this.fUpiMerchantString,
    required this.fAiocdSaleCompanyList,
    required this.fEInvoice,
    required this.fPriority,
    required this.fCertificateName,
    required this.fCertificatePin,
    required this.fAppLock,
    required this.fR1LockDate,
    required this.fR3BLockDate,
    required this.fEwayToken,
    required this.fEInvoiceToken,
    required this.fGstToken,
    required this.fPFirmCode,
    required this.fBFirmCode,
    required this.fOFirmCode,
  });

  final String fFirmCode;
  final String fFirmName;
  final String fFirmAdd1;
  final String fFirmAdd2;
  final dynamic fGodown;
  final dynamic fFirmPhone;
  final dynamic fAccNo;
  final dynamic fShortName;
  final dynamic fParentFirm;
  final bool fSaleAllow;
  final dynamic fMinimumCashSaleAmtInBill;
  final dynamic fMaximumCashSaleAmtInBill;
  final dynamic fMinimumCreditSaleAmtInBill;
  final dynamic fMaximumCreditSaleAmtInBill;
  final dynamic fUpttNumber;
  final dynamic fCstNumber;
  final String fEuCode;
  final String fMuCode;
  final dynamic fDrugLicNo1;
  final dynamic fDrugLicNo2;
  final dynamic fPanNo;
  final bool fNotInvoicePrint;
  final dynamic fTinNo;
  final dynamic fDesignationOfAssessingAuthority;
  final dynamic fCircleName;
  final dynamic fEccNumber;
  final dynamic fRange;
  final dynamic fDivision;
  final dynamic fCommissionerate;
  final dynamic fAuthSigName;
  final dynamic fAuthSigFatherName;
  final dynamic fAuthSigStatus;
  final dynamic fBankCode;
  final dynamic fFirmEmail;
  final dynamic fFirmWeb;
  final dynamic fFirmFax;
  final String fFirmJurisdictionCity;
  final dynamic fTinHead;
  final dynamic fCstHead;
  final dynamic fTinDate;
  final dynamic fCstDate;
  final String fFirmAdd3;
  final dynamic fBaseFirmCode;
  final dynamic fRangeAddress;
  final dynamic fDivisionAddress;
  final String fLocationCode;
  final String fCeRegNo;
  final dynamic fExportDetail;
  final dynamic fFirmPhone1;
  final dynamic fFirmMobile;
  final String fUnitAccCode;
  final String fPinCode;
  final String fGstNumber;
  final bool fNotTransactionReq;
  final String fSwLicenseNo;
  final String fEwayApiUser;
  final String fEwayApiPasswd;
  final dynamic fGstUserId;
  final dynamic fCity;
  final String fBussinessType;
  final bool fShowStock;
  final dynamic fRateType;
  final bool fIsHo;
  final dynamic fRetailioDistCode;
  final dynamic fPharmarackDistCode;
  final dynamic fAiocdDataUploadFrequency;
  final dynamic fAiocdCode;
  final dynamic fAiocdDataType;
  final dynamic fAiocdCompanyList;
  final dynamic fAiocdImplementationDate;
  final dynamic fAiocdPasswd;
  final dynamic fImsDataUploadFrequency;
  final dynamic fImsCode;
  final dynamic fImsCompanyList;
  final dynamic fImsImplementationDate;
  final dynamic fImsUserCode;
  final dynamic fImsPasswd;
  final dynamic fImsSaleCompanyList;
  final dynamic fImsSaleFile;
  final dynamic fImsPriceFile;
  final dynamic fImsStockFile;
  final bool fTcsApplicable;
  final dynamic fStationCode;
  final dynamic fSyncDate;
  final dynamic fOrderFirm;
  final dynamic fIsShowRoom;
  final dynamic fRImsCode;
  final dynamic fRImsImplementationDate;
  final dynamic fRImsUserCode;
  final dynamic fRImsPasswd;
  final dynamic fRImsSaleFile;
  final dynamic fRImsPurchaseFile;
  final dynamic fRImsStockFile;
  final dynamic fRImsDataUploadFrequency;
  final dynamic fUpiMerchantName;
  final dynamic fUpiMid;
  final dynamic fUpiKey;
  final dynamic fUpiVpa;
  final dynamic fUpiMerchantCode;
  final dynamic fUpiMerchantString;
  final dynamic fAiocdSaleCompanyList;
  final dynamic fEInvoice;
  final dynamic fPriority;
  final dynamic fCertificateName;
  final dynamic fCertificatePin;
  final dynamic fAppLock;
  final dynamic fR1LockDate;
  final dynamic fR3BLockDate;
  final dynamic fEwayToken;
  final dynamic fEInvoiceToken;
  final dynamic fGstToken;
  final String fPFirmCode;
  final String fBFirmCode;
  final String fOFirmCode;

  Datum copyWith({
    String? fFirmCode,
    String? fFirmName,
    String? fFirmAdd1,
    String? fFirmAdd2,
    dynamic? fGodown,
    dynamic? fFirmPhone,
    dynamic? fAccNo,
    dynamic? fShortName,
    dynamic? fParentFirm,
    bool? fSaleAllow,
    dynamic? fMinimumCashSaleAmtInBill,
    dynamic? fMaximumCashSaleAmtInBill,
    dynamic? fMinimumCreditSaleAmtInBill,
    dynamic? fMaximumCreditSaleAmtInBill,
    dynamic? fUpttNumber,
    dynamic? fCstNumber,
    String? fEuCode,
    String? fMuCode,
    dynamic? fDrugLicNo1,
    dynamic? fDrugLicNo2,
    dynamic? fPanNo,
    bool? fNotInvoicePrint,
    dynamic? fTinNo,
    dynamic? fDesignationOfAssessingAuthority,
    dynamic? fCircleName,
    dynamic? fEccNumber,
    dynamic? fRange,
    dynamic? fDivision,
    dynamic? fCommissionerate,
    dynamic? fAuthSigName,
    dynamic? fAuthSigFatherName,
    dynamic? fAuthSigStatus,
    dynamic? fBankCode,
    dynamic? fFirmEmail,
    dynamic? fFirmWeb,
    dynamic? fFirmFax,
    String? fFirmJurisdictionCity,
    dynamic? fTinHead,
    dynamic? fCstHead,
    dynamic? fTinDate,
    dynamic? fCstDate,
    String? fFirmAdd3,
    dynamic? fBaseFirmCode,
    dynamic? fRangeAddress,
    dynamic? fDivisionAddress,
    String? fLocationCode,
    String? fCeRegNo,
    dynamic? fExportDetail,
    dynamic? fFirmPhone1,
    dynamic? fFirmMobile,
    String? fUnitAccCode,
    String? fPinCode,
    String? fGstNumber,
    bool? fNotTransactionReq,
    String? fSwLicenseNo,
    String? fEwayApiUser,
    String? fEwayApiPasswd,
    dynamic? fGstUserId,
    dynamic? fCity,
    String? fBussinessType,
    bool? fShowStock,
    dynamic? fRateType,
    bool? fIsHo,
    dynamic? fRetailioDistCode,
    dynamic? fPharmarackDistCode,
    dynamic? fAiocdDataUploadFrequency,
    dynamic? fAiocdCode,
    dynamic? fAiocdDataType,
    dynamic? fAiocdCompanyList,
    dynamic? fAiocdImplementationDate,
    dynamic? fAiocdPasswd,
    dynamic? fImsDataUploadFrequency,
    dynamic? fImsCode,
    dynamic? fImsCompanyList,
    dynamic? fImsImplementationDate,
    dynamic? fImsUserCode,
    dynamic? fImsPasswd,
    dynamic? fImsSaleCompanyList,
    dynamic? fImsSaleFile,
    dynamic? fImsPriceFile,
    dynamic? fImsStockFile,
    bool? fTcsApplicable,
    dynamic? fStationCode,
    dynamic? fSyncDate,
    dynamic? fOrderFirm,
    dynamic? fIsShowRoom,
    dynamic? fRImsCode,
    dynamic? fRImsImplementationDate,
    dynamic? fRImsUserCode,
    dynamic? fRImsPasswd,
    dynamic? fRImsSaleFile,
    dynamic? fRImsPurchaseFile,
    dynamic? fRImsStockFile,
    dynamic? fRImsDataUploadFrequency,
    dynamic? fUpiMerchantName,
    dynamic? fUpiMid,
    dynamic? fUpiKey,
    dynamic? fUpiVpa,
    dynamic? fUpiMerchantCode,
    dynamic? fUpiMerchantString,
    dynamic? fAiocdSaleCompanyList,
    dynamic? fEInvoice,
    dynamic? fPriority,
    dynamic? fCertificateName,
    dynamic? fCertificatePin,
    dynamic? fAppLock,
    dynamic? fR1LockDate,
    dynamic? fR3BLockDate,
    dynamic? fEwayToken,
    dynamic? fEInvoiceToken,
    dynamic? fGstToken,
    String? fPFirmCode,
    String? fBFirmCode,
    String? fOFirmCode,
  }) {
    return Datum(
      fFirmCode: fFirmCode ?? this.fFirmCode,
      fFirmName: fFirmName ?? this.fFirmName,
      fFirmAdd1: fFirmAdd1 ?? this.fFirmAdd1,
      fFirmAdd2: fFirmAdd2 ?? this.fFirmAdd2,
      fGodown: fGodown ?? this.fGodown,
      fFirmPhone: fFirmPhone ?? this.fFirmPhone,
      fAccNo: fAccNo ?? this.fAccNo,
      fShortName: fShortName ?? this.fShortName,
      fParentFirm: fParentFirm ?? this.fParentFirm,
      fSaleAllow: fSaleAllow ?? this.fSaleAllow,
      fMinimumCashSaleAmtInBill: fMinimumCashSaleAmtInBill ?? this.fMinimumCashSaleAmtInBill,
      fMaximumCashSaleAmtInBill: fMaximumCashSaleAmtInBill ?? this.fMaximumCashSaleAmtInBill,
      fMinimumCreditSaleAmtInBill: fMinimumCreditSaleAmtInBill ?? this.fMinimumCreditSaleAmtInBill,
      fMaximumCreditSaleAmtInBill: fMaximumCreditSaleAmtInBill ?? this.fMaximumCreditSaleAmtInBill,
      fUpttNumber: fUpttNumber ?? this.fUpttNumber,
      fCstNumber: fCstNumber ?? this.fCstNumber,
      fEuCode: fEuCode ?? this.fEuCode,
      fMuCode: fMuCode ?? this.fMuCode,
      fDrugLicNo1: fDrugLicNo1 ?? this.fDrugLicNo1,
      fDrugLicNo2: fDrugLicNo2 ?? this.fDrugLicNo2,
      fPanNo: fPanNo ?? this.fPanNo,
      fNotInvoicePrint: fNotInvoicePrint ?? this.fNotInvoicePrint,
      fTinNo: fTinNo ?? this.fTinNo,
      fDesignationOfAssessingAuthority: fDesignationOfAssessingAuthority ?? this.fDesignationOfAssessingAuthority,
      fCircleName: fCircleName ?? this.fCircleName,
      fEccNumber: fEccNumber ?? this.fEccNumber,
      fRange: fRange ?? this.fRange,
      fDivision: fDivision ?? this.fDivision,
      fCommissionerate: fCommissionerate ?? this.fCommissionerate,
      fAuthSigName: fAuthSigName ?? this.fAuthSigName,
      fAuthSigFatherName: fAuthSigFatherName ?? this.fAuthSigFatherName,
      fAuthSigStatus: fAuthSigStatus ?? this.fAuthSigStatus,
      fBankCode: fBankCode ?? this.fBankCode,
      fFirmEmail: fFirmEmail ?? this.fFirmEmail,
      fFirmWeb: fFirmWeb ?? this.fFirmWeb,
      fFirmFax: fFirmFax ?? this.fFirmFax,
      fFirmJurisdictionCity: fFirmJurisdictionCity ?? this.fFirmJurisdictionCity,
      fTinHead: fTinHead ?? this.fTinHead,
      fCstHead: fCstHead ?? this.fCstHead,
      fTinDate: fTinDate ?? this.fTinDate,
      fCstDate: fCstDate ?? this.fCstDate,
      fFirmAdd3: fFirmAdd3 ?? this.fFirmAdd3,
      fBaseFirmCode: fBaseFirmCode ?? this.fBaseFirmCode,
      fRangeAddress: fRangeAddress ?? this.fRangeAddress,
      fDivisionAddress: fDivisionAddress ?? this.fDivisionAddress,
      fLocationCode: fLocationCode ?? this.fLocationCode,
      fCeRegNo: fCeRegNo ?? this.fCeRegNo,
      fExportDetail: fExportDetail ?? this.fExportDetail,
      fFirmPhone1: fFirmPhone1 ?? this.fFirmPhone1,
      fFirmMobile: fFirmMobile ?? this.fFirmMobile,
      fUnitAccCode: fUnitAccCode ?? this.fUnitAccCode,
      fPinCode: fPinCode ?? this.fPinCode,
      fGstNumber: fGstNumber ?? this.fGstNumber,
      fNotTransactionReq: fNotTransactionReq ?? this.fNotTransactionReq,
      fSwLicenseNo: fSwLicenseNo ?? this.fSwLicenseNo,
      fEwayApiUser: fEwayApiUser ?? this.fEwayApiUser,
      fEwayApiPasswd: fEwayApiPasswd ?? this.fEwayApiPasswd,
      fGstUserId: fGstUserId ?? this.fGstUserId,
      fCity: fCity ?? this.fCity,
      fBussinessType: fBussinessType ?? this.fBussinessType,
      fShowStock: fShowStock ?? this.fShowStock,
      fRateType: fRateType ?? this.fRateType,
      fIsHo: fIsHo ?? this.fIsHo,
      fRetailioDistCode: fRetailioDistCode ?? this.fRetailioDistCode,
      fPharmarackDistCode: fPharmarackDistCode ?? this.fPharmarackDistCode,
      fAiocdDataUploadFrequency: fAiocdDataUploadFrequency ?? this.fAiocdDataUploadFrequency,
      fAiocdCode: fAiocdCode ?? this.fAiocdCode,
      fAiocdDataType: fAiocdDataType ?? this.fAiocdDataType,
      fAiocdCompanyList: fAiocdCompanyList ?? this.fAiocdCompanyList,
      fAiocdImplementationDate: fAiocdImplementationDate ?? this.fAiocdImplementationDate,
      fAiocdPasswd: fAiocdPasswd ?? this.fAiocdPasswd,
      fImsDataUploadFrequency: fImsDataUploadFrequency ?? this.fImsDataUploadFrequency,
      fImsCode: fImsCode ?? this.fImsCode,
      fImsCompanyList: fImsCompanyList ?? this.fImsCompanyList,
      fImsImplementationDate: fImsImplementationDate ?? this.fImsImplementationDate,
      fImsUserCode: fImsUserCode ?? this.fImsUserCode,
      fImsPasswd: fImsPasswd ?? this.fImsPasswd,
      fImsSaleCompanyList: fImsSaleCompanyList ?? this.fImsSaleCompanyList,
      fImsSaleFile: fImsSaleFile ?? this.fImsSaleFile,
      fImsPriceFile: fImsPriceFile ?? this.fImsPriceFile,
      fImsStockFile: fImsStockFile ?? this.fImsStockFile,
      fTcsApplicable: fTcsApplicable ?? this.fTcsApplicable,
      fStationCode: fStationCode ?? this.fStationCode,
      fSyncDate: fSyncDate ?? this.fSyncDate,
      fOrderFirm: fOrderFirm ?? this.fOrderFirm,
      fIsShowRoom: fIsShowRoom ?? this.fIsShowRoom,
      fRImsCode: fRImsCode ?? this.fRImsCode,
      fRImsImplementationDate: fRImsImplementationDate ?? this.fRImsImplementationDate,
      fRImsUserCode: fRImsUserCode ?? this.fRImsUserCode,
      fRImsPasswd: fRImsPasswd ?? this.fRImsPasswd,
      fRImsSaleFile: fRImsSaleFile ?? this.fRImsSaleFile,
      fRImsPurchaseFile: fRImsPurchaseFile ?? this.fRImsPurchaseFile,
      fRImsStockFile: fRImsStockFile ?? this.fRImsStockFile,
      fRImsDataUploadFrequency: fRImsDataUploadFrequency ?? this.fRImsDataUploadFrequency,
      fUpiMerchantName: fUpiMerchantName ?? this.fUpiMerchantName,
      fUpiMid: fUpiMid ?? this.fUpiMid,
      fUpiKey: fUpiKey ?? this.fUpiKey,
      fUpiVpa: fUpiVpa ?? this.fUpiVpa,
      fUpiMerchantCode: fUpiMerchantCode ?? this.fUpiMerchantCode,
      fUpiMerchantString: fUpiMerchantString ?? this.fUpiMerchantString,
      fAiocdSaleCompanyList: fAiocdSaleCompanyList ?? this.fAiocdSaleCompanyList,
      fEInvoice: fEInvoice ?? this.fEInvoice,
      fPriority: fPriority ?? this.fPriority,
      fCertificateName: fCertificateName ?? this.fCertificateName,
      fCertificatePin: fCertificatePin ?? this.fCertificatePin,
      fAppLock: fAppLock ?? this.fAppLock,
      fR1LockDate: fR1LockDate ?? this.fR1LockDate,
      fR3BLockDate: fR3BLockDate ?? this.fR3BLockDate,
      fEwayToken: fEwayToken ?? this.fEwayToken,
      fEInvoiceToken: fEInvoiceToken ?? this.fEInvoiceToken,
      fGstToken: fGstToken ?? this.fGstToken,
      fPFirmCode: fPFirmCode ?? this.fPFirmCode,
      fBFirmCode: fBFirmCode ?? this.fBFirmCode,
      fOFirmCode: fOFirmCode ?? this.fOFirmCode,
    );
  }

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      fFirmCode: json["f_FirmCode"] ?? "",
      fFirmName: json["f_FirmName"] ?? "",
      fFirmAdd1: json["f_FirmAdd1"] ?? "",
      fFirmAdd2: json["f_FirmAdd2"] ?? "",
      fGodown: json["f_Godown"],
      fFirmPhone: json["f_firmPhone"],
      fAccNo: json["f_Acc_No"],
      fShortName: json["f_ShortName"],
      fParentFirm: json["f_Parent_Firm"],
      fSaleAllow: json["f_Sale_Allow"] ?? false,
      fMinimumCashSaleAmtInBill: json["f_Minimum_Cash_SaleAmt_In_Bill"],
      fMaximumCashSaleAmtInBill: json["f_Maximum_Cash_SaleAmt_In_Bill"],
      fMinimumCreditSaleAmtInBill: json["f_Minimum_Credit_SaleAmt_In_Bill"],
      fMaximumCreditSaleAmtInBill: json["f_Maximum_Credit_SaleAmt_In_Bill"],
      fUpttNumber: json["f_Uptt_Number"],
      fCstNumber: json["f_Cst_Number"],
      fEuCode: json["f_EUCode"] ?? "",
      fMuCode: json["f_MUCode"] ?? "",
      fDrugLicNo1: json["f_DrugLicNo1"],
      fDrugLicNo2: json["f_DrugLicNo2"],
      fPanNo: json["f_Pan_No"],
      fNotInvoicePrint: json["f_Not_Invoice_Print"] ?? false,
      fTinNo: json["f_Tin_No"],
      fDesignationOfAssessingAuthority: json["f_Designation_Of_Assessing_Authority"],
      fCircleName: json["f_Circle_Name"],
      fEccNumber: json["f_Ecc_Number"],
      fRange: json["f_Range"],
      fDivision: json["f_Division"],
      fCommissionerate: json["f_Commissionerate"],
      fAuthSigName: json["f_Auth_Sig_Name"],
      fAuthSigFatherName: json["f_Auth_Sig_Father_Name"],
      fAuthSigStatus: json["f_Auth_Sig_Status"],
      fBankCode: json["f_Bank_Code"],
      fFirmEmail: json["f_firm_Email"],
      fFirmWeb: json["f_firm_Web"],
      fFirmFax: json["f_firm_Fax"],
      fFirmJurisdictionCity: json["f_firm_JurisdictionCity"] ?? "",
      fTinHead: json["f_Tin_Head"],
      fCstHead: json["f_CST_Head"],
      fTinDate: json["f_Tin_Date"],
      fCstDate: json["f_CST_Date"],
      fFirmAdd3: json["f_FirmAdd3"] ?? "",
      fBaseFirmCode: json["f_Base_FirmCode"],
      fRangeAddress: json["f_Range_Address"],
      fDivisionAddress: json["f_Division_Address"],
      fLocationCode: json["f_Location_Code"] ?? "",
      fCeRegNo: json["f_CE_RegNo"] ?? "",
      fExportDetail: json["f_Export_Detail"],
      fFirmPhone1: json["f_firmPhone1"],
      fFirmMobile: json["f_firm_Mobile"],
      fUnitAccCode: json["f_UnitAcc_Code"] ?? "",
      fPinCode: json["f_Pin_Code"] ?? "",
      fGstNumber: json["f_GST_Number"] ?? "",
      fNotTransactionReq: json["f_Not_Transaction_Req"] ?? false,
      fSwLicenseNo: json["f_SW_LicenseNo"] ?? "",
      fEwayApiUser: json["f_Eway_ApiUser"] ?? "",
      fEwayApiPasswd: json["f_Eway_ApiPasswd"] ?? "",
      fGstUserId: json["f_Gst_UserId"],
      fCity: json["f_City"],
      fBussinessType: json["f_Bussiness_Type"] ?? "",
      fShowStock: json["f_Show_Stock"] ?? false,
      fRateType: json["f_Rate_Type"],
      fIsHo: json["f_Is_Ho"] ?? false,
      fRetailioDistCode: json["f_Retailio_Dist_Code"],
      fPharmarackDistCode: json["f_Pharmarack_Dist_Code"],
      fAiocdDataUploadFrequency: json["f_Aiocd_DataUpload_Frequency"],
      fAiocdCode: json["f_Aiocd_Code"],
      fAiocdDataType: json["f_Aiocd_Data_Type"],
      fAiocdCompanyList: json["f_Aiocd_Company_List"],
      fAiocdImplementationDate: json["f_Aiocd_Implementation_Date"],
      fAiocdPasswd: json["f_Aiocd_Passwd"],
      fImsDataUploadFrequency: json["f_Ims_DataUpload_Frequency"],
      fImsCode: json["f_Ims_Code"],
      fImsCompanyList: json["f_Ims_Company_List"],
      fImsImplementationDate: json["f_Ims_Implementation_Date"],
      fImsUserCode: json["f_Ims_UserCode"],
      fImsPasswd: json["f_Ims_Passwd"],
      fImsSaleCompanyList: json["f_Ims_Sale_Company_List"],
      fImsSaleFile: json["f_Ims_Sale_File"],
      fImsPriceFile: json["f_Ims_Price_File"],
      fImsStockFile: json["f_Ims_Stock_File"],
      fTcsApplicable: json["f_Tcs_Applicable"] ?? false,
      fStationCode: json["f_Station_Code"],
      fSyncDate: json["f_Sync_date"],
      fOrderFirm: json["f_Order_Firm"],
      fIsShowRoom: json["f_IsShowRoom"],
      fRImsCode: json["f_R_Ims_Code"],
      fRImsImplementationDate: json["f_R_Ims_Implementation_Date"],
      fRImsUserCode: json["f_R_Ims_UserCode"],
      fRImsPasswd: json["f_R_Ims_Passwd"],
      fRImsSaleFile: json["f_R_Ims_Sale_File"],
      fRImsPurchaseFile: json["f_R_Ims_Purchase_File"],
      fRImsStockFile: json["f_R_Ims_Stock_File"],
      fRImsDataUploadFrequency: json["f_R_Ims_DataUpload_Frequency"],
      fUpiMerchantName: json["f_Upi_Merchant_Name"],
      fUpiMid: json["f_Upi_MID"],
      fUpiKey: json["f_Upi_Key"],
      fUpiVpa: json["f_Upi_VPA"],
      fUpiMerchantCode: json["f_Upi_Merchant_Code"],
      fUpiMerchantString: json["f_Upi_Merchant_String"],
      fAiocdSaleCompanyList: json["f_Aiocd_Sale_Company_List"],
      fEInvoice: json["f_EInvoice"],
      fPriority: json["f_Priority"],
      fCertificateName: json["f_Certificate_Name"],
      fCertificatePin: json["f_Certificate_Pin"],
      fAppLock: json["f_App_Lock"],
      fR1LockDate: json["f_R1_LockDate"],
      fR3BLockDate: json["f_R3B_LockDate"],
      fEwayToken: json["f_Eway_Token"],
      fEInvoiceToken: json["f_EInvoice_Token"],
      fGstToken: json["f_GST_Token"],
      fPFirmCode: json["f_PFirmCode"] ?? "",
      fBFirmCode: json["f_BFirmCode"] ?? "",
      fOFirmCode: json["f_OFirmCode"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "f_FirmCode": fFirmCode,
    "f_FirmName": fFirmName,
    "f_FirmAdd1": fFirmAdd1,
    "f_FirmAdd2": fFirmAdd2,
    "f_Godown": fGodown,
    "f_firmPhone": fFirmPhone,
    "f_Acc_No": fAccNo,
    "f_ShortName": fShortName,
    "f_Parent_Firm": fParentFirm,
    "f_Sale_Allow": fSaleAllow,
    "f_Minimum_Cash_SaleAmt_In_Bill": fMinimumCashSaleAmtInBill,
    "f_Maximum_Cash_SaleAmt_In_Bill": fMaximumCashSaleAmtInBill,
    "f_Minimum_Credit_SaleAmt_In_Bill": fMinimumCreditSaleAmtInBill,
    "f_Maximum_Credit_SaleAmt_In_Bill": fMaximumCreditSaleAmtInBill,
    "f_Uptt_Number": fUpttNumber,
    "f_Cst_Number": fCstNumber,
    "f_EUCode": fEuCode,
    "f_MUCode": fMuCode,
    "f_DrugLicNo1": fDrugLicNo1,
    "f_DrugLicNo2": fDrugLicNo2,
    "f_Pan_No": fPanNo,
    "f_Not_Invoice_Print": fNotInvoicePrint,
    "f_Tin_No": fTinNo,
    "f_Designation_Of_Assessing_Authority": fDesignationOfAssessingAuthority,
    "f_Circle_Name": fCircleName,
    "f_Ecc_Number": fEccNumber,
    "f_Range": fRange,
    "f_Division": fDivision,
    "f_Commissionerate": fCommissionerate,
    "f_Auth_Sig_Name": fAuthSigName,
    "f_Auth_Sig_Father_Name": fAuthSigFatherName,
    "f_Auth_Sig_Status": fAuthSigStatus,
    "f_Bank_Code": fBankCode,
    "f_firm_Email": fFirmEmail,
    "f_firm_Web": fFirmWeb,
    "f_firm_Fax": fFirmFax,
    "f_firm_JurisdictionCity": fFirmJurisdictionCity,
    "f_Tin_Head": fTinHead,
    "f_CST_Head": fCstHead,
    "f_Tin_Date": fTinDate,
    "f_CST_Date": fCstDate,
    "f_FirmAdd3": fFirmAdd3,
    "f_Base_FirmCode": fBaseFirmCode,
    "f_Range_Address": fRangeAddress,
    "f_Division_Address": fDivisionAddress,
    "f_Location_Code": fLocationCode,
    "f_CE_RegNo": fCeRegNo,
    "f_Export_Detail": fExportDetail,
    "f_firmPhone1": fFirmPhone1,
    "f_firm_Mobile": fFirmMobile,
    "f_UnitAcc_Code": fUnitAccCode,
    "f_Pin_Code": fPinCode,
    "f_GST_Number": fGstNumber,
    "f_Not_Transaction_Req": fNotTransactionReq,
    "f_SW_LicenseNo": fSwLicenseNo,
    "f_Eway_ApiUser": fEwayApiUser,
    "f_Eway_ApiPasswd": fEwayApiPasswd,
    "f_Gst_UserId": fGstUserId,
    "f_City": fCity,
    "f_Bussiness_Type": fBussinessType,
    "f_Show_Stock": fShowStock,
    "f_Rate_Type": fRateType,
    "f_Is_Ho": fIsHo,
    "f_Retailio_Dist_Code": fRetailioDistCode,
    "f_Pharmarack_Dist_Code": fPharmarackDistCode,
    "f_Aiocd_DataUpload_Frequency": fAiocdDataUploadFrequency,
    "f_Aiocd_Code": fAiocdCode,
    "f_Aiocd_Data_Type": fAiocdDataType,
    "f_Aiocd_Company_List": fAiocdCompanyList,
    "f_Aiocd_Implementation_Date": fAiocdImplementationDate,
    "f_Aiocd_Passwd": fAiocdPasswd,
    "f_Ims_DataUpload_Frequency": fImsDataUploadFrequency,
    "f_Ims_Code": fImsCode,
    "f_Ims_Company_List": fImsCompanyList,
    "f_Ims_Implementation_Date": fImsImplementationDate,
    "f_Ims_UserCode": fImsUserCode,
    "f_Ims_Passwd": fImsPasswd,
    "f_Ims_Sale_Company_List": fImsSaleCompanyList,
    "f_Ims_Sale_File": fImsSaleFile,
    "f_Ims_Price_File": fImsPriceFile,
    "f_Ims_Stock_File": fImsStockFile,
    "f_Tcs_Applicable": fTcsApplicable,
    "f_Station_Code": fStationCode,
    "f_Sync_date": fSyncDate,
    "f_Order_Firm": fOrderFirm,
    "f_IsShowRoom": fIsShowRoom,
    "f_R_Ims_Code": fRImsCode,
    "f_R_Ims_Implementation_Date": fRImsImplementationDate,
    "f_R_Ims_UserCode": fRImsUserCode,
    "f_R_Ims_Passwd": fRImsPasswd,
    "f_R_Ims_Sale_File": fRImsSaleFile,
    "f_R_Ims_Purchase_File": fRImsPurchaseFile,
    "f_R_Ims_Stock_File": fRImsStockFile,
    "f_R_Ims_DataUpload_Frequency": fRImsDataUploadFrequency,
    "f_Upi_Merchant_Name": fUpiMerchantName,
    "f_Upi_MID": fUpiMid,
    "f_Upi_Key": fUpiKey,
    "f_Upi_VPA": fUpiVpa,
    "f_Upi_Merchant_Code": fUpiMerchantCode,
    "f_Upi_Merchant_String": fUpiMerchantString,
    "f_Aiocd_Sale_Company_List": fAiocdSaleCompanyList,
    "f_EInvoice": fEInvoice,
    "f_Priority": fPriority,
    "f_Certificate_Name": fCertificateName,
    "f_Certificate_Pin": fCertificatePin,
    "f_App_Lock": fAppLock,
    "f_R1_LockDate": fR1LockDate,
    "f_R3B_LockDate": fR3BLockDate,
    "f_Eway_Token": fEwayToken,
    "f_EInvoice_Token": fEInvoiceToken,
    "f_GST_Token": fGstToken,
    "f_PFirmCode": fPFirmCode,
    "f_BFirmCode": fBFirmCode,
    "f_OFirmCode": fOFirmCode,
  };

  @override
  String toString() {
    return "$fFirmCode, $fFirmName, $fFirmAdd1, $fFirmAdd2, $fGodown, $fFirmPhone, $fAccNo, $fShortName, $fParentFirm, $fSaleAllow, $fMinimumCashSaleAmtInBill, $fMaximumCashSaleAmtInBill, $fMinimumCreditSaleAmtInBill, $fMaximumCreditSaleAmtInBill, $fUpttNumber, $fCstNumber, $fEuCode, $fMuCode, $fDrugLicNo1, $fDrugLicNo2, $fPanNo, $fNotInvoicePrint, $fTinNo, $fDesignationOfAssessingAuthority, $fCircleName, $fEccNumber, $fRange, $fDivision, $fCommissionerate, $fAuthSigName, $fAuthSigFatherName, $fAuthSigStatus, $fBankCode, $fFirmEmail, $fFirmWeb, $fFirmFax, $fFirmJurisdictionCity, $fTinHead, $fCstHead, $fTinDate, $fCstDate, $fFirmAdd3, $fBaseFirmCode, $fRangeAddress, $fDivisionAddress, $fLocationCode, $fCeRegNo, $fExportDetail, $fFirmPhone1, $fFirmMobile, $fUnitAccCode, $fPinCode, $fGstNumber, $fNotTransactionReq, $fSwLicenseNo, $fEwayApiUser, $fEwayApiPasswd, $fGstUserId, $fCity, $fBussinessType, $fShowStock, $fRateType, $fIsHo, $fRetailioDistCode, $fPharmarackDistCode, $fAiocdDataUploadFrequency, $fAiocdCode, $fAiocdDataType, $fAiocdCompanyList, $fAiocdImplementationDate, $fAiocdPasswd, $fImsDataUploadFrequency, $fImsCode, $fImsCompanyList, $fImsImplementationDate, $fImsUserCode, $fImsPasswd, $fImsSaleCompanyList, $fImsSaleFile, $fImsPriceFile, $fImsStockFile, $fTcsApplicable, $fStationCode, $fSyncDate, $fOrderFirm, $fIsShowRoom, $fRImsCode, $fRImsImplementationDate, $fRImsUserCode, $fRImsPasswd, $fRImsSaleFile, $fRImsPurchaseFile, $fRImsStockFile, $fRImsDataUploadFrequency, $fUpiMerchantName, $fUpiMid, $fUpiKey, $fUpiVpa, $fUpiMerchantCode, $fUpiMerchantString, $fAiocdSaleCompanyList, $fEInvoice, $fPriority, $fCertificateName, $fCertificatePin, $fAppLock, $fR1LockDate, $fR3BLockDate, $fEwayToken, $fEInvoiceToken, $fGstToken, $fPFirmCode, $fBFirmCode, $fOFirmCode, ";
  }
}
