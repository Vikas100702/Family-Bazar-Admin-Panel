import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_item_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/add_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/model/dashboard_group_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/repository/dashboard_group_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/repository/items_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DashboardGroupController extends BaseTableController<ViewItemByTypeDatum> {
  final DashboardGroupRepository _groupRepository;
  final ItemRepository _itemRepository;
  final FirmRepository _firmRepository;

  DashboardGroupController({required this._groupRepository, required this._itemRepository, required this._firmRepository});

  // REACTIVE GROUP NAVIGATION STATE
  final RxList<ViewDashboardGroupDatum> groupList = <ViewDashboardGroupDatum>[].obs;
  final Rxn<ViewDashboardGroupDatum> selectedGroup = Rxn<ViewDashboardGroupDatum>();
  final RxInt selectedGroupId = 0.obs;

  // GROUP ITEMS CATALOG & TABLE STATE
  final RxBool isItemsLoading = false.obs;
  final RxList<ViewItemByTypeDatum> allGroupItems = <ViewItemByTypeDatum>[].obs;

  RxList<ViewItemByTypeDatum> get pagedGroupItems => pagedList;

  // CREATE GROUP STATE
  final GlobalKey<FormState> addGroupFormKey = GlobalKey<FormState>();
  late final TextEditingController groupNameController;

  // EDIT GROUP STATE
  final GlobalKey<FormState> editGroupFormKey = GlobalKey<FormState>();
  late final TextEditingController editGroupNameController;
  final RxInt editStatus = 1.obs;
  final RxString editGImgM = ''.obs;
  final RxString editGImgW = ''.obs;
  final Rxn<ViewDashboardGroupDatum> editingGroup = Rxn<ViewDashboardGroupDatum>();

  // ADD GROUP ITEMS SELECTION & MODAL STATE
  final RxBool isMasterItemsLoading = false.obs;
  final RxBool isSubmittingItems = false.obs;
  final RxList<ViewItemByTypeDatum> masterItemList = <ViewItemByTypeDatum>[].obs;
  final RxList<ViewItemByTypeDatum> filteredMasterItemList = <ViewItemByTypeDatum>[].obs;
  final RxSet<String> selectedItemCodeToAdd = <String>{}.obs;
  late final TextEditingController masterItemSearchController;

  // FIRM DROPDOWN & FILTER STATE
  final RxBool isFirmLoading = false.obs;
  final RxList<ViewFirmDatum> firmList = <ViewFirmDatum>[].obs;
  final RxString selectedFirmCode = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    groupNameController = TextEditingController();
    editGroupNameController = TextEditingController();
    masterItemSearchController = TextEditingController();
    fetchDashboardGroups();
    fetchFirms();
  }

  @override
  String searchTokenBuilder(ViewItemByTypeDatum item) {
    return '${item.iCode} ${item.iName} ${item.iBarCode} ${item.iFirmCode} ${item.itemGroupName} ${item.otherGroupName}';
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
    if (selectedGroupId.value == group.id && allGroupItems.isNotEmpty) {
      return;
    }

    selectedGroup.value = group;
    selectedGroupId.value = group.id;
    clearSearch();

    fetchGroupItems(group.id);
  }

  Future<bool> createGroup() async {
    if (!addGroupFormKey.currentState!.validate()) return false;

    final String name = groupNameController.text.trim();
    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final AddGroupModel response = await _groupRepository.addGroup(groupName: name);
        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          groupNameController.clear();

          final groupsRes = await _groupRepository.viewGroups();
          if (groupsRes.success && groupsRes.data.isNotEmpty) {
            groupList.assignAll(groupsRes.data);
            final created = groupList.firstWhereOrNull((g) => g.dgName.trim().toLowerCase() == name.toLowerCase()) ?? groupList.last;

            selectGroup(created);
          }
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
    editGroupNameController.text = group.dgName;
    editStatus.value = int.tryParse(group.dgStatus.toString()) ?? 1;
    editGImgM.value = group.imImageMob;
    editGImgW.value = group.imImageWeb;
  }

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
            final updated = groupList.firstWhereOrNull((g) => g.id == groupId);
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
    if (group == null || group.id == 0) return false;
    if (!editGroupFormKey.currentState!.validate()) return false;

    return await updateGroup(
      groupId: group.id,
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

      if (response.success) {
        allGroupItems.assignAll(response.data);
        setMasterData(response.data);
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

  Future<void> fetchFirmItems(String? firmCode) async {
    try {
      isMasterItemsLoading.value = true;
      final ViewItemByTypeModel response = await _groupRepository.viewFirmItems(firmCode);
      if (isClosed) return;

      if (response.success) {
        masterItemList.assignAll(response.data);
        filterMasterItems(masterItemSearchController.text);
      } else {
        masterItemList.clear();
        filteredMasterItemList.clear();
        if (response.message.isNotEmpty) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchFirmItems', {'firm_code': firmCode});
      masterItemList.clear();
      filteredMasterItemList.clear();
      errorMessage(message: 'Failed to retrieve catalog items for the selected firm.');
    } finally {
      if (!isClosed) isMasterItemsLoading.value = false;
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
    selectedItemCodeToAdd.clear();
    masterItemSearchController.clear();
    selectedFirmCode.value = 'ALL';

    for (final item in allGroupItems) {
      final code = item.iCode.trim();
      if (code.isNotEmpty) {
        selectedItemCodeToAdd.add(code);
      }
    }

    await Future.wait([fetchFirmItems('ALL'), if (firmList.isEmpty) fetchFirms()]);
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

  void toggleItemSelection(String itemCode) {
    if (selectedItemCodeToAdd.contains(itemCode)) {
      selectedItemCodeToAdd.remove(itemCode);
    } else {
      selectedItemCodeToAdd.add(itemCode);
    }
  }

  Future<bool> submitGroupItems() async {
    if (selectedGroupId.value == 0) {
      errorMessage(message: 'No active group selected.');
      return false;
    }

    if (selectedItemCodeToAdd.isEmpty) {
      errorMessage(message: 'Please select at least one item.');
      return false;
    }

    bool isSuccess = false;

    try {
      isSubmittingItems.value = true;
      final AddGroupItemsModel response = await _groupRepository.addGroupItems(
        groupId: selectedGroupId.value,
        itemCode: selectedItemCodeToAdd.toList(),
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
      _logException(e, stackTrace, 'submitGroupItems', {'group_id': selectedGroupId.value, 'item_ids': selectedItemCodeToAdd.toList()});
      errorMessage(message: 'An error occurred while linking items.');
    } finally {
      if (!isClosed) isSubmittingItems.value = false;
    }

    return isSuccess;
  }

  Future<bool> deleteGroup(ViewDashboardGroupDatum group) async {
    if (group.id == 0) {
      errorMessage(message: 'Invalid group selected.');
      return false;
    }

    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _groupRepository.deleteGroup(groupId: group.id);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Group deleted successfully.');

          // Clear selection if the deleted group was currently open
          if (selectedGroupId.value == group.id) {
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
        _logException(e, stackTrace, 'deleteGroup', {'group_id': group.id, 'group_name': group.dgName});
        errorMessage(message: 'An error occurred while deleting the dashboard group.');
      }
    });

    return isSuccess;
  }

  Future<bool> deleteGroupItem(ViewItemByTypeDatum item) async {
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

  Future<void> fetchFirms() async {
    try {
      isFirmLoading.value = true;
      final ViewFirmModel response = await _firmRepository.viewFirms();
      if (isClosed) return;

      if (response.success && response.data.isNotEmpty) {
        firmList.assignAll(response.data);
      } else {
        firmList.clear();
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchFirms');
    } finally {
      if (!isClosed) isFirmLoading.value = false;
    }
  }

  void onFirmFilterChanged(String? firmCode) {
    selectedFirmCode.value = firmCode ?? 'ALL';
    fetchFirmItems(selectedFirmCode.value);
  }

  void filterMasterItems(String query) {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      filteredMasterItemList.assignAll(masterItemList);
    } else {
      filteredMasterItemList.assignAll(
        masterItemList.where((item) {
          final String ean = item.iBarCode.toLowerCase();
          return item.iName.toLowerCase().contains(cleanQuery) ||
              item.iCode.toLowerCase().contains(cleanQuery) ||
              ean.contains(cleanQuery) ||
              item.iFirmCode.toLowerCase().contains(cleanQuery);
        }).toList(),
      );
    }
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
    debugPrint("[Dashboard Group Exception]$exception\n$stackTrace");
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
    selectedItemCodeToAdd.clear();
    selectedGroup.value = null;
    editingGroup.value = null;
    firmList.clear();
    selectedFirmCode.value = 'ALL';
    super.onClose();
  }
}
