import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final Widget? customAction;
  final bool isCard;
  final double maxWidth;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.iconColor = AppColors.primaryRed,
    this.actionLabel,
    this.actionIcon = Icons.refresh_rounded,
    this.onActionPressed,
    this.customAction,
    this.isCard = true,
    this.maxWidth = 420.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 40, color: iconColor),
        ),
        const SizedBox(height: 16),
        Text(title, style: context.titleStyleActive.copyWith(fontSize: 16), textAlign: TextAlign.center),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!.trim(),
            textAlign: TextAlign.center,
            style: context.subTitleStyle.copyWith(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate, height: 1.4),
          ),
        ],
        if (customAction != null) ...[
          const SizedBox(height: 20),
          customAction!,
        ] else if (actionLabel != null && onActionPressed != null) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: actionIcon != null ? Icon(actionIcon, size: 16) : const SizedBox.shrink(),
            label: Text(actionLabel!),
            style: ElevatedButton.styleFrom(
              enabledMouseCursor: SystemMouseCursors.click,
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ],
    );

    if (!isCard) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: content,
          ),
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: context.defaultDecoration,
        child: content,
      ),
    );
  }
}
