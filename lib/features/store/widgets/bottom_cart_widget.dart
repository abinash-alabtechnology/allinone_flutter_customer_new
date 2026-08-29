import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import '../../../common/widgets/custom_image.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/store_controller.dart';

class BottomCartWidget extends StatefulWidget {
  const BottomCartWidget({super.key});

  @override
  State<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends State<BottomCartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  final RxBool isExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void expand() {
    isExpanded.value = true;
    _ctrl.forward();
  }

  void collapse() {
    _ctrl.reverse().then((_) => isExpanded.value = false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return  cartController.cartList.isEmpty?SizedBox():AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            return Obx(()=> Transform.scale(
              scale: isExpanded.value
                  ? (0.9 + _anim.value * 0.10)
                  : (1 - _anim.value * 0.10),
              child: isExpanded.value
                  ? ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: InkWell(
                  onTap: () {
                    Get.find<CartController>().getCartDataOnline();
                    Get.toNamed(RouteHelper.getCartRoute());
                  },
                  child: Container(
                    width: Get.width * 0.93,
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0xFF398F3E), Colors.green.shade400],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00FF8A).withOpacity(0.70),
                          blurRadius: 28,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Color(0xFF00FF8A).withOpacity(0.25),
                          blurRadius: 45,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height:5.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: GetBuilder<StoreController>(
                              builder: (storeController) {
                                double percentage = 0;
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
                                        Icon(Icons.card_giftcard, size: 15.h,color: Theme.of(context).cardColor,),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Text("Add",
                                            style: robotoMedium.copyWith(color: Theme.of(context).cardColor,fontSize: 11.sp)
                                        ),
                                        Text(
                                          PriceConverter.convertPrice(Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver! - cartController.subTotal),
                                          style: robotoMedium.copyWith(color: Theme.of(context).cardColor,fontSize: 11.sp),
                                          textDirection: TextDirection.ltr,
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Text("for free delivery",
                                            style: robotoMedium.copyWith(color: Theme.of(context).cardColor,fontSize: 11.sp)
                                        ),
                                      ]),
                                    ]) : const SizedBox(),

                                  ],
                                );
                              }
                          ),
                        ),
                        SizedBox(height:5.h),
                        Container(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: cartController.cartList.length,
                                    itemBuilder: (context, index) {
                                      if (index >= cartController.cartList.length) return const SizedBox();
                                      return Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 4),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(6.r),
                                            color: Colors.white,
                                            border: Border.all(
                                                color:
                                                Colors.grey.shade500),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(6.r),
                                            child: CustomImage(
                                              image: cartController
                                                  .cartList[index]
                                                  .item
                                                  ?.imageFullUrl ??
                                                  "",
                                              height: 38,
                                              width: 38,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: 1.w,
                                height: 30.h,
                                margin: EdgeInsets.symmetric(horizontal: 6.w),
                                color: Colors.white,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10.r),
                                      color:
                                      Theme.of(context).cardColor,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      child: Row(
                                        children: [
                                          Text(
                                            'view_cart'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize: 12.sp,
                                              color: Color(0xFF398F3E),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Color(0xFF398F3E),
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: collapse,
                                    child: Container(
                                      width: 40.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black12,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(Icons.close,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : GestureDetector(
                onTap: expand,
                child: CollapsedCartView(
                  cartCount: cartController.cartList.length,
                ),
              ),
            ),);
          },
        );
      },
    );
  }
}



class BottomCartWidgetStore extends StatefulWidget {
  const BottomCartWidgetStore({super.key});

  @override
  State<BottomCartWidgetStore> createState() => _BottomCartWidgetStoreState();
}

class _BottomCartWidgetStoreState extends State<BottomCartWidgetStore>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        if (cartController.cartList.isEmpty) return const SizedBox();

        return InkWell(
          onTap: () {
            Get.find<CartController>().getCartDataOnline();
            Get.toNamed(RouteHelper.getCartRoute());
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4.h),
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(height: 2.h),
                    GetBuilder<StoreController>(
                      builder: (storeController) {
                        double percentage = 0;

                        if (Get.find<StoreController>().store != null &&
                            !Get.find<StoreController>().store!.freeDelivery! &&
                            (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true &&
                                Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount' &&
                                Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null)) {
                          percentage = cartController.subTotal /
                              Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver!;
                        }

                        return (storeController.store != null &&
                            !storeController.store!.freeDelivery! &&
                            (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true &&
                                Get.find<SplashController>().configModel?.adminFreeDelivery?.type ==
                                    'free_delivery_by_order_amount' &&
                                Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null) &&
                            percentage < 1)
                            ? Row(
                          children: [
                            Icon(Icons.card_giftcard,
                                size: 15.h,
                                color: Theme.of(context).cardColor),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Text("Add",
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 11.sp)),
                            Text(
                              PriceConverter.convertPrice(
                                  Get.find<SplashController>()
                                      .configModel!
                                      .adminFreeDelivery!
                                      .freeDeliveryOver! -
                                      cartController.subTotal),
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).cardColor,
                                  fontSize: 11.sp),
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Text("for free delivery",
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 11.sp)),
                          ],
                        )
                            : const SizedBox();
                      },
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 35,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: cartController.cartList.length,
                                itemBuilder: (context, index) {
                                  if (index >= cartController.cartList.length) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        color:Color(0xFF2A2A2A),
                                        border: Border.all(
                                            color:Theme.of(context).primaryColor),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6.r),
                                        child: CustomImage(
                                          image: cartController
                                              .cartList[index]
                                              .item
                                              ?.imageFullUrl ??
                                              "",
                                          height: 33,
                                          width: 33,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 30.h,
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                            // color: Colors.white,
                          ),
                          Container(
                            height: 30.h,
                            width: 30.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child:                                 FittedBox(
                                child: const Icon(
                                  Icons.shopping_cart_checkout_outlined,
                                  color: Colors.white,
                                ),
                              ),

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Item: ${cartController.cartList.length}   ",style: robotoBold.copyWith(fontSize: 13,color:Theme.of(context).cardColor,fontWeight: FontWeight.w500),),
                    Text("Total: ${PriceConverter.convertPrice(
                        cartController.calculationCart())}",style: robotoBold.copyWith(fontSize: 13,color:Colors.grey.shade600,fontWeight: FontWeight.w500),)
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}


class CollapsedCartView extends StatelessWidget {
  final int cartCount;
  const CollapsedCartView({super.key, required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Colors.green.shade800, Colors.green],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.shopping_bag_rounded,
              color: Colors.white, size: 28),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                cartCount.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
