class PincodeModel {
  final bool status;
  final String message;
  final List<Datum> data;

  // Proactive Memory Management: const constructor for memory reuse
  const PincodeModel({this.status = false, this.message = '', this.data = const []});

  factory PincodeModel.fromJson(Map<String, dynamic> json) {
    try {
      return PincodeModel(
        // Defensive boolean parsing: handles nulls or unexpected types safely
        status: json['status'] == true,
        message: json['message']?.toString() ?? '',
        // Safely map lists, preventing crashes if 'data' is null or a String
        data: json['data'] != null && json['data'] is List
            ? (json['data'] as List).map((x) => Datum.fromJson(x as Map<String, dynamic>)).toList()
            : const [],
      );
    } catch (e) {
      // Zero-Tolerance Error Handling: Return graceful default on severe parse failure
      return const PincodeModel();
    }
  }
}

class Datum {
  final int id;
  final String userName;
  final String pFirmCode;
  final String pFirmName;
  final String pPinCode;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Datum({
    this.id = 0,
    this.userName = '',
    this.pFirmCode = '',
    this.pFirmName = '',
    this.pPinCode = '',
    this.status = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    try {
      return Datum(
        // Defensive parsing for numbers
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        userName: json['user_name']?.toString() ?? '',
        pFirmCode: json['P_FirmCode']?.toString() ?? '',
        pFirmName: json['P_FirmName']?.toString() ?? '',
        pPinCode: json['P_PinCode']?.toString() ?? '',
        status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
        // Safe DateTime parsing
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      );
    } catch (e) {
      return const Datum();
    }
  }
}
