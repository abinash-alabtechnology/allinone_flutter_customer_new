import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/common/models/module_model.dart';
import 'package:handy_allinone/features/cart/domain/models/cart_model.dart';
import 'package:handy_allinone/features/cart/domain/models/online_cart_model.dart';
import 'package:handy_allinone/features/cart/domain/services/cart_service_interface.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/features/home/screens/home_screen.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/module_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOns = 0;
  double get addOns => _addOns;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  List<String> notAvailableList = [
    'Remove it from my cart',
    'Notify me when it’s back in stock',
    'Suggest similar products',
  ];
  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  int? _directAddCartItemIndex = -1;
  int? get directAddCartItemIndex => _directAddCartItemIndex;

  void setDirectlyAddToCartIndex(int? index) {
    _directAddCartItemIndex = index;
  }

  int? _loadingItemId;
  int? get loadingItemId => _loadingItemId;

  void setLoadingItemId(int? id) {
    _loadingItemId = id;
    update();
  }

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    update();
  }

  bool _isSubscriptionLoading = false;
  bool get isSubscriptionLoading => _isSubscriptionLoading;

  void setSubscriptionLoading(bool status) {
    _isSubscriptionLoading = status;
    update();
  }

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if (willUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex = cartServiceInterface.availableSelectedIndex(
      _notAvailableIndex,
      index,
    );
    if (willUpdate) {
      update();
    }
  }

  void updateCutlery({bool willUpdate = true}) {
    _addCutlery = !_addCutlery;
    if (willUpdate) {
      update();
    }
  }

  Future<void> forcefullySetModule(int moduleId) async {
    ModuleModel? module = cartServiceInterface.forcefullySetModule(
      Get.find<SplashController>().module,
      Get.find<SplashController>().moduleList,
      moduleId,
    );
    if (module != null) {
      await Get.find<SplashController>().setModule(module);
      HomeScreen.loadData(true);
    }
  }

  void filterCartByCurrentModule() {
    final activeModule =
        ModuleHelper.getModule() ?? ModuleHelper.getCacheModule();
    if (activeModule == null) return;

    _cartList.removeWhere((cartModel) {
      if (cartModel.item == null) return true;

      bool matches = false;

      if (activeModule.id != null &&
          activeModule.id! > 0 &&
          cartModel.item!.moduleId != null &&
          cartModel.item!.moduleId! > 0) {
        if (cartModel.item!.moduleId == activeModule.id) {
          matches = true;
        }
      }

      if (activeModule.moduleType != null &&
          activeModule.moduleType!.isNotEmpty &&
          cartModel.item!.moduleType != null &&
          cartModel.item!.moduleType!.isNotEmpty) {
        if (cartModel.item!.moduleType!.toLowerCase() ==
            activeModule.moduleType!.toLowerCase()) {
          matches = true;
        }
      }

      if (activeModule.id == null &&
          (activeModule.moduleType == null ||
              activeModule.moduleType!.isEmpty)) {
        matches = true;
      }

      return !matches;
    });
  }

  double calculationCart() {
    filterCartByCurrentModule();
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    _variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    for (var cartModel in cartList) {
      isFoodVariation = ModuleHelper.getModuleConfig(
        cartModel.item!.moduleType,
      ).newVariation!;
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(
        DateConverter.isAvailable(
          cartModel.item!.availableTimeStarts,
          cartModel.item!.availableTimeEnds,
        ),
      );

      _addOns = cartServiceInterface.calculateAddonPrice(
        _addOns,
        addOnList,
        cartModel,
      );

      _variationPrice = cartServiceInterface.calculateVariationPrice(
        isFoodVariation,
        cartModel,
        discount,
        discountType,
        _variationPrice,
      );

      variationWithoutDiscountPrice = cartServiceInterface
          .calculateVariationWithoutDiscountPrice(
            isFoodVariation,
            cartModel,
            variationWithoutDiscountPrice,
          );
      haveVariation = cartServiceInterface.checkVariation(
        isFoodVariation,
        cartModel,
      );

      double price = haveVariation
          ? variationWithoutDiscountPrice
          : (cartModel.item!.price! * (cartModel.quantity ?? 1));
      double discountPrice = haveVariation
          ? (variationWithoutDiscountPrice - _variationPrice)
          : (price -
                (PriceConverter.convertWithDiscount(
                      cartModel.item!.price!,
                      discount,
                      discountType,
                    )! *
                    (cartModel.quantity ?? 1)));

      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    if (isFoodVariation) {
      _itemDiscountPrice =
          _itemDiscountPrice +
          (variationWithoutDiscountPrice - _variationPrice);
      _variationPrice = variationWithoutDiscountPrice;
      _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;
    } else {
      _subTotal = (_itemPrice - _itemDiscountPrice);
    }

    return _subTotal;
  }

  Future<void> addToCart(CartModel cartModel, int? index) async {
    if (index != null && index != -1) {
      _cartList.replaceRange(index, index + 1, [cartModel]);
    } else {
      _cartList.add(cartModel);
    }
    Get.find<ItemController>().setExistInCart(
      cartModel.item,
      null,
      notify: true,
    );
    await cartServiceInterface.addSharedPrefCartList(_cartList);

    calculationCart();
    if (Get.isRegistered<HandymanHomeController>()) {
      Get.find<HandymanHomeController>().syncWithCartController();
    }
    update();
  }

  int? getCartId(int cartIndex) {
    return cartServiceInterface.getCartId(cartIndex, _cartList);
  }

  Future<void> setQuantity(
    bool isIncrement,
    int cartIndex,
    int? stock,
    int? quantityLimit,
  ) async {
    if (_isLoading) return;

    final stopwatch = Stopwatch()..start();

    _isLoading = true;

    final cartItem = _cartList[cartIndex];
    _loadingItemId = cartItem.item?.id;

    final newQty = await cartServiceInterface.decideItemQuantity(
      isIncrement,
      _cartList,
      cartIndex,
      stock,
      quantityLimit,
      Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ??
          false,
    );

    if (newQty == cartItem.quantity) {
      _isLoading = false;
      _loadingItemId = null;
      return;
    }

    cartItem.quantity = newQty;
    calculationCart();
    if (Get.isRegistered<HandymanHomeController>()) {
      Get.find<HandymanHomeController>().syncWithCartController();
    }
    update();

    unawaited(() async {
      final moduleConfig = ModuleHelper.getModuleConfig(
        cartItem.item!.moduleType,
      );
      final hasNewVariation = moduleConfig.newVariation ?? false;

      final discountedPrice = await cartServiceInterface
          .calculateDiscountedPrice(cartItem, newQty, hasNewVariation);

      if (cartItem.id != null) {
        await updateCartQuantityOnline(cartItem.id!, discountedPrice, newQty);
      }

      if (hasNewVariation) {
        await Get.find<ItemController>().setExistInCart(
          cartItem.item,
          null,
          notify: false,
        );
      }

      _isLoading = false;
      _loadingItemId = null;
      update();
    }());

    stopwatch.stop();
    debugPrint('setQuantity triggered in ${stopwatch.elapsedMilliseconds} ms');
  }

  // Future<void> setQuantity(bool isIncrement, int cartIndex, int? stock, int ? quantityLimit) async {
  //   _isLoading = true;
  //   update();
  //
  //   _cartList[cartIndex].quantity = await cartServiceInterface.decideItemQuantity(isIncrement, _cartList, cartIndex, stock, quantityLimit, Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!);
  //
  //   double discountedPrice = await cartServiceInterface.calculateDiscountedPrice(_cartList[cartIndex], _cartList[cartIndex].quantity!, ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!);
  //   if(ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!) {
  //    await Get.find<ItemController>().setExistInCart(_cartList[cartIndex].item, null, notify: true);
  //   }
  //
  //   await updateCartQuantityOnline(_cartList[cartIndex].id!, discountedPrice, _cartList[cartIndex].quantity!);
  //
  // }

  Future<void> removeFromCart(int index, {Item? item}) async {
    int cartId = _cartList[index].id!;
    _loadingItemId = _cartList[index].item?.id;
    _cartList.removeAt(index);
    calculationCart();
    if (Get.isRegistered<HandymanHomeController>()) {
      Get.find<HandymanHomeController>().syncWithCartController();
    }
    update();
    Get.find<ItemController>().cartIndexSet();
    await removeCartItemOnline(cartId, item: item);
    if (Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }
    _loadingItemId = null;
    update();
  }

  Future<void> clearCartList({bool canRemoveOnline = true}) async {
    _cartList = [];
    calculationCart();
    if (Get.isRegistered<HandymanHomeController>()) {
      Get.find<HandymanHomeController>().syncWithCartController();
    }
    update();
    if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
        (ModuleHelper.getModule() != null ||
            ModuleHelper.getCacheModule() != null) &&
        canRemoveOnline) {
      clearCartOnline();
    }
  }

  int isExistInCart(
    int? itemID,
    String variationType,
    bool isUpdate,
    int? cartIndex,
  ) {
    return cartServiceInterface.isExistInCart(
      _cartList,
      itemID,
      variationType,
      isUpdate,
      cartIndex,
    );
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    return cartServiceInterface.existAnotherStoreItem(
      storeID,
      moduleId,
      _cartList,
    );
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  Future<bool> addToCartOnline(OnlineCart cart) async {
    if (cart.isSubscribed == true) {
      _isSubscriptionLoading = true;
    } else {
      _isLoading = true;
    }
    _loadingItemId = cart.itemId;
    bool success = false;
    update();
    try {
      List<OnlineCartModel>? onlineCartList = await cartServiceInterface
          .addToCartOnline(cart);
      if (onlineCartList != null) {
        _cartList = [];
        _cartList.addAll(
          cartServiceInterface.formatOnlineCartToLocalCart(
            onlineCartModel: onlineCartList,
          ),
        );
        calculationCart();
        success = true;
      } else {
        await getCartDataOnline();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in addToCartOnline: $e');
      }
    }
    _isLoading = false;
    _isSubscriptionLoading = false;
    _loadingItemId = null;
    update();

    return success;
  }

  Future<bool> updateCartOnline(OnlineCart cart) async {
    _isLoading = true;
    _loadingItemId = cart.itemId;
    bool success = false;
    update();
    try {
      List<OnlineCartModel>? onlineCartList = await cartServiceInterface
          .updateCartOnline(cart);
      if (onlineCartList != null) {
        _cartList = [];
        _cartList.addAll(
          cartServiceInterface.formatOnlineCartToLocalCart(
            onlineCartModel: onlineCartList,
          ),
        );
        calculationCart();
        success = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateCartOnline: $e');
      }
    }
    _isLoading = false;
    _loadingItemId = null;
    update();

    return success;
  }

  Future<void> updateCartQuantityOnline(
    int cartId,
    double price,
    int quantity,
  ) async {
    _isLoading = true;
    update();
    try {
      bool success = await cartServiceInterface.updateCartQuantityOnline(
        cartId,
        price,
        quantity,
      );
      if (success) {
        await getCartDataOnline();
        calculationCart();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateCartQuantityOnline: $e');
      }
    }
    _isLoading = false;
    _loadingItemId = null;
    update();
  }

  Future<void> getCartDataOnline({bool isSubscription = false}) async {
    if (ModuleHelper.getModule() != null ||
        ModuleHelper.getCacheModule() != null ||
        Get.isRegistered<HandymanHomeController>() ||
        Get.isRegistered<SplashController>()) {
      if (isSubscription) {
        _isSubscriptionLoading = true;
      } else {
        _isLoading = true;
      }
      try {
        List<OnlineCartModel>? onlineCartList = await cartServiceInterface
            .getCartDataOnline();
        if (onlineCartList != null) {
          _cartList = [];
          _cartList.addAll(
            cartServiceInterface.formatOnlineCartToLocalCart(
              onlineCartModel: onlineCartList,
            ),
          );
          calculationCart();
          if (Get.isRegistered<HandymanHomeController>()) {
            Get.find<HandymanHomeController>().syncWithCartController();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error in getCartDataOnline: $e');
        }
      }
      _isLoading = false;
      _isSubscriptionLoading = false;
      _loadingItemId = null;
      update();
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item}) async {
    _isLoading = true;
    if (item != null) {
      _loadingItemId = item.id;
    }
    int index = _cartList.indexWhere((element) => element.id == cartId);
    if (index != -1) {
      _cartList.removeAt(index);
      calculationCart();
      if (Get.isRegistered<HandymanHomeController>()) {
        Get.find<HandymanHomeController>().syncWithCartController();
      }
    }
    update();
    bool success = await cartServiceInterface.removeCartItemOnline(cartId);
    if (success) {
      await getCartDataOnline();
      if (item != null) {
        Get.find<ItemController>().setExistInCart(item, null, notify: true);
      }
    }
    _isLoading = false;
    _loadingItemId = null;
    update();
    return success;
  }

  Future<bool> clearCartOnline({bool isSubscription = false}) async {
    if (isSubscription) {
      _isSubscriptionLoading = true;
    } else {
      _isLoading = true;
    }
    _cartList = [];
    calculationCart();
    if (Get.isRegistered<HandymanHomeController>()) {
      Get.find<HandymanHomeController>().syncWithCartController();
    }
    update();
    bool success = await cartServiceInterface.clearCartOnline();
    if (success) {
      await getCartDataOnline(isSubscription: isSubscription);
    }
    _isLoading = false;
    _isSubscriptionLoading = false;
    _loadingItemId = null;
    update();
    return success;
  }

  int cartQuantity(int itemId) {
    return cartServiceInterface.cartQuantity(itemId, _cartList);
  }

  String cartVariant(int itemId) {
    return cartServiceInterface.cartVariant(itemId, _cartList);
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }
}
