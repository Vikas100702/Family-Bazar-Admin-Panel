import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ItemController extends BaseTableController<ViewItemDatum> {
  final ItemRepository _itemRepository;
  ItemController({required this._itemRepository});

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  String searchTokenBuilder(ViewItemDatum item) {
    return '${item.iCode} ${item.iName} ${item.eanCode ?? ''} ${item.iFirmCode} ${item.iItemGroup} ${item.itemGroup} ${item.otherGroup}';
  }

  Future<void> fetchItems() async {
    await runWithLoading(() async {
      try {
        final response = await _itemRepository.viewItems();
        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the item list.');
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

  Future<void> refreshCategories() async => fetchItems();
}
