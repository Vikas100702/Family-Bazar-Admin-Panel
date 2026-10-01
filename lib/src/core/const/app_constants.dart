import 'package:flutter/foundation.dart';

@immutable
abstract final class AppConstants {
  const AppConstants._();

  /// UI BREAKPOINTS
  static const double mobileBreakpoint = 700.0;
  static const double tabletBreakpoint = 1200.0;

  /// API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Auth
  static const String authTokenKey = 'auth_token';
}
