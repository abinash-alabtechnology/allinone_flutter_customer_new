import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountView({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
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
              child: cartController.isLoading && cartController.directAddCartItemIndex == index
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor))
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
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
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
              child: cartController.isLoading && cartController.directAddCartItemIndex == index
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor))
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
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
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
              child: cartController.isLoading && cartController.directAddCartItemIndex == index
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor))
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
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
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
              child: cartController.isLoading && cartController.directAddCartItemIndex == index
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor))
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
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "ADD ITEM",
              style: robotoBold.copyWith(
                fontSize: 10,
                color: Colors.white,
                letterSpacing: 0.5,
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
              child: cartController.isLoading && cartController.directAddCartItemIndex == index
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
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
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
