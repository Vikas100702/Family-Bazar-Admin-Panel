import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:family_bazar_admin_panel/src/core/utils/helpers/dialog_helper.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:sentry_flutter/sentry_flutter.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  late final Dio _externalDio;

  ApiClient._internal() {
    // 1. Internal Authenticated Dio Instance
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {'Content-Type': 'application/json', 'x-api-key': 'api@familybazar.com'},
      ),
    );

    // 2. Unauthenticated External Dio Instance (For third-party APIs like IPInfo)
    _externalDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // headers: {
        //   // 'Content-Type': 'application/json',
        //   // 'Accept': 'application/json',
        // },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message: 'API Request: ${options.method} ${options.path}',
                category: 'HTTP',
                data: {'url': options.uri.toString(), 'method': options.method},
              ),
            );

            // SECURITY LOCK: Only attach Bearer token if the request is going to our internal API host
            final isInternalRequest = options.uri.toString().startsWith(ApiConstants.baseUrl) || options.path.startsWith('/');

            if (isInternalRequest && Get.isRegistered<StorageService>()) {
              final StorageService storage = Get.find<StorageService>();
              final token = storage.getString('auth_token');

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (e, stackTrace) {
            Sentry.captureException(Exception('API Client Interceptor Auth Warning: $e'), stackTrace: stackTrace);
            debugPrint("--- [API CLIENT] Interceptor Auth Warning: $e ---");
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          Sentry.captureException(
            e,
            stackTrace: e.stackTrace,
            withScope: (scope) {
              scope.setTag('api_endpoint', e.requestOptions.path);
              scope.setContexts('API_Error_Details', {'statusCode': e.response?.statusCode, 'message': e.message});
            },
          );

          // Global 401 Unauthorized Routing & Dialog Stacking Protection
          if (e.response?.statusCode == 401) {
            try {
              if (Get.isRegistered<StorageService>()) {
                final StorageService storage = Get.find<StorageService>();
                await storage.clearAll();
              }

              // Ensure we don't stack multiple session expired redirects
              if (Get.currentRoute != '/auth') {
                Get.offAllNamed('/auth'); // Adjust to your exact AppRoutes.auth string

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DialogHelper.showError(title: 'Session Expired', message: 'Your session has expired. Please log in again to continue.');
                });
              }
            } catch (clearError, stackTrace) {
              Sentry.captureException(Exception('Failed to clear session on 401: $clearError'), stackTrace: stackTrace);
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Development Logging Interceptor
    _dio.interceptors.add(
      LogInterceptor(request: true, requestHeader: true, requestBody: true, responseHeader: false, responseBody: true, error: true),
    );
  }

  /// Use [dio] for all internal backend requests requiring authentication.
  Dio get dio => _dio;

  /// Use [externalDio] for third-party external services (e.g., IPInfo, public web hooks)
  /// to prevent leaking internal Authorization headers.
  Dio get externalDio => _externalDio;
}
