class CustomerDetailsModel {
  CustomerDetailsModel({required this.status, required this.message, required this.pagination, required this.data});

  final bool status;
  final String message;
  final Pagination? pagination;
  final List<CustomerDetailsDatum> data;

  CustomerDetailsModel copyWith({bool? status, String? message, Pagination? pagination, List<CustomerDetailsDatum>? data}) {
    return CustomerDetailsModel(
      status: status ?? this.status,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null ? [] : List<CustomerDetailsDatum>.from(json["data"]!.map((x) => CustomerDetailsDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString() {
    return "$status, $message, $pagination, $data, ";
  }
}

class CustomerDetailsDatum {
  CustomerDetailsDatum({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.firbaseToken,
    required this.isPhoneVarified,
    required this.isEmailVarifired,
    required this.loginLocation,
    required this.referralCode,
    required this.loginTime,
    required this.softDelete,
    required this.createdAt,
    required this.updatedAt,
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
    required this.transactionCount,
    required this.lastTransactionDate,
    required this.addresses,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String firbaseToken;
  final int isPhoneVarified;
  final int isEmailVarifired;
  final dynamic loginLocation;
  final String referralCode;
  final DateTime? loginTime;
  final String softDelete;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String totalCredit;
  final String totalDebit;
  final String balance;
  final int transactionCount;
  final DateTime? lastTransactionDate;
  final List<Address> addresses;

  CustomerDetailsDatum copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? firbaseToken,
    int? isPhoneVarified,
    int? isEmailVarifired,
    dynamic? loginLocation,
    String? referralCode,
    DateTime? loginTime,
    String? softDelete,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? totalCredit,
    String? totalDebit,
    String? balance,
    int? transactionCount,
    DateTime? lastTransactionDate,
    List<Address>? addresses,
  }) {
    return CustomerDetailsDatum(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      firbaseToken: firbaseToken ?? this.firbaseToken,
      isPhoneVarified: isPhoneVarified ?? this.isPhoneVarified,
      isEmailVarifired: isEmailVarifired ?? this.isEmailVarifired,
      loginLocation: loginLocation ?? this.loginLocation,
      referralCode: referralCode ?? this.referralCode,
      loginTime: loginTime ?? this.loginTime,
      softDelete: softDelete ?? this.softDelete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCredit: totalCredit ?? this.totalCredit,
      totalDebit: totalDebit ?? this.totalDebit,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      addresses: addresses ?? this.addresses,
    );
  }

  factory CustomerDetailsDatum.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsDatum(
      id: json["id"] ?? 0,
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      firbaseToken: json["firbase_token"] ?? "",
      isPhoneVarified: json["isPhoneVarified"] ?? 0,
      isEmailVarifired: json["isEmailVarifired"] ?? 0,
      loginLocation: json["login_location"],
      referralCode: json["referral_code"] ?? "",
      loginTime: DateTime.tryParse(json["login_time"] ?? ""),
      softDelete: json["soft_delete"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      totalCredit: json["total_credit"] ?? "",
      totalDebit: json["total_debit"] ?? "",
      balance: json["balance"] ?? "",
      transactionCount: json["transaction_count"] ?? 0,
      lastTransactionDate: DateTime.tryParse(json["last_transaction_date"] ?? ""),
      addresses: json["addresses"] == null ? [] : List<Address>.from(json["addresses"]!.map((x) => Address.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "email": email,
    "firbase_token": firbaseToken,
    "isPhoneVarified": isPhoneVarified,
    "isEmailVarifired": isEmailVarifired,
    "login_location": loginLocation,
    "referral_code": referralCode,
    "login_time": loginTime?.toIso8601String(),
    "soft_delete": softDelete,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "total_credit": totalCredit,
    "total_debit": totalDebit,
    "balance": balance,
    "transaction_count": transactionCount,
    "last_transaction_date": lastTransactionDate?.toIso8601String(),
    "addresses": addresses.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $firstName, $lastName, $phone, $email, $firbaseToken, $isPhoneVarified, $isEmailVarifired, $loginLocation, $referralCode, $loginTime, $softDelete, $createdAt, $updatedAt, $totalCredit, $totalDebit, $balance, $transactionCount, $lastTransactionDate, $addresses, ";
  }
}

class Address {
  Address({
    required this.addressId,
    required this.addressUserId,
    required this.addLine1,
    required this.addLine2,
    required this.addType,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
    required this.status,
    required this.addressCreatedAt,
    required this.addressUpdatedAt,
  });

  final int addressId;
  final int addressUserId;
  final String addLine1;
  final String addLine2;
  final String addType;
  final String state;
  final String city;
  final String zipCode;
  final String countryCode;
  final String latitude;
  final String longitude;
  final String isPrimary;
  final int status;
  final DateTime? addressCreatedAt;
  final DateTime? addressUpdatedAt;

  Address copyWith({
    int? addressId,
    int? addressUserId,
    String? addLine1,
    String? addLine2,
    String? addType,
    String? state,
    String? city,
    String? zipCode,
    String? countryCode,
    String? latitude,
    String? longitude,
    String? isPrimary,
    int? status,
    DateTime? addressCreatedAt,
    DateTime? addressUpdatedAt,
  }) {
    return Address(
      addressId: addressId ?? this.addressId,
      addressUserId: addressUserId ?? this.addressUserId,
      addLine1: addLine1 ?? this.addLine1,
      addLine2: addLine2 ?? this.addLine2,
      addType: addType ?? this.addType,
      state: state ?? this.state,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPrimary: isPrimary ?? this.isPrimary,
      status: status ?? this.status,
      addressCreatedAt: addressCreatedAt ?? this.addressCreatedAt,
      addressUpdatedAt: addressUpdatedAt ?? this.addressUpdatedAt,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json["address_id"] ?? 0,
      addressUserId: json["address_user_id"] ?? 0,
      addLine1: json["add_line_1"] ?? "",
      addLine2: json["add_line_2"] ?? "",
      addType: json["add_type"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      zipCode: json["zip_code"] ?? "",
      countryCode: json["country_code"] ?? "",
      latitude: json["latitude"] ?? "",
      longitude: json["longitude"] ?? "",
      isPrimary: json["isPrimary"] ?? "",
      status: json["status"] ?? 0,
      addressCreatedAt: DateTime.tryParse(json["address_created_at"] ?? ""),
      addressUpdatedAt: DateTime.tryParse(json["address_updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "address_id": addressId,
    "address_user_id": addressUserId,
    "add_line_1": addLine1,
    "add_line_2": addLine2,
    "add_type": addType,
    "state": state,
    "city": city,
    "zip_code": zipCode,
    "country_code": countryCode,
    "latitude": latitude,
    "longitude": longitude,
    "isPrimary": isPrimary,
    "status": status,
    "address_created_at": addressCreatedAt?.toIso8601String(),
    "address_updated_at": addressUpdatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$addressId, $addressUserId, $addLine1, $addLine2, $addType, $state, $city, $zipCode, $countryCode, $latitude, $longitude, $isPrimary, $status, $addressCreatedAt, $addressUpdatedAt, ";
  }
}

class Pagination {
  Pagination({required this.currentPage, required this.limit, required this.totalRecords, required this.totalPages});

  final int currentPage;
  final int limit;
  final int totalRecords;
  final int totalPages;

  Pagination copyWith({int? currentPage, int? limit, int? totalRecords, int? totalPages}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      limit: json["limit"] ?? 0,
      totalRecords: json["total_records"] ?? 0,
      totalPages: json["total_pages"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"current_page": currentPage, "limit": limit, "total_records": totalRecords, "total_pages": totalPages};

  @override
  String toString() {
    return "$currentPage, $limit, $totalRecords, $totalPages, ";
  }
}
