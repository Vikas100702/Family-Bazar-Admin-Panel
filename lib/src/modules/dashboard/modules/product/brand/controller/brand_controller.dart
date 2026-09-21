/*
import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandController extends BaseTableController<Item> {
  final BrandRepository _brandRepository;
  BrandController({required this._brandRepository});

  final RxBool isItemsLoading = false.obs;
  final RxList<Item> allBrandItems = <Item>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  @override
  String searchTokenBuilder(Item item) {
    return '${item.iCode} ${item.brandName}';
  }

  Future<void> fetchBrands() async {
    await runWithLoading(() async {
      try {
        final response = await _brandRepository.viewBrands();
        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the brand list from server.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'BrandController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching brands.');
      }
    });
  }

  Future<bool> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final updatedDatum = await _brandRepository.updateBrand(
          mcCompCode: mcCompCode,
          featuredBrand: featuredBrand,
          status: status,
          mImg: mImg,
          wImg: wImg,
        );

        if (updatedDatum.mcCompCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.mcCompName} updated successfully');
          await fetchBrands();
        }
      } catch (e) {
        errorMessage(message: 'Failed to update brand');
      }
    });
    return isSuccess;
  }

  Future<void> fetchBrandItems(int brandId) async {
    if (brandId == 0) return;

    try {
      isItemsLoading.value = true;
      final ViewItemByTypeModel response = await _brandRepository.viewBrandItems(brandId: brandId);
      if (isClosed) return;

      if (response.success) {
        allBrandItems.assignAll(response.data);
        setMasterData(response.data);
      } else {
        allBrandItems.clear();
        setMasterData([]);
        if (response.message.isNotEmpty && !response.success) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchBrandItems', {'brand_id': brandId});
      allBrandItems.clear();
      setMasterData([]);
      errorMessage(message: 'Failed to retrieve catalog items for the selected brand.');
    } finally {
      if (!isClosed) isItemsLoading.value = false;
    }
  }

  Future<void> toggleBrandStatus(ViewBrandDatum brand, bool newStatus) async {
    await updateBrand(mcCompCode: brand.mcCompCode, status: newStatus ? 1 : 0);
  }

  Future<void> toggleBrandFeatured(ViewBrandDatum brand, bool newFeatured) async {
    await updateBrand(mcCompCode: brand.mcCompCode, featuredBrand: newFeatured ? 1 : 0);
  }

  Future<void> refreshBrands() async => fetchBrands();

  @override
  void onClose() {
    super.onClose();
  }
}
*/

/*import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandController extends BaseTableController<ViewBrandDatum> {
  final BrandRepository _brandRepository;

  BrandController({required BrandRepository brandRepository}) : _brandRepository = brandRepository;

  final RxBool isItemsLoading = false.obs;
  final RxList<Item> allBrandItems = <Item>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  @override
  String searchTokenBuilder(ViewBrandDatum item) {
    return '${item.mcCompCode} ${item.mcCompName}';
  }

  Future<void> fetchBrands() async {
    await runWithLoading(() async {
      try {
        final response = await _brandRepository.viewBrands();
        if (isClosed) return;
        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the brand list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchBrands');
        errorMessage(message: 'An unexpected error occurred while fetching brands.');
      }
    });
  }

  Future<bool> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final updatedDatum = await _brandRepository.updateBrand(
          mcCompCode: mcCompCode,
          featuredBrand: featuredBrand,
          status: status,
          mImg: mImg,
          wImg: wImg,
        );
        if (updatedDatum.mcCompCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.mcCompName} updated successfully');
          await fetchBrands();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateBrand', {'mcCompCode': mcCompCode});
        errorMessage(message: 'Failed to update brand');
      }
    });
    return isSuccess;
  }

  Future<void> fetchBrandItems(String brandCode) async {
    final String sanitizedCode = brandCode.trim();
    if (sanitizedCode.isEmpty) return;

    try {
      isItemsLoading.value = true;
      final ViewItemByTypeModel response = await _brandRepository.viewBrandItems(brandCode: sanitizedCode);
      if (isClosed) return;

      if (response.success) {
        allBrandItems.assignAll(response.data);
      } else {
        allBrandItems.clear();
        if (response.message.isNotEmpty) {
          errorMessage(message: response.message);
        }
      }
    } catch (e, stackTrace) {
      _logException(e, stackTrace, 'fetchBrandItems', {'brand_code': sanitizedCode});
      allBrandItems.clear();
      errorMessage(message: 'Failed to retrieve catalog items for the selected brand.');
    } finally {
      if (!isClosed) isItemsLoading.value = false;
    }
  }

  Future<void> toggleBrandStatus(ViewBrandDatum brand, bool newStatus) async {
    await updateBrand(mcCompCode: brand.mcCompCode, status: newStatus ? 1 : 0);
  }

  Future<void> toggleBrandFeatured(ViewBrandDatum brand, bool newFeatured) async {
    await updateBrand(mcCompCode: brand.mcCompCode, featuredBrand: newFeatured ? 1 : 0);
  }

  Future<void> refreshBrands() async => fetchBrands();

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
    allBrandItems.clear();
    super.onClose();
  }
}*/

import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/shared/models/view_items_by_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandController extends BaseTableController<ViewBrandDatum> {
  final BrandRepository _brandRepository;

  BrandController({required BrandRepository brandRepository}) : _brandRepository = brandRepository;

  // BRAND ITEMS STATE (DIALOG)
  final RxBool isItemsLoading = false.obs;
  final RxList<Item> allBrandItems = <Item>[].obs;
  final RxList<Item> filteredBrandItems = <Item>[].obs;
  late final TextEditingController brandItemSearchController;

  @override
  void onInit() {
    super.onInit();
    brandItemSearchController = TextEditingController();
    fetchBrands();
  }

  @override
  String searchTokenBuilder(ViewBrandDatum item) {
    return '${item.mcCompCode} ${item.mcCompName}';
  }

  Future<void> fetchBrands() async {
    await runWithLoading(() async {
      try {
        final response = await _brandRepository.viewBrands();
        if (isClosed) return;
        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the brand list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchBrands');
        errorMessage(message: 'An unexpected error occurred while fetching brands.');
      }
    });
  }

  Future<bool> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final updatedDatum = await _brandRepository.updateBrand(
          mcCompCode: mcCompCode,
          featuredBrand: featuredBrand,
          status: status,
          mImg: mImg,
          wImg: wImg,
        );
        if (updatedDatum.mcCompCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.mcCompName} updated successfully');
          await fetchBrands();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateBrand', {'mcCompCode': mcCompCode});
        errorMessage(message: 'Failed to update brand');
      }
    });
    return isSuccess;
  }

  /// Opens the brand items dialog and starts data fetch
  Future<void> openBrandItemsModal(String brandCode) async {
    brandItemSearchController.clear();
    await fetchBrandItems(brandCode);
  }

  Future<void> fetchBrandItems(String brandCode) async {
    final String sanitizedCode = brandCode.trim();
    if (sanitizedCode.isEmpty) return;

    try {
      isItemsLoading.value = true;
      allBrandItems.clear();
      filteredBrandItems.clear();

      final ViewItemByTypeModel response = await _brandRepository.viewBrandItems(brandCode: sanitizedCode);
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
      _logException(e, stackTrace, 'fetchBrandItems', {'brand_code': sanitizedCode});
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
          final String ean = item.eanCode.toLowerCase();
          final String category = item.categoryDisplayName.toLowerCase();
          final String subCategory = item.subCategoryDisplayName.toLowerCase();
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

  Future<void> toggleBrandStatus(ViewBrandDatum brand, bool newStatus) async {
    await updateBrand(mcCompCode: brand.mcCompCode, status: newStatus ? 1 : 0);
  }

  Future<void> toggleBrandFeatured(ViewBrandDatum brand, bool newFeatured) async {
    await updateBrand(mcCompCode: brand.mcCompCode, featuredBrand: newFeatured ? 1 : 0);
  }

  Future<void> refreshBrands() async => fetchBrands();

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
