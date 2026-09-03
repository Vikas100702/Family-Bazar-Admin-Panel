class UnmapAndAssignPincodeModel {
  final bool success;
  final int status;
  final String message;
  final Assignment? oldAssignment;
  final Assignment? newAssignment;

  // Proactive Memory Management: const constructor enables zero-allocation fallback caching
  const UnmapAndAssignPincodeModel({this.success = false, this.status = 0, this.message = '', this.oldAssignment, this.newAssignment});

  UnmapAndAssignPincodeModel copyWith({bool? success, int? status, String? message, Assignment? oldAssignment, Assignment? newAssignment}) {
    return UnmapAndAssignPincodeModel(
      success: success ?? this.success,
      status: status ?? this.status,
      message: message ?? this.message,
      oldAssignment: oldAssignment ?? this.oldAssignment,
      newAssignment: newAssignment ?? this.newAssignment,
    );
  }

  factory UnmapAndAssignPincodeModel.fromJson(Map<String, dynamic> json) {
    try {
      return UnmapAndAssignPincodeModel(
        // Defensive boolean parsing: handles true, "true", and 1 safely
        success: json['success'] == true || json['success'] == 'true' || json['success'] == 1,
        // Defensive integer parsing: safeguards against backend type mismatches
        status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
        message: json['message']?.toString() ?? '',
        // Type-safe map validation: prevents crashes if backend returns an empty array `[]`
        oldAssignment: json['old_assignment'] != null && json['old_assignment'] is Map<String, dynamic>
            ? Assignment.fromJson(json['old_assignment'] as Map<String, dynamic>)
            : null,
        newAssignment: json['new_assignment'] != null && json['new_assignment'] is Map<String, dynamic>
            ? Assignment.fromJson(json['new_assignment'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      // Zero-Tolerance Error Handling: Return safe immutable fallback on failure
      return const UnmapAndAssignPincodeModel();
    }
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status,
    "message": message,
    "old_assignment": oldAssignment?.toJson(),
    "new_assignment": newAssignment?.toJson(),
  };

  @override
  String toString() {
    return "success: $success, status: $status, message: $message, oldAssignment: $oldAssignment, newAssignment: $newAssignment";
  }
}

class Assignment {
  final int id;
  final String userName;
  final String pFirmCode;
  final String pPinCode;
  final int status;

  const Assignment({this.id = 0, this.userName = '', this.pFirmCode = '', this.pPinCode = '', this.status = 0});

  Assignment copyWith({int? id, String? userName, String? pFirmCode, String? pPinCode, int? status}) {
    return Assignment(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      pFirmCode: pFirmCode ?? this.pFirmCode,
      pPinCode: pPinCode ?? this.pPinCode,
      status: status ?? this.status,
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    try {
      return Assignment(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        userName: json['user_name']?.toString() ?? '',
        pFirmCode: json['P_FirmCode']?.toString() ?? '',
        pPinCode: json['P_PinCode']?.toString() ?? '',
        status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      );
    } catch (e) {
      return const Assignment();
    }
  }

  Map<String, dynamic> toJson() => {"id": id, "user_name": userName, "P_FirmCode": pFirmCode, "P_PinCode": pPinCode, "status": status};

  @override
  String toString() {
    return "id: $id, userName: $userName, pFirmCode: $pFirmCode, pPinCode: $pPinCode, status: $status";
  }
}
