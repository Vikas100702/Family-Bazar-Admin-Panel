import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final StorageService storageService = Get.find<StorageService>();

    // Check if token exists and is valid
    final String? token = storageService.getString(AppConstants.authTokenKey);
    final bool isLoggedIn = token != null && token.trim().isNotEmpty;

    // If user is NOT logged in and trying to access any page other than login
    if (!isLoggedIn) {
      if (route != AppRoutes.login) {
        return const RouteSettings(name: AppRoutes.login);
      }
    } else {
      // If user is ALREADY logged in and visits login, redirect directly to dashboard
      if (route == AppRoutes.login) {
        return const RouteSettings(name: AppRoutes.dashboard);
      }
    }

    return null; // Continue to the requested route
  }
}
