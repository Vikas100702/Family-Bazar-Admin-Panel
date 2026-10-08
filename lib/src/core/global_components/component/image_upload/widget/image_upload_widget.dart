import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/controller/image_upload_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageUploadView extends GetView<ImageUploadController> {
  final VoidCallback? onDismiss;
  final String entityCode;
  final String? entityTitle;
  final String uploadType;
  final VoidCallback? onSuccess;
  final String? initialWebImageUrl;
  final String? initialMobileImageUrl;
  final List<String>? initialSecondaryUrls;
  final List<String>? initialInformationUrls;

  const ImageUploadView({
    super.key,
    required this.entityCode,
    this.entityTitle,
    this.uploadType = '',
    this.onSuccess,
    this.onDismiss,
    this.initialWebImageUrl,
    this.initialMobileImageUrl,
    this.initialSecondaryUrls,
    this.initialInformationUrls,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.configureEntity(
        entityCode: entityCode,
        type: uploadType,
        onSuccess: onSuccess,
        initialWebImageUrl: initialWebImageUrl,
        initialMobileImageUrl: initialMobileImageUrl,
        initialSecondaryUrls: initialSecondaryUrls,
        initialInformationUrls: initialInformationUrls,
      );
    });

    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 840, maxHeight: context.screenHeight * 0.92),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedSlate : AppColors.surfaceWhite,
        borderRadius: context.responsiveRadius(12, 16),
        border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
      ),
      padding: EdgeInsets.all(context.responsiveSize(16, 22)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainUploadGrid(context),
                  const SizedBox(height: 16),
                  _buildCompactMultiImageSection(
                    context: context,
                    title: 'Secondary Images (Max 5)',
                    isSecondary: true,
                    bytesListRx: controller.secondaryBytesList,
                    urlsListRx: controller.uploadedSecondaryUrls,
                  ),
                  const SizedBox(height: 16),
                  _buildCompactMultiImageSection(
                    context: context,
                    title: 'Informational Images (Max 5)',
                    isSecondary: false,
                    bytesListRx: controller.informationBytesList,
                    urlsListRx: controller.uploadedInformationUrls,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFooterActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String resolvedTitle = entityTitle?.trim().isNotEmpty == true ? entityTitle!.trim() : 'Asset';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Upload Media: $resolvedTitle ($entityCode)',
            style: context.titleStyleActive.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
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

  Widget _buildMainUploadGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMainTile(
            context,
            title: 'App Image (1:1)',
            isMobile: true,
            bytesRx: controller.mobileImageBytes,
            uploadedUrlRx: controller.uploadedMobileImageUrl,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMainTile(
            context,
            title: 'Web Image (16:9)',
            isMobile: false,
            bytesRx: controller.webImageBytes,
            uploadedUrlRx: controller.uploadedWebImageUrl,
          ),
        ),
      ],
    );
  }

  Widget _buildMainTile(
    BuildContext context, {
    required String title,
    required bool isMobile,
    required Rxn<Uint8List> bytesRx,
    required RxString uploadedUrlRx,
  }) {
    final isDark = context.isDark;

    return Obx(() {
      final bytes = bytesRx.value;
      final String uploadedUrl = uploadedUrlRx.value.trim();
      final bool hasPickedImage = bytes != null && bytes.isNotEmpty;
      final bool hasUploadedImage = uploadedUrl.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (hasPickedImage)
                InkWell(
                  onTap: () => bytesRx.value = null,
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 11, color: AppColors.statusRedError, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => controller.pickMainImage(isMobile: isMobile),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasPickedImage ? AppColors.primaryRed : (hasUploadedImage ? AppColors.statusGreenSuccess : AppColors.borderSubtleSlate),
                  width: hasPickedImage || hasUploadedImage ? 1.5 : 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasPickedImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(bytes, fit: isMobile ? BoxFit.contain : BoxFit.cover),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: const Text(
                              'Selected (Click to change)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    )
                  : (hasUploadedImage
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: _resolveImageUrl(uploadedUrl),
                                fit: isMobile ? BoxFit.contain : BoxFit.cover,
                                placeholder: (_, _) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed),
                                  ),
                                ),
                                errorWidget: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 24)),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: const Text(
                                    'Current Image (Click to replace)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 26),
                                SizedBox(height: 4),
                                Text('Click to upload', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          )),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCompactMultiImageSection({
    required BuildContext context,
    required String title,
    required bool isSecondary,
    required RxList<Uint8List> bytesListRx,
    required RxList<String> urlsListRx,
  }) {
    return Obx(() {
      final List<Uint8List> pickedList = bytesListRx.toList();
      final List<String> serverUrls = urlsListRx.toList();

      // Total existing slots = uploaded URLs + newly picked local files
      final int totalCount = serverUrls.length + pickedList.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$title ($totalCount/5)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (totalCount > 0)
                InkWell(
                  onTap: () {
                    bytesListRx.clear();
                    urlsListRx.clear();
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 11, color: AppColors.statusRedError, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final bool hasServerUrl = index < serverUrls.length;
              final int pickedIndex = index - serverUrls.length;
              final bool hasPickedBytes = !hasServerUrl && pickedIndex >= 0 && pickedIndex < pickedList.length;
              final bool hasItem = hasServerUrl || hasPickedBytes;

              return Expanded(
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: context.isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: hasItem ? AppColors.statusGreenSuccess : AppColors.borderSubtleSlate, width: hasItem ? 1.2 : 1.0),
                  ),
                  child: hasItem
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: hasPickedBytes
                                  ? Image.memory(pickedList[pickedIndex], fit: BoxFit.cover)
                                  : CachedNetworkImage(
                                      imageUrl: _resolveImageUrl(serverUrls[index]),
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => const Center(
                                        child: SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryRed),
                                        ),
                                      ),
                                      errorWidget: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, size: 16, color: Colors.grey)),
                                    ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () {
                                  if (hasServerUrl) {
                                    urlsListRx.removeAt(index);
                                  } else {
                                    controller.removeImageAtIndex(pickedIndex, isSecondary: isSecondary);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )
                      : (index == totalCount
                            ? InkWell(
                                onTap: () => controller.pickMultipleImage(isSecondary: isSecondary),
                                child: const Center(child: Icon(Icons.add, size: 20, color: Colors.grey)),
                              )
                            : const SizedBox.shrink()),
                ),
              );
            }),
          ),
        ],
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
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => controller.uploadImages(),
          icon: const Icon(Icons.cloud_upload_rounded, size: 16),
          label: const Text('Save & Link Media'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  static String _resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    const String baseDomain = ApiConstants.baseUrl;
    final String cleanBase = baseDomain.endsWith('/') ? baseDomain.substring(0, baseDomain.length - 1) : baseDomain;
    final String cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }
}

typedef ImageUploadWidget = ImageUploadView;
