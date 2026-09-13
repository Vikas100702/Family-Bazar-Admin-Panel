class GetTokenModel {
  GetTokenModel({required this.status, required this.message, required this.token});

  final bool status;
  final String message;
  final String token;

  GetTokenModel copyWith({bool? status, String? message, String? token}) {
    return GetTokenModel(status: status ?? this.status, message: message ?? this.message, token: token ?? this.token);
  }

  factory GetTokenModel.fromJson(Map<String, dynamic> json) {
    return GetTokenModel(status: json["status"] ?? false, message: json["message"] ?? "", token: json["token"] ?? "");
  }

  Map<String, dynamic> toJson() => {"status": status, "message": message, "token": token};

  @override
  String toString() {
    return "$status, $message, $token, ";
  }
}
