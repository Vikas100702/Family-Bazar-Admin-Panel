import 'dart:async';

import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final Duration debounceDuration;
  final double width;
  final double height;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Search records...',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.width = 260.0,
    this.height = 42.0,
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _effectiveController;
  bool _isInternalController = false;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initController();
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChanged);
  }

  void _initController() {
    if (widget.controller != null) {
      _effectiveController = widget.controller!;
      _isInternalController = false;
    } else {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    }
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      if (_isInternalController) {
        _effectiveController.dispose();
      }
      _initController();
      _hasText = _effectiveController.text.isNotEmpty;
      _effectiveController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    final bool hasText = _effectiveController.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleChanged(String value) {
    if (widget.onChanged == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(value.trim());
    });
  }

  void _handleClear() {
    _effectiveController.clear();
    _debounceTimer?.cancel();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _effectiveController.removeListener(_onTextChanged);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextField(
        controller: _effectiveController,
        autofocus: widget.autofocus,
        onChanged: _handleChanged,
        onSubmitted: widget.onSubmitted,
        style: context.bodyTextStyle.copyWith(fontSize: 13, color: isDark ? AppColors.textPrimaryWhite : AppColors.textPrimarySlate),
        cursorColor: AppColors.primaryRed,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: context.captionStyle.copyWith(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondarySlate,
                  splashRadius: 16,
                  tooltip: 'Clear Search',
                  onPressed: _handleClear,
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
        ),
      ),
    );
  }
}
