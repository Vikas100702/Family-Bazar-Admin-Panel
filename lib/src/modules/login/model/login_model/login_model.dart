class LoginModel {
  LoginModel({required this.status, required this.message, required this.token, required this.data});

  final bool status;
  final String message;
  final String token;
  final Data? data;

  LoginModel copyWith({bool? status, String? message, String? token, Data? data}) {
    return LoginModel(status: status ?? this.status, message: message ?? this.message, token: token ?? this.token, data: data ?? this.data);
  }

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      token: json["token"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "message": message, "token": token, "data": data?.toJson()};

  @override
  String toString() {
    return "$status, $message, $token, $data, ";
  }
}

class Data {
  Data({
    required this.id,
    required this.roleId,
    required this.username,
    required this.firebaseToken,
    required this.ipAddress,
    required this.networkLocation,
    required this.gpsLocation,
    required this.loginDate,
    required this.loginTime,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
    required this.roleName,
    required this.permissions,
  });

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
  final Map<String, Permission> permissions;

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
    Map<String, Permission>? permissions,
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
      permissions: permissions ?? this.permissions,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? 0,
      roleId: json["role_id"] ?? 0,
      username: json["username"] ?? "",
      firebaseToken: json["firebase_token"] ?? "",
      ipAddress: json["ip_address"] ?? "",
      networkLocation: json["network_location"] ?? "",
      gpsLocation: json["gps_location"] ?? "",
      loginDate: DateTime.tryParse(json["login_date"] ?? ""),
      loginTime: json["login_time"] ?? "",
      timezone: json["timezone"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      roleName: json["role_name"] ?? "",
      permissions: Map.from(json["permissions"]).map((k, v) => MapEntry<String, Permission>(k, Permission.fromJson(v))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "role_id": roleId,
    "username": username,
    "firebase_token": firebaseToken,
    "ip_address": ipAddress,
    "network_location": networkLocation,
    "gps_location": gpsLocation,
    "login_date":
        "${loginDate?.year.toString().padLeft(4, '0')}-${loginDate?.month.toString().padLeft(2, '0')}-${loginDate?.day.toString().padLeft(2, '0')}",
    "login_time": loginTime,
    "timezone": timezone,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "role_name": roleName,
    "permissions": Map.from(permissions).map((k, v) => MapEntry<String, dynamic>(k, v?.toJson())),
  };

  @override
  String toString() {
    return "$id, $roleId, $username, $firebaseToken, $ipAddress, $networkLocation, $gpsLocation, $loginDate, $loginTime, $timezone, $createdAt, $updatedAt, $roleName, $permissions, ";
  }
}

class Permission {
  Permission({required this.name, required this.icon, required this.permissions});

  final String name;
  final dynamic icon;
  final Permissions? permissions;

  Permission copyWith({String? name, dynamic? icon, Permissions? permissions}) {
    return Permission(name: name ?? this.name, icon: icon ?? this.icon, permissions: permissions ?? this.permissions);
  }

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      name: json["name"] ?? "",
      icon: json["icon"],
      permissions: json["permissions"] == null ? null : Permissions.fromJson(json["permissions"]),
    );
  }

  Map<String, dynamic> toJson() => {"name": name, "icon": icon, "permissions": permissions?.toJson()};

  @override
  String toString() {
    return "$name, $icon, $permissions, ";
  }
}

class Permissions {
  Permissions({required this.add, required this.edit, required this.delete, required this.view});

  final bool add;
  final bool edit;
  final bool delete;
  final bool view;

  Permissions copyWith({bool? add, bool? edit, bool? delete, bool? view}) {
    return Permissions(add: add ?? this.add, edit: edit ?? this.edit, delete: delete ?? this.delete, view: view ?? this.view);
  }

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(add: json["add"] ?? false, edit: json["edit"] ?? false, delete: json["delete"] ?? false, view: json["view"] ?? false);
  }

  Map<String, dynamic> toJson() => {"add": add, "edit": edit, "delete": delete, "view": view};

  @override
  String toString() {
    return "$add, $edit, $delete, $view, ";
  }
}
