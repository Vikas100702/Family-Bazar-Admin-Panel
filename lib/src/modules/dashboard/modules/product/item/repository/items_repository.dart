import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/insert_item_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ItemRepository {
  final ApiClient _apiClient;
  const ItemRepository({required this._apiClient});

  Future<ViewItemByTypeModel> viewItems() async {
    const String endpoint = ApiConstants.viewItemsByTypeApiEndpoint;
    final Map<String, dynamic> payload = <String, dynamic>{'type': 'ITEM', 'isAdmin': '1'};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemByTypeModel.fromJson(responseData);
      }

      throw FormatException('[ItemRepository.viewItems]: Invalid data format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('viewItems', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<InsertItemDetailsModel> addItemDetails({required String itemCode, required String mImg, required String wImg}) async {
    const String endpoint = ApiConstants.insertItemDetailsApiEndpoint;
    final String trimmedItemCode = itemCode.trim();
    final String trimmedMImg = mImg.trim();
    final String trimmedWImg = wImg.trim();

    if (trimmedItemCode.isEmpty) {
      throw ArgumentError('Item code cannot be empty.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{'I_Code': trimmedItemCode, 'w_img': trimmedWImg, 'm_img': trimmedMImg};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return InsertItemDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw FormatException('[ItemRepository.addItemDetails]: Invalid response format received from $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('addItemDetails', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  Future<ViewItemByTypeDatum> updateItem({required String itemCode, int? status}) async {
    const String endpoint = ApiConstants.updateItemApiEndpoint;
    final String trimmedCode = itemCode.trim();

    if (trimmedCode.isEmpty) {
      throw ArgumentError('Item code cannot be empty.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{'itemCode': trimmedCode, 'status': ?status};

    try {
      final Response<dynamic> response = await _apiClient.dio.post(endpoint, data: payload);

      if (response.data != null &&
          response.data is Map<String, dynamic> &&
          response.data['data'] != null &&
          response.data['data'] is Map<String, dynamic>) {
        return ViewItemByTypeDatum.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw FormatException('[ItemRepository.updateItem]: Invalid response format received from endpoint: $endpoint');
    } catch (e, stackTrace) {
      _captureSentryError('updateItem', endpoint, e, stackTrace, payload: payload);
      rethrow;
    }
  }

  void _captureSentryError(String action, String endpoint, Object error, StackTrace stackTrace, {Map<String, dynamic>? payload}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'ItemRepository.$action failed on $endpoint',
        category: 'product.item.repository',
        level: SentryLevel.error,
        data: <String, dynamic>{
          'action': action,
          'endpoint': endpoint,
          if (error is DioException) 'status_code': error.response?.statusCode,
          'payload': ?payload,
        },
      ),
    );

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'item');
        scope.setTag('repository', 'ItemRepository');
        scope.setTag('action', action);
        scope.setContexts('network_context', <String, dynamic>{
          'endpoint': endpoint,
          if (error is DioException) ...<String, dynamic>{
            'status_code': error.response?.statusCode,
            'response_data': error.response?.data?.toString(),
          },
          'payload': ?payload,
        });
      },
    );
  }
}
