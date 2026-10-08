class ImageUploadModel {
  ImageUploadModel({
    required this.success,
    required this.message,
    required this.type,
    required this.mImg,
    required this.wImg,
    required this.secondaryImages,
    required this.informationImages,
  });

  final bool success;
  final String message;
  final String type;
  final String mImg;
  final String wImg;
  final List<String> secondaryImages;
  final List<String> informationImages;

  ImageUploadModel copyWith({
    bool? success,
    String? message,
    String? type,
    String? mImg,
    String? wImg,
    List<String>? secondaryImages,
    List<String>? informationImages,
  }) {
    return ImageUploadModel(
      success: success ?? this.success,
      message: message ?? this.message,
      type: type ?? this.type,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
      secondaryImages: secondaryImages ?? this.secondaryImages,
      informationImages: informationImages ?? this.informationImages,
    );
  }

  factory ImageUploadModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ImageUploadModel(
        success: false,
        message: 'Empty response payload received',
        type: '',
        mImg: '',
        wImg: '',
        secondaryImages: const [],
        informationImages: const [],
      );
    }

    final List<String> parsedSecondary = [];
    final dynamic rawSecondary =
        json["secondaryImages"] ??
        json["secondryImage"] ??
        json["secondary_img"] ??
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

    final List<String> parsedInfo = [];
    final dynamic rawInfo = json["informationImages"] ?? json["information_img"] ?? json["Imformation"];
    if (rawInfo is List) {
      for (final item in rawInfo) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedInfo.add(item.toString().trim());
        }
      }
    }

    return ImageUploadModel(
      success: _parseBool(json["success"]),
      message: json["message"]?.toString().trim() ?? "",
      type: json["type"]?.toString().trim() ?? "",
      mImg: json["m_img"]?.toString().trim() ?? json["cat_m_img"]?.toString().trim() ?? "",
      wImg: json["w_img"]?.toString().trim() ?? json["cat_w_img"]?.toString().trim() ?? "",
      secondaryImages: parsedSecondary,
      informationImages: parsedInfo,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "type": type,
    "m_img": mImg,
    "w_img": wImg,
    "secondaryImages": secondaryImages,
    "informationImages": informationImages,
  };

  @override
  String toString() {
    return "ImageUploadModel(success: $success, message: $message, type: $type, mImg: $mImg, wImg: $wImg, secondaryImages: ${secondaryImages.length}, informationImages: ${informationImages.length})";
  }

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    final str = val.toString().trim().toLowerCase();
    return str == '1' || str == 'true';
  }
}
