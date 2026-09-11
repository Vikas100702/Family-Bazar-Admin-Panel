import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class ComingSoonView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const ComingSoonView({super.key, required this.title, this.subtitle, this.icon = Icons.construction_rounded});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16, 24), vertical: context.responsiveHeight(20, 32)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, minHeight: 320),
          child: Container(
            padding: EdgeInsets.all(context.responsiveSize(24, 40)),
            decoration: context.defaultDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsiveSize(16, 22)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Icon(icon, size: context.responsiveSize(36, 48), color: AppColors.primaryRed),
                ),
                SizedBox(height: context.responsiveHeight(20, 28)),

                // Module Title
                Text(
                  title,
                  style: context.titleStyleActive.copyWith(fontSize: context.responsiveSize(18, 22), letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                Text(
                  subtitle ??
                      'This enterprise module is scheduled for release in an upcoming system deployment. Real-time data and configuration controls will be accessible here.',
                  style: context.subTitleStyle.copyWith(
                    fontSize: context.responsiveSize(13, 14),
                    color: isDark ? AppColors.textSecondaryMuted : AppColors.textSecondarySlate,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveHeight(20, 28)),

                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.accentGoldAmber, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Under Active Development',
                        style: context.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
