import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseTableController<T> extends BaseController {
  final List<T> _masterData = []; // Master in-memory data
  final RxList<T> pagedList = <T>[].obs; // Reactive Viewport Slice (UI table binds directly to this)

  // Pagination State
  final RxInt itemsPerPage = 20.obs;
  final List<int> pageSizeOptions = const [10, 20, 50, 100];
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalRecords = 0.obs;

  // Scroll Delegates (Prevents Flutter Web Scrollbar crashes)
  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  @override
  void onInit() {
    super.onInit();
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
  }

  /// Sets raw data from API and initializes pagination
  void setMasterData(List<T> data) {
    _masterData.clear();
    _masterData.addAll(data);
    totalRecords.value = _masterData.length;
    _recalculateTotalPages();
    currentPage.value = 1;
    _updatePaginatedSlice();
  }

  void _recalculateTotalPages() {
    totalPages.value = (_masterData.length / itemsPerPage.value).ceil();
    if (totalPages.value == 0) totalPages.value = 1;
  }

  /// Slices in-memory master records into active viewport page
  void _updatePaginatedSlice() {
    if (_masterData.isEmpty) {
      pagedList.clear();
      return;
    }

    final int startIndex = (currentPage.value - 1) * itemsPerPage.value;
    int endIndex = startIndex + itemsPerPage.value;

    if (endIndex > _masterData.length) {
      endIndex = _masterData.length;
    }

    if (startIndex < _masterData.length) {
      pagedList.assignAll(_masterData.sublist(startIndex, endIndex));
    } else {
      pagedList.clear();
    }
  }

  /// Navigates to a specific pagination page index
  void changePage(int newPage) {
    if (newPage < 1 || newPage > totalPages.value) return;
    currentPage.value = newPage;
    _updatePaginatedSlice();
  }

  /// Changes rows per page (10, 20, 50, 100) and resets to page 1
  void changePageSize(int newSize) {
    if (newSize == itemsPerPage.value) return;
    itemsPerPage.value = newSize;
    _recalculateTotalPages();
    currentPage.value = 1;
    _updatePaginatedSlice();
  }

  @override
  void onClose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    _masterData.clear();
    pagedList.clear();
    super.onClose();
  }
}
