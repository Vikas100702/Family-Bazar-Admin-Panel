import 'package:flutter/material.dart';

@immutable
class DrawerMenuModel {
  final String title;
  final String identifier; // The raw key from API (e.g., 'productCategory')
  final String? icon; // API Image URL
  final IconData? fallbackIcon; // For static items (Dashboard) or error fallbacks
  final List<DrawerMenuModel> subItems;
  final bool isExpansion;

  const DrawerMenuModel({
    required this.title,
    required this.identifier,
    this.icon,
    this.fallbackIcon,
    this.subItems = const <DrawerMenuModel>[],
    this.isExpansion = false,
  });

  /// Defensive helper to prevent bang-operator force unwraps in presentation widgets
  bool get hasSubItems => isExpansion && subItems.isNotEmpty;

  DrawerMenuModel copyWith({
    String? title,
    String? identifier,
    String? icon,
    IconData? fallbackIcon,
    List<DrawerMenuModel>? subItems,
    bool? isExpansion,
  }) {
    return DrawerMenuModel(
      title: title ?? this.title,
      identifier: identifier ?? this.identifier,
      icon: icon ?? this.icon,
      fallbackIcon: fallbackIcon ?? this.fallbackIcon,
      subItems: subItems ?? this.subItems,
      isExpansion: isExpansion ?? this.isExpansion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawerMenuModel &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          title == other.title &&
          isExpansion == other.isExpansion;

  @override
  int get hashCode => Object.hash(identifier, title, isExpansion);

  @override
  String toString() => 'DrawerMenuModel(title: $title, identifier: $identifier, isExpansion: $isExpansion, subItemsCount: ${subItems.length})';
}
