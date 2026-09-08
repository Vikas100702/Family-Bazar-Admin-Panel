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

  const ImageUploadView({
    super.key,
    required this.entityCode,
    this.entityTitle,
    this.uploadType = '',
    this.onLinkEntity,
    this.onSuccess,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Synchronize the entity data and callback into the controller
    controller.configureEntity(entityCode: entityCode, type: uploadType, onLinkEntity: onLinkEntity, onSuccess: onSuccess);

    final mediaQuery = MediaQuery.sizeOf(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 840, maxHeight: mediaQuery.height * 0.92),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(context.responsiveSize(12, 16)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.secondaryBrandNavy.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: EdgeInsets.all(context.responsiveSize(20, 28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          SizedBox(height: context.responsiveHeight(16, 20)),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUploadGrid(context),
                  SizedBox(height: context.responsiveHeight(16, 20)),
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

  Widget _buildHeader(BuildContext context) {
    final String resolvedTitle = entityTitle != null && entityTitle!.trim().isNotEmpty
        ? entityTitle!.trim()
        : (uploadType.isNotEmpty ? '${uploadType[0].toUpperCase()}${uploadType.substring(1)}' : 'Asset');
    final String resolvedCode = 'Code: ${entityCode.trim()} (${uploadType.toUpperCase()})';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSize(8, 10)),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.responsiveSize(8, 10)),
                ),
                child: Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBrandOrange, size: context.responsiveSize(20, 24)),
              ),
              SizedBox(width: context.responsiveWidth(12, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Assets: $resolvedTitle',
                      style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(16, 18), fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$resolvedCode • Web Banner (16:9) & Mobile Icon (1:1)',
                      style: context.subTitleStyle.copyWith(
                        fontSize: context.responsiveSize(11, 12),
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
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
          icon: const Icon(Icons.close_rounded),
          splashRadius: 20,
          tooltip: 'Close',
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

  Widget _buildUploadGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isStacked = constraints.maxWidth < 650;
        if (isStacked) {
          return Column(
            children: [
              _buildDropzone(
                context: context,
                title: 'Website Image',
                specLabel: '16:9 Banner (Min 800x450 px, Max 2MB)',
                isMobile: false,
                bytesRx: controller.webImageBytes,
                fileNameRx: controller.webImageFileName,
                errorRx: controller.webImageError,
                uploadedUrlRx: controller.uploadedWebImageUrl,
              ),
              SizedBox(height: context.responsiveHeight(16, 16)),
              _buildDropzone(
                context: context,
                title: 'Mobile App Image',
                specLabel: '1:1 Square (Min 300x300 px, Max 1MB)',
                isMobile: true,
                bytesRx: controller.mobileImageBytes,
                fileNameRx: controller.mobileImageFileName,
                errorRx: controller.mobileImageError,
                uploadedUrlRx: controller.uploadedMobileImageUrl,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropzone(
                context: context,
                title: 'Website Image',
                specLabel: '16:9 Banner (Min 800x450 px, Max 2MB)',
                isMobile: false,
                bytesRx: controller.webImageBytes,
                fileNameRx: controller.webImageFileName,
                errorRx: controller.webImageError,
                uploadedUrlRx: controller.uploadedWebImageUrl,
              ),
            ),
            SizedBox(width: context.responsiveWidth(16, 20)),
            Expanded(
              child: _buildDropzone(
                context: context,
                title: 'Mobile App Image',
                specLabel: '1:1 Square (Min 300x300 px, Max 1MB)',
                isMobile: true,
                bytesRx: controller.mobileImageBytes,
                fileNameRx: controller.mobileImageFileName,
                errorRx: controller.mobileImageError,
                uploadedUrlRx: controller.uploadedMobileImageUrl,
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
    return Obx(() {
      final Uint8List? bytes = bytesRx.value;
      final String? fileName = fileNameRx.value;
      final String uploadedUrl = uploadedUrlRx.value;
      final String validationError = errorRx.value;
      final bool hasSelection = bytes != null && bytes.isNotEmpty;
      final bool isUploaded = uploadedUrl.isNotEmpty;
      final bool hasError = validationError.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.surface,
          borderRadius: context.responsiveRadius(10, 12),
          border: Border.all(
            color: hasError
                ? AppColors.error
                : (isUploaded ? Colors.green.shade400 : (hasSelection ? AppColors.primaryBrandOrange : AppColors.borderLight)),
            width: hasSelection || isUploaded || hasError ? 1.5 : 1.0,
          ),
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
                  style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(13, 14), fontWeight: FontWeight.w600),
                ),
                if (isUploaded)
                  Container(
                    padding: const .symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Linked',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  )
                else if (hasSelection)
                  InkWell(
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
                        style: TextStyle(fontSize: context.responsiveSize(11, 12), color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.responsiveHeight(4, 6)),
            Text(
              specLabel,
              style: context.subTitleStyle.copyWith(
                fontSize: context.responsiveSize(11, 12),
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: context.responsiveHeight(12, 14)),
            InkWell(
              borderRadius: BorderRadius.circular(context.responsiveSize(8, 10)),
              onTap: () => controller.pickImage(isMobile: isMobile),
              child: Container(
                height: context.responsiveHeight(140, 160),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(context.responsiveSize(8, 10)),
                  border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasSelection
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(bytes, fit: isMobile ? BoxFit.contain : BoxFit.cover),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.65),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              child: Text(
                                fileName ?? 'Selected Asset',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
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
                            color: AppColors.primaryBrandOrange.withValues(alpha: 0.7),
                          ),
                          SizedBox(height: context.responsiveHeight(8, 10)),
                          Text(
                            'Click to select asset',
                            style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(12, 13), fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: context.responsiveHeight(2, 4)),
                          Text(
                            'Supported: JPG, PNG, WEBP',
                            style: context.subTitleStyle.copyWith(
                              fontSize: context.responsiveSize(10, 11),
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: context.responsiveHeight(8, 10)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        validationError,
                        style: TextStyle(color: AppColors.error, fontSize: context.responsiveSize(10, 11), fontWeight: FontWeight.w500),
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

  Widget _buildServerResponseStatus(BuildContext context) {
    return Obx(() {
      final String msg = controller.uploadStatusMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(12, 14), vertical: context.responsiveHeight(8, 10)),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.responsiveSize(6, 8)),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 18),
            SizedBox(width: context.responsiveWidth(8, 10)),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(fontSize: context.responsiveSize(12, 13), color: Colors.green.shade800, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFooterActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
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
          child: Text('Reset / Cancel', style: TextStyle(fontSize: context.responsiveSize(13, 14))),
        ),
        SizedBox(width: context.responsiveWidth(12, 16)),
        Obx(() {
          final bool hasSelection =
              (controller.webImageBytes.value != null && controller.webImageBytes.value!.isNotEmpty) ||
              (controller.mobileImageBytes.value != null && controller.mobileImageBytes.value!.isNotEmpty);
          return ElevatedButton.icon(
            onPressed: hasSelection ? () => controller.uploadImages() : null,
            icon: const Icon(Icons.cloud_upload, size: 18),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrandOrange,
              padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(18, 24), vertical: context.responsiveHeight(12, 16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.responsiveSize(8, 10))),
            ),
          );
        }),
      ],
    );
  }
}
