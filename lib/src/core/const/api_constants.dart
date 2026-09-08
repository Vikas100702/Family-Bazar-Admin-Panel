import 'package:flutter/foundation.dart';

@immutable
abstract final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = "https://abctest.animationmedia.org";
  static const String tokenApiEndpoint = "$baseUrl/api/admin/get-token";
  static const String roleApiEndpoint = "$baseUrl/api/admin/role-type";
  static const String loginApiEndpoint = "$baseUrl/api/admin/login";
  static const String uploadImgApiEndpoint = "$baseUrl/api/product/uploadImage";
  static const String viewFirmApiEndpoint = "$baseUrl/api/firm/viewFirm";
  static const String getPincodeApiEndpoint = "$baseUrl/api/firm/getPincode";
  static const String insertPincodeApiEndpoint = "$baseUrl/api/firm/addPincode";
  static const String unmapPincodeApiEndpoint = "$baseUrl/api/firm/unmapAndAssign";
  static const String viewCategoryApiEndpoint = "$baseUrl/api/product/viewCategory";
  static const String insertCategoryDetailsApiEndpoint = "$baseUrl/api/product/addCategory";
  static const String viewSubCategoryApiEndpoint = "$baseUrl/api/product/viewSubcategory";
  static const String insertSubCatDetailsApiEndpoint = "$baseUrl/api/product/addSubCategory";
  static const String viewItemsApiEndpoint = "$baseUrl/api/product/viewItem";
  static const String insertItemDetailsApiEndpoint = "$baseUrl/api/product/addItem";
}
