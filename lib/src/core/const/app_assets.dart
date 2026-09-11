import 'package:flutter/foundation.dart';

@immutable
abstract final class AppAssets {
  const AppAssets._();

  /// Base paths
  static const String _baseImagePath = 'assets/images';

  /// Branding Assets
  static const String appLogo = '$_baseImagePath/app_logo.png';
  static const String groceryPromoHero = '$_baseImagePath/grocery_promo_hero.png';
  static const String adminSignInBanner = '$_baseImagePath/admin_sign_in_banner.png';
  static const String signInBanner = '$_baseImagePath/sign_in_banner.png';
}
