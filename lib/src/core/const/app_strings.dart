import 'package:flutter/foundation.dart';

@immutable
abstract final class AppStrings {
  const AppStrings._();

  /// GENERAL
  static const String appName = "Family Bazar Admin Panel";
  static const String close = "Close";
  static const String cancel = "Cancel";
  static const String confirm = "Confirm";
  static const String alert = "Alert!";
  static const String success = "Success";
  static const String retry = "Retry";

  /// AUTH
  static const String adminLogin = "Admin Login";
  static const String welcomeMsg = "Welcome Back";
  static const String username = "Username";
  static const String password = "Password";
  static const String selectRole = "Select Role";
  static const String login = "LOGIN";
  static const String requiredField = "Required";
  static const String loginDisclaimer = '''By logging in you agree to record your IP and location info for security reason.''';

  /// DRAWER (Newly Added)
  static const String superAdminRole = "Super Admin Role";
  static const String appVersion = "Version 1.0.0";
  static const String failedToLoadIcon = "Failed to load icon image";
  static const String drawerMenuIconLoadFailure = "Drawer Menu Icon Load Failure:";

  /// Exception Messages
  static const String socketException = "SocketException: No internet connection";
  static const String exceptionCaught = "Exception caught while fetching data from API";
  static const String exceptionVerifyAuthCode = "Exception while verifying auth code:";
  static const String exception2FACode = "Exception while sending 2FA code:";
  static const String exceptionVerify2FACode = "Exception while verifying 2FA code:";

  /// Timeout Messages
  static const String connectionTimeout = 'We\'re having trouble reaching our servers. Please check your Wi-Fi or cellular data.';
  static const String receiveTimeout = 'Looks like the server is a bit slow today. Give it a moment and try again.';
  static const String sendTimeout = 'We couldn\'t send your request. Please check your network stability and try again.';

  /// Connection Error Messages
  static const String noInternet = "No internet connection. Please check your network.";
  static const String unexpectedError = "An unexpected error occurred. Please try again.";
  static const String somethingWentWrong = "Something went wrong. Please try again.";
  static const String emptyData = "Server returned empty data";

  /// HTTP Code Messages
  static const String errorCode = "Error Code";
  static const String msg400 = "Bad Request. Please check your input.";
  static const String msg401 = "Unauthorized. Please login again.";
  static const String msg403 = "Forbidden. You don't have permission to access this resource.";
  static const String msg404 = "Not Found. The requested resource was not found.";
  static const String msg405 = "Method Not Allowed. The requested method is not allowed.";
  static const String msg406 = "Input format mismatched or unacceptable.";
  static const String msg408 = "Request Timeout. The request took too long to respond.";
  static const String msg409 = "Conflict. Data already exists.";
  static const String msg413 = "Payload Too Large. Request entity is too large.";
  static const String msg415 = "Unsupported Media Type. Unsupported media type in request.";
  static const String msg422 = "Unprocessable Entity. Invalid input. Cannot proceed with the provided data.";
  static const String msg429 = "Too Many Requests. Rate limit exceeded.";
  static const String msg499 = "Request to API server was cancelled.";
  static const String msg500 = "Internal Server Error. Please try again later.";
  static const String msg502 = "Bad Gateway. Gateway is unavailable.";
  static const String msg503 = "Service Unavailable. Server is temporarily unavailable.";
  static const String msg504 = "Gateway Timeout. Gateway took too long to respond.";
  static const String msg505 = "HTTP Version Not Supported. Client is using an unsupported version of HTTP.";
  static const String msg522 = "Connection Timed Out. It is taking too long to connect to the server.";
  static const String errorMsgDefault = "Error while communicating with server";
}