import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/cart/domain/models/cart_model.dart';
import 'package:handy_allinone/features/cart/domain/models/online_cart_model.dart';
import 'package:handy_allinone/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/module_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';

class CartRepository implements CartRepositoryInterface<OnlineCart> {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepository({required this.apiClient, required this.sharedPreferences});

  Map<String, String> _getCartHeader([int? customModuleId]) {
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    int? modId = customModuleId;
    if (modId == null || modId == 0) {
      if (Get.isRegistered<HandymanHomeController>()) {
        if (Get.isRegistered<SplashController>()) {
          modId = Get.find<SplashController>().getHandymanModuleId();
        } else {
          modId = 10;
        }
      } else {
        modId =
            ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;
        if (modId == null || modId == 0) {
          if (Get.isRegistered<SplashController>()) {
            final splash = Get.find<SplashController>();
            modId = splash.module?.id ?? splash.cacheModule?.id;
            if (modId == null || modId == 0) {
              modId = splash.getHandymanModuleId();
            }
          }
        }
      }
    }
    if (modId != null && modId > 0) {
      reqHeaders[AppConstants.moduleId] = modId.toString();
    }
    return reqHeaders;
  }

  @override
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    if (sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<String> cartStringList = [];
    for (String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if (cartModel.item!.moduleId != _getModuleId()) {
        cartStringList.add(cartString);
      }
    }
    for (CartModel cartModel in cartProductList) {
      cartStringList.add(jsonEncode(cartModel.toJson()));
    }
    await sharedPreferences.setStringList(
      AppConstants.cartList,
      cartStringList,
    );
  }

  int _getModuleId() {
    return ModuleHelper.getModule()?.id ??
        ModuleHelper.getCacheModule()?.id ??
        0;
  }

  @override
  Future add(OnlineCart cart) async {
    return await _addToCartOnline(cart);
  }

  Future<List<OnlineCartModel>?> _addToCartOnline(OnlineCart cart) async {
    List<OnlineCartModel>? onlineCartList;
    int? itemModId;
    if (Get.isRegistered<HandymanHomeController>()) {
      if (Get.isRegistered<SplashController>()) {
        itemModId = Get.find<SplashController>().getHandymanModuleId();
      } else {
        itemModId = 10;
      }
    }
    Response response = await apiClient.postData(
      '${AppConstants.addCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      cart.toJson(),
      headers: _getCartHeader(itemModId),
    );
    if (response.statusCode == 200) {
      onlineCartList = [];
      response.body.forEach(
        (c) => onlineCartList!.add(OnlineCartModel.fromJson(c)),
      );
    } else if (response.statusCode == 403 ||
        (response.body is Map &&
            response.body.toString().contains('Item already exists'))) {
      // Remove stale duplicate item in backend cart and re-add with current module ID
      if (cart.itemId != null) {
        await apiClient.deleteData(
          '${AppConstants.removeItemCartUri}?cart_id=${cart.itemId}${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}',
          headers: _getCartHeader(itemModId),
        );
      }
      response = await apiClient.postData(
        '${AppConstants.addCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
        cart.toJson(),
        headers: _getCartHeader(itemModId),
      );
      if (response.statusCode == 200) {
        onlineCartList = [];
        response.body.forEach(
          (c) => onlineCartList!.add(OnlineCartModel.fromJson(c)),
        );
      } else {
        onlineCartList = await _getCartDataOnline();
      }
    }
    return onlineCartList;
  }

  @override
  Future<bool> delete(int? id, {bool isRemoveAll = false}) async {
    if (isRemoveAll) {
      return await _clearCartOnline();
    } else {
      return await _removeCartItemOnline(id!);
    }
  }

  Future<bool> _removeCartItemOnline(int cartId) async {
    Response response = await apiClient.deleteData(
      '${AppConstants.removeItemCartUri}?cart_id=$cartId${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}',
      headers: _getCartHeader(),
    );
    return (response.statusCode == 200);
  }

  Future<bool> _clearCartOnline() async {
    Response response = await apiClient.deleteData(
      '${AppConstants.removeAllCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      headers: _getCartHeader(),
    );
    return (response.statusCode == 200);
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return await _getCartDataOnline();
  }

  Future<List<OnlineCartModel>?> _getCartDataOnline() async {
    List<OnlineCartModel>? onlineCartList;
    Response response = await apiClient.getData(
      '${AppConstants.getCartListUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      headers: _getCartHeader(),
    );
    if (response.statusCode == 200) {
      onlineCartList = [];
      response.body.forEach(
        (cart) => onlineCartList!.add(OnlineCartModel.fromJson(cart)),
      );
    }
    return onlineCartList;
  }

  @override
  Future update(
    Map<String, dynamic> body,
    int? id, {
    double? price,
    int? quantity,
    bool isUpdateQty = false,
  }) async {
    if (isUpdateQty) {
      return await _updateCartQuantityOnline(id!, price!, quantity!);
    } else {
      return await _updateCartOnline(body);
    }
  }

  Future<List<OnlineCartModel>?> _updateCartOnline(
    Map<String, dynamic> body,
  ) async {
    List<OnlineCartModel>? onlineCartList;
    Response response = await apiClient.postData(
      '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      body,
      headers: _getCartHeader(),
    );
    if (response.statusCode == 200) {
      onlineCartList = [];
      response.body.forEach(
        (cart) => onlineCartList!.add(OnlineCartModel.fromJson(cart)),
      );
    }
    return onlineCartList;
  }

  Future<bool> _updateCartQuantityOnline(
    int cartId,
    double price,
    int quantity,
  ) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    Response response = await apiClient.postData(
      '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      data,
      headers: _getCartHeader(),
    );
    return (response.statusCode == 200);
  }
}
