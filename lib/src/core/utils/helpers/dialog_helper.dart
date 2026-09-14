import 'dart:async';

import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract final class DialogHelper {
  const DialogHelper._();

  static bool _isDialogActive = false;
  static bool _isOfflineDialogActive = false;

  /// PUBLIC DIALOG TRIGGERS
  /// Displays an error dialog
  static void showError({String? title, required String message, VoidCallback? onPressed}) {
    if (Get.overlayContext == null) return;
    _showGlobalDialog(
      title: title ?? 'Alert',
      message: message,
      accentColor: AppColors.statusRedError,
      icon: Icons.error_outline_rounded,
      onPressed: onPressed,
      logCategory: 'ui.dialog.error',
    );
  }

  /// Displays a success dialog
  static void showSuccess({String? title, required String message, VoidCallback? onPressed}) {
    if (Get.overlayContext == null) return;
    _showGlobalDialog(
      title: title ?? 'Success',
      message: message,
      accentColor: AppColors.statusGreenSuccess,
      icon: Icons.check_circle_outline_rounded,
      onPressed: onPressed,
      logCategory: 'ui.dialog.success',
    );
  }

  /// Displays a warning dialog safely
  static void showWarning({String? title, required String message, VoidCallback? onPressed}) {
    if (Get.overlayContext == null) return;
    _showGlobalDialog(
      title: title ?? 'Warning',
      message: message,
      accentColor: AppColors.statusAmberWarning,
      icon: Icons.warning_amber_rounded,
      onPressed: onPressed,
      logCategory: 'ui.dialog.warning',
    );
  }

  /// Displays an informational notice dialog
  /// Displays an informational notice dialog safely
  static void showInfo({String? title, required String message, VoidCallback? onPressed}) {
    if (Get.overlayContext == null) return;
    _showGlobalDialog(
      title: title ?? 'Information',
      message: message,
      accentColor: AppColors.statusBlueInfo,
      icon: Icons.info_outline_rounded,
      onPressed: onPressed,
      logCategory: 'ui.dialog.info',
    );
  }

  // CORE DIALOG GENERATOR WITH CONCURRENCY LOCK
  static void _showGlobalDialog({
    required String title,
    required String message,
    required Color accentColor,
    required IconData icon,
    required String logCategory,
    VoidCallback? onPressed,
  }) {
    if (_isDialogActive || _isOfflineDialogActive) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
    _isDialogActive = true;
    Get.dialog<void>(
      PopScope(
        canPop: false,
        child: Builder(
          builder: (context) {
            final isDark = context.isDark;
            final double dialogWidth = context.responsiveWidth(context.screenWidth * 0.88, 420);
            return Dialog(
              backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
              ),
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(24, 28), horizontal: context.responsiveWidth(20, 24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: accentColor, size: context.responsiveSize(36, 44)),
                    ),
                    SizedBox(height: context.responsiveHeight(14, 18)),
                    Text(
                      title,
                      style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.responsiveHeight(8, 12)),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.bodyTextStyle.copyWith(
                        fontSize: context.responsiveSize(13, 14),
                        color: isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: context.responsiveHeight(20, 26)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _isDialogActive = false;
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }
                          if (onPressed != null) {
                            try {
                              onPressed();
                            } catch (e, stackTrace) {
                              Sentry.captureException(Exception('Dialog Callback Failed: $e'), stackTrace: stackTrace);
                              debugPrint('--- [DIALOG EXCEPTION] Callback Failed: $e ---');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(12, 14)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(AppStrings.close, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isDialogActive = false;
    });
  }

  // OFFLINE CONNECTION RESILIENCE DIALOG
  static void showOfflineDialog() {
    if (Get.overlayContext == null || _isOfflineDialogActive) return;

    if (_isDialogActive && Get.isDialogOpen == true) {
      Get.back();
      _isDialogActive = false;
    }

    _isOfflineDialogActive = true;

    Get.dialog<void>(
      PopScope(
        canPop: false,
        child: Builder(
          builder: (context) {
            final isDark = context.isDark;
            final double dialogWidth = context.responsiveWidth(context.screenWidth * 0.88, 440);

            return Dialog(
              backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.statusRedError.withValues(alpha: isDark ? 0.5 : 0.8), width: 1.5),
              ),
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.all(context.responsiveSize(22, 28)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.statusRedError.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.wifi_off_rounded, color: AppColors.statusRedError, size: context.responsiveSize(40, 48)),
                    ),
                    SizedBox(height: context.responsiveHeight(16, 20)),
                    Text(
                      'Connection Lost',
                      style: context.mainHeadingTextStyle.copyWith(fontSize: context.responsiveSize(18, 20), color: AppColors.statusRedError),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.responsiveHeight(10, 14)),
                    Text(
                      'This application requires an active internet connection. Please check your network to resume.',
                      style: context.bodyTextStyle.copyWith(
                        fontSize: context.responsiveSize(13, 14),
                        color: isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isOfflineDialogActive = false;
    });
  }

  /// Utility to safely dismiss the offline dialog once connectivity restores
  static void dismissOfflineDialog() {
    if (_isOfflineDialogActive && Get.isDialogOpen == true) {
      Get.back();
      _isOfflineDialogActive = false;
    }
  }

  static void showDeleteDialog({
    String? title,
    String? itemName,
    String? message,
    String actionNoun = 'delete',
    String confirmLabel = 'Confirm Delete',
    String cancelLabel = 'Cancel',
    required FutureOr<void> Function() onConfirm,
    VoidCallback? onCancel,
  }) {
    if (Get.overlayContext == null) return;

    // Concurrency Lock: Tear down any currently open dialog before mounting
    if (_isDialogActive || _isOfflineDialogActive) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }

    _isDialogActive = true;

    Get.dialog<void>(
      PopScope(
        canPop: false, // Strict protection against accidental backdrop clicks
        child: Builder(
          builder: (context) {
            final isDark = context.isDark;
            final double dialogWidth = context.responsiveWidth(context.screenWidth * 0.88, 440);

            return Dialog(
              backgroundColor: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
              ),
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.all(context.responsiveSize(22, 28)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.statusRedError.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.delete_outline_rounded, color: AppColors.statusRedError, size: context.responsiveSize(36, 42)),
                    ),
                    SizedBox(height: context.responsiveHeight(14, 18)),
                    Text(
                      title ?? 'Confirm Deletion',
                      style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.responsiveHeight(8, 12)),
                    if (message != null)
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: context.bodyTextStyle.copyWith(
                          fontSize: context.responsiveSize(13, 14),
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                          height: 1.45,
                        ),
                      )
                    else
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: context.bodyTextStyle.copyWith(
                            fontSize: context.responsiveSize(13, 14),
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                            height: 1.45,
                          ),
                          children: [
                            TextSpan(text: 'Are you sure you want to $actionNoun '),
                            if (itemName != null && itemName.trim().isNotEmpty)
                              TextSpan(
                                text: itemName.trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                                ),
                              ),
                            const TextSpan(text: '? This action cannot be undone.'),
                          ],
                        ),
                      ),
                    SizedBox(height: context.responsiveHeight(22, 26)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _isDialogActive = false;
                              if (Get.isDialogOpen == true) {
                                Get.back();
                              }
                              if (onCancel != null) {
                                try {
                                  onCancel();
                                } catch (e, stackTrace) {
                                  Sentry.captureException(Exception('Delete Dialog Cancel Callback Failed: $e'), stackTrace: stackTrace);
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              enabledMouseCursor: SystemMouseCursors.click,
                              padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(12, 14)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(cancelLabel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              _isDialogActive = false;
                              if (Get.isDialogOpen == true) {
                                Get.back();
                              }
                              try {
                                await onConfirm();
                              } catch (e, stackTrace) {
                                Sentry.captureException(Exception('Delete Dialog Confirm Callback Failed: $e'), stackTrace: stackTrace);
                                debugPrint('--- [DIALOG EXCEPTION] Delete Callback Failed: $e ---');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              enabledMouseCursor: SystemMouseCursors.click,
                              backgroundColor: AppColors.statusRedError,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(12, 14)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isDialogActive = false;
    });
  }
}
