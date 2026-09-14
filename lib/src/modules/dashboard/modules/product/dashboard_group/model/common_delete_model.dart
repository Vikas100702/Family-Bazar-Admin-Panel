class CommonDeleteModel {
  final bool success;
  final String message;

  const CommonDeleteModel({required this.success, required this.message});

  factory CommonDeleteModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CommonDeleteModel(success: false, message: 'Empty response received from server');
    }
    return CommonDeleteModel(
      success: json['success'] == true || json['success'] == 1 || json['success']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
    );
  }
}
