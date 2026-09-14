import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final dynamic statusValue;
  final bool? isActive; // Optional explicit boolean override.
  final bool isEditable;
  final bool isLoading;
  final ValueChanged<bool>? onToggle;
  final String activeLabel;
  final String inactiveLabel;
  final Color activeColor;
  final Color inactiveColor;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool showLabelInEditable;

  const StatusBadge({
    super.key,
    this.statusValue,
    this.isActive,
    this.isEditable = false,
    this.isLoading = false,
    this.onToggle,
    this.activeLabel = 'Active',
    this.inactiveLabel = 'Inactive',
    this.activeColor = AppColors.statusGreenSuccess,
    this.inactiveColor = AppColors.statusRedError,
    this.activeIcon = Icons.check_circle_rounded,
    this.inactiveIcon = Icons.cancel_rounded,
    this.showLabelInEditable = true,
  });

  bool get _resolvedActiveState {
    if (isActive != null) return isActive!;
    if (statusValue == null) return false;
    if (statusValue is bool) return statusValue as bool;
    if (statusValue is num) return statusValue == 1;

    final String strVal = statusValue.toString().trim().toLowerCase();
    return strVal == '1' || strVal == 'true' || strVal == 'y' || strVal == 'active';
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _resolvedActiveState;

    if (isEditable) {
      return _buildEditableToggle(context, active);
    }
    return _buildViewOnlyBadge(context, active);
  }

  Widget _buildViewOnlyBadge(BuildContext context, bool active) {
    final Color color = active ? activeColor : inactiveColor;
    final String label = active ? activeLabel : inactiveLabel;
    final IconData icon = active ? activeIcon : inactiveIcon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableToggle(BuildContext context, bool active) {
    final Color color = active ? activeColor : inactiveColor;
    final String label = active ? activeLabel : inactiveLabel;

    return InkWell(
      onTap: (isLoading || onToggle == null) ? null : () => onToggle!(!active),
      mouseCursor: (isLoading || onToggle == null) ? SystemMouseCursors.basic : SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Toggle Switch
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 32,
              height: 18,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: active ? color : Colors.grey.withValues(alpha: 0.35)),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(active ? Colors.white : color)),
                      ),
                    )
                  : Align(
                      alignment: active ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                        ),
                      ),
                    ),
            ),
            if (showLabelInEditable) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
