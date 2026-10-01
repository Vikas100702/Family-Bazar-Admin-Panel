class ViewCouponListModel {
  ViewCouponListModel({required this.status, required this.message, required this.data, required this.pagination});

  final bool status;
  final String message;
  final List<ViewCouponListDatum> data;
  final Pagination? pagination;

  ViewCouponListModel copyWith({bool? status, String? message, List<ViewCouponListDatum>? data, Pagination? pagination}) {
    return ViewCouponListModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }

  factory ViewCouponListModel.fromJson(Map<String, dynamic> json) {
    return ViewCouponListModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<ViewCouponListDatum>.from(json["data"]!.map((x) => ViewCouponListDatum.fromJson(x))),
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };

  @override
  String toString() {
    return "$status, $message, $data, $pagination, ";
  }
}

class ViewCouponListDatum {
  ViewCouponListDatum({
    required this.id,
    required this.code,
    required this.discountType,
    required this.title,
    required this.discountValue,
    required this.maxDiscount,
    required this.minOrderAmount,
    required this.usageLimit,
    required this.usagePerCustomer,
    required this.applicableAll,
    required this.applicableGroup,
    required this.applicableBrand,
    required this.usedCount,
    required this.userType,
    required this.paymentType,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String code;
  final String discountType;
  final String title;
  final String discountValue;
  final String maxDiscount;
  final String minOrderAmount;
  final int usageLimit;
  final int usagePerCustomer;
  final String applicableAll;
  final List<dynamic> applicableGroup;
  final List<dynamic> applicableBrand;
  final int usedCount;
  final String userType;
  final String paymentType;
  final DateTime? startAt;
  final DateTime? endAt;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ViewCouponListDatum copyWith({
    int? id,
    String? code,
    String? discountType,
    String? title,
    String? discountValue,
    String? maxDiscount,
    String? minOrderAmount,
    int? usageLimit,
    int? usagePerCustomer,
    String? applicableAll,
    List<dynamic>? applicableGroup,
    List<dynamic>? applicableBrand,
    int? usedCount,
    String? userType,
    String? paymentType,
    DateTime? startAt,
    DateTime? endAt,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ViewCouponListDatum(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      title: title ?? this.title,
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usagePerCustomer: usagePerCustomer ?? this.usagePerCustomer,
      applicableAll: applicableAll ?? this.applicableAll,
      applicableGroup: applicableGroup ?? this.applicableGroup,
      applicableBrand: applicableBrand ?? this.applicableBrand,
      usedCount: usedCount ?? this.usedCount,
      userType: userType ?? this.userType,
      paymentType: paymentType ?? this.paymentType,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ViewCouponListDatum.fromJson(Map<String, dynamic> json) {
    return ViewCouponListDatum(
      id: json["id"] ?? 0,
      code: json["code"] ?? "",
      discountType: json["discount_type"] ?? "",
      title: json["title"] ?? "",
      discountValue: json["discount_value"] ?? "",
      maxDiscount: json["max_discount"] ?? "",
      minOrderAmount: json["min_order_amount"] ?? "",
      usageLimit: json["usage_limit"] ?? 0,
      usagePerCustomer: json["usage_per_customer"] ?? 0,
      applicableAll: json["applicable_all"] ?? "",
      applicableGroup: json["applicable_group"] == null ? [] : List<dynamic>.from(json["applicable_group"]!.map((x) => x)),
      applicableBrand: json["applicable_brand"] == null ? [] : List<dynamic>.from(json["applicable_brand"]!.map((x) => x)),
      usedCount: json["used_count"] ?? 0,
      userType: json["user_type"] ?? "",
      paymentType: json["payment_type"] ?? "",
      startAt: DateTime.tryParse(json["start_at"] ?? ""),
      endAt: DateTime.tryParse(json["end_at"] ?? ""),
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "discount_type": discountType,
    "title": title,
    "discount_value": discountValue,
    "max_discount": maxDiscount,
    "min_order_amount": minOrderAmount,
    "usage_limit": usageLimit,
    "usage_per_customer": usagePerCustomer,
    "applicable_all": applicableAll,
    "applicable_group": applicableGroup.map((x) => x).toList(),
    "applicable_brand": applicableBrand.map((x) => x).toList(),
    "used_count": usedCount,
    "user_type": userType,
    "payment_type": paymentType,
    "start_at": startAt?.toIso8601String(),
    "end_at": endAt?.toIso8601String(),
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $code, $discountType, $title, $discountValue, $maxDiscount, $minOrderAmount, $usageLimit, $usagePerCustomer, $applicableAll, $applicableGroup, $applicableBrand, $usedCount, $userType, $paymentType, $startAt, $endAt, $status, $createdAt, $updatedAt, ";
  }
}

class Pagination {
  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  Pagination copyWith({int? currentPage, int? perPage, int? total, int? totalPages, bool? hasNextPage, bool? hasPreviousPage}) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      perPage: json["per_page"] ?? 0,
      total: json["total"] ?? 0,
      totalPages: json["total_pages"] ?? 0,
      hasNextPage: json["has_next_page"] ?? false,
      hasPreviousPage: json["has_previous_page"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "total_pages": totalPages,
    "has_next_page": hasNextPage,
    "has_previous_page": hasPreviousPage,
  };

  @override
  String toString() {
    return "$currentPage, $perPage, $total, $totalPages, $hasNextPage, $hasPreviousPage, ";
  }
}
