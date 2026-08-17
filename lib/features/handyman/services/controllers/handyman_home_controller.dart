import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/cart/domain/models/cart_model.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_booking_model.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/item/domain/services/item_service_interface.dart';

import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/confirmation_dialog.dart';

class CategorySectionModel {
  final int? categoryId;
  final String title;
  final String subtitle;
  final List<HandymanServiceModel> services;

  CategorySectionModel({
    this.categoryId,
    required this.title,
    required this.subtitle,
    required this.services,
  });
}

class HandymanHomeController extends GetxController {
  // ─── Master State ──────────────────────────────────────────────────────────
  final RxMap<String, HandymanServiceModel> allServices =
      <String, HandymanServiceModel>{}.obs;

  // ─── UI References ─────────────────────────────────────────────────────────
  final RxList<HandymanServiceModel> mostBookedServices =
      <HandymanServiceModel>[].obs;
  final RxList<CategorySectionModel> categorySections =
      <CategorySectionModel>[].obs;
  final RxList<HandymanBookingModel> bookings = <HandymanBookingModel>[].obs;

  final RxBool isLoading = false.obs;

  // ─── Service Type Selection (home_service / store_visit) ───────────────────
  String _selectedServiceType = 'home_service';
  bool hasPromptedServiceTypeSelection = false;
  String get selectedServiceType => _selectedServiceType;

  void updateServiceType(String type, {bool reload = true}) {
    _selectedServiceType = type;
    update();
    if (reload) {
      clearAndRefetchServices();
    }
  }

  void clearAndRefetchServices() {
    if (Get.isRegistered<CategoryController>()) {
      Get.find<CategoryController>().clearCategoryCache();
    }
    if (Get.isRegistered<FavouriteController>()) {
      Get.find<FavouriteController>().getFavouriteList();
    }
    update();
  }

  // ─── Derived ─────────────────────────────────────────────────────────────────
  int get totalCartItems {
    int total = 0;
    for (final s in allServices.values) {
      total += s.cartQuantity;
    }
    return total;
  }

  int getServiceQuantity(String serviceId) {
    int? itemId = int.tryParse(serviceId);

    if (allServices.containsKey(serviceId) && allServices[serviceId]!.cartQuantity > 0) {
      return allServices[serviceId]!.cartQuantity;
    }

    for (var section in categorySections) {
      final match = section.services.firstWhereOrNull((s) => s.id == serviceId || (itemId != null && int.tryParse(s.id) == itemId));
      if (match != null && match.cartQuantity > 0) {
        return match.cartQuantity;
      }
    }

    final mb = mostBookedServices.firstWhereOrNull((s) => s.id == serviceId || (itemId != null && int.tryParse(s.id) == itemId));
    if (mb != null && mb.cartQuantity > 0) {
      return mb.cartQuantity;
    }

    if (Get.isRegistered<CartController>()) {
      final cartList = Get.find<CartController>().cartList;
      for (var c in cartList) {
        if (c.item != null) {
          if (itemId != null && c.item!.id == itemId) {
            return c.quantity ?? 0;
          }
          String idStr = c.item!.id.toString();
          if (idStr == serviceId) {
            return c.quantity ?? 0;
          }
        }
      }
    }

    return 0;
  }

  int getHandymanModuleId() {
    if (Get.isRegistered<SplashController>()) {
      final splashController = Get.find<SplashController>();
      final handymanMod = splashController.moduleList?.firstWhereOrNull((m) {
        String title = m.moduleName?.toLowerCase() ?? '';
        String mType = m.moduleType?.toLowerCase() ?? '';
        return title.contains('handyman') || mType.contains('handyman');
      });
      if (handymanMod != null && handymanMod.id != null) {
        return handymanMod.id!;
      }
      if (splashController.module != null &&
          (splashController.module!.moduleType?.toLowerCase() == 'handyman' ||
           splashController.module!.moduleName?.toLowerCase().contains('handyman') == true)) {
        return splashController.module!.id!;
      }
      if (splashController.cacheModule != null &&
          (splashController.cacheModule!.moduleType?.toLowerCase() == 'handyman' ||
           splashController.cacheModule!.moduleName?.toLowerCase().contains('handyman') == true)) {
        return splashController.cacheModule!.id!;
      }
    }
    return 10;
  }

  List<HandymanServiceModel> get wishlistedServices {
    int activeModuleId = getHandymanModuleId();

    if (Get.isRegistered<FavouriteController>()) {
      final favController = Get.find<FavouriteController>();
      if (favController.wishItemList != null && favController.wishItemList!.isNotEmpty) {
        final apiWishList = <HandymanServiceModel>[];
        for (var item in favController.wishItemList!) {
          if (item != null) {
            bool isHandymanModule = item.moduleId == activeModuleId ||
                (item.moduleType?.toLowerCase() == 'handyman');
            if (isHandymanModule) {
              apiWishList.add(HandymanServiceModel.fromItem(item));
            }
          }
        }
        return apiWishList;
      }
    }
    return allServices.values.where((s) => s.isWishlisted).toList();
  }

  List<HandymanServiceModel> get cartServices {
    return allServices.values.where((s) => s.cartQuantity > 0).toList();
  }

  int get cartTotalPrice {
    int total = 0;
    for (final s in cartServices) {
      total += s.startingPrice * s.cartQuantity;
    }
    return total;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────
  bool isServiceWishlisted(String serviceId) {
    int? itemId = int.tryParse(serviceId);
    if (Get.isRegistered<FavouriteController>() && itemId != null) {
      if (Get.find<FavouriteController>().wishItemIdList.contains(itemId)) {
        return true;
      }
    }
    final s = allServices[serviceId];
    return s?.isWishlisted ?? false;
  }

  void toggleWishlist(String serviceId) {
    final s = allServices[serviceId];
    int? itemId = int.tryParse(serviceId);
    if (Get.isRegistered<FavouriteController>() && itemId != null) {
      final favController = Get.find<FavouriteController>();
      bool currentlyWishlisted = favController.wishItemIdList.contains(itemId) || (s?.isWishlisted ?? false);
      if (currentlyWishlisted) {
        favController.removeFromFavouriteList(itemId, false, getXSnackBar: true);
        if (s != null) s.isWishlisted = false;
      } else {
        favController.addToFavouriteList(Item(id: itemId), null, false, getXSnackBar: true);
        if (s != null) s.isWishlisted = true;
      }
    } else if (s != null) {
      s.isWishlisted = !s.isWishlisted;
    }
    _refreshAll();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().getCartDataOnline().then((_) {
        syncWithCartController();
      });
    }
  }

  void syncWithCartController({bool notify = true}) {
    if (!Get.isRegistered<CartController>()) return;
    final cartList = Get.find<CartController>().cartList;

    for (var s in allServices.values) {
      s.cartQuantity = 0;
      for (var o in s.options) {
        o.quantity = 0;
      }
    }
    for (var m in mostBookedServices) {
      m.cartQuantity = 0;
    }
    for (var section in categorySections) {
      for (var s in section.services) {
        s.cartQuantity = 0;
      }
    }

    int handymanModuleId = getHandymanModuleId();

    for (var cart in cartList) {
      if (cart.item != null) {
        bool isHandymanModule = cart.item!.moduleId == handymanModuleId ||
            (cart.item!.moduleType?.toLowerCase() == 'handyman');

        if (!isHandymanModule) {
          continue;
        }

        String idStr = cart.item!.id.toString();
        String itemName = cart.item!.name?.toLowerCase().trim() ?? '';
        int cartQty = cart.quantity ?? 0;

        if (!allServices.containsKey(idStr)) {
          allServices[idStr] = HandymanServiceModel.fromItem(cart.item!);
        }
        allServices[idStr]!.cartQuantity = cartQty;
        if (allServices[idStr]!.options.length == 1) {
          allServices[idStr]!.options[0].quantity = cartQty;
        }

        for (var m in mostBookedServices) {
          String mName = m.name.toLowerCase().trim();
          if (m.id == idStr || (itemName.isNotEmpty && (mName.contains(itemName) || itemName.contains(mName)))) {
            m.cartQuantity = cartQty;
            allServices[m.id]?.cartQuantity = cartQty;
          }
        }

        for (var section in categorySections) {
          for (var s in section.services) {
            String sName = s.name.toLowerCase().trim();
            if (s.id == idStr || (itemName.isNotEmpty && (sName.contains(itemName) || itemName.contains(sName)))) {
              s.cartQuantity = cartQty;
              allServices[s.id]?.cartQuantity = cartQty;
            }
          }
        }
      }
    }

    if (notify) {
      allServices.refresh();
      mostBookedServices.refresh();
      categorySections.refresh();
      update();
    }
  }

  Future<bool> addToCart(String serviceId, {HandymanServiceModel? serviceModel}) async {
    if (serviceModel != null) {
      allServices[serviceId] = serviceModel;
    }

    HandymanServiceModel? s = allServices[serviceId];

    if (s == null) {
      for (final section in categorySections) {
        final match = section.services.firstWhereOrNull((element) => element.id == serviceId);
        if (match != null) {
          s = match;
          allServices[serviceId] = match;
          break;
        }
      }
    }
    if (s == null) {
      final match = mostBookedServices.firstWhereOrNull((element) => element.id == serviceId);
      if (match != null) {
        s = match;
        allServices[serviceId] = match;
      }
    }

    int? parsedId = int.tryParse(serviceId);
    int itemId = parsedId ?? (serviceId.hashCode & 0x7FFFFFFF);

    if (parsedId != null && (s == null || s.startingPrice <= 0 || s.storeId == null) && Get.isRegistered<ItemServiceInterface>()) {
      try {
        Item? fetchedItem = await Get.find<ItemServiceInterface>().getItemDetails(parsedId);
        if (fetchedItem != null) {
          s = HandymanServiceModel.fromItem(fetchedItem);
          allServices[serviceId] = s;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching item details for cart: $e');
        }
      }
    }

    if (Get.isRegistered<CartController>()) {
      final cartController = Get.find<CartController>();
      int cartIndex = cartController.cartList.indexWhere((c) {
        if (c.item?.id == itemId) return true;
        if (s != null && c.item?.name != null && c.item!.name!.toLowerCase().trim() == s.name.toLowerCase().trim()) return true;
        return false;
      });

      double calculatedPrice = 0.0;
      if (s != null && s.startingPrice > 0) {
        calculatedPrice = s.startingPrice.toDouble();
      } else if (s != null && s.options.isNotEmpty) {
        final firstOpt = s.options.first;
        calculatedPrice = (firstOpt.discountedPrice > 0 ? firstOpt.discountedPrice : firstOpt.originalPrice).toDouble();
      }

      if (cartIndex != -1) {
        final cartModel = cartController.cartList[cartIndex];
        int newQty = (cartModel.quantity ?? 0) + 1;
        cartModel.quantity = newQty;
        if (s != null) {
          s.cartQuantity = newQty;
          if (s.options.length == 1) s.options[0].quantity = newQty;
        }
        _refreshAll();
        cartController.calculationCart();
        cartController.update();

        if (parsedId != null && cartModel.id != null) {
          double finalPrice = calculatedPrice > 0 ? calculatedPrice : (cartModel.price ?? 0.0);
          unawaited(cartController.updateCartQuantityOnline(
            cartModel.id!,
            finalPrice,
            newQty,
          ));
        }
        return true;
      } else {
        int? targetStoreId = s?.storeId;
        int activeModuleId = getHandymanModuleId();

        bool isAnotherStore = false;
        final handymanCartItems = cartController.cartList.where((cartModel) {
          if (cartModel.item == null) return false;
          bool isHandyman = cartModel.item!.moduleId == activeModuleId ||
              (cartModel.item!.moduleType?.toLowerCase() == 'handyman');
          return isHandyman;
        }).toList();

        if (handymanCartItems.isNotEmpty) {
          for (var cartModel in handymanCartItems) {
            if (cartModel.item != null && targetStoreId != null && cartModel.item!.storeId != null) {
              if (cartModel.item!.storeId != targetStoreId) {
                isAnotherStore = true;
                break;
              }
            }
          }
        }

        if (isAnotherStore) {
          Completer<bool> completer = Completer<bool>();
          Get.dialog(
            ConfirmationDialog(
              icon: Images.warning,
              title: 'are_you_sure_to_reset'.tr,
              description: 'if_you_continue_from_another_provider'.tr,
              onYesPressed: () async {
                Get.back();
                await clearCart();
                _performAddToCart(
                  s: s,
                  serviceId: serviceId,
                  itemId: itemId,
                  parsedId: parsedId,
                  calculatedPrice: calculatedPrice,
                  cartController: cartController,
                );
                completer.complete(true);
              },
              onNoPressed: () {
                Get.back();
                completer.complete(false);
              },
            ),
            barrierDismissible: false,
          );
          return completer.future;
        } else {
          _performAddToCart(
            s: s,
            serviceId: serviceId,
            itemId: itemId,
            parsedId: parsedId,
            calculatedPrice: calculatedPrice,
            cartController: cartController,
          );
          return true;
        }
      }
    } else {
      if (s != null) {
        s.cartQuantity++;
        if (s.options.length == 1) s.options[0].quantity++;
        _refreshAll();
      }
      return true;
    }
  }

  void _performAddToCart({
    required HandymanServiceModel? s,
    required String serviceId,
    required int itemId,
    required int? parsedId,
    required double calculatedPrice,
    required CartController cartController,
  }) {
    if (s != null) {
      s.cartQuantity = 1;
      if (s.options.length == 1) s.options[0].quantity = 1;
    }

    int activeModuleId = getHandymanModuleId();

    int existingIndex = cartController.cartList.indexWhere((c) => c.item?.id == itemId || (s != null && c.item?.name != null && c.item!.name!.toLowerCase().trim() == s.name.toLowerCase().trim()));

    if (existingIndex != -1) {
      final existingCart = cartController.cartList[existingIndex];
      int newQty = (existingCart.quantity ?? 0) + 1;
      existingCart.quantity = newQty;
      if (s != null) {
        s.cartQuantity = newQty;
        if (s.options.length == 1) s.options[0].quantity = newQty;
      }
      _refreshAll();
      cartController.calculationCart();
      cartController.update();

      if (existingCart.id != null) {
        unawaited(cartController.updateCartQuantityOnline(
          existingCart.id!,
          calculatedPrice > 0 ? calculatedPrice : (existingCart.price ?? 0.0),
          newQty,
        ));
      }
      return;
    }

    Item itemObj = Item(
      id: itemId,
      name: s?.name ?? 'Service',
      price: calculatedPrice,
      moduleType: 'handyman',
      moduleId: activeModuleId,
      storeId: s?.storeId,
    );
    CartModel localCartModel = CartModel(
      null, calculatedPrice, 0, [], [], calculatedPrice, 1, [], [], false,
      100, itemObj, 99,
    );
    cartController.cartList.add(localCartModel);

    _refreshAll();
    cartController.calculationCart();
    cartController.update();

    if (parsedId != null) {
      OnlineCart onlineCart = OnlineCart(
        null,
        itemId,
        null,
        calculatedPrice.toString(),
        '',
        null,
        [],
        1,
        [],
        [],
        [],
        'Item',
        false,
      );
      unawaited(cartController.addToCartOnline(onlineCart).then((_) {
        syncWithCartController();
      }));
    }
  }

  Future<void> removeFromCart(String serviceId) async {
    HandymanServiceModel? s = allServices[serviceId];
    if (s == null) {
      for (final section in categorySections) {
        final match = section.services.firstWhereOrNull((element) => element.id == serviceId);
        if (match != null) {
          s = match;
          break;
        }
      }
    }
    if (s == null) {
      s = mostBookedServices.firstWhereOrNull((element) => element.id == serviceId);
    }
    
    int? parsedId = int.tryParse(serviceId);
    int itemId = parsedId ?? (serviceId.hashCode & 0x7FFFFFFF);

    if (Get.isRegistered<CartController>()) {
      final cartController = Get.find<CartController>();
      int cartIndex = cartController.cartList.indexWhere((c) {
        if (c.item?.id == itemId) return true;
        if (s != null && c.item?.name != null && c.item!.name!.toLowerCase().trim() == s.name.toLowerCase().trim()) return true;
        return false;
      });

      if (cartIndex != -1) {
        final cartModel = cartController.cartList[cartIndex];
        int currentQty = cartModel.quantity ?? 0;
        if (currentQty > 1) {
          int newQty = currentQty - 1;
          cartModel.quantity = newQty;
          if (s != null) {
            s.cartQuantity = newQty;
            if (s.options.length == 1) s.options[0].quantity = newQty;
          }
          _refreshAll();
          cartController.calculationCart();
          cartController.update();

          if (parsedId != null && cartModel.id != null) {
            unawaited(cartController.updateCartQuantityOnline(
              cartModel.id!,
              (s?.startingPrice ?? cartModel.price?.toInt() ?? 0).toDouble(),
              newQty,
            ));
          }
        } else {
          if (s != null) {
            s.cartQuantity = 0;
            if (s.options.length == 1) s.options[0].quantity = 0;
          }
          cartController.cartList.removeAt(cartIndex);
          _refreshAll();
          cartController.calculationCart();
          cartController.update();
          if (parsedId != null && cartModel.id != null) {
            await cartController.removeCartItemOnline(cartModel.id!);
          }
        }
      }
      syncWithCartController();
    } else {
      if (s != null && s.cartQuantity > 0) {
        s.cartQuantity--;
        if (s.options.length == 1 && s.options[0].quantity > 0) s.options[0].quantity--;
        _refreshAll();
      }
    }
  }

  Future<bool> addServiceToCart(String serviceId, {HandymanServiceModel? serviceModel}) async {
    return await addToCart(serviceId, serviceModel: serviceModel);
  }

  void removeServiceFromCart(String serviceId) {
    removeFromCart(serviceId);
  }

  Future<bool> addOptionToCart(String serviceId, String optionId, {HandymanServiceModel? serviceModel}) async {
    return await addToCart(serviceId, serviceModel: serviceModel);
  }

  void removeOptionFromCart(String serviceId, String optionId) {
    removeFromCart(serviceId);
  }

  Future<void> clearCart() async {
    for (final s in allServices.values) {
      s.cartQuantity = 0;
      for (final o in s.options) {
        o.quantity = 0;
      }
    }
    _refreshAll();

    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().clearCartOnline();
      syncWithCartController();
    }
  }

  void _refreshAll() {
    allServices.refresh();
    mostBookedServices.refresh();
    categorySections.refresh();
  }



  // ─── Data ────────────────────────────────────────────────────────────────────
  void _loadData() {
    isLoading.value = true;
    _initializeMasterServices();
    _loadMostBookedServices();
    _loadCategoryServices();
    _loadBookings();
    isLoading.value = false;
  }

  void _initializeMasterServices() {
    allServices.clear();
  }

  void _loadMostBookedServices() {
    mostBookedServices.clear();
  }

  void _loadCategoryServices() {
    categorySections.clear();
  }

  void _loadBookings() {
    bookings.assignAll([
      HandymanBookingModel(
        id: '100138',
        serviceName: 'Rent Ambulance',
        bookingDate: DateTime(2026, 6, 2, 16, 57),
        serviceDate: DateTime(2026, 6, 2, 16, 59),
        price: 11340.0,
        status: 'Pending',
        tasks: ['Ambulance with life support', 'Emergency ambulance'],
        timeSlot: '04:59 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Rent Ambulance',
            variantName: 'Ambulance with life support',
            quantity: 1,
            unitPrice: 8000.0,
          ),
          HandymanBookingItem(
            title: 'Rent Ambulance',
            variantName: 'Emergency ambulance',
            quantity: 1,
            unitPrice: 3000.0,
          ),
        ],
        subTotal: 11000.0,
        vat: 330.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100137',
        serviceName: 'Eyebrow & Upper Lip Threading',
        bookingDate: DateTime(2026, 6, 1, 17, 11),
        serviceDate: DateTime(2026, 6, 1, 17, 12),
        price: 938.0,
        status: 'Pending',
        tasks: ['Eyebrow threading', 'Upper lip threading'],
        timeSlot: '05:12 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Threading',
            variantName: 'Eyebrow threading',
            quantity: 1,
            unitPrice: 500.0,
          ),
          HandymanBookingItem(
            title: 'Threading',
            variantName: 'Upper lip threading',
            quantity: 1,
            unitPrice: 400.0,
          ),
        ],
        subTotal: 900.0,
        vat: 28.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100136',
        serviceName: 'Emergency Electrician',
        bookingDate: DateTime(2026, 5, 31, 10, 0),
        serviceDate: DateTime(2026, 5, 31, 11, 30),
        price: 150.0,
        status: 'Accepted',
        tasks: ['Switchboard repair'],
        timeSlot: '11:30 AM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Handy Wallet',
        paymentStatus: 'Paid',
        items: [
          HandymanBookingItem(
            title: 'Emergency Electrician',
            variantName: 'Switchboard repair',
            quantity: 1,
            unitPrice: 135.0,
          ),
        ],
        subTotal: 135.0,
        vat: 5.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100135',
        serviceName: 'Home Painting',
        bookingDate: DateTime(2026, 5, 30, 14, 0),
        serviceDate: DateTime(2026, 5, 30, 15, 0),
        price: 699.0,
        status: 'Ongoing',
        tasks: ['Wall touchup'],
        timeSlot: '03:00 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Home Painting',
            variantName: 'Wall touchup',
            quantity: 1,
            unitPrice: 669.0,
          ),
        ],
        subTotal: 669.0,
        vat: 20.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100134',
        serviceName: "Men's Haircut & Styling",
        bookingDate: DateTime(2026, 5, 29, 9, 0),
        serviceDate: DateTime(2026, 5, 29, 10, 0),
        price: 299.0,
        status: 'Completed',
        tasks: ['Haircut', 'Hair styling'],
        timeSlot: '10:00 AM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Handy Wallet',
        paymentStatus: 'Paid',
        items: [
          HandymanBookingItem(
            title: 'Haircut',
            variantName: 'Men\'s Haircut',
            quantity: 1,
            unitPrice: 150.0,
          ),
          HandymanBookingItem(
            title: 'Styling',
            variantName: 'Hair styling',
            quantity: 1,
            unitPrice: 120.0,
          ),
        ],
        subTotal: 270.0,
        vat: 19.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100133',
        serviceName: 'Urgent Lockout Service',
        bookingDate: DateTime(2026, 5, 28, 16, 0),
        serviceDate: DateTime(2026, 5, 28, 17, 0),
        price: 199.0,
        status: 'Cancelled',
        tasks: ['Door lock opening'],
        timeSlot: '05:00 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Lockout Service',
            variantName: 'Door lock opening',
            quantity: 1,
            unitPrice: 180.0,
          ),
        ],
        subTotal: 180.0,
        vat: 9.0,
        fee: 10.0,
      ),
    ]);
  }

  void placeBooking({
    required String serviceName,
    required double price,
    required DateTime serviceDate,
    required List<String> tasks,
    required String timeSlot,
  }) {
    final nextNum = bookings.isEmpty ? 100139 : int.parse(bookings.first.id) + 1;
    final double calculatedSubTotal = price * 0.9;
    final double calculatedVat = price * 0.03;
    final double calculatedFee = price - calculatedSubTotal - calculatedVat;

    final newBooking = HandymanBookingModel(
      id: nextNum.toString(),
      serviceName: serviceName,
      bookingDate: DateTime.now(),
      serviceDate: serviceDate,
      price: price,
      status: 'Pending',
      tasks: tasks,
      timeSlot: timeSlot,
      address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
      paymentMethod: 'Cash after service',
      paymentStatus: 'Unpaid',
      items: tasks.map((t) => HandymanBookingItem(
        title: serviceName,
        variantName: t,
        quantity: 1,
        unitPrice: calculatedSubTotal / (tasks.isEmpty ? 1 : tasks.length),
      )).toList(),
      subTotal: calculatedSubTotal,
      vat: calculatedVat,
      fee: calculatedFee,
    );
    bookings.insert(0, newBooking);
  }
}
