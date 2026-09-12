import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized(); // 1. Mandatory requirement before using SystemChrome or native platform channels
      final storageService = StorageService();
      await storageService.init();
      Get.put<StorageService>(storageService, permanent: true);

      Sentry.addBreadcrumb(Breadcrumb(message: 'Web App Core Initialization Completed Safely', category: 'system.boot', level: SentryLevel.info));
      debugPrint('--- [SYSTEM] Web App Core Initialization Completed Safely ---');
    } catch (e, stackTrace) {
      Sentry.captureException(
        Exception('CRITICAL FATAL: Web App Initialization Exception - $e'),
        stackTrace: stackTrace,
        withScope: (scope) => scope.setTag('layer', 'app_initializer'),
      );
      debugPrint('==================================================');
      debugPrint('--- [CRITICAL FATAL] WEB APP INITIALIZATION EXCEPTION ---');
      debugPrint('Exception: ${e.toString()}');
      debugPrint('StackTrace: ${stackTrace.toString()}');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
