import 'dart:typed_data';

import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/controller/image_upload_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageUploadView extends GetView<ImageUploadController> {
  final VoidCallback? onDismiss;
  final String entityCode;
  final String? entityTitle;
  final String uploadType; // e.g. 'category', 'subcategory', 'item'
  final EntityLinkCallback? onLinkEntity;
  final VoidCallback? onSuccess;
  final String? initialWebImageUrl;
  final String? initialMobileImageUrl;

  const ImageUploadView({
    super.key,
    required this.entityCode,
    this.entityTitle,
    this.uploadType = '',
    this.onLinkEntity,
    this.onSuccess,
    this.onDismiss,
    this.initialWebImageUrl,
    this.initialMobileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Synchronize the entity data and callback into the controller
    controller.configureEntity(
      entityCode: entityCode,
      type: uploadType,
      onLinkEntity: onLinkEntity,
      onSuccess: onSuccess,
      initialWebImageUrl: initialWebImageUrl,
      initialMobileImageUrl: initialMobileImageUrl,
    );

    final isDark = context.isDark;
    final mediaQuery = MediaQuery.sizeOf(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 840, maxHeight: mediaQuery.height * 0.92),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: context.responsiveRadius(12, 16),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.responsiveSize(20, 28)),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          _buildHeader(context),
          SizedBox(height: context.responsiveHeight(16, 20)),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  _buildUploadGrid(context),
                  SizedBox(height: context.responsiveHeight(14, 18)),
                  _buildServerResponseStatus(context),
                ],
              ),
            ),
          ),
          SizedBox(height: context.responsiveHeight(16, 20)),
          _buildFooterActions(context),
        ],
      ),
    );
  }

  /// DIALOG HEADER
  Widget _buildHeader(BuildContext context) {
    final isDark = context.isDark;
    final String resolvedTitle = entityTitle != null && entityTitle!.trim().isNotEmpty
        ? entityTitle!.trim()
        : (uploadType.isNotEmpty ? '${uploadType[0].toUpperCase()}${uploadType.substring(1)}' : 'Asset');
    final String resolvedCode = 'Code: ${entityCode.trim()} (${uploadType.toUpperCase()})';

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: .all(context.responsiveSize(8, 10)),
                decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), borderRadius: context.responsiveRadius(8, 10)),
                child: Icon(Icons.cloud_upload_outlined, color: AppColors.primaryRed, size: context.responsiveSize(20, 24)),
              ),
              SizedBox(width: context.responsiveWidth(12, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Upload Media: $resolvedTitle',
                      style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$resolvedCode • Web Banner (16:9) & Mobile Icon (1:1)',
                      style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          splashRadius: 20,
          tooltip: 'Close',
          color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
          onPressed: () {
            controller.clearImageBuffers();
            if (onDismiss != null) {
              onDismiss!();
            } else {
              Get.back();
            }
          },
        ),
      ],
    );
  }

  // 2. RESPONSIVE DUAL-DROP ZONE GRID
  Widget _buildUploadGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isStacked = constraints.maxWidth < 650;
        if (isStacked) {
          return Column(
            children: [
              _buildDropzone(
                context: context,
                title: 'App Banner',
                specLabel: '1:1 Square (Min 300x300 px, Max 1MB)',
                isMobile: true,
                bytesRx: controller.mobileImageBytes,
                fileNameRx: controller.mobileImageFileName,
                errorRx: controller.mobileImageError,
                uploadedUrlRx: controller.uploadedMobileImageUrl,
              ),
              SizedBox(height: context.responsiveHeight(16, 16)),
              _buildDropzone(
                context: context,
                title: 'Website Banner',
                specLabel: '16:9 Banner (Min 800x450 px, Max 2MB)',
                isMobile: false,
                bytesRx: controller.webImageBytes,
                fileNameRx: controller.webImageFileName,
                errorRx: controller.webImageError,
                uploadedUrlRx: controller.uploadedWebImageUrl,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: _buildDropzone(
                context: context,
                title: 'App Banner',
                specLabel: '1:1 Square (Min 300x300 px, Max 1MB)',
                isMobile: true,
                bytesRx: controller.mobileImageBytes,
                fileNameRx: controller.mobileImageFileName,
                errorRx: controller.mobileImageError,
                uploadedUrlRx: controller.uploadedMobileImageUrl,
              ),
            ),
            SizedBox(width: context.responsiveWidth(16, 20)),
            Expanded(
              child: _buildDropzone(
                context: context,
                title: 'Website Banner',
                specLabel: '16:9 Banner (Min 800x450 px, Max 2MB)',
                isMobile: false,
                bytesRx: controller.webImageBytes,
                fileNameRx: controller.webImageFileName,
                errorRx: controller.webImageError,
                uploadedUrlRx: controller.uploadedWebImageUrl,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropzone({
    required BuildContext context,
    required String title,
    required String specLabel,
    required bool isMobile,
    required Rxn<Uint8List> bytesRx,
    required Rxn<String> fileNameRx,
    required RxString errorRx,
    required RxString uploadedUrlRx,
  }) {
    final isDark = context.isDark;

    return Obx(() {
      final Uint8List? bytes = bytesRx.value;
      final String? fileName = fileNameRx.value;
      final String uploadedUrl = uploadedUrlRx.value;
      final String validationError = errorRx.value;
      final bool hasSelection = bytes != null && bytes.isNotEmpty;
      final bool isUploaded = uploadedUrl.isNotEmpty;
      final bool hasError = validationError.isNotEmpty;

      Color borderColor;
      if (hasError) {
        borderColor = AppColors.statusRedError;
      } else if (isUploaded) {
        borderColor = AppColors.statusGreenSuccess;
      } else if (hasSelection) {
        borderColor = AppColors.primaryRed;
      } else {
        borderColor = isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate;
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceWhite,
          borderRadius: context.responsiveRadius(10, 12),
          border: Border.all(color: borderColor, width: hasSelection || isUploaded || hasError ? 1.5 : 1.0),
        ),
        padding: EdgeInsets.all(context.responsiveSize(14, 16)),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  title,
                  style: context.titleStyleRegular.copyWith(fontSize: context.responsiveSize(13, 14), fontWeight: FontWeight.w600),
                ),
                if (isUploaded)
                  Container(
                    padding: const .symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.statusGreenSuccess.withValues(alpha: 0.12),
                      borderRadius: .circular(20),
                      border: Border.all(color: AppColors.statusGreenSuccess.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: .min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: AppColors.statusGreenSuccess),
                        SizedBox(width: 4),
                        Text(
                          'Linked',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.statusGreenSuccess),
                        ),
                      ],
                    ),
                  )
                else if (hasSelection)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () {
                        bytesRx.value = null;
                        fileNameRx.value = null;
                        errorRx.value = '';
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Remove',
                          style: TextStyle(fontSize: context.responsiveSize(11, 12), color: AppColors.statusRedError, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.responsiveHeight(4, 6)),
            Text(specLabel, style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate)),
            SizedBox(height: context.responsiveHeight(12, 14)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                borderRadius: context.responsiveRadius(8, 10),
                onTap: () => controller.pickImage(isMobile: isMobile),
                child: Container(
                  height: context.responsiveHeight(140, 160),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                    borderRadius: context.responsiveRadius(8, 10),
                    border: .all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasSelection
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(bytes, fit: isMobile ? .contain : .cover),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.65),
                                padding: const .symmetric(horizontal: 8, vertical: 5),
                                child: Text(
                                  fileName ?? 'Selected Media Asset',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        )
                      : (uploadedUrl.isNotEmpty
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    uploadedUrl.startsWith('http') ? uploadedUrl : 'https://abctest.animationmedia.org$uploadedUrl',
                                    fit: isMobile ? BoxFit.contain : BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: const Text(
                                        'Current Image (Click to change)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isMobile ? Icons.phone_android_rounded : Icons.desktop_mac_rounded,
                                    size: context.responsiveSize(32, 38),
                                    color: AppColors.primaryRed.withValues(alpha: 0.7),
                                  ),
                                  SizedBox(height: context.responsiveHeight(8, 10)),
                                  Text(
                                    'Click to browse or drop asset',
                                    style: context.titleStyleRegular.copyWith(fontSize: context.responsiveSize(12, 13), fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: context.responsiveHeight(2, 4)),
                                  Text(
                                    'Formats: JPG, PNG, WEBP',
                                    style: context.captionStyle.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
                                  ),
                                ],
                              )),
                ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: context.responsiveHeight(8, 10)),
              Container(
                padding: const .symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.statusRedError.withValues(alpha: 0.08),
                  borderRadius: .circular(6),
                  border: Border.all(color: AppColors.statusRedError.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.statusRedError),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        validationError,
                        style: TextStyle(color: AppColors.statusRedError, fontSize: context.responsiveSize(10, 11), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // SERVER RESPONSE STATUS BANNER

  Widget _buildServerResponseStatus(BuildContext context) {
    return Obx(() {
      final String msg = controller.uploadStatusMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: .symmetric(horizontal: context.responsiveWidth(12, 14), vertical: context.responsiveHeight(8, 10)),
        decoration: BoxDecoration(
          color: AppColors.statusGreenSuccess.withValues(alpha: 0.08),
          borderRadius: context.responsiveRadius(6, 8),
          border: .all(color: AppColors.statusGreenSuccess.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.statusGreenSuccess, size: 18),
            SizedBox(width: context.responsiveWidth(8, 10)),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(fontSize: context.responsiveSize(12, 13), color: AppColors.statusGreenSuccess, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    });
  }

  // FOOTER ACTIONS

  Widget _buildFooterActions(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      mainAxisAlignment: .end,
      children: [
        TextButton(
          onPressed: () {
            controller.clearImageBuffers();
            if (onDismiss != null) {
              onDismiss!();
            } else {
              Get.back();
            }
          },
          child: Text(
            'Reset / Cancel',
            style: TextStyle(fontSize: context.responsiveSize(13, 14), color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
          ),
        ),
        SizedBox(width: context.responsiveWidth(12, 16)),
        Obx(() {
          final bool hasSelection =
              (controller.webImageBytes.value != null && controller.webImageBytes.value!.isNotEmpty) ||
              (controller.mobileImageBytes.value != null && controller.mobileImageBytes.value!.isNotEmpty);
          final bool isSubmitting = controller.isLoading.value;

          return ElevatedButton.icon(
            onPressed: (hasSelection && !isSubmitting) ? () => controller.uploadImages() : null,
            icon: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.cloud_upload_rounded, size: 18),
            label: Text(isSubmitting ? 'Uploading...' : 'Save & Link Media', style: const TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.onPrimaryWhite,
              disabledBackgroundColor: AppColors.primaryRed.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white70,
              padding: .symmetric(horizontal: context.responsiveWidth(18, 24), vertical: context.responsiveHeight(12, 16)),
              shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(8, 10)),
            ),
          );
        }),
      ],
    );
  }
}

typedef ImageUploadWidget = ImageUploadView;
