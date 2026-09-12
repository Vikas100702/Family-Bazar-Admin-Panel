import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/view_group_items_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardGroupController extends BaseController {
  final DashboardGroupRepository _groupRepository;
  final ItemRepository _itemRepository;

  DashboardGroupController({required this._groupRepository, required this._itemRepository});

  // REACTIVE GROUP NAVIGATION STATE
  final RxList<ViewDashboardGroupDatum> groupList = <ViewDashboardGroupDatum>[].obs;
  final Rxn<ViewDashboardGroupDatum> selectedGroup = Rxn<ViewDashboardGroupDatum>();
  final RxInt selectedGroupId = 0.obs;

  // REACTIVE ITEM CATALOG STATE
  final RxBool isItemsLoading = false.obs;
  final RxList<GroupItemDatum> allGroupItems = <GroupItemDatum>[].obs;
  final RxList<GroupItemDatum> filteredGroupItems = <GroupItemDatum>[].obs;
  final RxList<GroupItemDatum> pagedGroupItems = <GroupItemDatum>[].obs;

  // PAGINATION & SEARCH STATE
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxInt totalRecords = 0.obs;
  final List<int> pageSizeOptions = const [10, 20, 50, 100];
  final RxString searchQuery = ''.obs;

  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  // ADD GROUP MUTATION STATE
  final GlobalKey<FormState> addGroupFormKey = GlobalKey<FormState>();
  late final TextEditingController groupNameController;

  // ADD GROUP ITEMS SELECTION & MODAL STATE
  final RxBool isMasterItemsLoading = false.obs;
  final RxBool isSubmittingItems = false.obs;
  final RxList<ViewItemDatum> masterItemList = <ViewItemDatum>[].obs;
  final RxList<ViewItemDatum> filteredMasterItemList = <ViewItemDatum>[].obs;
  final RxSet<int> selectedItemIdsToAdd = <int>{}.obs;
  late final TextEditingController masterItemSearchController;

  @override
  void onInit() {
    super.onInit();
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
    groupNameController = TextEditingController();
    masterItemSearchController = TextEditingController();
    fetchDashboardGroups();
  }

  int extractItemCode(String iCode, int fallback) {
    return int.tryParse(iCode.trim()) ?? fallback;
  }

  Future<void> fetchDashboardGroups() async {
    await runWithLoading(() async {
      try {
        final response = await _groupRepository.viewGroups();
        if (isClosed) return;

        if (response.success && response.data.isNotEmpty) {
          groupList.assignAll(response.data);
          if (selectedGroup.value == null && groupList.isNotEmpty) {
            selectGroup(groupList.first);
          }
        } else if (response.data.isEmpty) {
          groupList.clear();
          selectedGroup.value = null;
          selectedGroupId.value = 0;
          _clearItemsState();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to retrieve dashboard groups.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchDashboardGroups');
        errorMessage(message: 'An unexpected error occurred while loading groups.');
      }
    });
  }

  void selectGroup(ViewDashboardGroupDatum group) {
    if (selectedGroupId.value == group.groupId && allGroupItems.isNotEmpty) {
      return;
    }

    selectedGroup.value = group;
    selectedGroupId.value = group.groupId;
    searchQuery.value = '';
    currentPage.value = 1;

    fetchGroupItems(group.groupId);
  }

  Future<bool> createGroup() async {
    if (!addGroupFormKey.currentState!.validate()) return false;

    final String name = groupNameController.text.trim();
    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final AddGroupModel response = await _groupRepository.addGroup(groupName: name);
        if (isClosed) return;

        if (response.success && response.data != null) {
          isSuccess = true;
          groupNameController.clear();
          successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Group added successfully.');

          await fetchDashboardGroups();
          final created = groupList.firstWhereOrNull((g) => g.groupId == response.data!.groupId);
          if (created != null) selectGroup(created);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to add group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'createGroup', {'group_name': name});
        errorMessage(message: 'Failed to add group due to a network error.');
      }
    });

    return isSuccess;
  }

  Future<void> fetchGroupItems(int groupId) async {
    if (groupId == 0) return;

    try {
      isItemsLoading.value = true;
      final response = await _groupRepository.viewGroupItems(groupId: groupId);
      if (isClosed) return;

      if (response.success && response.data != null) {
        allGroupItems.assignAll(response.data!.items);
        _applyFilterAndPagination();
      } else {
        _clearItemsState();
        if (response.message.isNotEmpty && !response.success) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchGroupItems', {'group_id': groupId});
      _clearItemsState();
      errorMessage(message: 'Failed to retrieve catalog items for the selected group.');
    } finally {
      if (!isClosed) isItemsLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await fetchDashboardGroups();
    if (selectedGroupId.value != 0) {
      await fetchGroupItems(selectedGroupId.value);
    }
  }

  Future<void> refreshCurrentGroupItems() async {
    if (selectedGroupId.value != 0) {
      await fetchGroupItems(selectedGroupId.value);
    }
  }

  Future<void> openAddItems() async {
    selectedItemIdsToAdd.clear();
    masterItemSearchController.clear();

    // Pre-select items that already exist in this group
    for (final item in allGroupItems) {
      final codeInt = extractItemCode(item.iCode, item.id);
      if (codeInt != 0) {
        selectedItemIdsToAdd.add(codeInt);
      }
    }

    await loadMasterItems();
  }

  Future<void> loadMasterItems() async {
    try {
      isMasterItemsLoading.value = true;
      final response = await _itemRepository.viewItems();
      if (isClosed) return;

      if (response.success) {
        masterItemList.assignAll(response.data);
        filterMasterItems('');
      } else {
        masterItemList.clear();
        filteredMasterItemList.clear();
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'loadMasterItems');
      errorMessage(message: 'Failed to fetch catalog items for selection.');
    } finally {
      if (!isClosed) isMasterItemsLoading.value = false;
    }
  }

  void filterMasterItems(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      filteredMasterItemList.assignAll(masterItemList);
    } else {
      filteredMasterItemList.assignAll(
        masterItemList.where((item) {
          return item.iName.toLowerCase().contains(cleanQuery) ||
              item.iCode.toLowerCase().contains(cleanQuery) ||
              (item.eanCode).toLowerCase().contains(cleanQuery) ||
              item.iFirmCode.toLowerCase().contains(cleanQuery);
        }).toList(),
      );
    }
  }

  void toggleItemSelection(int itemId) {
    if (selectedItemIdsToAdd.contains(itemId)) {
      selectedItemIdsToAdd.remove(itemId);
    } else {
      selectedItemIdsToAdd.add(itemId);
    }
  }

  Future<bool> submitGroupItems() async {
    if (selectedGroupId.value == 0) {
      errorMessage(message: 'No active group selected.');
      return false;
    }

    if (selectedItemIdsToAdd.isEmpty) {
      errorMessage(message: 'Please select at least one item.');
      return false;
    }

    bool isSuccess = false;

    try {
      isSubmittingItems.value = true;
      final AddGroupItemsModel response = await _groupRepository.addGroupItems(
        groupId: selectedGroupId.value,
        itemIds: selectedItemIdsToAdd.toList(),
      );

      if (isClosed) return false;

      if (response.success) {
        isSuccess = true;
        successMessage(title: 'Success', message: response.message.isNotEmpty ? response.message : 'Items assigned to group successfully.');
        await refreshCurrentGroupItems();
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to assign items to group.');
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'submitGroupItems', {'group_id': selectedGroupId.value, 'item_ids': selectedItemIdsToAdd.toList()});
      errorMessage(message: 'An error occurred while linking items.');
    } finally {
      if (!isClosed) isSubmittingItems.value = false;
    }

    return isSuccess;
  }

  Future<bool> deleteGroupItem(GroupItemDatum item) async {
    if (selectedGroupId.value == 0) {
      errorMessage(message: 'No active dashboard group selected.');
      return false;
    }

    final int itemCodeNumber = extractItemCode(item.iCode, item.id);
    if (itemCodeNumber == 0) {
      errorMessage(message: 'Unable to resolve valid item code.');
      return false;
    }

    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final AddGroupItemsModel response = await _groupRepository.deleteGroupItems(groupId: selectedGroupId.value, itemId: itemCodeNumber);
        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          await refreshCurrentGroupItems();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to remove item from group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteGroupItem', {'group_id': selectedGroupId.value, 'item_id': itemCodeNumber});
        errorMessage(message: 'An error occurred while deleting item from group.');
      }
    });

    return isSuccess;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
    currentPage.value = 1;
    _applyFilterAndPagination();
  }

  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 1;
    _applyFilterAndPagination();
  }

  void changePage(int newPage) {
    final int maxPage = (totalRecords.value / itemsPerPage.value).ceil();
    if (newPage < 1 || (maxPage > 0 && newPage > maxPage)) return;
    currentPage.value = newPage;
    _updatePagedList();
  }

  void changePageSize(int newSize) {
    if (!pageSizeOptions.contains(newSize)) return;
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    _applyFilterAndPagination();
  }

  void _applyFilterAndPagination() {
    final query = searchQuery.value;

    if (query.isEmpty) {
      filteredGroupItems.assignAll(allGroupItems);
    } else {
      filteredGroupItems.assignAll(
        allGroupItems.where((item) {
          return item.iName.toLowerCase().contains(query) ||
              item.iCode.toLowerCase().contains(query) ||
              item.eanCode.toLowerCase().contains(query) ||
              item.iFirmCode.toLowerCase().contains(query) ||
              item.iItemGroup.toLowerCase().contains(query) ||
              item.iOtherGroup.toLowerCase().contains(query);
        }).toList(),
      );
    }

    totalRecords.value = filteredGroupItems.length;
    _updatePagedList();
  }

  void _updatePagedList() {
    if (filteredGroupItems.isEmpty) {
      pagedGroupItems.clear();
      return;
    }

    final int startIndex = (currentPage.value - 1) * itemsPerPage.value;
    if (startIndex >= filteredGroupItems.length) {
      currentPage.value = 1;
      _updatePagedList();
      return;
    }

    final int endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredGroupItems.length);

    pagedGroupItems.assignAll(filteredGroupItems.sublist(startIndex, endIndex));
  }

  void _clearItemsState() {
    allGroupItems.clear();
    filteredGroupItems.clear();
    pagedGroupItems.clear();
    totalRecords.value = 0;
    currentPage.value = 1;
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'DashboardGroupController');
        scope.setContexts('group_action', {'action': action, 'selected_group_id': selectedGroupId.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    groupNameController.dispose();
    masterItemSearchController.dispose();
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    groupList.clear();
    masterItemList.clear();
    filteredMasterItemList.clear();
    selectedItemIdsToAdd.clear();
    _clearItemsState();
    selectedGroup.value = null;
    super.onClose();
  }
}
