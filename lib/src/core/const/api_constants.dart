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

  /// AUTH APIs
  static const String tokenApiEndpoint = "$baseUrl/api/admin/get-token";
  static const String roleApiEndpoint = "$baseUrl/api/admin/role-type";
  static const String loginApiEndpoint = "$baseUrl/api/admin/login";

  /// Image API
  static const String uploadImgApiEndpoint = "$baseUrl/api/product/uploadImage";

  /// FIRM API
  static const String viewFirmApiEndpoint = "$baseUrl/api/firm/viewFirm";

  /// PIN CODE APIs
  static const String getPincodeApiEndpoint = "$baseUrl/api/firm/getPincode";
  static const String insertPincodeApiEndpoint = "$baseUrl/api/firm/addPincode";
  static const String unmapPincodeApiEndpoint = "$baseUrl/api/firm/unmapAndAssign";

  /// CATEGORY APIs
  static const String viewCategoryApiEndpoint = "$baseUrl/api/product/viewCategory";
  static const String insertCategoryDetailsApiEndpoint = "$baseUrl/api/product/addCategory";

  /// SUBCATEGORY APIs
  static const String viewSubCategoryApiEndpoint = "$baseUrl/api/product/viewSubcategory";
  static const String insertSubCatDetailsApiEndpoint = "$baseUrl/api/product/addSubCategory";

  /// ITEM APIs
  static const String viewItemsApiEndpoint = "$baseUrl/api/product/viewItem";
  static const String insertItemDetailsApiEndpoint = "$baseUrl/api/product/addItem";

  /// DASHBOARD GROUP APIs
  static const String viewDashboardGroupApiEndpoint = "$baseUrl/api/product/viewGroup";
  static const String addDashboardGroupApiEndpoint = "$baseUrl/api/product/addGroup";
  static const String deleteDashboardGroupApiEndpoint = "$baseUrl/api/product/deleteGroup";
  static const String updateDashboardGroupApiEndpoint = "$baseUrl/api/product/updateGroup";

  /// DASHBOARD GROUP ITEM APIs
  static const String viewGroupItemsApiEndpoint = "$baseUrl/api/product/viewGroupItems";
  static const String addGroupItemsApiEndpoint = "$baseUrl/api/product/addGroupItems";
  static const String deleteGroupItemsApiEndpoint = "$baseUrl/api/product/deleteGroupItem";

  /// BRAND APIs
  static const String viewBrandsApiEndpoint = "$baseUrl/api/product/viewBrand";
  static const String updateBrandApiEndpoint = "$baseUrl/api/product/updateBrand";
}
