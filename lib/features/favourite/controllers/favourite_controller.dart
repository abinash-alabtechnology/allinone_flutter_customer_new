import 'package:flutter/material.dart';
import 'package:handy_allinone/common/models/response_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/favourite/domain/services/favourite_service_interface.dart';

class FavouriteController extends GetxController implements GetxService {
  final FavouriteServiceInterface favouriteServiceInterface;
  FavouriteController({required this.favouriteServiceInterface});

  List<Item?>? _wishItemList;
  List<Item?>? get wishItemList => _wishItemList;

  List<Store?>? _wishStoreList;
  List<Store?>? get wishStoreList => _wishStoreList;

  List<int?> _wishItemIdList = [];
  List<int?> get wishItemIdList => _wishItemIdList;

  List<int?> _wishStoreIdList = [];
  List<int?> get wishStoreIdList => _wishStoreIdList;

  bool _isRemoving = false;
  bool get isRemoving => _isRemoving;

  void addToFavouriteList(Item? product, int? storeID, bool isStore, {bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();
    if(isStore) {
      _wishStoreList ??= [];
      _wishStoreIdList.add(storeID);
      _wishStoreList!.add(Store());
    }else{
      _wishItemList ??= [];
      _wishItemList!.add(product);
      _wishItemIdList.add(product!.id);
    }
    ResponseModel responseModel = await favouriteServiceInterface.addFavouriteList(isStore ? storeID : product!.id, isStore);
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
    } else {
      if(isStore) {
        _wishStoreIdList.remove(storeID);
        _wishStoreList?.removeWhere((store) => store?.id == storeID);
      }else{
        _wishItemIdList.remove(product!.id);
        _wishItemList?.removeWhere((item) => item?.id == product.id);
      }
      showCustomSnackBar(responseModel.message, isError: true, getXSnackBar: getXSnackBar);
    }
    _isRemoving = false;
    update();
  }

  void removeFromFavouriteList(int? id, bool isStore, {bool getXSnackBar = false}) async {


    _isRemoving = true;
    update();

    int idIndex = -1;
    int? storeId, itemId;
    Store? store;
    Item? item;
    if(isStore) {
      idIndex = _wishStoreIdList.indexOf(id);
      if(idIndex != -1) {
        storeId = id;
        _wishStoreIdList.removeAt(idIndex);
        store = _wishStoreList![idIndex];
        _wishStoreList!.removeAt(idIndex);
      }
    }else {
      idIndex = _wishItemIdList.indexOf(id);
      if(idIndex != -1) {
        itemId = id;
        _wishItemIdList.removeAt(idIndex);
        item = _wishItemList![idIndex];
        _wishItemList!.removeAt(idIndex);
      }
    }
    ResponseModel responseModel = await favouriteServiceInterface.removeFavouriteList(id, isStore);
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
    }
    else {
      showCustomSnackBar(responseModel.message, isError: true, getXSnackBar: getXSnackBar);
      if(isStore) {
        _wishStoreIdList.add(storeId);
        _wishStoreList!.add(store);
      }else {
        _wishItemIdList.add(itemId);
        _wishItemList!.add(item);
      }
    }
    _isRemoving = false;
    update();
  }

  Future<void> getFavouriteList() async {
    _wishItemList = null;
    _wishStoreList = null;
    Response response = await favouriteServiceInterface.getFavouriteList();
    if (response.statusCode == 200) {
      update();
      _wishItemList = [];
      _wishStoreList = [];
      _wishStoreIdList = [];
      _wishItemIdList = [];

      if(response.body['item'] != null) {
        response.body['item'].forEach((item) {
          Item i = Item.fromJson(item);
          _wishItemList!.add(i);
          _wishItemIdList.add(i.id);
        });
      }

      if(response.body['store'] != null) {
        response.body['store'].forEach((store) {
          Store? s;
          try{
            s = Store.fromJson(store);
          }catch(e){
            debugPrint('exception create in store list create : $e');
          }
          if(s != null) {
            _wishStoreList!.add(s);
            _wishStoreIdList.add(s.id);
          }
        });
      }
    }
    update();
  }

  void removeFavourite() {
    _wishItemIdList = [];
    _wishStoreIdList = [];
  }

}
