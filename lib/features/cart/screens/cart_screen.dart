import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/cart/widgets/extra_packaging_widget.dart';
import 'package:handy_allinone/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/common/widgets/confirmation_dialog.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/cart/domain/models/cart_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/module_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/item_widget.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/no_data_screen.dart';
import 'package:handy_allinone/common/widgets/web_constrained_box.dart';
import 'package:handy_allinone/common/widgets/web_page_title_widget.dart';
import 'package:handy_allinone/features/checkout/widgets/time_slot_bottom_sheet.dart';
import 'package:handy_allinone/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/cart/widgets/web_cart_items_widget.dart';
import 'package:handy_allinone/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:handy_allinone/features/home/screens/home_screen.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  final GlobalKey _widgetKey = GlobalKey();
  double _height = 0;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    if(Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if(Get.find<CartController>().cartList.isNotEmpty){
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(willUpdate: false);
      }
      if(Get.find<CartController>().needExtraPackage){
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);
      Get.find<CartController>().calculationCart();
      showReferAndEarnSnackBar();
    }
  }

  void _initialBottomSheetShowHide() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      key.currentState?.expand();
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          key.currentState?.contract();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';

    return Scaffold(
      appBar: CustomAppBar3(
        backButton: true,
        onBackPressed: () => Get.back(),
        bgcolor: isPharmacy ? Colors.white : Theme.of(context).primaryColor,
        textcolor: isPharmacy ? Colors.black : Theme.of(context).cardColor,
        iconcolor: isPharmacy ? Colors.black : Theme.of(context).cardColor,
        title: isPharmacy 
            ? "Your Cart (${Get.find<CartController>().cartList.length} Items)" 
            : "Your Basket",
      ),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CartController>(builder: (cartController) {
          bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';
          
          if (cartController.cartList.isEmpty) {
            return SizedBox(
              height: Get.height,
              child: const NoDataScreen(isCart: true, text: '', showFooter: true),
            );
          }

          if (isPharmacy) {
            bool hasPrescriptionItem = cartController.cartList.any((cart) => cart.item?.isPrescriptionRequired ?? false);

            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Deliver to
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Deliver to', style: robotoBold.copyWith(fontSize: 14)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AddressHelper.getUserAddressFromSharedPref()?.address ?? 'Select Address',
                                            style: robotoRegular.copyWith(fontSize: 14, color: Colors.black87),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('cart')),
                                          child: Text('Change', style: robotoBold.copyWith(color: const Color(0xFF16A34A), fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Items List
                              ListView.builder(
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

                              // Add More Items
                              TextButton.icon(
                                onPressed: () {
                                  cartController.forcefullySetModule(cartController.cartList[0].item!.moduleId!);
                                  Get.toNamed(
                                    RouteHelper.getStoreRoute(id: cartController.cartList[0].item!.storeId, page: 'item'),
                                    arguments: StoreScreen(store: Store(id: cartController.cartList[0].item!.storeId), fromModule: false),
                                  );
                                },
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A)),
                                label: Text('Add more items', style: robotoBold.copyWith(color: Color(0xFF16A34A))),
                              ),

                              // Add Delivery Instructions
                              GetBuilder<CheckoutController>(builder: (checkoutController) {
                                return InkWell(
                                  onTap: () {
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
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade100),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Add Delivery Instructions', style: robotoBold.copyWith(fontSize: 14)),
                                              const SizedBox(height: 4),
                                              Text(
                                                checkoutController.selectedInstruction != -1 
                                                  ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction].tr 
                                                  : 'E.g. Leave at door', 
                                                style: robotoRegular.copyWith(fontSize: 13, color: checkoutController.selectedInstruction != -1 ? const Color(0xFF16A34A) : Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(checkoutController.selectedInstruction != -1 ? Icons.check_circle : Icons.edit_outlined, size: 20, color: checkoutController.selectedInstruction != -1 ? const Color(0xFF16A34A) : Colors.black87),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Bill Details
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bill Details', style: robotoBold.copyWith(fontSize: 15)),
                                    const SizedBox(height: 16),
                                    _buildBillRow('Item Total', PriceConverter.convertPrice(cartController.itemPrice)),
                                    const SizedBox(height: 12),
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
                                        PriceConverter.convertAnimationPrice(
                                          cartController.subTotal + 5.0,
                                          textStyle: robotoBold.copyWith(fontSize: 18, color: Colors.black),
                                        ),
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
                  
                  // Sticky Checkout Button for Pharmacy
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: SafeArea(
                      child: CustomButton(
                        buttonText: 'Proceed to Checkout',
                        onPressed: () => _onCheckout(context, cartController, cartController.availableList),
                        radius: 12,
                        height: 50,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(children: [
            Expanded(
              child: ExpandableBottomSheet(
                key: key,
                onIsExtendedCallback: () {
                  _getExpandedBottomSheetHeight();
                },
                onIsContractedCallback: () {
                  setState(() {
                    _height = 0;
                  });
                },

                persistentHeader: isDesktop ? const SizedBox() :
                InkWell(
                  onTap: () {
                    if (cartController.isExpanded) {
                      key.currentState?.contract();
                    } else {
                      key.currentState?.expand();
                    }
                    cartController.setExpanded(!cartController.isExpanded);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      constraints: const BoxConstraints.expand(height: 35),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusDefault),
                          topRight: Radius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Icon(Icons.drag_handle, color: Theme.of(context).hintColor, size: 25),
                    ),
                  ),
                ),

                expandableContent: isDesktop ? const SizedBox() :
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: context.width,
                    key: _widgetKey,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                        ),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('item_price'.tr, style: robotoMedium),
                            PriceConverter.convertAnimationPrice(cartController.itemPrice, textStyle: robotoBold),
                          ]),
                          SizedBox(height: cartController.variationPrice > 0 && ModuleHelper.getModuleConfig(cartController.cartList.first.item!.moduleType).newVariation!
                              ? Dimensions.paddingSizeSmall : 0),

                          cartController.variationPrice > 0 && ModuleHelper.getModuleConfig(cartController.cartList.first.item!.moduleType).newVariation! ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('variations'.tr, style: robotoMedium),
                              Text(
                                '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                style: robotoBold, textDirection: TextDirection.ltr,
                              ),
                            ],
                          ) : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('discount'.tr, style: robotoMedium.copyWith(color:Colors.green)),
                            storeController.store != null ? Row(children: [
                              Text('(-)', style: robotoRegular.copyWith(color:Colors.green)),
                              PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoBold.copyWith(color:Colors.green)),
                            ]) : Text('calculating'.tr, style: robotoMedium.copyWith(color:Colors.green)),
                          ]),
                          SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Dimensions.paddingSizeSmall : 0),

                          Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('addons'.tr, style: robotoMedium),
                              Row(children: [
                                Text('(+)', style: robotoBold),
                                PriceConverter.convertAnimationPrice(cartController.addOns, textStyle: robotoBold),
                              ]),
                            ],
                          ) : const SizedBox(),
                        ]),
                      ),
                    ]),
                  ),
                ),

                background: Column(children: [
                  WebScreenTitleWidget(title: 'cart_list'.tr),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: isDesktop ? const EdgeInsets.only(top: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                      child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              if (isDesktop) WebCardItemsWidget(cartList: cartController.cartList),
                              if (!isDesktop) Expanded(
                                flex: 7,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  WebConstrainedBox(
                                    dataLength: cartController.cartList.length, minLength: 5, minHeight: 0.6,
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          ),
                                          child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: cartController.cartList.length,
                                            itemBuilder: (context, index) {
                                              return CartItemWidget(cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index], isAvailable: cartController.availableList[index], showDivider: index != cartController.cartList.length - 1);
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: (){
                                            cartController.forcefullySetModule(cartController.cartList[0].item!.moduleId!);
                                            Get.toNamed(
                                              RouteHelper.getStoreRoute(id: cartController.cartList[0].item!.storeId, page: 'item'),
                                              arguments: StoreScreen(store: Store(id: cartController.cartList[0].item!.storeId), fromModule: false),
                                            );
                                          },
                                          icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
                                          label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                                        ),
                                      ),
                                      ExtraPackagingWidget(cartController: cartController),
                                      !isDesktop ? suggestedItemView(cartController.cartList) : const SizedBox(),
                                    ]),
                                  ),
                                  isDesktop ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),
                                  isDesktop ? Expanded(flex: 4, child: pricingView(cartController, cartController.cartList[0].item!)) : const SizedBox(),
                                ]),
                              ),
                              if (isDesktop) WebSuggestedItemViewWidget(cartList: cartController.cartList),
                              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
                            ]),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _height),
                ]),
              ),
            ),
            isDesktop ? const SizedBox.shrink() : CheckoutButton(cartController: cartController, availableList: cartController.availableList),
          ]);
        });
      }),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList) {
    return GetBuilder<StoreController>(builder: (storeController) {
      if(storeController.cartSuggestItemModel != null && storeController.cartSuggestItemModel!.items != null && storeController.cartSuggestItemModel!.items!.isNotEmpty){
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
            child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
          ),

          SizedBox(
            height: ResponsiveHelper.isDesktop(context) ? 160 : 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: storeController.cartSuggestItemModel!.items!.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                return Padding(
                  padding:  const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                  child: ItemWidget(
                    isStore: false, item: storeController.cartSuggestItemModel!.items![index],
                    fromCartSuggestion: true, store: null, index: index, length: null, isCampaign: false,
                    inStore: true,
                  ),
                );
              },
            ),
          ),
        ]);
      } else {
        return const SizedBox();
      }
    });
  }

  Widget pricingView(CartController cartController, Item item) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: GetBuilder<StoreController>(builder: (storeController) {
        return Column(children: [
          Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation! && (storeController.store != null && storeController.store!.cutlery!) ?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Image.asset(Images.cutlery, height: 18, width: 18),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                ]),
              ),
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  value: cartController.addCutlery,
                  activeTrackColor: Theme.of(context).primaryColor,
                  onChanged: (bool? value) {
                    cartController.updateCutlery();
                  },
                  inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              )
            ]),
          ) : const SizedBox(),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('item_price'.tr, style: robotoRegular),
                PriceConverter.convertAnimationPrice(cartController.itemPrice, textStyle: robotoRegular),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('discount'.tr, style: robotoRegular),
                storeController.store != null ? Row(children: [
                  Text('(-)', style: robotoRegular),
                  PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoRegular),
                ]) : Text('calculating'.tr, style: robotoRegular),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('addons'.tr, style: robotoRegular),
                Row(children: [
                  Text('(+)', style: robotoRegular),
                  PriceConverter.convertAnimationPrice(cartController.addOns, textStyle: robotoRegular),
                ]),
              ]),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Divider(thickness: 1, color: Colors.black12),
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('subtotal'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ]),
            ]),
          ),
        ]);
      }),
    );
  }

  void _getExpandedBottomSheetHeight() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        if (key.currentState != null && Get.find<CartController>().isExpanded) {
          _height = _widgetKey.currentContext?.size?.height ?? 0;
        } else {
          _height = 0;
        }
      });
    });
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

  void _onCheckout(BuildContext context, CartController cartController, List<bool> availableList) {
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
    } else if(!cartController.cartList.first.item!.scheduleOrder! && availableList.contains(false)) {
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
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
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

class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  const CheckoutButton({super.key, required this.cartController, required this.availableList});

  @override
  Widget build(BuildContext context) {
    bool isMeat = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleName.toString().toLowerCase() == "meat";
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          if(Get.find<StoreController>().store != null && !Get.find<StoreController>().store!.freeDelivery!
              && (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true && (Get.find<SplashController>().configModel?.adminFreeDelivery?.type != null && Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount') && (Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null))){
            percentage = cartController.subTotal/Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver!;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (storeController.store != null && !storeController.store!.freeDelivery! && (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true && (Get.find<SplashController>().configModel?.adminFreeDelivery?.type != null && Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount') && (Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null)) && percentage < 1)
                  ? Column(children: [
                Row(children: [
                  Image.asset(Images.percentTag, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    PriceConverter.convertPrice(Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver! - cartController.subTotal),
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  value: percentage,
                ),
              ]) : const SizedBox(),

              ResponsiveHelper.isDesktop(context) ? const Divider(height: 1) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall,left: 10,right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr, style: robotoMedium.copyWith(color:  ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor)),
                    PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),

              ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(cartController.cartList[0].item!.moduleType).newVariation!
                  && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Image.asset(Images.cutlery, height: 18, width: 18),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: cartController.addCutlery,
                      activeTrackColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        cartController.updateCutlery();
                      },
                      inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    ),
                  )
                ]),
              ) : const SizedBox(),
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

/*              !ResponsiveHelper.isDesktop(context) ? const SizedBox() :
              Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), width: 0.5),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: (){
                        if(ResponsiveHelper.isDesktop(context)) {
                          Get.dialog(const Dialog(child: NotAvailableBottomSheetWidget()));
                        } else {
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (con) => const NotAvailableBottomSheetWidget(),
                          );
                        }
                      },
                      child: Row(children: [
                        Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      ),
                      child: cartController.notAvailableIndex != -1 ? Row(mainAxisSize: MainAxisSize.min,  children: [
                        Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                        IconButton(
                          onPressed: ()=> cartController.setAvailableIndex(-1),
                          icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                        )
                      ]) : const SizedBox(),
                    ),
                  ],
                ),
              ),*/
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              SafeArea(
                child: isMeat ? Container(
                  height: 55,
                  width: Get.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge*1.2,),
                      color: Theme.of(context).primaryColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all( 2.0),
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.grey.withOpacity(0.8)),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child:
                            Icon(Icons.arrow_back_outlined,color: Theme.of(context).primaryColor,),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart,color: Theme.of(context).cardColor,),
                          Text(cartController.cartList.length.toString(), style: robotoMedium.copyWith(color:
                          Theme.of(context).cardColor)),
                          const SizedBox(width: 10,),
                          SizedBox(
                              height: 20,
                              child: VerticalDivider(width: 5,thickness:2,color: Theme.of(context).cardColor,)),
                          const SizedBox(width: 10,),
                          PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoBold.copyWith(color: Theme.of(context).cardColor)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                            width: 120,
                            height: 45,
                            color: Theme.of(context).cardColor,
                            buttonText:"CHECK OUT",
                            textColor:Theme.of(context).primaryColor ,
                            fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                            isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                            radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusExtraLarge : Dimensions.radiusExtraLarge,
                            onPressed: () {
                              (context.findAncestorStateOfType<_CartScreenState>())?._onCheckout(context, cartController, availableList);
                            }),
                      ),
                    ],
                  ),
                ) : CustomButton(
                    buttonText: 'Good to Go!'.tr,
                    fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                    isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                    radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                    onPressed: () {
                      (context.findAncestorStateOfType<_CartScreenState>())?._onCheckout(context, cartController, availableList);
                    }),
              ),
            ],
          );
        }
      ),
    );
  }
}
