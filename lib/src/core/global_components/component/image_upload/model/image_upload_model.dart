class ImageUploadModel {
  ImageUploadModel({required this.success, required this.message, required this.type, required this.mImg, required this.wImg});

  final bool success;
  final String message;
  final String type;
  final String mImg;
  final String wImg;

  ImageUploadModel copyWith({bool? success, String? message, String? type, String? mImg, String? wImg}) {
    return ImageUploadModel(
      success: success ?? this.success,
      message: message ?? this.message,
      type: type ?? this.type,
      mImg: mImg ?? this.mImg,
      wImg: wImg ?? this.wImg,
    );
  }

  factory ImageUploadModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ImageUploadModel(success: false, message: 'Empty response payload received', type: '', mImg: '', wImg: '');
    }
    return ImageUploadModel(
      success: _parseBool(json["success"]),
      message: json["message"]?.toString().trim() ?? "",
      type: json["type"]?.toString().trim() ?? "",
      mImg: json["m_img"]?.toString().trim() ?? json["cat_m_img"]?.toString().trim() ?? "",
      wImg: json["w_img"]?.toString().trim() ?? json["cat_w_img"]?.toString().trim() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "type": type, "m_img": mImg, "w_img": wImg};

  @override
  String toString() {
    return "ImageUploadModel(success: $success, message: $message, type: $type, mImg: $mImg, wImg: $wImg)";
  }

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    final str = val.toString().trim().toLowerCase();
    return str == '1' || str == 'true';
  }
}
