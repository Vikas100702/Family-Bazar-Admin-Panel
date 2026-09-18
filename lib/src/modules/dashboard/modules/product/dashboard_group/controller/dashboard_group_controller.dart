import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/view_items_by_type_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/model/item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardGroupController extends BaseTableController<Item> {
  final DashboardGroupRepository _groupRepository;
  final ItemRepository _itemRepository;

  DashboardGroupController({required this._groupRepository, required this._itemRepository});

  // REACTIVE GROUP NAVIGATION STATE
  final RxList<ViewDashboardGroupDatum> groupList = <ViewDashboardGroupDatum>[].obs;
  final Rxn<ViewDashboardGroupDatum> selectedGroup = Rxn<ViewDashboardGroupDatum>();
  final RxInt selectedGroupId = 0.obs;

  // GROUP ITEMS CATALOG & TABLE STATE
  final RxBool isItemsLoading = false.obs;
  final RxList<Item> allGroupItems = <Item>[].obs;

  RxList<Item> get pagedGroupItems => pagedList;

  // ADD GROUP MUTATION STATE
  final GlobalKey<FormState> addGroupFormKey = GlobalKey<FormState>();
  late final TextEditingController groupNameController;

  // EDIT GROUP MUTATION STATE
  final GlobalKey<FormState> editGroupFormKey = GlobalKey<FormState>();
  late final TextEditingController editGroupNameController;
  final RxInt editStatus = 1.obs;
  final RxString editGImgM = ''.obs;
  final RxString editGImgW = ''.obs;
  final Rxn<ViewDashboardGroupDatum> editingGroup = Rxn<ViewDashboardGroupDatum>();

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
    groupNameController = TextEditingController();
    editGroupNameController = TextEditingController(); // <-- ADD THIS
    masterItemSearchController = TextEditingController();
    fetchDashboardGroups();
  }

  @override
  String searchTokenBuilder(Item item) {
    return '${item.iCode} ${item.iName} ${item.eanCode} ${item.iFirmCode} ${item.iItemGroup} ${item.iOtherGroup}';
  }

  int extractCode(String code, int fallback) {
    return int.tryParse(code.trim()) ?? fallback;
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
          allGroupItems.clear();
          setMasterData([]);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to retrieve dashboard groups.');
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
    clearSearch();

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
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to add group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'createGroup', {'group_name': name});
        errorMessage(message: 'Failed to add group due to a network error.');
      }
    });

    return isSuccess;
  }

  /// Loads the group data into the form before the modal opens
  void prepareEditGroup(ViewDashboardGroupDatum group) {
    editingGroup.value = group;
    editGroupNameController.text = group.groupName;
    editStatus.value = int.tryParse(group.status.toString()) ?? 1;
    editGImgM.value = group.gImgM ?? '';
    editGImgW.value = group.gImgW ?? '';
  }

  /// Atomic update method: Individual fields or combined fields can be passed
  Future<bool> updateGroup({required int groupId, String? groupName, int? status, String? gImgM, String? gImgW}) async {
    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final AddGroupModel response = await _groupRepository.updateGroup(
          groupId: groupId,
          groupName: groupName,
          status: status,
          gImgM: gImgM,
          gImgW: gImgW,
        );

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Updated', message: response.message.isNotEmpty ? response.message : 'Group updated successfully.');

          // Reload master tabs to synchronize the updated state
          refreshAll();
          if (selectedGroupId.value == groupId) {
            final updated = groupList.firstWhereOrNull((g) => g.groupId == groupId);
            if (updated != null) selectGroup(updated);
          }
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateGroup', {
          'group_id': groupId,
          'group_name': groupName,
          'status': status,
          'g_img_m': gImgM,
          'g_img_w': gImgW,
        });
        errorMessage(message: 'Failed to update group due to a network error.');
      }
    });

    return isSuccess;
  }

  /// Dispatches all updated values at once when the edit modal form is submitted
  Future<bool> submitEditGroup() async {
    final group = editingGroup.value;
    if (group == null || group.groupId == 0) return false;
    if (!editGroupFormKey.currentState!.validate()) return false;

    return await updateGroup(
      groupId: group.groupId,
      status: editStatus.value,
      gImgM: editGImgM.value.trim().isNotEmpty ? editGImgM.value.trim() : null,
      gImgW: editGImgW.value.trim().isNotEmpty ? editGImgW.value.trim() : null,
    );
  }

  Future<void> fetchGroupItems(int groupId) async {
    if (groupId == 0) return;

    try {
      isItemsLoading.value = true;
      final ViewItemByTypeModel response = await _groupRepository.viewGroupItems(groupId: groupId);
      if (isClosed) return;

      if (response.success && response.data != null) {
        allGroupItems.assignAll(response.data!.items);
        setMasterData(response.data!.items);
      } else {
        allGroupItems.clear();
        setMasterData([]);
        if (response.message.isNotEmpty && !response.success) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchGroupItems', {'group_id': groupId});
      allGroupItems.clear();
      setMasterData([]);
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

    for (final item in allGroupItems) {
      final codeInt = extractCode(item.iCode, item.id);
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
          final String ean = item.eanCode;
          return item.iName.toLowerCase().contains(cleanQuery) ||
              item.iCode.toLowerCase().contains(cleanQuery) ||
              ean.toLowerCase().contains(cleanQuery) ||
              item.iFirmCode.toLowerCase().contains(cleanQuery);
        }).toList(),
      );
    }
  }

  void toggleItemSelection(int itemCodeNumber) {
    if (selectedItemIdsToAdd.contains(itemCodeNumber)) {
      selectedItemIdsToAdd.remove(itemCodeNumber);
    } else {
      selectedItemIdsToAdd.add(itemCodeNumber);
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

  Future<bool> deleteGroup(ViewDashboardGroupDatum group) async {
    if (group.groupId == 0) {
      errorMessage(message: 'Invalid group selected.');
      return false;
    }

    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _groupRepository.deleteGroup(groupId: group.groupId);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Group deleted successfully.');

          // Clear selection if the deleted group was currently open
          if (selectedGroupId.value == group.groupId) {
            selectedGroup.value = null;
            selectedGroupId.value = 0;
            allGroupItems.clear();
            setMasterData([]);
          }

          // Reload master group tabs
          await fetchDashboardGroups();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteGroup', {'group_id': group.groupId, 'group_name': group.groupName});
        errorMessage(message: 'An error occurred while deleting the dashboard group.');
      }
    });

    return isSuccess;
  }

  Future<bool> deleteGroupItem(Item item) async {
    if (selectedGroupId.value == 0) {
      errorMessage(message: 'No active dashboard group selected.');
      return false;
    }

    final int itemCodeNumber = extractCode(item.iCode, item.id);
    if (itemCodeNumber == 0) {
      errorMessage(message: 'Unable to resolve valid item code.');
      return false;
    }

    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _groupRepository.deleteGroupItems(groupId: selectedGroupId.value, itemId: itemCodeNumber);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Item removed from group successfully.');
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
    editGroupNameController.dispose();
    masterItemSearchController.dispose();
    groupList.clear();
    allGroupItems.clear();
    masterItemList.clear();
    filteredMasterItemList.clear();
    selectedItemIdsToAdd.clear();
    selectedGroup.value = null;
    editingGroup.value = null;
    super.onClose();
  }
}
