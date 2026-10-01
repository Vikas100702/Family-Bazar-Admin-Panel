import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ItemController extends BaseTableController<ViewItemByTypeDatum> {
  final ItemRepository _itemRepository;

  ItemController({required this._itemRepository});

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  String searchTokenBuilder(ViewItemByTypeDatum item) {
    return '${item.iCode} ${item.iName} ${item.iBarCode} ${item.iFirmCode} ${item.iItemGroup} ${item.itemGroupName} ${item.otherGroupName}';
  }

  Future<void> fetchItems() async {
    await runWithLoading(() async {
      try {
        final response = await _itemRepository.viewItems();
        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the item list from server.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'ItemController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching items.');
      }
    });
  }

  Future<bool> updateItems({required String itemCode, int? status}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final updatedDatum = await _itemRepository.updateItem(itemCode: itemCode, status: status);
        if (updatedDatum.iCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.iCode} updated successfully');
          await fetchItems();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateItem', {'itemCode': itemCode});
        errorMessage(message: 'Failed to update brand');
      }
    });
    return isSuccess;
  }

  Future<void> toggleItemStatus(ViewItemByTypeDatum item, bool newStatus) async {
    await updateItems(itemCode: item.iCode, status: newStatus ? 1 : 0);
  }

  Future<void> refreshItems() async => fetchItems();

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'BrandController error in $action', category: 'brand.controller', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'BrandController');
        scope.setContexts('brand_action', {'action': action, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
