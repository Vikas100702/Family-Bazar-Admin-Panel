import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/core/models/common_delete_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
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

  bool _isActionLocked = false;
  final RxBool isReordering = false.obs;

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
  late final TextEditingController addGroupSequenceController;

  // EDIT GROUP STATE
  final GlobalKey<FormState> editGroupFormKey = GlobalKey<FormState>();
  late final TextEditingController editGroupNameController;
  late final TextEditingController editGroupSequenceController;
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
    addGroupSequenceController = TextEditingController();
    editGroupNameController = TextEditingController();
    editGroupSequenceController = TextEditingController();
    masterItemSearchController = TextEditingController();
    fetchDashboardGroups();
    fetchFirms();
  }

  @override
  String searchTokenBuilder(ViewItemByTypeDatum item) {
    return '${item.iCode} ${item.iName} ${item.iBarCode} ${item.iFirmCode} ${item.itemGroupName} ${item.otherGroupName}'.toLowerCase().trim();
  }

  /// Sorts groups by sequence, then fallback to id
  void _sortGroups() {
    groupList.sort((a, b) {
      final int seqComparison = a.dgSequence.compareTo(b.dgSequence);
      if (seqComparison != 0) return seqComparison;
      return a.id.compareTo(b.id);
    });
  }

  Future<void> fetchDashboardGroups() async {
    await runWithLoading(() async {
      try {
        final ViewDashboardGroupModel response = await _groupRepository.viewGroups();
        if (isClosed) return;

        if (response.success && response.data.isNotEmpty) {
          groupList.assignAll(response.data);
          _sortGroups();

          if (selectedGroup.value == null && groupList.isNotEmpty) {
            selectGroup(groupList.first);
          } else if (selectedGroup.value != null) {
            final ViewDashboardGroupDatum? updatedSelected = groupList.firstWhereOrNull((g) => g.id == selectedGroupId.value);
            if (updatedSelected != null) {
              selectedGroup.value = updatedSelected;
            }
          }
        } else if (response.data.isEmpty) {
          groupList.clear();
          selectedGroup.value = null;
          selectedGroupId.value = 0;
          allGroupItems.clear();
          setMasterData(<ViewItemByTypeDatum>[]);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to retrieve dashboard groups.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchDashboardGroups');
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while loading groups.');
        }
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
    if (_isActionLocked) return false;
    if (!addGroupFormKey.currentState!.validate()) return false;

    final String name = groupNameController.text.trim();
    final int? seq = int.tryParse(addGroupSequenceController.text.trim());
    bool isSuccess = false;
    _isActionLocked = true;

    await runWithLoading(() async {
      try {
        final AddGroupModel response = await _groupRepository.addGroup(groupName: name, sequence: seq);
        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          groupNameController.clear();
          addGroupSequenceController.clear();

          final ViewDashboardGroupModel groupsRes = await _groupRepository.viewGroups();
          if (isClosed) return;

          if (groupsRes.success && groupsRes.data.isNotEmpty) {
            groupList.assignAll(groupsRes.data);
            _sortGroups();
            final ViewDashboardGroupDatum created =
                groupList.firstWhereOrNull((g) => g.dgName.trim().toLowerCase() == name.toLowerCase()) ?? groupList.last;
            selectGroup(created);
          }
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to add group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'createGroup', {'group_name': name, 'sequence': seq});
        if (!isClosed) {
          errorMessage(message: 'Failed to add group due to a network error.');
        }
      } finally {
        _isActionLocked = false;
      }
    });

    return isSuccess;
  }

  void prepareEditGroup(ViewDashboardGroupDatum group) {
    editingGroup.value = group;
    editGroupNameController.text = group.dgName;
    editGroupSequenceController.text = group.dgSequence.toString();
    editStatus.value = group.dgStatus;
    editGImgM.value = group.imImageMob;
    editGImgW.value = group.imImageWeb;
  }

  Future<bool> updateGroup({required int groupId, String? groupName, int? status, int? sequence, String? gImgM, String? gImgW}) async {
    if (_isActionLocked) return false;
    _isActionLocked = true;
    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final AddGroupModel response = await _groupRepository.updateGroup(
          groupId: groupId,
          groupName: groupName,
          status: status,
          sequence: sequence,
          gImgM: gImgM,
          gImgW: gImgW,
        );
        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Updated', message: response.message.isNotEmpty ? response.message : 'Group updated successfully.');
          await refreshAll();
          if (selectedGroupId.value == groupId) {
            final ViewDashboardGroupDatum? updated = groupList.firstWhereOrNull((g) => g.id == groupId);
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
          'sequence': sequence,
          'g_img_m': gImgM,
          'g_img_w': gImgW,
        });
        if (!isClosed) {
          errorMessage(message: 'Failed to update group due to a network error.');
        }
      } finally {
        _isActionLocked = false;
      }
    });

    return isSuccess;
  }

  Future<bool> submitEditGroup() async {
    final ViewDashboardGroupDatum? group = editingGroup.value;
    if (group == null || group.id == 0) return false;
    if (!editGroupFormKey.currentState!.validate()) return false;

    final int? seq = int.tryParse(editGroupSequenceController.text.trim());

    return await updateGroup(
      groupId: group.id,
      status: editStatus.value,
      sequence: seq,
      groupName: editGroupNameController.text.trim().isNotEmpty ? editGroupNameController.text.trim() : null,
      gImgM: editGImgM.value.trim().isNotEmpty ? editGImgM.value.trim() : null,
      gImgW: editGImgW.value.trim().isNotEmpty ? editGImgW.value.trim() : null,
    );
  }

  Future<void> reorderGroups(int oldIndex, int newIndex) async {
    if (isReordering.value || _isActionLocked) return;
    if (oldIndex < 0 || oldIndex >= groupList.length) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) return;

    final List<ViewDashboardGroupDatum> originalList = List<ViewDashboardGroupDatum>.from(groupList);

    final ViewDashboardGroupDatum movedItem = groupList.removeAt(oldIndex);
    groupList.insert(newIndex, movedItem);

    final List<ViewDashboardGroupDatum> updatedList = <ViewDashboardGroupDatum>[];
    for (int i = 0; i < groupList.length; i++) {
      final ViewDashboardGroupDatum current = groupList[i];
      final int newSeq = i + 1;
      updatedList.add(current.copyWith(dgSequence: newSeq));
    }
    groupList.assignAll(updatedList);

    isReordering.value = true;
    try {
      for (int i = 0; i < groupList.length; i++) {
        final ViewDashboardGroupDatum group = groupList[i];
        final ViewDashboardGroupDatum original = originalList.firstWhere((g) => g.id == group.id, orElse: () => group);

        if (original.dgSequence != group.dgSequence) {
          await _groupRepository.updateGroup(groupId: group.id, sequence: group.dgSequence);
        }
      }

      if (isClosed) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return;
        successMessage(title: 'Sequence Updated', message: 'Dashboard group tab order saved successfully.');
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!isClosed && (Get.isDialogOpen ?? false)) {
            Get.back();
          }
        });
      });
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'reorderGroups', {'old_index': oldIndex, 'new_index': newIndex});
      // Rollback to prior order
      if (!isClosed) {
        groupList.assignAll(originalList);
        errorMessage(message: 'Failed to persist tab sequence. Reverted changes.');
      }
    } finally {
      if (!isClosed) {
        isReordering.value = false;
      }
    }
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
        setMasterData(<ViewItemByTypeDatum>[]);
        if (response.message.isNotEmpty) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchGroupItems', {'group_id': groupId});
      allGroupItems.clear();
      setMasterData(<ViewItemByTypeDatum>[]);
      if (!isClosed) {
        errorMessage(message: 'Failed to retrieve catalog items for the selected group.');
      }
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
      if (!isClosed) {
        errorMessage(message: 'Failed to retrieve catalog items for the selected firm.');
      }
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

    for (final ViewItemByTypeDatum item in allGroupItems) {
      final String code = item.iCode.trim();
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
      if (!isClosed) {
        errorMessage(message: 'Failed to fetch catalog items for selection.');
      }
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
    if (_isActionLocked) return false;
    if (selectedGroupId.value == 0) {
      errorMessage(message: 'No active group selected.');
      return false;
    }

    if (selectedItemCodeToAdd.isEmpty) {
      errorMessage(message: 'Please select at least one item.');
      return false;
    }

    _isActionLocked = true;
    isSubmittingItems.value = true;
    bool isSuccess = false;

    try {
      final AddGroupItemsModel response = await _groupRepository.addGroupItems(
        groupId: selectedGroupId.value,
        itemCode: selectedItemCodeToAdd.toList(growable: false),
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
      _logException(e, stackTrace, 'submitGroupItems', {'group_id': selectedGroupId.value, 'item_ids_count': selectedItemCodeToAdd.length});
      if (!isClosed) {
        errorMessage(message: 'An error occurred while linking items.');
      }
    } finally {
      _isActionLocked = false;
      if (!isClosed) isSubmittingItems.value = false;
    }

    return isSuccess;
  }

  Future<bool> hasItems(int groupId) async {
    // If the same group is open, we can directly check the length of the active list
    if (selectedGroupId.value == groupId && allGroupItems.isNotEmpty) {
      return true;
    }
    // If deleting another group tab, check via the API
    try {
      final res = await _groupRepository.viewGroupItems(groupId: groupId);
      return res.success && res.data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteGroup(ViewDashboardGroupDatum group) async {
    if (_isActionLocked) return false;
    if (group.id == 0) {
      errorMessage(message: 'Invalid group selected.');
      return false;
    }

    final bool groupHasItems = await hasItems(group.id);
    if (groupHasItems) {
      errorMessage(
        title: 'Cannot Delete Group',
        message: 'This group contains items. Please remove or delete all items from "${group.dgName}" first.',
      );
      return false;
    }

    _isActionLocked = true;
    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _groupRepository.deleteGroup(groupId: group.id);
        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Group deleted successfully.');

          if (selectedGroupId.value == group.id) {
            selectedGroup.value = null;
            selectedGroupId.value = 0;
            allGroupItems.clear();
            setMasterData(<ViewItemByTypeDatum>[]);
          }

          await fetchDashboardGroups();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to delete group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteGroup', {'group_id': group.id, 'group_name': group.dgName});
        if (!isClosed) {
          errorMessage(message: 'An error occurred while deleting the dashboard group.');
        }
      } finally {
        _isActionLocked = false;
      }
    });

    return isSuccess;
  }

  Future<bool> deleteGroupItem(ViewItemByTypeDatum item) async {
    if (_isActionLocked) return false;
    if (selectedGroupId.value == 0) {
      errorMessage(message: 'No active dashboard group selected.');
      return false;
    }

    _isActionLocked = true;
    bool isSuccess = false;

    await runWithLoading(() async {
      try {
        final CommonDeleteModel response = await _groupRepository.deleteGroupItems(groupId: selectedGroupId.value, itemCode: item.iCode);

        if (isClosed) return;

        if (response.success) {
          isSuccess = true;
          successMessage(title: 'Deleted', message: response.message.isNotEmpty ? response.message : 'Item removed from group successfully.');
          await refreshCurrentGroupItems();
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to remove item from group.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'deleteGroupItem', {'group_id': selectedGroupId.value, 'item_code': item.iCode});
        if (!isClosed) {
          errorMessage(message: 'An error occurred while deleting item from group.');
        }
      } finally {
        _isActionLocked = false;
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
    final String cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      filteredMasterItemList.assignAll(masterItemList);
    } else {
      filteredMasterItemList.assignAll(
        masterItemList
            .where((ViewItemByTypeDatum item) {
              final String ean = item.iBarCode.toLowerCase();
              return item.iName.toLowerCase().contains(cleanQuery) ||
                  item.iCode.toLowerCase().contains(cleanQuery) ||
                  ean.contains(cleanQuery) ||
                  item.iFirmCode.toLowerCase().contains(cleanQuery);
            })
            .toList(growable: false),
      );
    }
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'dashboard_group');
        scope.setTag('controller', 'DashboardGroupController');
        scope.setContexts('group_action', <String, dynamic>{'action': action, 'selected_group_id': selectedGroupId.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    groupNameController.dispose();
    addGroupSequenceController.dispose();
    editGroupNameController.dispose();
    editGroupSequenceController.dispose();
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
