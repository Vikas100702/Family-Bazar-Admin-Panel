import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin CommonDeleteMixin {
  ApiClient get apiClient;

  Future<CommonDeleteModel> executeDelete({required String tableName, required int id}) async {
    const String endpoint = ApiConstants.deleteApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'tablename': tableName.trim(), 'id': id.toString().trim()};

    try {
      final Response<dynamic> response = await apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return CommonDeleteModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[CommonDeleteMixin.executeDelete]: Unexpected response format received from $endpoint');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Common delete failed for table $tableName with id $id',
          category: 'repository.delete.error',
          level: SentryLevel.error,
          data: payload,
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (Scope scope) {
            scope.setTag('mixin', 'CommonDeleteMixin');
            scope.setTag('target_table', tableName);
            scope.setContexts('delete_payload', payload);
          },
        );
      }
      rethrow;
    }
  }
}
