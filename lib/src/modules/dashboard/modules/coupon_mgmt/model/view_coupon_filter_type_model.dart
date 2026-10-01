class ViewCouponFilterTypeModel {
  ViewCouponFilterTypeModel({required this.status, required this.message, required this.data});

  final bool status;
  final String message;
  final ViewCouponFilterTypeData? data;

  ViewCouponFilterTypeModel copyWith({bool? status, String? message, ViewCouponFilterTypeData? data}) {
    return ViewCouponFilterTypeModel(status: status ?? this.status, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewCouponFilterTypeModel.fromJson(Map<String, dynamic> json) {
    return ViewCouponFilterTypeModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : ViewCouponFilterTypeData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "message": message, "data": data?.toJson()};

  @override
  String toString() {
    return "$status, $message, $data, ";
  }
}

class ViewCouponFilterTypeData {
  ViewCouponFilterTypeData({required this.discountType, required this.userType, required this.paymentType, required this.status});

  final List<Type> discountType;
  final List<Type> userType;
  final List<Type> paymentType;
  final List<Status> status;

  ViewCouponFilterTypeData copyWith({List<Type>? discountType, List<Type>? userType, List<Type>? paymentType, List<Status>? status}) {
    return ViewCouponFilterTypeData(
      discountType: discountType ?? this.discountType,
      userType: userType ?? this.userType,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
    );
  }

  factory ViewCouponFilterTypeData.fromJson(Map<String, dynamic> json) {
    return ViewCouponFilterTypeData(
      discountType: json["discount_type"] == null ? [] : List<Type>.from(json["discount_type"]!.map((x) => Type.fromJson(x))),
      userType: json["user_type"] == null ? [] : List<Type>.from(json["user_type"]!.map((x) => Type.fromJson(x))),
      paymentType: json["payment_type"] == null ? [] : List<Type>.from(json["payment_type"]!.map((x) => Type.fromJson(x))),
      status: json["status"] == null ? [] : List<Status>.from(json["status"]!.map((x) => Status.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "discount_type": discountType.map((x) => x.toJson()).toList(),
    "user_type": userType.map((x) => x.toJson()).toList(),
    "payment_type": paymentType.map((x) => x.toJson()).toList(),
    "status": status.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$discountType, $userType, $paymentType, $status, ";
  }
}

class Type {
  Type({required this.value, required this.name});

  final String value;
  final String name;

  Type copyWith({String? value, String? name}) {
    return Type(value: value ?? this.value, name: name ?? this.name);
  }

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(value: json["value"] ?? "", name: json["name"] ?? "");
  }

  Map<String, dynamic> toJson() => {"value": value, "name": name};

  @override
  String toString() {
    return "$value, $name, ";
  }
}

class Status {
  Status({required this.value, required this.name});

  final int value;
  final String name;

  Status copyWith({int? value, String? name}) {
    return Status(value: value ?? this.value, name: name ?? this.name);
  }

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(value: json["value"] ?? 0, name: json["name"] ?? "");
  }

  Map<String, dynamic> toJson() => {"value": value, "name": name};

  @override
  String toString() {
    return "$value, $name, ";
  }
}
