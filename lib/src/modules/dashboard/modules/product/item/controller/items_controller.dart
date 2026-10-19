import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ItemController extends BaseTableController<ViewItemByTypeDatum> {
  final ItemRepository _itemRepository;

  ItemController({required this._itemRepository});

  bool _isActionLocked = false;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  String searchTokenBuilder(ViewItemByTypeDatum item) {
    return '${item.iCode} ${item.iName} ${item.iBarCode} ${item.iFirmCode} ${item.iItemGroup} ${item.itemGroupName} ${item.otherGroupName}'
        .toLowerCase()
        .trim();
  }

  Future<void> fetchItems() async {
    await runWithLoading(() async {
      try {
        final ViewItemByTypeModel response = await _itemRepository.viewItems();

        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the item list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchItems');
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching items.');
        }
      }
    });
  }

  Future<void> refreshItems() async => fetchItems();

  Future<bool> updateItems({required String itemCode, int? status}) async {
    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final ViewItemByTypeDatum updatedDatum = await _itemRepository.updateItem(itemCode: itemCode, status: status);

        if (isClosed) return;

        if (updatedDatum.iCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.iCode} updated successfully.');
          await fetchItems();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateItems', <String, dynamic>{'itemCode': itemCode, 'status': status});
        if (!isClosed) {
          errorMessage(message: 'Failed to update item parameters.');
        }
      } finally {
        _isActionLocked = false;
      }
    });

    return isSuccess;
  }

  Future<void> toggleItemStatus(ViewItemByTypeDatum item, bool newStatus) async {
    await updateItems(itemCode: item.iCode, status: newStatus ? 1 : 0);
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'ItemController error in $action', category: 'product.item.controller', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'item');
        scope.setTag('controller', 'ItemController');
        scope.setContexts('item_action', <String, dynamic>{'action': action, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
