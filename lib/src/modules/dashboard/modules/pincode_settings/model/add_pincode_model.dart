class AddPincodeModel {
  final bool success;
  final int status;
  final String message;
  final int id;

  const AddPincodeModel({this.success = false, this.status = 0, this.message = '', this.id = 0});

  AddPincodeModel copyWith({bool? success, int? status, String? message, int? id}) {
    return AddPincodeModel(success: success ?? this.success, status: status ?? this.status, message: message ?? this.message, id: id ?? this.id);
  }

  factory AddPincodeModel.fromJson(Map<String, dynamic> json) {
    try {
      return AddPincodeModel(
        success: json['success'] == true || json['success'] == 'true' || json['success'] == 1,
        status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
        message: json['message']?.toString() ?? '',
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      );
    } catch (e) {
      return const AddPincodeModel();
    }
  }

  Map<String, dynamic> toJson() => {"success": success, "status": status, "message": message, "id": id};

  @override
  String toString() {
    return "success: $success, status: $status, message: $message, id: $id";
  }
}
