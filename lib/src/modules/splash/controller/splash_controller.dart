import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SplashController extends BaseController {
  final StorageService _storageService;

  SplashController({required this._storageService});

  @override
  void onInit() {
    super.onInit();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    try {
      Sentry.addBreadcrumb(Breadcrumb(message: 'Splash Sequence Initiated', category: 'Splash routing', level: SentryLevel.info));
      await Future.delayed(const Duration(seconds: 2));
      if (isClosed) return;
      _verifyAuthAndRedirect();
    } catch (e, stackTrace) {
      debugPrint('--- [CRITICAL] Splash Sequence Failed ---');
      debugPrint('[Exception]: ${e.toString()}');
      debugPrint('[Stacktrace]: ${stackTrace.toString()}');
      Sentry.captureException('Splash Sequence Crash: $e', stackTrace: stackTrace, withScope: (scope) => scope.setTag('layer', 'splash_controller'));
      if (!isClosed) Get.offAllNamed(AppRoutes.login);
    }
  }

  void _verifyAuthAndRedirect() {
    try {
      final String? token = _storageService.getString(AppConstants.authTokenKey);

      if (token != null && token.trim().isNotEmpty) {
        Sentry.addBreadcrumb(Breadcrumb(message: 'Valid Auth Token found -> Redirecting to Dashboard', category: 'auth', level: SentryLevel.info));
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Sentry.addBreadcrumb(Breadcrumb(message: 'No Token found -> Redirecting to Login', category: 'auth', level: SentryLevel.info));
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e, stackTrace) {
      debugPrint('--- [ERROR] Token Verification Exception ---');
      debugPrint('[Exception]: ${e.toString()}');
      debugPrint('[Stacktrace]: ${stackTrace.toString()}');

      Sentry.captureException(
        'Splash Token Read Crash: $e',
        stackTrace: stackTrace,
        withScope: (scope) => scope.setTag('layer', 'splash_controller'),
      );
      if (!isClosed) Get.offAllNamed(AppRoutes.login);
    }
  }
}
