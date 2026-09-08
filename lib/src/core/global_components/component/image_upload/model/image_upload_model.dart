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

  factory ImageUploadModel.fromJson(Map<String, dynamic> json) {
    return ImageUploadModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      type: json["type"] ?? "",
      mImg: json["m_img"] ?? "",
      wImg: json["w_img"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "type": type, "m_img": mImg, "w_img": wImg};

  @override
  String toString() {
    return "$success, $message, $type, $mImg, $wImg, ";
  }
}
