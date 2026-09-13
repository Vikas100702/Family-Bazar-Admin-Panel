import 'package:flutter/foundation.dart';

@immutable
class GetRoleModel {
  final bool status;
  final String message;
  final List<RoleDatum> data;

  const GetRoleModel({this.status = false, this.message = '', this.data = const <RoleDatum>[]});

  factory GetRoleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GetRoleModel();

    return GetRoleModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)?.map((e) => RoleDatum.fromJson(e as Map<String, dynamic>?)).toList() ?? const <RoleDatum>[],
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'data': data.map((e) => e.toJson()).toList()};
}

@immutable
class RoleDatum {
  final int id;
  final String roleName;
  final String createdAt;
  final String updatedAt;

  const RoleDatum({this.id = 0, this.roleName = '', this.createdAt = '', this.updatedAt = ''});

  factory RoleDatum.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RoleDatum();

    return RoleDatum(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      roleName: json['role_name'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'role_name': roleName, 'created_at': createdAt, 'updated_at': updatedAt};
}
