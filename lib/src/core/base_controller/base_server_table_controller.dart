import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseServerTableController<T> extends BaseController {
  final RxList<T> pagedList = <T>[].obs; // Current page slice of records received directly from the API
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxInt totalRecords = 0.obs;
  final RxInt totalPages = 1.obs;
  final List<int> pageSizeOptions = const [10, 20, 50, 100];

  final RxString searchQuery = ''.obs;
  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  @override
  void onInit() {
    super.onInit();
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
  }

  Future<void> fetchServerData();

  void setServerData({required List<T> data, required int totalCount, int? pageCount}) {
    pagedList.assignAll(data);
    totalRecords.value = totalCount;

    if (pageCount != null && pageCount > 0) {
      totalPages.value = pageCount;
    } else {
      totalPages.value = (totalCount / itemsPerPage.value).ceil();
      if (totalPages.value == 0) totalPages.value = 1;
    }
  }

  void changePage(int newPage) {
    if (newPage < 1 || newPage > totalPages.value || isLoading.value) return;
    currentPage.value = newPage;
    fetchServerData();
  }

  void changePageSize(int newSize) {
    if (newSize == itemsPerPage.value || isLoading.value) return;
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    fetchServerData();
  }

  Future<void> refreshData() async {
    currentPage.value = 1;
    await fetchServerData();
  }

  void onSearchChanged(String query) {
    final cleanQuery = query.trim();
    if (searchQuery.value == cleanQuery) return;

    searchQuery.value = cleanQuery;
    currentPage.value = 1; // Reset to page 1 for accurate search indexing
    fetchServerData();
  }

  void onSearchSubmitted(String query) {
    final cleanQuery = query.trim();

    // If the search query is the same as the current one, then return (No redundant API hit)
    if (searchQuery.value == cleanQuery && cleanQuery.isNotEmpty) return;

    searchQuery.value = cleanQuery;
    currentPage.value = 1; // Always reset to Page 1 so that search is applied accurately
    fetchServerData();
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    currentPage.value = 1;
    fetchServerData();
  }

  @override
  void onClose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    pagedList.clear();
    super.onClose();
  }
}
