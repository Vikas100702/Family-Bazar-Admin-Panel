import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/view/app_search_field.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableHeaderWidget extends StatelessWidget {
  final String? title; // Optional module title.

  /// Search field configuration
  final bool showSearch;
  final String searchHintText;
  final double searchFieldWidth;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;

  /// Refresh button configuration
  final bool showRefresh;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final RxBool? rxIsRefreshing;
  final String refreshTooltip;

  final List<Widget>? extraActions; // Slot for extra module-specific action buttons
  final Widget? bottomWidget; // Slot for sub-header elements

  const TableHeaderWidget({
    super.key,
    this.title,
    this.showSearch = true,
    this.searchHintText = 'Search...',
    this.searchFieldWidth = 260,
    this.onSearchChanged,
    this.onSearchClear,
    this.showRefresh = true,
    this.onRefresh,
    this.isRefreshing = false,
    this.rxIsRefreshing,
    this.refreshTooltip = 'Refresh Data',
    this.extraActions,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMobile) _buildMobileLayout(context) else _buildDesktopLayout(context),
        if (bottomWidget != null) ...[const SizedBox(height: 12), bottomWidget!],
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null && title!.trim().isNotEmpty)
              Expanded(
                child: Text(title!.trim(), style: context.headingTextStyle.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis),
              )
            else
              const Spacer(),
            if (showRefresh && onRefresh != null) _buildMobileRefreshIcon(context, isDark),
          ],
        ),
        if (showSearch) ...[const SizedBox(height: 10), AppSearchField(hintText: searchHintText, onChanged: onSearchChanged, onClear: onSearchClear)],
        if (extraActions != null && extraActions!.isNotEmpty) ...[
          const SizedBox(height: 10),
          if (extraActions!.length == 1)
            SizedBox(width: double.infinity, child: extraActions!.first)
          else
            Row(
              children: [
                for (int i = 0; i < extraActions!.length; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: extraActions![i])],
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final isDark = context.isDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isConstrained = constraints.maxWidth < 980;

        final Widget actionsContent = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showSearch)
              AppSearchField(
                width: isConstrained ? 210 : searchFieldWidth,
                hintText: searchHintText,
                onChanged: onSearchChanged,
                onClear: onSearchClear,
              ),
            if (showSearch && (showRefresh || (extraActions != null && extraActions!.isNotEmpty))) const SizedBox(width: 10),
            if (showRefresh && onRefresh != null) ...[
              _buildDesktopRefreshButton(context),
              if (extraActions != null && extraActions!.isNotEmpty) const SizedBox(width: 10),
            ],
            if (extraActions != null)
              for (int i = 0; i < extraActions!.length; i++) ...[if (i > 0) const SizedBox(width: 10), extraActions![i]],
          ],
        );

        if (title != null && title!.trim().isNotEmpty) {
          if (isConstrained) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title!.trim(), style: context.headingTextStyle.copyWith(fontSize: 18)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: actionsContent),
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(title!.trim(), style: context.headingTextStyle.copyWith(fontSize: 20), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 16),
              actionsContent,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isConstrained)
              Expanded(
                child: SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: actionsContent),
              )
            else
              actionsContent,
          ],
        );
      },
    );
  }

  Widget _buildDesktopRefreshButton(BuildContext context) {
    if (rxIsRefreshing != null) {
      return Obx(() => _renderDesktopRefreshButton(rxIsRefreshing!.value));
    }
    return _renderDesktopRefreshButton(isRefreshing);
  }

  Widget _renderDesktopRefreshButton(bool loading) {
    return OutlinedButton.icon(
      onPressed: loading ? null : onRefresh,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
            )
          : const Icon(Icons.refresh_rounded, size: 18),
      label: Text(loading ? 'Refreshing...' : 'Refresh'),
      style: OutlinedButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildMobileRefreshIcon(BuildContext context, bool isDark) {
    if (rxIsRefreshing != null) {
      return Obx(() => _renderMobileRefreshIcon(rxIsRefreshing!.value, isDark));
    }
    return _renderMobileRefreshIcon(isRefreshing, isDark);
  }

  Widget _renderMobileRefreshIcon(bool loading, bool isDark) {
    return IconButton(
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
            )
          : const Icon(Icons.refresh_rounded, size: 20),
      mouseCursor: SystemMouseCursors.click,
      color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate,
      tooltip: refreshTooltip,
      onPressed: loading ? null : onRefresh,
    );
  }
}
