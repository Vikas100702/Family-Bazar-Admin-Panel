import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class AppSingleImageTableCell extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final String uploadButtonLabel;
  final String tooltipMessage;
  final double previewWidth;
  final double previewHeight;
  final bool isLoading;

  const AppSingleImageTableCell({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.uploadButtonLabel = 'Upload',
    this.tooltipMessage = 'Click to replace image',
    this.previewWidth = 50.0,
    this.previewHeight = 26.0,
    this.isLoading = false,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: previewWidth,
        height: previewHeight,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
        ),
      );
    }

    if (!_hasImage) {
      return _buildEmptyUploadButton(context);
    }

    return _buildThumbnailPreview(context);
  }

  Widget _buildEmptyUploadButton(BuildContext context) {
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: context.responsiveRadius(4, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryRed.withValues(alpha: 0.08),
          borderRadius: context.responsiveRadius(4, 6),
          border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 15, color: AppColors.primaryRed),
            const SizedBox(width: 4),
            Text(
              uploadButtonLabel,
              style: context.captionStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryRed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPreview(BuildContext context) {
    final bool isDark = context.isDark;
    final String resolvedUrl = ApiConstants.resolveImageUrl(imageUrl);

    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: context.responsiveRadius(4, 6),
      child: Tooltip(
        message: tooltipMessage,
        waitDuration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: context.responsiveRadius(4, 6),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: resolvedUrl,
                  width: previewWidth,
                  height: previewHeight,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => SizedBox(
                    width: previewWidth,
                    height: previewHeight,
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => const Icon(Icons.broken_image_rounded, size: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.edit_outlined, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
            ],
          ),
        ),
      ),
    );
  }
}
