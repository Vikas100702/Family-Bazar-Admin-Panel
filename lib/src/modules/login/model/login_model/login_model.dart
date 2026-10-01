import 'package:flutter/foundation.dart';

@immutable
class LoginModel {
  final bool status;
  final String message;
  final String token;
  final Data? data;

  const LoginModel({this.status = false, this.message = '', this.token = '', this.data});

  factory LoginModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LoginModel();

    return LoginModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic> ? Data.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message, 'token': token, 'data': data?.toJson()};

  LoginModel copyWith({bool? status, String? message, String? token, Data? data}) {
    return LoginModel(status: status ?? this.status, message: message ?? this.message, token: token ?? this.token, data: data ?? this.data);
  }

  @override
  String toString() => 'LoginModel(status: $status, message: $message, token: $token, data: $data)';
}

@immutable
class Data {
  final int id;
  final int roleId;
  final String username;
  final String firebaseToken;
  final String ipAddress;
  final String networkLocation;
  final String gpsLocation;
  final DateTime? loginDate;
  final String loginTime;
  final String timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String roleName;

  /// Pure permissions_new contract: Group Key -> List of Module Permission Items
  final Map<String, List<PermissionModuleItem>> permissionsNew;

  const Data({
    this.id = 0,
    this.roleId = 0,
    this.username = '',
    this.firebaseToken = '',
    this.ipAddress = '',
    this.networkLocation = '',
    this.gpsLocation = '',
    this.loginDate,
    this.loginTime = '',
    this.timezone = '',
    this.createdAt,
    this.updatedAt,
    this.roleName = '',
    this.permissionsNew = const <String, List<PermissionModuleItem>>{},
  });

  factory Data.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Data();

    // Defensive parsing for permissions_new schema
    final Map<String, List<PermissionModuleItem>> parsedPermissions = {};
    final dynamic rawPermissionsNew = json['permissions_new'];

    if (rawPermissionsNew != null && rawPermissionsNew is Map<String, dynamic>) {
      rawPermissionsNew.forEach((groupKey, groupList) {
        if (groupList is List) {
          final List<PermissionModuleItem> items = groupList
              .whereType<Map<String, dynamic>>()
              .map((item) => PermissionModuleItem.fromJson(item))
              .toList();

          parsedPermissions[groupKey] = items;
        }
      });
    }

    return Data(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      roleId: json['role_id'] is int ? json['role_id'] as int : int.tryParse(json['role_id']?.toString() ?? '') ?? 0,
      username: json['username']?.toString() ?? '',
      firebaseToken: json['firebase_token']?.toString() ?? '',
      ipAddress: json['ip_address']?.toString() ?? '',
      networkLocation: json['network_location']?.toString() ?? '',
      gpsLocation: json['gps_location']?.toString() ?? '',
      loginDate: DateTime.tryParse(json['login_date']?.toString() ?? ''),
      loginTime: json['login_time']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      roleName: json['role_name']?.toString() ?? '',
      permissionsNew: parsedPermissions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role_id': roleId,
    'username': username,
    'firebase_token': firebaseToken,
    'ip_address': ipAddress,
    'network_location': networkLocation,
    'gps_location': gpsLocation,
    'login_date': loginDate?.toIso8601String(),
    'login_time': loginTime,
    'timezone': timezone,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'role_name': roleName,
    'permissions_new': permissionsNew.map((key, list) => MapEntry(key, list.map((item) => item.toJson()).toList())),
  };

  Data copyWith({
    int? id,
    int? roleId,
    String? username,
    String? firebaseToken,
    String? ipAddress,
    String? networkLocation,
    String? gpsLocation,
    DateTime? loginDate,
    String? loginTime,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roleName,
    Map<String, List<PermissionModuleItem>>? permissionsNew,
  }) {
    return Data(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      username: username ?? this.username,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      ipAddress: ipAddress ?? this.ipAddress,
      networkLocation: networkLocation ?? this.networkLocation,
      gpsLocation: gpsLocation ?? this.gpsLocation,
      loginDate: loginDate ?? this.loginDate,
      loginTime: loginTime ?? this.loginTime,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roleName: roleName ?? this.roleName,
      permissionsNew: permissionsNew ?? this.permissionsNew,
    );
  }
}

@immutable
class PermissionModuleItem {
  final String name;
  final String? icon;
  final ActionPermissions permissions;

  const PermissionModuleItem({this.name = '', this.icon, this.permissions = const ActionPermissions()});

  factory PermissionModuleItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PermissionModuleItem();

    return PermissionModuleItem(
      name: json['name']?.toString().trim() ?? '',
      icon: json['icon']?.toString(),
      permissions: json['permissions'] != null && json['permissions'] is Map<String, dynamic>
          ? ActionPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
          : const ActionPermissions(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'icon': icon, 'permissions': permissions.toJson()};
}

@immutable
class ActionPermissions {
  final bool add;
  final bool edit;
  final bool delete;
  final bool view;

  const ActionPermissions({this.add = false, this.edit = false, this.delete = false, this.view = false});

  factory ActionPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActionPermissions();

    bool parseBool(dynamic val) => val == true || val == 1 || val == 'true';

    return ActionPermissions(
      add: parseBool(json['add']),
      edit: parseBool(json['edit']),
      delete: parseBool(json['delete']),
      view: parseBool(json['view']),
    );
  }

  Map<String, dynamic> toJson() => {'add': add, 'edit': edit, 'delete': delete, 'view': view};
}
