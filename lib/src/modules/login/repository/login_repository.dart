import 'dart:async';

import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/login/model/login_model/login_model.dart';
import 'package:family_bazar_admin_panel/src/modules/login/model/role_type_model/role_type_model.dart';
import 'package:family_bazar_admin_panel/src/modules/login/model/token_model/token_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoginRepository {
  final ApiClient _apiClient;
  const LoginRepository({required this._apiClient});

  Future<GetTokenModel> fetchToken() async {
    try {
      Sentry.addBreadcrumb(Breadcrumb(message: 'Initiating fetchToken API call', category: 'auth.repository', level: SentryLevel.info));
      final response = await _apiClient.dio.post(ApiConstants.tokenApiEndpoint);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final tokenModel = GetTokenModel.fromJson(response.data as Map<String, dynamic>);
        if (tokenModel.status == true && tokenModel.token.isNotEmpty) {
          return tokenModel;
        } else {
          throw Exception(tokenModel.message.isNotEmpty ? tokenModel.message : '[Token API]: Failed to generate valid handshake token');
        }
      } else {
        throw FormatException("[Token API]: ${AppStrings.emptyData}");
      }
    } catch (e, stackTrace) {
      _logRepositoryException(exception: e, stackTrace: stackTrace, endpoint: ApiConstants.tokenApiEndpoint, action: 'fetchToken');
      rethrow;
    }
  }

  Future<GetRoleModel> fetchRoleTypes() async {
    try {
      Sentry.addBreadcrumb(Breadcrumb(message: 'Initiating fetchRoleTypes API call', category: 'auth.repository', level: SentryLevel.info));

      final response = await _apiClient.dio.post(ApiConstants.roleApiEndpoint);
      if (response.data != null) {
        return GetRoleModel.fromJson(response.data);
      } else {
        throw Exception("[Role Types]: ${AppStrings.emptyData}");
      }
    } catch (e, stackTrace) {
      if (e is! DioException) {
        Sentry.captureException(
          Exception('Failed to parse Role Types JSON: $e'),
          stackTrace: stackTrace,
          withScope: (scope) => scope.setTag('layer', 'login_repository'),
        );
      }
      rethrow;
    }
  }

  Future<LoginModel> fetchLoginUser({
    required String username,
    required String password,
    required String firebaseToken,
    required String latitude,
    required String longitude,
    required String loginDate,
    required String loginTime,
  }) async {
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Initiating loginUser API call for user: $username',
          category: 'auth.repository',
          level: SentryLevel.info,
          data: {'username': username},
        ),
      );

      final response = await _apiClient.dio.post(
        ApiConstants.loginApiEndpoint,
        data: {
          "username": username,
          "password": password,
          "firebase_token": firebaseToken,
          "latitude": latitude,
          "longitude": longitude,
          "login_date": loginDate,
          "login_time": loginTime,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        final result = LoginModel.fromJson(response.data as Map<String, dynamic>);

        if (result.status == true) {
          return result;
        } else {
          throw Exception(result.message); // Backend returned 200 OK but rejected login credentials or parameters
        }
      } else {
        throw FormatException("[Login API]: ${AppStrings.emptyData}");
      }
    } catch (e, stackTrace) {
      _logRepositoryException(exception: e, stackTrace: stackTrace, endpoint: ApiConstants.loginApiEndpoint, action: 'fetchLoginUser');
      rethrow;
    }
  }

  void _logRepositoryException({required Object exception, required StackTrace stackTrace, required String endpoint, required String action}) {
    if (exception is! DioException) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('layer', 'login_repository');
          scope.setTag('action', action);
          scope.setTag('endpoint', endpoint);
          scope.setContexts('Repository_Error_Details', {
            'error_type': exception.runtimeType.toString(),
            'error_message': exception.toString(),
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
        },
      );
    }
  }
}
