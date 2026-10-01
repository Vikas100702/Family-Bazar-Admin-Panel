import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandController extends BaseServerTableController<ViewBrandDatum> {
  final BrandRepository _brandRepository;
  BrandController({required this._brandRepository});

  final RxBool isItemsLoading = false.obs;
  final RxList<ViewItemByTypeDatum> allBrandItems = <ViewItemByTypeDatum>[].obs;
  final RxList<ViewItemByTypeDatum> filteredBrandItems = <ViewItemByTypeDatum>[].obs;
  late final TextEditingController brandItemSearchController;

  @override
  void onInit() {
    super.onInit();
    brandItemSearchController = TextEditingController();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final response = await _brandRepository.viewBrands(page: currentPage.value, limit: itemsPerPage.value, searchValue: searchQuery.value);
        if (isClosed) return;

        if (response.success) {
          setServerData(
            data: response.data,
            totalCount: response.pagination?.totalRecords ?? response.data.length,
            pageCount: response.pagination?.totalPages,
          );
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the brand list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', {'page': currentPage.value, 'limit': itemsPerPage.value, 'search': searchQuery.value});
        errorMessage(message: 'An unexpected error occurred while fetching brands.');
      }
    });
  }

  Future<void> refreshBrands() async => refreshData();

  Future<bool> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final updatedDatum = await _brandRepository.updateBrand(mcCompCode: mcCompCode, featuredBrand: featuredBrand, status: status);

        if (updatedDatum.mcCompCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.mcCompName} updated successfully');
          await refreshBrands();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateBrand', {'mcCompCode': mcCompCode});
        errorMessage(message: 'Failed to update brand');
      }
    });
    return isSuccess;
  }

  Future<void> toggleBrandStatus(ViewBrandDatum brand, bool newStatus) async {
    await updateBrand(mcCompCode: brand.mcCompCode, status: newStatus ? 1 : 0);
  }

  Future<void> toggleBrandFeatured(ViewBrandDatum brand, bool newFeatured) async {
    await updateBrand(mcCompCode: brand.mcCompCode, featuredBrand: newFeatured ? 1 : 0);
  }

  Future<void> openBrandItemsModal(String brandCode) async {
    brandItemSearchController.clear();
    await fetchBrandItems(brandCode);
  }

  Future<void> fetchBrandItems(String brandCode) async {
    final String trimmedCode = brandCode.trim();
    if (trimmedCode.isEmpty) return;

    try {
      isItemsLoading.value = true;
      allBrandItems.clear();
      filteredBrandItems.clear();

      final ViewItemByTypeModel response = await _brandRepository.viewBrandItems(
        brandCode: trimmedCode,
        page: currentPage.value,
        limit: itemsPerPage.value,
        searchValue: searchQuery.value,
      );
      if (isClosed) return;

      if (response.success) {
        allBrandItems.assignAll(response.data);
        filterBrandItems(brandItemSearchController.text);
      } else {
        allBrandItems.clear();
        filteredBrandItems.clear();
        if (response.message.isNotEmpty) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchBrandItems', {'brand_code': trimmedCode});
      allBrandItems.clear();
      filteredBrandItems.clear();
      errorMessage(message: 'Failed to retrieve catalog items for the selected brand.');
    } finally {
      if (!isClosed) isItemsLoading.value = false;
    }
  }

  void filterBrandItems(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      filteredBrandItems.assignAll(allBrandItems);
    } else {
      filteredBrandItems.assignAll(
        allBrandItems.where((item) {
          final String ean = item.iBarCode.toLowerCase();
          final String category = item.itemGroupName.toLowerCase();
          final String subCategory = (item.otherGroupName?.toString() ?? '').toLowerCase();
          return item.iName.toLowerCase().contains(cleanQuery) ||
              item.iCode.toLowerCase().contains(cleanQuery) ||
              item.iFirmCode.toLowerCase().contains(cleanQuery) ||
              ean.contains(cleanQuery) ||
              category.contains(cleanQuery) ||
              subCategory.contains(cleanQuery);
        }).toList(),
      );
    }
  }

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
    brandItemSearchController.dispose();
    allBrandItems.clear();
    filteredBrandItems.clear();
    super.onClose();
  }
}
