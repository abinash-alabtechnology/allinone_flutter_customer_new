import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountView({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    if (item.moduleType == 'handyman' || (Get.isRegistered<SplashController>() && Get.find<SplashController>().module?.moduleType == 'handyman')) {
      return CartCountViewHandyman(
        service: HandymanServiceModel.fromItem(item),
        child: child,
        index: index,
      );
    }
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      return cartQty != 0 ? Center(
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                }else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 2))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? SizedBox(
                height: 25, width: 25,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2),
                ),
              )
            : child ?? Container(
                height: 25, width: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
              ),
      );
    });
  }
}

class CartCountViewGrocery extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountViewGrocery({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      return cartQty != 0 ? Center(
        child: Container(
          width: 89.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                }else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.lightGreen.shade800),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 1.5))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.lightGreen.shade800),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                height: 30,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.lightGreen.shade800),
                  color: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: SizedBox(
                    height: 14.h,
                    width: 14.w,
                    child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2),
                  ),
                ),
              )
            : child ?? Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.lightGreen.shade800),
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child:Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                    child: Text("ADD", style: robotoBold.copyWith(
                      fontSize: 11.sp,
                    ) ,
                    ),
                  ),
                ),
              ),
      );
    });
  }
}

class CartCountViewGreen extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountViewGreen({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      return cartQty != 0 ? Center(
        child: Container(
          width: 88.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                }else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 1.5))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                height: 28,
                width: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.green.shade600),
                ),
                child: Center(
                  child: SizedBox(
                    height: 14.h,
                    width: 14.w,
                    child: CircularProgressIndicator(color: Colors.green.shade700, strokeWidth: 2),
                  ),
                ),
              )
            : child ?? Container(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Theme.of(context).cardColor,
                  gradient: LinearGradient(colors: [Colors.green.shade400,Colors.green.shade800],begin: Alignment.centerLeft,end: Alignment.centerRight)
                ),
                child:Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart_outlined, size: 12.sp, color: Theme.of(context).cardColor),
                        SizedBox(width: 4.w),
                        Text("ADD", style: robotoBold.copyWith(
                          fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).cardColor
                        ) ,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }
}

class CartCountViewStore extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountViewStore({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      return cartQty != 0 ? Center(
        child: Container(
          width: 89.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                }else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 1.5))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                height: 30,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2),
                  ),
                ),
              )
            : child ?? Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    "Add",
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
      );
    });
  }
}

class CartCountViewPharmacy extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountViewPharmacy({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      return cartQty != 0 ? Center(
        child: Container(
          width: 89.w,
          decoration: BoxDecoration(
            color: const Color(0xFF24AE5F),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                }else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: Colors.white,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: const Color(0xFF24AE5F),
                ),
                child: const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
            : child ?? Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: const Color(0xFF24AE5F),
                ),
                child: Text("Add", style: robotoBold.copyWith(
                  fontSize: 14.sp,
                  color: Colors.white,
                )),
              ),
      );
    });
  }
}

class CartCountViewHandyman extends StatelessWidget {
  final HandymanServiceModel service;
  final Widget? child;
  final int? index;
  const CartCountViewHandyman({super.key, required this.service, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      return GetBuilder<HandymanHomeController>(builder: (controller) {
        int qty = controller.getServiceQuantity(service.id);
        
        if (qty == 0 && cartController.cartList.isNotEmpty) {
          int? sId = int.tryParse(service.id);
          String sName = service.name.toLowerCase().trim();
          final cartItem = cartController.cartList.firstWhereOrNull((c) {
            if (sId != null && c.item?.id == sId) return true;
            if (c.item?.name != null) {
              String cName = c.item!.name!.toLowerCase().trim();
              if (cName.isNotEmpty && (sName.contains(cName) || cName.contains(sName))) return true;
            }
            return false;
          });
          if (cartItem != null && (cartItem.quantity ?? 0) > 0) {
            qty = cartItem.quantity!;
            service.cartQuantity = qty;
          }
        }

        return qty != 0
            ? Container(
                width: 76,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => controller.removeFromCart(service.id),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 24,
                        height: 34,
                        child: Icon(
                          Icons.remove_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Text(
                      '$qty',
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (service.optionsCount > 0) {
                          ServiceOptionsBottomSheet.show(context, service);
                        } else {
                          controller.addToCart(service.id, serviceModel: service);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 24,
                        height: 34,
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  if (service.optionsCount == 0) {
                    controller.addToCart(service.id, serviceModel: service);
                  } else {
                    ServiceOptionsBottomSheet.show(context, service);
                  }
                },
                child: child ??
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 76,
                          height: 34,
                          margin: EdgeInsets.only(bottom: service.optionsCount > 0 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Add',
                            style: robotoRegular.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                        if (service.optionsCount > 0)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              color: Colors.white,
                              child: Text(
                                '${service.optionsCount} options',
                                style: robotoRegular.copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
              );
      });
    });
  }
}
