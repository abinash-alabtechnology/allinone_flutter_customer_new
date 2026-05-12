import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/no_data_screen.dart';
import 'package:handy_allinone/common/widgets/confirmation_dialog.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/cart/widgets/cart_item_widget.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/checkout/widgets/coupon_section.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';

import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';
import 'package:handy_allinone/features/home/screens/home_screen.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    if(Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if(Get.find<CartController>().cartList.isNotEmpty){
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);
      Get.find<CartController>().calculationCart();
      showReferAndEarnSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar3(
        backButton: true,
        onBackPressed: () => Get.back(),
        bgcolor: Colors.white,
        textcolor: Colors.black,
        iconcolor: Colors.black,
        title: "Your Cart (${Get.find<CartController>().cartList.length} Items)",
      ),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<CartController>(builder: (cartController) {
        if (cartController.cartList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NoDataScreen(isCart: true, text: '', showFooter: true),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomButton(
                  buttonText: 'shop_now'.tr,
                  width: 200,
                  onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                ),
              ],
            ),
          );
        }


        bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deliver to Section
                        if (!isPharmacy) ...[
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Color(0xFF16A34A), size: 20),
                                    const SizedBox(width: 8),
                                    Text('Delivering to', style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey.shade600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const SizedBox(width: 28),
                                    Expanded(
                                      child: Text(
                                        AddressHelper.getUserAddressFromSharedPref()?.address ?? 'Select Address',
                                        style: robotoBold.copyWith(fontSize: 14, color: Colors.black),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.keyboard_arrow_down, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        ],

                        // Items List Section
                        Container(
                          color: Colors.white,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cartController.cartList.length,
                            itemBuilder: (context, index) {
                              return CartItemWidget(
                                cart: cartController.cartList[index],
                                cartIndex: index,
                                addOns: cartController.addOnsList[index],
                                isAvailable: cartController.availableList[index],
                                showDivider: index != cartController.cartList.length - 1,
                              );
                            },
                          ),
                        ),

                        // Add More / Instructions Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  cartController.forcefullySetModule(cartController.cartList[0].item!.moduleId!);
                                  Get.toNamed(
                                    RouteHelper.getStoreRoute(id: cartController.cartList[0].item!.storeId, page: 'item'),
                                    arguments: StoreScreen(store: Store(id: cartController.cartList[0].item!.storeId), fromModule: false),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A), size: 20),
                                      const SizedBox(width: 12),
                                      Text('Add more items', style: robotoBold.copyWith(color: const Color(0xFF16A34A))),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
                              
                              GetBuilder<CheckoutController>(builder: (checkoutController) {
                                return InkWell(
                                  onTap: () {
                                    _showInstructionsBottomSheet(context, checkoutController);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_note, color: Colors.black87, size: 22),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            checkoutController.selectedInstruction != -1 
                                              ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction].tr 
                                              : 'Add cooking instructions', 
                                            style: robotoMedium.copyWith(fontSize: 14, color: Colors.black87),
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_right, size: 20),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Coupon Section
                        GetBuilder<CheckoutController>(builder: (checkoutController) {
                          return CouponSection(
                            storeId: cartController.cartList[0].item!.storeId,
                            checkoutController: checkoutController,
                            total: cartController.subTotal,
                            price: cartController.itemPrice,
                            discount: cartController.itemDiscountPrice,
                            addOns: cartController.addOns,
                            deliveryCharge: 0,
                            variationPrice: 0,
                          );

                        }),
                        const SizedBox(height: 12),

                        // Bill Details Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bill Details', style: robotoBold.copyWith(fontSize: 15)),
                              const SizedBox(height: 16),
                              _buildBillRow('Item Total', PriceConverter.convertPrice(cartController.itemPrice)),
                              const SizedBox(height: 12),
                              if (cartController.itemDiscountPrice > 0)
                                _buildBillRow('Item Discount', '(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', isGreen: true),
                              if (cartController.itemDiscountPrice > 0)
                                const SizedBox(height: 12),
                              
                              GetBuilder<CouponController>(builder: (couponController) {
                                return Column(children: [
                                  if (couponController.discount! > 0)
                                    _buildBillRow('Coupon Discount', '(-) ${PriceConverter.convertPrice(couponController.discount)}', isGreen: true),
                                  if (couponController.discount! > 0)
                                    const SizedBox(height: 12),
                                ]);
                              }),

                              _buildBillRow('Delivery Fee', 'FREE', originalPrice: PriceConverter.convertPrice(30), isGreen: true),
                              const SizedBox(height: 12),
                              _buildBillRow('Packaging Charges', PriceConverter.convertPrice(5)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('To Pay', style: robotoBold.copyWith(fontSize: 18)),
                                  GetBuilder<CouponController>(builder: (couponController) {
                                    return PriceConverter.convertAnimationPrice(
                                      (cartController.subTotal - (couponController.discount ?? 0)) + 5.0,
                                      textStyle: robotoBold.copyWith(fontSize: 18, color: Colors.black),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Sticky Checkout Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: CustomButton(
                  buttonText: 'Proceed to Checkout',
                  onPressed: () => _onCheckout(context, cartController),
                  radius: 12,
                  height: 50,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showInstructionsBottomSheet(BuildContext context, CheckoutController checkoutController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Delivery Instructions', style: robotoBold.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.deliveryInstructionList.length,
            itemBuilder: (context, index) {
              bool isSelected = checkoutController.selectedInstruction == index;
              return InkWell(
                onTap: () {
                  checkoutController.setInstruction(index);
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF16A34A).withValues(alpha: 0.1) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFF16A34A) : Colors.transparent),
                  ),
                  child: Row(children: [
                    Icon(
                      index == 0 ? Icons.door_front_door_outlined :
                      index == 1 ? Icons.business :
                      index == 2 ? Icons.chat_outlined : Icons.pets,
                      color: isSelected ? const Color(0xFF16A34A) : Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppConstants.deliveryInstructionList[index].tr,
                        style: robotoMedium.copyWith(color: isSelected ? const Color(0xFF16A34A) : Colors.black87),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {String? originalPrice, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600)),
        Row(
          children: [
            if (originalPrice != null)
              Text(
                originalPrice,
                style: robotoRegular.copyWith(
                  fontSize: 13,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            if (originalPrice != null) const SizedBox(width: 8),
            Text(
              value,
              style: robotoBold.copyWith(
                fontSize: 14,
                color: isGreen ? const Color(0xFF16A34A) : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onCheckout(BuildContext context, CartController cartController) {
    if (AddressHelper.getUserAddressFromSharedPref() == null) {
      showCustomSnackBar('select_address_first'.tr);
    } else if (cartController.cartList.isEmpty) {
      showCustomSnackBar('cart_is_empty'.tr);
    } else if (Get.find<StoreController>().store != null && Get.find<StoreController>().store!.open == 0 && !cartController.cartList.first.item!.scheduleOrder!) {
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
        },
      ));
    } else if(!cartController.cartList.first.item!.scheduleOrder! && cartController.availableList.contains(false)) {
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: 'available_item_will_be_processed'.tr,
        description: 'one_or_more_product_unavailable'.tr,
        onYesPressed: () {
          Get.back();
          _proceedToCheckout(cartController);
        },
      ));
    } else {
      _proceedToCheckout(cartController);
    }
  }

  Future<void> showReferAndEarnSnackBar() async {
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar('your_referral_discount_added_on_your_first_order'.tr, isError: false);
    }
  }

  void _proceedToCheckout(CartController cartController) {
    Get.find<CheckoutController>().updateFirstTime();
    if(Get.find<SplashController>().module == null) {
      int i = 0;
      for(i = 0; i < Get.find<SplashController>().moduleList!.length; i++){
        if(cartController.cartList[0].item!.moduleId == Get.find<SplashController>().moduleList![i].id){
          break;
        }
      }
      Get.find<SplashController>().setModule(Get.find<SplashController>().moduleList![i]);
      HomeScreen.loadData(true);
    }
    Get.find<CouponController>().removeCouponData(false);
    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
  }
}
