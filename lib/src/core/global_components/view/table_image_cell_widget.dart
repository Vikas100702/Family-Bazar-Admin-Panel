import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/binding/image_upload_binding.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/widget/image_upload_widget.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef LinkEntityCallback = Future<bool> Function({required String entityCode, required String webImageUrl, required String mobileImageUrl});

class TableImageCellWidget extends StatelessWidget {
  final String webImageUrl;
  final String mobileImageUrl;
  final String uploadType;
  final String entityCode;
  final String entityTitle;
  final LinkEntityCallback onLinkEntity;
  final VoidCallback? onSuccess;

  const TableImageCellWidget({
    super.key,
    required this.webImageUrl,
    required this.mobileImageUrl,
    required this.uploadType,
    required this.entityCode,
    required this.entityTitle,
    required this.onLinkEntity,
    this.onSuccess,
  });

  bool get _hasWebImg => webImageUrl.trim().isNotEmpty;
  bool get _hasMobileImg => mobileImageUrl.trim().isNotEmpty;
  bool get _hasAnyImage => _hasWebImg || _hasMobileImg;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (!_hasAnyImage) {
      return InkWell(
        onTap: () => _openImageUploadModal(context),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 15, color: AppColors.primaryRed),
              SizedBox(width: 4),
              Text(
                'Upload',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryRed),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openImageUploadModal(context),
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Tooltip(
        message: 'Click to view / update media assets',
        waitDuration: const Duration(milliseconds: 400),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniThumbnail(
                imageUrl: webImageUrl,
                width: 40,
                height: 24,
                placeholderIcon: Icons.desktop_mac_rounded,
                tooltipLabel: 'Web Banner',
              ),
              const SizedBox(width: 6),
              _buildMiniThumbnail(
                imageUrl: mobileImageUrl,
                width: 24,
                height: 24,
                placeholderIcon: Icons.phone_android_rounded,
                tooltipLabel: 'Mobile Icon',
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, size: 13, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniThumbnail({
    required String imageUrl,
    required double width,
    required double height,
    required IconData placeholderIcon,
    required String tooltipLabel,
  }) {
    final bool hasImage = imageUrl.trim().isNotEmpty;
    final String resolvedUrl = _resolveImageUrl(imageUrl);

    return Tooltip(
      message: tooltipLabel,
      waitDuration: const Duration(milliseconds: 300),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(placeholderIcon, size: 12, color: Colors.grey),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5))),
              )
            : Icon(placeholderIcon, size: 12, color: Colors.grey.shade400),
      ),
    );
  }

  static String _resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    const String baseDomain = ApiConstants.baseUrl;
    return '$baseDomain${path.startsWith('/') ? '' : '/'}$path';
  }

  void _openImageUploadModal(BuildContext context) {
    ImageUploadBinding().dependencies();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16, 24), vertical: context.responsiveSize(16, 24)),
        child: ImageUploadView(
          uploadType: uploadType,
          entityCode: entityCode,
          entityTitle: entityTitle,
          initialWebImageUrl: webImageUrl,
          initialMobileImageUrl: mobileImageUrl,
          onLinkEntity: onLinkEntity,
          onSuccess: onSuccess,
          onDismiss: () => Get.back(),
        ),
      ),
    );
  }
}
