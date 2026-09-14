import 'package:dio/dio.dart';
import 'package:family_bazar_admin_panel/src/core/const/api_constants.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/insert_item_details_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ItemRepository {
  final ApiClient _apiClient;
  const ItemRepository({required this._apiClient});

  Future<ViewItemModel> viewItems() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.viewItemsApiEndpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return ViewItemModel.fromJson(responseData);
      }
      throw FormatException('[ItemRepository.viewItems]: Invalid data format received from endpoint: ${ApiConstants.viewItemsApiEndpoint}');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed to fetch or parse Item list',
          category: 'item.repository',
          level: SentryLevel.error,
          data: {'endpoint': ApiConstants.viewItemsApiEndpoint, 'error': e.toString()},
        ),
      );

      if (e is! DioException) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('repository', 'ItemRepository');
            scope.setTag('action', 'viewItems');
          },
        );
      }
      rethrow;
    }
  }

  Future<InsertItemDetailsModel> addItemDetails({required String itemCode, required String mImg, required String wImg}) async {
    final String trimmedItemCode = itemCode.trim();
    final String trimmedMImg = mImg.trim();
    final String trimmedWImg = wImg.trim();

    if (trimmedItemCode.isEmpty) {
      throw ArgumentError('Item code cannot be empty.');
    }

    final Map<String, dynamic> payload = {'I_Code': trimmedItemCode, 'w_img': trimmedWImg, 'm_img': trimmedMImg};
    try {
      final response = await _apiClient.dio.post(ApiConstants.insertItemDetailsApiEndpoint, data: payload);

      if (response.data != null && response.data is Map<String, dynamic>) {
        return InsertItemDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const FormatException('Invalid response format received from addItemDetails.');
    } catch (e, stackTrace) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Failed executing item image association',
          category: 'ItemRepository.addItem',
          level: SentryLevel.error,
          data: {'I_Code': itemCode, 'has_w_img': wImg.isNotEmpty, 'has_m_img': mImg.isNotEmpty},
        ),
      );

      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', 'ItemRepository');
          scope.setContexts('item_association', {'I_Code': itemCode});
        },
      );

      rethrow;
    }
  }
}
