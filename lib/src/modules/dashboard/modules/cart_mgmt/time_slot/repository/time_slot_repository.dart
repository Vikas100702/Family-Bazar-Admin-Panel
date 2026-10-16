import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/model/time_slot_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TimeSlotRepository {
  final ApiClient _apiClient;

  const TimeSlotRepository({required this._apiClient});

  Future<TimeSlotResponseModel> getTimeSlots({int page = 1, int limit = 20, String? searchValue}) async {
    const String endpoint = ApiConstants.getTimeSlotsApiEndpoint;
    final String cleanSearch = searchValue?.trim() ?? '';

    final Map<String, dynamic> payload = {"searchvalue": cleanSearch, "page": page, "limit": limit};

    try {
      final Response response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return TimeSlotResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[TimeSlotRepository.getTimeSlots]: Invalid response envelope received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('getTimeSlots', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<TimeSlotResponseModel> addOrUpdateSlot({int? id, required String startTimeSlot, required String endTimeSlot}) async {
    const String endpoint = ApiConstants.addUpdateTimeSlotApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'id': ?id, 'starttimeslot': startTimeSlot.trim(), 'endtimeslot': endTimeSlot.trim()};

    try {
      final Response response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return TimeSlotResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[TimeSlotRepository.addOrUpdateSlot]: Invalid response envelope received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addOrUpdateSlot', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<CommonDeleteModel> deleteTimeSlot({required String slotId}) async {
    const String endpoint = ApiConstants.softDeleteTimeSlotsApiEndpoint;
    final Map<String, dynamic> payload = {'id': slotId};

    try {
      final response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return CommonDeleteModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[TimeSlotRepository.deleteTimeSlot]: Invalid response format received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('deleteTimeSlot', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'TimeSlotRepository.$action failed',
        category: 'time_slot.repository.network',
        level: SentryLevel.error,
        data: {'action': action, 'endpoint': endpoint, 'error': error.toString(), 'payload': ?payload},
      ),
    );

    if (error is! DioException) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'TimeSlotRepository');
          scope.setTag('action', action);
          if (payload != null) {
            scope.setContexts('request_payload', payload);
          }
        },
      );
    }
  }
}
