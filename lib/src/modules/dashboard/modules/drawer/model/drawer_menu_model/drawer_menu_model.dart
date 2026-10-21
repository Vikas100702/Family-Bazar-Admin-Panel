import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class DrawerMenuModel {
  final String title;
  final String identifier; // Raw route/permission key (e.g. 'category', 'item')
  final String? icon; // Remote network image asset URL
  final IconData? fallbackIcon; // Semantic fallback icon
  final List<DrawerMenuModel> subItems;
  final bool isExpansion;

  DrawerMenuModel({
    required this.title,
    required this.identifier,
    this.icon,
    this.fallbackIcon,
    List<DrawerMenuModel> subItems = const <DrawerMenuModel>[],
    this.isExpansion = false,
  }) : subItems = List<DrawerMenuModel>.unmodifiable(subItems);

  const DrawerMenuModel.empty()
    : title = '',
      identifier = '',
      icon = null,
      fallbackIcon = null,
      subItems = const <DrawerMenuModel>[],
      isExpansion = false;

  /// Defensive helper to determine if expandable sub-items exist.
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
      subItems: subItems != null ? List<DrawerMenuModel>.unmodifiable(subItems) : this.subItems,
      isExpansion: isExpansion ?? this.isExpansion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawerMenuModel &&
        runtimeType == other.runtimeType &&
        identifier == other.identifier &&
        title == other.title &&
        icon == other.icon &&
        fallbackIcon == other.fallbackIcon &&
        isExpansion == other.isExpansion &&
        listEquals(subItems, other.subItems);
  }

  @override
  int get hashCode => Object.hash(identifier, title, icon, fallbackIcon, isExpansion, Object.hashAll(subItems));

  @override
  String toString() => 'DrawerMenuModel(title: $title, identifier: $identifier, isExpansion: $isExpansion, subItemsCount: ${subItems.length})';
}
