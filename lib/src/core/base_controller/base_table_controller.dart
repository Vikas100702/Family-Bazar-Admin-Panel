import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseTableController<T> extends BaseController {
  final List<T> _masterData = [];
  final List<String> _masterSearchTokens = [];
  final List<T> _filteredData = [];
  final List<String> _filteredTokens = [];

  final RxList<T> pagedList = <T>[].obs;
  final RxString searchQuery = ''.obs;

  final RxInt itemsPerPage = 20.obs;
  final List<int> pageSizeOptions = const [10, 20, 50, 100];
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalRecords = 0.obs;

  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  @override
  void onInit() {
    super.onInit();
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
  }

  /// Child controller isko override karega searchable string banane ke liye
  String searchTokenBuilder(T item) => item.toString();

  void setMasterData(List<T> data) {
    _masterData.clear();
    _masterSearchTokens.clear();
    _masterData.addAll(data);

    // Initial load par pre-tokenization
    for (int i = 0; i < data.length; i++) {
      _masterSearchTokens.add(searchTokenBuilder(data[i]).toLowerCase());
    }

    _applyFilterAndPaginate();
  }

  void onSearchChanged(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (searchQuery.value == cleanQuery) return;

    // 1-character threshold check (50k items par single letter choke avoid karne ke liye)
    if (cleanQuery.isNotEmpty && cleanQuery.length < 2) return;

    final String oldQuery = searchQuery.value;
    searchQuery.value = cleanQuery;
    currentPage.value = 1;

    _applyOptimizedFilter(cleanQuery, oldQuery);
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    currentPage.value = 1;
    _applyFilterAndPaginate();
  }

  void _applyOptimizedFilter(String newQuery, String oldQuery) {
    if (newQuery.isEmpty) {
      _applyFilterAndPaginate();
      return;
    }

    final bool isIncremental = oldQuery.isNotEmpty && newQuery.startsWith(oldQuery);
    final List<T> sourceData = isIncremental ? List.from(_filteredData) : _masterData;
    final List<String> sourceTokens = isIncremental ? List.from(_filteredTokens) : _masterSearchTokens;

    _filteredData.clear();
    _filteredTokens.clear();

    for (int i = 0; i < sourceData.length; i++) {
      if (sourceTokens[i].contains(newQuery)) {
        _filteredData.add(sourceData[i]);
        _filteredTokens.add(sourceTokens[i]);
      }
    }

    totalRecords.value = _filteredData.length;
    _recalculateTotalPages();
    _updatePaginatedSlice();
  }

  void _applyFilterAndPaginate() {
    _filteredData.clear();
    _filteredTokens.clear();

    if (searchQuery.value.isEmpty) {
      _filteredData.addAll(_masterData);
      _filteredTokens.addAll(_masterSearchTokens);
    } else {
      for (int i = 0; i < _masterData.length; i++) {
        if (_masterSearchTokens[i].contains(searchQuery.value)) {
          _filteredData.add(_masterData[i]);
          _filteredTokens.add(_masterSearchTokens[i]);
        }
      }
    }

    totalRecords.value = _filteredData.length;
    _recalculateTotalPages();
    _updatePaginatedSlice();
  }

  void _recalculateTotalPages() {
    totalPages.value = (_filteredData.length / itemsPerPage.value).ceil();
    if (totalPages.value == 0) totalPages.value = 1;
  }

  // Strictly slices from _filteredData
  void _updatePaginatedSlice() {
    if (_filteredData.isEmpty) {
      pagedList.clear();
      return;
    }

    final int startIndex = (currentPage.value - 1) * itemsPerPage.value;
    int endIndex = startIndex + itemsPerPage.value;

    if (endIndex > _filteredData.length) {
      endIndex = _filteredData.length;
    }

    if (startIndex < _filteredData.length) {
      pagedList.assignAll(_filteredData.sublist(startIndex, endIndex));
    } else {
      pagedList.clear();
    }
  }

  void changePage(int newPage) {
    if (newPage < 1 || newPage > totalPages.value) return;
    currentPage.value = newPage;
    _updatePaginatedSlice();
  }

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
    _masterSearchTokens.clear();
    _filteredData.clear();
    _filteredTokens.clear();
    pagedList.clear();
    super.onClose();
  }
}
