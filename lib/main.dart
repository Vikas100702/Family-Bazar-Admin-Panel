import 'dart:async';
import 'dart:ui';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/initial_bindings/initial_bindings.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_pages.dart';
import 'package:family_bazar_admin_panel/src/core/theme/app_theme.dart';
import 'package:family_bazar_admin_panel/src/core/utils/startup/app_initializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  // Global boundary for all asynchronous Dart errors
  runZonedGuarded(
    () async {
      await AppInitializer.init();

      /// Global UI Error Handling
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
          withScope: (scope) => scope.setTag('error_type', 'flutter_ui_error'),
        );
        debugPrint('==================================================');
        debugPrint('--- [CRITICAL FATAL] FLUTTER UI EXCEPTION ---');
        debugPrint(details.exceptionAsString());
        debugPrint(details.stack?.toString());
        debugPrint('==================================================');
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) => scope.setTag('error_type', 'platform_dispatcher'),
        );
        return true;
      };

      await SentryFlutter.init((options) {
        options.dsn = 'https://67e8dcb99bd741608a3e426d4cbd751d@o4505270769090560.ingest.us.sentry.io/4511790284341248';
        options.tracesSampleRate = 1.0; // Sample all traces
        options.environment = kReleaseMode ? 'production' : 'development';
      }, appRunner: () => runApp(const FamilyBazarAdminApp()));
    },
    (error, stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) => scope.setTag('error_type', 'unhandled_async_error'),
      );
      debugPrint('==================================================');
      debugPrint('--- [CRITICAL FATAL] UNHANDLED ASYNC EXCEPTION ---');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      debugPrint('==================================================');
    },
  );
}

class FamilyBazarAdminApp extends StatelessWidget {
  const FamilyBazarAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900), // Standard Desktop Base Resolution
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true, // Ensures the app allows proper resizing logic when browser window changes
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.trackpad},
            physics: const BouncingScrollPhysics(),
          ),
          initialRoute: AppPages.initial,
          initialBinding: InitialBindings(),
          getPages: AppPages.routes,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const Scaffold(
              body: Center(child: Text('404 - Route Not Found')),
            ),
          ),
          defaultTransition: Transition.fadeIn,
          builder: (context, widget) {
            // [Proactive Styling] Locks global text scaling so user browser settings don't destroy your layout
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
