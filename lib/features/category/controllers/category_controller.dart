import 'package:flutter/cupertino.dart';
import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/features/category/domain/models/category_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/category/domain/services/category_service_interface.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Item>? _categoryItemList;
  List<Item>? get categoryItemList => _categoryItemList;

  List<Store>? _categoryStoreList;
  List<Store>? get categoryStoreList => _categoryStoreList;

  List<Item>? _searchItemList = [];
  List<Item>? get searchItemList => _searchItemList;

  List<Store>? _searchStoreList = [];
  List<Store>? get searchStoreList => _searchStoreList;

  List<bool>? _interestSelectedList;
  List<bool>? get interestSelectedList => _interestSelectedList;

  bool isCategoryExpanded = false;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restPageSize;
  int? get restPageSize => _restPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isStore = false;
  bool get isStore => _isStore;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  bool _isOverallLoading = false;
  bool get isOverallLoading => _isOverallLoading;

  // Pagination details
  int? _totalPageSize;
  int? get totalPageSize => _totalPageSize;

  final int _currentOffset = 1;
  int get currentOffset => _currentOffset;

/// newly added by ak
  int selectedCategoryId = -1;

  void setSelectedCategory(int id) {
    selectedCategoryId = id;
    update();
  }

  void displayBottomLoader(String categoryID) {
    _isOverallLoading = true;
    update();
  }
  bool isLoadingCategories = false;

  final Map<String, List<Item>> _itemsByCategory = {};
  Map<String, List<Item>> get itemsByCategory => _itemsByCategory;
  List<Item>? getItemsForCategory(String categoryID) =>
      _itemsByCategory[categoryID];

  // Stores loading status for each category ID
  final Map<String, bool> _loadingStatusByCategory = {};
  bool isLoadingForCategory(String categoryID) =>
      _loadingStatusByCategory[categoryID] ?? false;

  void clearCategoryList() {
    _categoryList = null;
    _subCategoryList = null;
    _categoryItemList = null;
    _categoryStoreList = null;
    update();
  }

  Future<void> getCategoryList(
      bool reload, {
        bool allCategory = false,
        DataSourceEnum dataSource = DataSourceEnum.local,
        bool fromRecall = false,
      }) async {
    if (_categoryList == null || reload || fromRecall) {
      int? currentModuleId = Get.isRegistered<SplashController>() ? Get.find<SplashController>().module?.id : null;

      try {
        isLoadingCategories = true;

        // ✅ Safe update — schedule it after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update(); // show shimmer safely
        });

        if (reload) {
          _categoryList = null;
        }

        List<CategoryModel>? categoryList;

        if (dataSource == DataSourceEnum.local) {
          categoryList = await categoryServiceInterface.getCategoryList(
            allCategory,
            source: DataSourceEnum.local,
          );

          if (Get.isRegistered<SplashController>() && Get.find<SplashController>().module?.id != currentModuleId) return;

          _prepareCategoryList(categoryList);

          // Recall to fetch from client source
          await getCategoryList(
            false,
            fromRecall: true,
            allCategory: allCategory,
            dataSource: DataSourceEnum.client,
          );
        } else {
          categoryList = await categoryServiceInterface.getCategoryList(
            allCategory,
            source: DataSourceEnum.client,
          );

          if (Get.isRegistered<SplashController>() && Get.find<SplashController>().module?.id != currentModuleId) return;

          _prepareCategoryList(categoryList);
        }
      } catch (e) {
        _categoryList = [];
      } finally {
        isLoadingCategories = false;

        // ✅ Safe update again
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update(); // refresh UI safely
        });
      }
    }
  }


  // Future<void> getCategoryList(bool reload, {bool allCategory = false, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
  //   if(_categoryList == null || reload || fromRecall) {
  //     if(reload) {
  //       _categoryList = null;
  //     }
  //     List<CategoryModel>? categoryList;
  //     if(dataSource == DataSourceEnum.local) {
  //       categoryList = await categoryServiceInterface.getCategoryList(allCategory, source: DataSourceEnum.local);
  //       _prepareCategoryList(categoryList);
  //       getCategoryList(false, fromRecall: true, allCategory: allCategory, dataSource: DataSourceEnum.client);
  //     } else {
  //       categoryList = await categoryServiceInterface.getCategoryList(allCategory, source: DataSourceEnum.client);
  //       _prepareCategoryList(categoryList);
  //     }
  //
  //   }
  // }

  void _prepareCategoryList(List<CategoryModel>? categoryList) {
    if (categoryList != null) {
      _categoryList = [];
      _interestSelectedList = [];
      final Map<int, CategoryModel> uniqueCatMap = {};
      for (var cat in categoryList) {
        if (cat.id != null) {
          uniqueCatMap[cat.id!] = cat;
        }
      }
      _categoryList!.addAll(uniqueCatMap.values);
      for(int i = 0; i < _categoryList!.length; i++) {
        _interestSelectedList!.add(false);
        if (_categoryList![i].id != null) {
          fetchItemsForCategory(_categoryList![i].id.toString(), 1, 'all', false);
        }
      }
    }
    update();
  }
  Future<void> fetchItemsForCategory(
      String categoryID, int offset, String type, bool notify) async {
    if (_loadingStatusByCategory[categoryID] == true) return;

    _loadingStatusByCategory[categoryID] = true;
    if (offset == 1 || !_itemsByCategory.containsKey(categoryID)) {
      _itemsByCategory[categoryID] = [];
    }

    // Fetch items from the service
    ItemModel? fetchedItems = await categoryServiceInterface
        .getCategoryItemList(categoryID, offset, type);
    if (fetchedItems != null && fetchedItems.items != null) {
      for (var item in fetchedItems.items!) {
        if (item.id != null) {
          int existingIndex = _itemsByCategory[categoryID]!.indexWhere((i) => i.id == item.id);
          if (existingIndex != -1) {
            _itemsByCategory[categoryID]![existingIndex] = item;
          } else {
            _itemsByCategory[categoryID]!.add(item);
          }
        }
      }
      _totalPageSize = fetchedItems.totalSize;
      _isOverallLoading = false;
    }

    _loadingStatusByCategory[categoryID] = false;
    update();
  }

  void clearCategoryCache() {
    _itemsByCategory.clear();
    _loadingStatusByCategory.clear();
    if (_categoryList != null && _categoryList!.isNotEmpty) {
      for (var cat in _categoryList!) {
        if (cat.id != null) {
          fetchItemsForCategory(cat.id.toString(), 1, 'all', true);
        }
      }
    }
    update();
  }
  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryItemList = null;
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if (subCategoryList != null) {
      _subCategoryList= [];
      _subCategoryList!.add(CategoryModel(id: int.parse(categoryID!), name: 'all'.tr));
      _subCategoryList!.addAll(subCategoryList);
      if (_isStore) {
        getCategoryStoreList(categoryID, 1, 'all', false);
      } else {
        getCategoryItemList(categoryID, 1, 'all', false);
      }
    }
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    if(_isStore) {
      getCategoryStoreList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }else {
      getCategoryItemList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }
  }

  void getCategoryItemList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryItemList = null;
    }
    ItemModel? categoryItem = await categoryServiceInterface.getCategoryItemList(categoryID, offset, type);
    if (categoryItem != null) {
      if (offset == 1) {
        _categoryItemList = [];
      }
      _categoryItemList!.addAll(categoryItem.items!);
      _pageSize = categoryItem.totalSize;
      _isLoading = false;
    }
    update();
  }

  void getCategoryStoreList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryStoreList = null;
    }
    StoreModel? categoryStore = await categoryServiceInterface.getCategoryStoreList(categoryID, offset, type);
    if (categoryStore != null) {
      if (offset == 1) {
        _categoryStoreList = [];
      }
      _categoryStoreList!.addAll(categoryStore.stores!);
      _restPageSize = categoryStore.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if((_isStore && query!.isNotEmpty) || (!_isStore && query!.isNotEmpty /*&& query != _itemResultText*/)) {
      _searchText = query;
      _type = type;
      _isStore ? _searchStoreList = null : _searchItemList = null;
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(query, categoryID, _isStore, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          _isStore ? _searchStoreList = [] : _searchItemList = [];
        } else {
          if (_isStore) {
            _searchStoreList = [];
            _searchStoreList!.addAll(StoreModel.fromJson(response.body).stores!);
            update();
          } else {
            _searchItemList = [];
            _searchItemList!.addAll(ItemModel.fromJson(response.body).items!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchItemList = [];
    if(_categoryItemList != null) {
      _searchItemList!.addAll(_categoryItemList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<bool> saveInterest(List<int?> interests) async {
    _isLoading = true;
    update();
    bool isSuccess = await categoryServiceInterface.saveUserInterests(interests);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void addInterestSelection(int index) {
    _interestSelectedList![index] = !_interestSelectedList![index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isStore = isRestaurant;
    update();
  }

}
