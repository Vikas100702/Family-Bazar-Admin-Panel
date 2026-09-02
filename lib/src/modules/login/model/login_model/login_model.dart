import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_model.freezed.dart';
part 'login_model.g.dart';

@freezed
abstract class LoginModel with _$LoginModel {
  const factory LoginModel({@Default(false) bool status, @Default('') String message, @Default('') String token, UserData? data}) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) => _$LoginModelFromJson(json);
}

@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    @Default(0) int id,
    @JsonKey(name: 'role_id') @Default(0) int roleId,
    @Default('') String username,
    @JsonKey(name: 'firebase_token') @Default('') String firebaseToken,
    @JsonKey(name: 'ip_address') @Default('') String ipAddress,
    @JsonKey(name: 'network_location') @Default('') String networkLocation,
    @JsonKey(name: 'gps_location') @Default('') String gpsLocation,
    @JsonKey(name: 'login_date') DateTime? loginDate,
    @JsonKey(name: 'login_time') @Default('') String loginTime,
    @Default('') String timezone,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'role_name') @Default('') String roleName,
    @Default({}) Map<String, PermissionNode> permissions,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
}

@freezed
abstract class PermissionNode with _$PermissionNode {
  const factory PermissionNode({@Default('') String name, @Default('') String icon, PermissionDetails? permissions}) = _PermissionNode;

  factory PermissionNode.fromJson(Map<String, dynamic> json) => _$PermissionNodeFromJson(json);
}

@freezed
abstract class PermissionDetails with _$PermissionDetails {
  const factory PermissionDetails({@Default(false) bool add, @Default(false) bool edit, @Default(false) bool delete, @Default(false) bool view}) =
      _PermissionDetails;

  factory PermissionDetails.fromJson(Map<String, dynamic> json) => _$PermissionDetailsFromJson(json);
}
