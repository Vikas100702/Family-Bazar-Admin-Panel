import 'package:flutter/material.dart';

@immutable
class DrawerMenuModel {
  final String title;
  final String identifier; // The raw key from API (e.g., 'masterCategory')
  final String? icon; // API Image URL
  final IconData? fallbackIcon; // For static items (Dashboard) or error fallbacks
  final List<DrawerMenuModel>? subItems;
  final bool isExpansion;

  const DrawerMenuModel({
    required this.title,
    required this.identifier,
    this.icon,
    this.fallbackIcon,
    this.subItems,
    this.isExpansion = false,
  });

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
}