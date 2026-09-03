import 'package:flutter/foundation.dart';

@immutable
abstract final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = "http://192.168.1.21:8083";
  static const String tokenApiEndpoint = "$baseUrl/api/admin/get-token";
  static const String roleApiEndpoint = "$baseUrl/api/admin/role-type";
  static const String loginApiEndpoint = "$baseUrl/api/admin/login";
  static const String viewFirmApiEndpoint = "$baseUrl/api/firm/viewFirm";
  static const String getPincodeApiEndpoint = "$baseUrl/api/firm/getPincode";
  static const String addPincodeApiEndpoint = "$baseUrl/api/firm/addPincode";
  static const String unmapPincodeApiEndpoint = "$baseUrl/api/firm/unmapAndAssign";
}
