import 'package:flutter/foundation.dart';

@immutable
class ViewBrandModel {
  final bool success;
  final String message;
  final List<ViewBrandDatum> data;

  const ViewBrandModel({required this.success, required this.message, required this.data});

  ViewBrandModel copyWith({bool? success, String? message, List<ViewBrandDatum>? data}) {
    return ViewBrandModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory ViewBrandModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewBrandModel(success: false, message: 'Empty response payload received', data: <ViewBrandDatum>[]);
    }

    return ViewBrandModel(
      success: json["success"] == true || json["success"] == 1 || json["success"]?.toString().toLowerCase() == 'true',
      message: json["message"]?.toString().trim() ?? "",
      data: json["data"] is List
          ? List<ViewBrandDatum>.from((json["data"] as List).whereType<Map<String, dynamic>>().map((x) => ViewBrandDatum.fromJson(x)))
          : const <ViewBrandDatum>[],
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data.map((x) => x.toJson()).toList()};

  @override
  String toString() => "ViewBrandModel(success: $success, message: $message, dataCount: ${data.length})";
}

@immutable
class ViewBrandDatum {
  final String mcCompCode;
  final String mcCompName;
  final String? wImg;
  final String? mImg;
  final int? featuredBrand;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  const ViewBrandDatum({
    required this.mcCompCode,
    required this.mcCompName,
    this.wImg,
    this.mImg,
    this.featuredBrand,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Defensive convenience getters for null-safe presentation
  String get safeWImg => wImg ?? '';
  String get safeMImg => mImg ?? '';
  int get safeStatus => status ?? 0;
  int get safeFeaturedBrand => featuredBrand ?? 0;
  bool get isActive => status == 1;

  ViewBrandDatum copyWith({
    String? mcCompCode,
    String? mcCompName,
    String? wImg,
    String? mImg,
    int? featuredBrand,
    int? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ViewBrandDatum(
      mcCompCode: mcCompCode ?? this.mcCompCode,
      mcCompName: mcCompName ?? this.mcCompName,
      wImg: wImg ?? this.wImg,
      mImg: mImg ?? this.mImg,
      featuredBrand: featuredBrand ?? this.featuredBrand,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ViewBrandDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ViewBrandDatum(mcCompCode: '', mcCompName: '');
    }

    return ViewBrandDatum(
      mcCompCode: json["MC_CompCode"]?.toString().trim() ?? "",
      mcCompName: json["MC_CompName"]?.toString().trim() ?? "",
      wImg: _parseNullableString(json["w_img"]),
      mImg: _parseNullableString(json["m_img"]),
      featuredBrand: _parseNullableInt(json["featured_brand"]),
      status: _parseNullableInt(json["status"]),
      createdAt: _parseNullableString(json["created_at"]),
      updatedAt: _parseNullableString(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "MC_CompCode": mcCompCode,
    "MC_CompName": mcCompName,
    "w_img": wImg,
    "m_img": mImg,
    "featured_brand": featuredBrand,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };

  @override
  String toString() => "ViewBrandDatum(mcCompCode: $mcCompCode, mcCompName: $mcCompName, status: $status, featured: $featuredBrand)";

  // Static Defensive Helpers (Cross-Platform Web Safe)
  static String? _parseNullableString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    return str.isEmpty ? null : str;
  }

  static int? _parseNullableInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString().trim());
  }
}
