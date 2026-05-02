

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/order/widgets/order_shimmer_widget.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';

import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/no_data_screen.dart';
import 'package:handy_allinone/common/widgets/paginated_list_view.dart';
import 'package:handy_allinone/features/order/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  const OrderViewWidget({super.key, required this.isRunning});
  Color getStatusColor(String status) {
    switch (status) {

      case 'pending':
        return const Color(0xFFFCB900); // yellow

      case 'accepted':
        return const Color(0xFF0BA5EC); // blue

      case 'processing':
        return const Color(0xFF7F56D9); // purple

      case 'confirmed':
        return const Color(0xFF12BD5F); // green (your brand tone)

      case 'handover':
        return const Color(0xFF36B37E); // lighter green

      case 'picked_up':
        return const Color(0xFF2E90FA); // bold delivery blue

      case 'delivered':
        return const Color(0xFF12BD5F); // success green

      default:
        return Colors.grey; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: GetBuilder<OrderController>(builder: (orderController) {
        PaginatedOrderModel? paginatedOrderModel;
        if(isRunning) {
          paginatedOrderModel = orderController.runningOrderModel;
        }else {
          paginatedOrderModel = orderController.historyOrderModel;
        }


        return paginatedOrderModel != null ? paginatedOrderModel.orders!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isRunning) {
              await orderController.getRunningOrders(1, isUpdate: true);
            }else {
              await orderController.getHistoryOrders(1, isUpdate: true);
            }
          },


          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 20.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(colors: [
                                Color(0xFF2E2C31),
                                Color(0xFF2C1B09),

                              ])),
                          child:Row(
                            mainAxisAlignment: .center,
                            crossAxisAlignment: .center,
                            children: [
                              Column(
                                mainAxisAlignment: .center,crossAxisAlignment: .start,
                                children: [
                                  Text("Picked, Packed\n& Delivered",style:robotoBold.copyWith(color: Colors.white,fontSize:18,
                                      fontWeight: FontWeight.w900),maxLines: 3,overflow: TextOverflow.ellipsis,),
                                  SizedBox(height: 5,),
                                  Text("See everything you've ordered recently,\nTap to reorder or track instantly.",style:robotoBold.copyWith(color: Colors.white,fontSize:10,
                                      fontWeight: FontWeight.w700),maxLines: 3,overflow: TextOverflow.ellipsis,),
                                ],
                              ),
                              SizedBox(width: 10,),
                              CustomAssetImageWidget(Images.tickmark,height: 80,width: 80,),
                            ],
                          )
                      ),

                      PaginatedListView(
                        scrollController: scrollController,
                        onPaginate: (int? offset) async {
                          if(isRunning) {
                            await orderController.getRunningOrders(offset!, isUpdate: true);
                          }else {
                            await orderController.getHistoryOrders(offset!, isUpdate: true);
                          }
                        },
                        totalSize: isRunning ? orderController.runningOrderModel?.totalSize : orderController.historyOrderModel?.totalSize,
                        offset: isRunning ? orderController.runningOrderModel?.offset : orderController.historyOrderModel?.offset,
                        itemView: AnimationLimiter(
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : Dimensions.paddingSizeLarge,
                              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 5,
                              mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 160 : 120,
                              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            itemCount: paginatedOrderModel.orders!.length,
                            itemBuilder: (context, index) {
                              bool isParcel = paginatedOrderModel!.orders![index].orderType == 'parcel';
                              bool isPrescription = paginatedOrderModel.orders![index].prescriptionOrder!;
                              final status = paginatedOrderModel.orders![index].orderStatus!;
                              final statusColor = getStatusColor(status);
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 1050),
                                columnCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                                child: SlideAnimation(
                                  verticalOffset: 40,
                                  curve: Curves.easeOutQuad,
                                  child: FadeInAnimation(
                                child:  Container(

                                    padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : EdgeInsets.symmetric(horizontal: 5.0,vertical: 12),
                                    margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall) : EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
                                    decoration: ResponsiveHelper.isDesktop(context) ?
                                    BoxDecoration(
                                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300.withValues(alpha: 0.6),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ) :  BoxDecoration(
                                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300.withValues(alpha: 0.6),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: CustomInkWell(
                                      onTap: () {
                                        Get.toNamed(
                                          RouteHelper.getOrderDetailsRoute(paginatedOrderModel!.orders![index].id),
                                          arguments: OrderDetailsScreen(
                                            orderId: paginatedOrderModel.orders![index].id,
                                            orderModel: paginatedOrderModel.orders![index],
                                          ),
                                        );
                                      },
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                      child: Column(mainAxisAlignment: .start,crossAxisAlignment: .start, children: [

                                        Row(children: [

                                          Stack(children: [
                                            Container(
                                              height: ResponsiveHelper.isDesktop(context) ? 80 : 80, width: ResponsiveHelper.isDesktop(context) ? 80 : 80, alignment: Alignment.center,
                                              decoration: isParcel ? BoxDecoration(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                                border: Border.all(color:Colors.grey.shade300)
                                              ) : null,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                child: CustomImage(
                                                  image: isParcel ? '${paginatedOrderModel.orders![index].parcelCategory != null ? paginatedOrderModel.orders![index].parcelCategory!.imageFullUrl : ''}'
                                                      : '${paginatedOrderModel.orders![index].store != null ? paginatedOrderModel.orders![index].store!.logoFullUrl : ''}',
                                                  height: isParcel ? 35 : ResponsiveHelper.isDesktop(context) ? 80 : 80,
                                                  width: isParcel ? 35 : ResponsiveHelper.isDesktop(context) ? 80 : 80, fit: isParcel ? null : BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            isParcel ? Positioned(left: 0, top: 10, child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(Dimensions.radiusSmall)),
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              child: Text('parcel'.tr, style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white,
                                              )),
                                            )) : const SizedBox(),

                                            isPrescription ? Positioned(left: 0, top: 10, child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2),
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(Dimensions.radiusSmall)),
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              child: Text('prescription'.tr, style: robotoMedium.copyWith(
                                                fontSize: 10, color: Colors.white,
                                              )),
                                            )) : const SizedBox(),
                                          ]),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),

                                          Expanded(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Row(children: [
                                                Icon(Icons.receipt_long, size: 13, color: Theme.of(context).disabledColor),
                                                // Text(
                                                //   '${isParcel ? 'delivery_id'.tr : 'order_id'.tr}:',
                                                //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                // ),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                Text('#${paginatedOrderModel.orders![index].id}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                              ]),
                                              const SizedBox(height: Dimensions.paddingSizeSmall),

                                              ResponsiveHelper.isDesktop(context) ? Padding(
                                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                  ),
                                                  child: Text(paginatedOrderModel.orders![index].orderStatus!.tr, style: robotoMedium.copyWith(
                                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                                                  )),
                                                ),
                                              ) : const SizedBox(),

                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today_rounded, size: 12, color: Theme.of(context).disabledColor),
                                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                  Text(
                                                    DateConverter.dateTimeStringToDateTime(paginatedOrderModel.orders![index].createdAt!),
                                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeSmall),

                                              !ResponsiveHelper.isDesktop(context) ?
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: Dimensions.paddingSizeSmall,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: statusColor.withOpacity(0.12),
                                                ),
                                                child: IntrinsicWidth(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.circle, size: 5, color: statusColor),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        status.tr,
                                                        style: robotoMedium.copyWith(
                                                          fontSize: Dimensions.fontSizeExtraSmall,
                                                          color: statusColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              // Container(
                                              //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical:2),
                                              //   decoration: BoxDecoration(
                                              //     borderRadius: BorderRadius.circular(6),
                                              //     color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                              //   ),
                                              //   child: IntrinsicWidth(
                                              //     child: Row(
                                              //       children: [
                                              //         Icon(Icons.circle,size:5,color: Theme.of(context).primaryColor),
                                              //         SizedBox(width: 5,),
                                              //         Text(paginatedOrderModel.orders![index].orderStatus!.tr, style: robotoMedium.copyWith(
                                              //           fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                                              //         )),
                                              //       ],
                                              //     ),
                                              //   ),
                                              // )

                                                  : const SizedBox(),

                                            ]),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),

                                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                                            isRunning ? InkWell(
                                              onTap: () async {
                                                OrderModel order = paginatedOrderModel!.orders![index];
                                                bool isDelivar = (Get.find<SplashController>().configModel?.delivarBooking ?? false) || (order.delivarBooking ?? false);
                                                if(isDelivar) {
                                                  String? baseUrl = Get.find<SplashController>().configModel?.deliverurl;
                                                  String? trackingId = order.publicTrackingId;
                                                  if(baseUrl != null && baseUrl.isNotEmpty && trackingId != null && trackingId.isNotEmpty) {
                                                    String fullUrl = baseUrl.endsWith('/') ? '$baseUrl$trackingId' : '$baseUrl/$trackingId';
                                                    debugPrint('Generating Delivar Tracking URL: $fullUrl');
                                                    await Get.toNamed(RouteHelper.getDelivarTrackingRoute(fullUrl));
                                                  } else {
                                                    await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, null));
                                                  }
                                                } else {
                                                  await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, null));
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : 10),
                                                decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                                  borderRadius: BorderRadius.circular(9),
                                                  color: Color(0xFF12BD5F),
                                                ) : BoxDecoration(
                                                  borderRadius: BorderRadius.circular(9),
                                                  color: Color(0xFF12BD5F),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:  Colors.greenAccent.withValues(alpha: 0.35), // glow tone
                                                      blurRadius: 4,
                                                      spreadRadius: 2,
                                                      offset: const Offset(0, 0),
                                                    ),
                                                  ],

                                                  // border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                                ),
                                                child: Row(children: [
                                                  Icon(Icons.my_location,color: Colors.white,size:15),
                                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                  Text(isParcel ? 'Track' : 'Track', style: robotoMedium.copyWith(
                                                    fontSize: Dimensions.fontSizeExtraSmall, color: ResponsiveHelper.isDesktop(context) ? Colors.white : Colors.white,
                                                  )),
                                                ]),
                                              ),
                                            ) : isParcel ? const SizedBox() : Column(
                                              mainAxisAlignment: .end,
                                              crossAxisAlignment: .end,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6)
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.shopping_bag_outlined,size: 12,),
                                                        SizedBox(width: 5,),
                                                        Text(
                                                          '${paginatedOrderModel.orders![index].detailsCount} ${paginatedOrderModel.orders![index].detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Icon(Icons.arrow_forward_ios,color: Colors.grey.shade300,size: 15,)),
                                              ],
                                            ),
                                          ]),
                                        ]),
                                      ]),
                                    ),
                                  ),
                                ),
                              ));
                            },),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ) : NoDataScreen(text: 'no_order_found'.tr, showFooter: true) : OrderShimmerWidget(orderController: orderController);
      }),
    );
  }
}

