import 'dart:convert';

import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/utils/device/device_meta_service.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/login/repository/login_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoginController extends BaseController {
  final LoginRepository _loginRepository;
  final StorageService _storageService;
  final DeviceMetaService _deviceMetaService;

  LoginController({required this._loginRepository, required this._storageService, required this._deviceMetaService});

  // UI CONTROLLERS & KEYS
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // REACTIVE STATE VARIABLES
  final RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your username';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate() != true) return; // Form Validation

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'User initiated administrative login attempt',
        category: 'auth.controller',
        level: SentryLevel.info,
        data: {'username': usernameController.text.trim()},
      ),
    );

    await runWithLoading(() async {
      Sentry.addBreadcrumb(Breadcrumb(message: 'Generating API Token prior to user authentication', category: 'auth.controller'));

      final tokenModel = await _loginRepository.fetchToken();
      if (isClosed) return;

      if (tokenModel.token.isEmpty) {
        throw Exception('Failed to generate security token from server.');
      }
      await _storageService.setString(AppConstants.authTokenKey, tokenModel.token);

      final metaData = await _deviceMetaService.fetchLoginMetaData();
      if (isClosed) return;

      final response = await _loginRepository.fetchLoginUser(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        firebaseToken: metaData['firebase_token'] as String? ?? '',
        latitude: metaData['latitude'] as String? ?? '',
        longitude: metaData['longitude'] as String? ?? '',
        loginDate: metaData['login_date'] as String? ?? '',
        loginTime: metaData['login_time'] as String? ?? '',
      );

      if (isClosed) return;
      if (response.token.isNotEmpty) {
        await _storageService.setString(AppConstants.authTokenKey, response.token);

        if (response.data != null) {
          final userDataJson = jsonEncode(response.data!.toJson());
          await _storageService.setString('user_data', userDataJson);
          await _storageService.setString('username', response.data!.username);

          await Sentry.configureScope((scope) {
            scope.setUser(SentryUser(id: response.data!.id.toString(), username: response.data!.username));
          });
        }
        successMessage(
          title: AppStrings.welcomeBack,
          message: response.message.isNotEmpty ? response.message : AppStrings.loginSuccess,
          onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        passwordController.clear(); // Clear password on failure
        throw Exception('Authentication failed: No access token received from server.');
      }
    }, message: 'Authenticating...');
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
