import 'package:flutter/foundation.dart';

@immutable
class AddImageModel {
  final bool success;
  final String message;
  final AddImageData? data;

  const AddImageModel({required this.success, required this.message, this.data});

  AddImageModel copyWith({bool? success, String? message, AddImageData? data}) {
    return AddImageModel(success: success ?? this.success, message: message ?? this.message, data: data ?? this.data);
  }

  factory AddImageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddImageModel(success: false, message: 'Empty response payload received from server.', data: null);
    }
    return AddImageModel(
      success: _parseBool(json['success'] ?? json['status']),
      message: json['message']?.toString().trim() ?? '',
      data: json['data'] is Map<String, dynamic> ? AddImageData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message, 'data': data?.toJson()};

  @override
  String toString() => 'AddImageModel(success: $success, message: $message, data:$data)';

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    final str = val.toString().trim().toLowerCase();
    return str == '1' || str == 'true';
  }
}

/// Detailed payload entity returned on entity association.
@immutable
class AddImageData {
  final int id;
  final String itemCode;
  final String itemType;
  final String imageMob;
  final String imageWeb;
  final List<String> secondaryImages;
  final List<String> informationImages;
  final String action;

  const AddImageData({
    required this.id,
    required this.itemCode,
    required this.itemType,
    required this.imageMob,
    required this.imageWeb,
    required this.secondaryImages,
    required this.informationImages,
    required this.action,
  });

  AddImageData copyWith({
    int? id,
    String? itemCode,
    String? itemType,
    String? imageMob,
    String? imageWeb,
    List<String>? secondaryImages,
    List<String>? informationImages,
    String? action,
  }) {
    return AddImageData(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      itemType: itemType ?? this.itemType,
      imageMob: imageMob ?? this.imageMob,
      imageWeb: imageWeb ?? this.imageWeb,
      secondaryImages: secondaryImages ?? this.secondaryImages,
      informationImages: informationImages ?? this.informationImages,
      action: action ?? this.action,
    );
  }

  factory AddImageData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddImageData(
        id: 0,
        itemCode: '',
        itemType: '',
        imageMob: '',
        imageWeb: '',
        secondaryImages: [],
        informationImages: [],
        action: '',
      );
    }

    // Defensive parsing for secondary images with spelling fallbacks
    final List<String> parsedSecondary = [];
    final dynamic rawSecondary =
        json['SecondryImage'] ??
        json['SeondaryImage'] ??
        json['secondaryImages'] ??
        json['secondary_img'] ??
        json['SecondaryImage'] ??
        json['SecondaryImages'];
    if (rawSecondary is List) {
      for (final item in rawSecondary) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedSecondary.add(item.toString().trim());
        }
      }
    }

    // Defensive parsing for information images with spelling fallbacks
    final List<String> parsedInfo = [];
    final dynamic rawInfo =
        json['Imformation'] ?? json['Information'] ?? json['InformationImage'] ?? json['informationImages'] ?? json['InformationImages'];
    if (rawInfo is List) {
      for (final item in rawInfo) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedInfo.add(item.toString().trim());
        }
      }
    }

    return AddImageData(
      id: _parseInt(json['id']),
      itemCode: json['ItemCode']?.toString().trim() ?? '',
      itemType: json['ItemType']?.toString().trim() ?? '',
      imageMob: json['ImageMob']?.toString().trim() ?? '',
      imageWeb: json['ImageWeb']?.toString().trim() ?? '',
      secondaryImages: List.unmodifiable(parsedSecondary),
      informationImages: List.unmodifiable(parsedInfo),
      action: json['action']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ItemCode': itemCode,
    'ItemType': itemType,
    'ImageMob': imageMob,
    'ImageWeb': imageWeb,
    'SecondryImage': secondaryImages,
    'Imformation': informationImages,
    'action': action,
  };

  @override
  String toString() =>
      'AddImageData(id: $id, itemCode:$itemCode, itemType: $itemType, secondary:${secondaryImages.length}, info: ${informationImages.length}, action:$action)';

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString().trim()) ?? 0;
  }
}
