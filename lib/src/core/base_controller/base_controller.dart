import 'dart:async';

import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/network/network_exception.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  bool _isShowingSuccessMessage = false;

  /// Core wrapper for executing tasks with automated loading state and error handling
  Future<void> runWithLoading(Future<void> Function() task, {String message = 'Processing...'}) async {
    if (isClosed) return; // Abort immediately if the controller is already destroyed
    bool hasError = false;
    _isShowingSuccessMessage = false;

    try {
      // Wait until the current UI frame is finished before starting the loader
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) isLoading(true); // Double-check before mutating state
      });
      await task();
    } on DioException catch (e, stackTrace) {
      hasError = true;
      _handleException(e, stackTrace, isNetworkError: true);
    } catch (e, stackTrace) {
      hasError = true;
      _handleException(e, stackTrace, isNetworkError: false);
    } finally {
      // Avoid 'return' in finally blocks to prevent swallowing control flow[cite: 1].
      // Guard state mutation using conditional block instead[cite: 1].
      if (!isClosed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isClosed) return;

          isLoading(false);
          // Only close active dialogs (like loading overlays) if no error or success dialog took over[cite: 1]
          if (!hasError && !_isShowingSuccessMessage && Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }
    }
  }

  void _handleException(dynamic e, StackTrace stackTrace, {required bool isNetworkError}) {
    if (isClosed) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'controller.exception',
        message: 'Exception intercepted in ${runtimeType.toString()}',
        level: SentryLevel.error,
        data: {'isNetworkError': isNetworkError, 'exceptionType': e.runtimeType.toString()},
      ),
    );

    Sentry.captureException(
      e,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('error_type', isNetworkError ? 'network' : 'business_logic');
        scope.setContexts('Controller Context', {'controller': runtimeType.toString(), 'isClosed': isClosed});
      },
    );

    debugPrint('--- [BASE CONTROLLER] EXCEPTION CAUGHT ---');
    debugPrint('Type: ${e.runtimeType}');
    debugPrint('Message: ${e.toString()}');
    debugPrint('StackTrace: $stackTrace');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      String cleanMessage = AppStrings.unexpectedError;

      if (isNetworkError && e is DioException) {
        cleanMessage = NetworkExceptions.fromDioException(e).message;
      } else {
        cleanMessage = e.toString().replaceAll('Exception: ', '').trim();
      }

      // Delegating to centralize DialogHelper
      DialogHelper.showError(message: cleanMessage);
    });
  }

  void successMessage({required String title, required String message, VoidCallback? onPressed}) {
    if (isClosed) return;
    _isShowingSuccessMessage = true;
    DialogHelper.showSuccess(title: title, message: message, onPressed: onPressed);
  }

  void errorMessage({String? title, required String message, VoidCallback? onPressed}) {
    if (isClosed) return;
    DialogHelper.showError(title: title, message: message, onPressed: onPressed);
  }
}
