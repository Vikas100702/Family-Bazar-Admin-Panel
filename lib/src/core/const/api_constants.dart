import 'package:flutter/foundation.dart';

@immutable
abstract final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = "https://abctest.animationmedia.org";
  static String resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final cleanPath = path.trim();
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }
    final formattedPath = cleanPath.startsWith('/') ? cleanPath : '/$cleanPath';
    return '$baseUrl$formattedPath';
  }

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
  static const String viewDashboardGroupApiEndpoint = "$baseUrl/api/product/viewGroup";
  static const String addDashboardGroupApiEndpoint = "$baseUrl/api/product/addGroup";
  static const String deleteDashboardGroupApiEndpoint = "$baseUrl/api/product/deleteGroup";
  static const String viewGroupItemsApiEndpoint = "$baseUrl/api/product/viewGroupItems";
  static const String addGroupItemsApiEndpoint = "$baseUrl/api/product/addGroupItems";
  static const String deleteGroupItemsApiEndpoint = "$baseUrl/api/product/deleteGroupItem";
}
