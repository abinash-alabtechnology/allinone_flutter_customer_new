import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/common/widgets/confirmation_dialog.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/features/home/screens/home_screen.dart';

class BottomCartButton extends StatelessWidget {
  const BottomCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: GetBuilder<CartController>(
            builder: (cartController) {
              if (cartController.cartList.isEmpty) {
                return const SizedBox.shrink();
              }

              return InkWell(
                onTap: () {
                  _onViewCart(context, cartController);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A6B5D), // Dark green
                        Color(0xFF4CAF90), // Light green
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Color(0xFF4CAF90),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "View Cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "${cartController.cartList.length} Items Added",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BottomCartButton1 extends StatelessWidget {
  const BottomCartButton1({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        if (cartController.cartList.isEmpty) return const SizedBox.shrink();

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A6B5D),
                  Color(0xFF4CAF90),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF4CAF90),
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: () {
                _onViewCart(context, cartController);
              },
              borderRadius: BorderRadius.circular(30),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "View Cart",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "${cartController.cartList.length} Items Added",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _onViewCart(BuildContext context, CartController cartController) {
  if (Get.find<StoreController>().store != null && Get.find<StoreController>().store!.open == 0 && !cartController.cartList.first.item!.scheduleOrder!) {
    bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';
    bool showRestaurantText = Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false;
    Get.dialog(ConfirmationDialog(
      icon: Images.closed,
      title: isPharmacy ? 'pharmacy_is_closed_title'.tr : showRestaurantText ? 'restaurant_is_closed_title'.tr : 'store_is_closed_title'.tr,
      description: isPharmacy ? 'order_in_another_pharmacy'.tr : showRestaurantText ? 'order_in_another_restaurant'.tr : 'order_in_another_store'.tr,
      onYesPressed: () {
        cartController.clearCartList();
        Get.back();
        Get.offAllNamed(RouteHelper.getInitialRoute());
        HomeScreen.loadData(true);
      },
    ));
  } else if (!cartController.cartList.first.item!.scheduleOrder! && cartController.availableList.contains(false)) {
    Get.dialog(ConfirmationDialog(
      icon: Images.warning,
      title: 'available_item_will_be_processed'.tr,
      description: 'one_or_more_product_unavailable'.tr,
      onYesPressed: () {
        Get.back();
        Navigator.pushNamed(context, RouteHelper.getCartRoute());
      },
    ));
  } else {
    Navigator.pushNamed(context, RouteHelper.getCartRoute());
  }
}
