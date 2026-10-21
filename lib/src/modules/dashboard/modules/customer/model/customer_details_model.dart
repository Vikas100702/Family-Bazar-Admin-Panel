import 'package:flutter/foundation.dart';

@immutable
class CustomerDetailsModel {
  final bool status;
  final String message;
  final Pagination? pagination;
  final List<CustomerDetailsDatum> data;

  const CustomerDetailsModel({required this.status, required this.message, this.pagination, required this.data});

  CustomerDetailsModel copyWith({bool? status, String? message, Pagination? pagination, List<CustomerDetailsDatum>? data}) {
    return CustomerDetailsModel(
      status: status ?? this.status,
      message: message ?? this.message,
      pagination: pagination ?? this.pagination,
      data: data ?? this.data,
    );
  }

  factory CustomerDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CustomerDetailsModel(
        status: false,
        message: 'Empty response payload received from server.',
        pagination: null,
        data: <CustomerDetailsDatum>[],
      );
    }

    final dynamic rawData = json['data'];
    final List<CustomerDetailsDatum> parsedData = <CustomerDetailsDatum>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(CustomerDetailsDatum.fromJson(item));
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(CustomerDetailsDatum.fromJson(rawData));
    }

    return CustomerDetailsModel(
      status: _parseBool(json['status'] ?? json['success']),
      message: _parseCleanString(json['message']),
      pagination: json['pagination'] is Map<String, dynamic> ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      data: List<CustomerDetailsDatum>.unmodifiable(parsedData),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    if (pagination != null) 'pagination': pagination?.toJson(),
    'data': data.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'CustomerDetailsModel(status: $status, message: $message, records: ${data.length})';
}

@immutable
class CustomerDetailsDatum {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String firbaseToken;
  final int isPhoneVarified;
  final int isEmailVarifired;
  final String loginLocation;
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

  const CustomerDetailsDatum({
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
    this.loginTime,
    required this.softDelete,
    this.createdAt,
    this.updatedAt,
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
    required this.transactionCount,
    this.lastTransactionDate,
    this.addresses = const <Address>[],
  });

  String get fullName {
    final String full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : 'Unnamed Customer';
  }

  bool get isPhoneVerified => isPhoneVarified == 1;

  bool get isEmailVerified => isEmailVarifired == 1;

  Address? get primaryAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere((a) => a.isPrimaryAddress, orElse: () => addresses.first);
  }

  CustomerDetailsDatum copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? firbaseToken,
    int? isPhoneVarified,
    int? isEmailVarifired,
    String? loginLocation,
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

  factory CustomerDetailsDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CustomerDetailsDatum(
        id: 0,
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        firbaseToken: '',
        isPhoneVarified: 0,
        isEmailVarifired: 0,
        loginLocation: '',
        referralCode: '',
        softDelete: '0',
        totalCredit: '0.00',
        totalDebit: '0.00',
        balance: '0.00',
        transactionCount: 0,
      );
    }

    final List<Address> parsedAddresses = <Address>[];
    if (json['addresses'] is List) {
      for (final item in json['addresses'] as List) {
        if (item is Map<String, dynamic>) {
          parsedAddresses.add(Address.fromJson(item));
        }
      }
    }

    return CustomerDetailsDatum(
      id: _parseInt(json['id']),
      firstName: _parseCleanString(json['first_name'] ?? json['firstName']),
      lastName: _parseCleanString(json['last_name'] ?? json['lastName']),
      phone: _parseCleanString(json['phone']),
      email: _parseCleanString(json['email']),
      firbaseToken: _parseCleanString(json['firbase_token'] ?? json['firebase_token']),
      isPhoneVarified: _parseInt(json['isPhoneVarified'] ?? json['is_phone_verified']),
      isEmailVarifired: _parseInt(json['isEmailVarifired'] ?? json['is_email_verified']),
      loginLocation: _parseCleanString(json['login_location']),
      referralCode: _parseCleanString(json['referral_code']),
      loginTime: _parseDate(json['login_time']),
      softDelete: _parseCleanString(json['soft_delete'], fallback: '0'),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      totalCredit: _parseCleanString(json['total_credit'], fallback: '0.00'),
      totalDebit: _parseCleanString(json['total_debit'], fallback: '0.00'),
      balance: _parseCleanString(json['balance'], fallback: '0.00'),
      transactionCount: _parseInt(json['transaction_count']),
      lastTransactionDate: _parseDate(json['last_transaction_date']),
      addresses: List<Address>.unmodifiable(parsedAddresses),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'email': email,
    'firbase_token': firbaseToken,
    'isPhoneVarified': isPhoneVarified,
    'isEmailVarifired': isEmailVarifired,
    'login_location': loginLocation,
    'referral_code': referralCode,
    'login_time': loginTime?.toIso8601String(),
    'soft_delete': softDelete,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'total_credit': totalCredit,
    'total_debit': totalDebit,
    'balance': balance,
    'transaction_count': transactionCount,
    'last_transaction_date': lastTransactionDate?.toIso8601String(),
    'addresses': addresses.map((x) => x.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'CustomerDetailsDatum(id: $id, fullName: $fullName, phone: $phone, balance: $balance, addresses: ${addresses.length})';
}

@immutable
class Address {
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

  const Address({
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
    this.addressCreatedAt,
    this.addressUpdatedAt,
  });

  bool get isPrimaryAddress {
    final String p = isPrimary.trim().toLowerCase();
    return p == '1' || p == 'yes' || p == 'true';
  }

  String get formattedAddress {
    final List<String> parts = <String>[
      addLine1,
      addLine2,
      city,
      state,
      zipCode,
      countryCode,
    ].where((part) => part.trim().isNotEmpty).toList(growable: false);
    return parts.isNotEmpty ? parts.join(', ') : 'No Address Specified';
  }

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

  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Address(
        addressId: 0,
        addressUserId: 0,
        addLine1: '',
        addLine2: '',
        addType: '',
        state: '',
        city: '',
        zipCode: '',
        countryCode: '',
        latitude: '',
        longitude: '',
        isPrimary: '0',
        status: 0,
      );
    }

    return Address(
      addressId: _parseInt(json['address_id'] ?? json['id']),
      addressUserId: _parseInt(json['address_user_id'] ?? json['user_id']),
      addLine1: _parseCleanString(json['add_line_1'] ?? json['address_line_1']),
      addLine2: _parseCleanString(json['add_line_2'] ?? json['address_line_2']),
      addType: _parseCleanString(json['add_type'] ?? json['type'], fallback: 'Home'),
      state: _parseCleanString(json['state']),
      city: _parseCleanString(json['city']),
      zipCode: _parseCleanString(json['zip_code'] ?? json['pincode']),
      countryCode: _parseCleanString(json['country_code'] ?? json['country'], fallback: 'IN'),
      latitude: _parseCleanString(json['latitude']),
      longitude: _parseCleanString(json['longitude']),
      isPrimary: _parseCleanString(json['isPrimary'] ?? json['is_primary'], fallback: '0'),
      status: _parseInt(json['status'], defaultValue: 1),
      addressCreatedAt: _parseDate(json['address_created_at'] ?? json['created_at']),
      addressUpdatedAt: _parseDate(json['address_updated_at'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'address_id': addressId,
    'address_user_id': addressUserId,
    'add_line_1': addLine1,
    'add_line_2': addLine2,
    'add_type': addType,
    'state': state,
    'city': city,
    'zip_code': zipCode,
    'country_code': countryCode,
    'latitude': latitude,
    'longitude': longitude,
    'isPrimary': isPrimary,
    'status': status,
    if (addressCreatedAt != null) 'address_created_at': addressCreatedAt?.toIso8601String(),
    if (addressUpdatedAt != null) 'address_updated_at': addressUpdatedAt?.toIso8601String(),
  };

  @override
  String toString() => 'Address(addressId: $addressId, type: $addType, city: $city, isPrimary: $isPrimary)';
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
  String toString() => 'Pagination(currentPage: $currentPage, totalRecords: $totalRecords)';
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
