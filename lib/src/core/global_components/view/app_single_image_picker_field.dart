import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppSingleImagePickerField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Uint8List? selectedBytes;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final double height;
  final String placeholderText;

  const AppSingleImagePickerField({
    super.key,
    this.label = 'Banner Image',
    this.isRequired = true,
    required this.selectedBytes,
    required this.existingImageUrl,
    required this.onPickImage,
    required this.onClearImage,
    this.height = 120.0,
    this.placeholderText = 'Click to select image',
  });

  bool get _hasPickedBytes => selectedBytes != null && selectedBytes!.isNotEmpty;
  bool get _hasExistingUrl => existingImageUrl != null && existingImageUrl!.trim().isNotEmpty;
  bool get _hasAnyImage => _hasPickedBytes || _hasExistingUrl;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              isRequired ? '$label *' : label,
              style: context.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasDarkSlate : AppColors.surfaceSubtleGray,
            borderRadius: context.responsiveRadius(6, 8),
            border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [_buildImageSurface(context), if (_hasAnyImage) _buildFloatingControls(context)]),
        ),
      ],
    );
  }

  Widget _buildImageSurface(BuildContext context) {
    if (_hasPickedBytes) {
      return Center(
        child: Image.memory(selectedBytes!, fit: BoxFit.contain, width: double.infinity, height: height),
      );
    }

    if (_hasExistingUrl) {
      return Center(
        child: CachedNetworkImage(
          imageUrl: ApiConstants.resolveImageUrl(existingImageUrl),
          fit: BoxFit.contain,
          width: double.infinity,
          height: height,
          placeholder: (_, _) => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
            ),
          ),
          errorWidget: (_, _, _) => const Icon(Icons.broken_image_rounded, size: 32, color: Colors.grey),
        ),
      );
    }

    return Center(
      child: InkWell(
        onTap: onPickImage,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: context.responsiveRadius(6, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primaryRed),
            const SizedBox(height: 6),
            Text(placeholderText, style: context.captionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingControls(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
              tooltip: 'Change Image',
              mouseCursor: SystemMouseCursors.click,
              splashRadius: 16,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              onPressed: onPickImage,
            ),
            if (_hasPickedBytes) ...[
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.statusRedError),
                tooltip: 'Clear Selected Image',
                mouseCursor: SystemMouseCursors.click,
                splashRadius: 16,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: onClearImage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
