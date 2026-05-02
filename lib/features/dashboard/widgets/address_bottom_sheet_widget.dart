import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/common/widgets/address_widget.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_loader.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/features/location/screens/pick_map_screen.dart';
import 'package:geolocator/geolocator.dart';
class AddressBottomSheetWidget extends StatelessWidget {
  final bool fromDialog;

  const AddressBottomSheetWidget({super.key, this.fromDialog = false});

  @override
  Widget build(BuildContext context) {
    if (Get.find<AddressController>().addressList == null) {
      Get.find<AddressController>().getAddressList();
    }

    return FutureBuilder<LocationPermission>(
      future: Geolocator.checkPermission(),
      builder: (context, permissionSnapshot) {

        bool locationGranted = false;

        if (permissionSnapshot.hasData) {
          locationGranted =
              permissionSnapshot.data == LocationPermission.always ||
              permissionSnapshot.data == LocationPermission.whileInUse;
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: GetBuilder<AddressController>(
            builder: (addressController) {

              AddressModel? selectedAddress =
                  AddressHelper.getUserAddressFromSharedPref();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// LOCATION PERMISSION WARNING
                  if (!locationGranted)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withAlpha(150),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [

                            Row(
                              children: [

                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withAlpha(120),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.location_off_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        "Location Permission Is Off",
                                        style: robotoBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color:
                                              Theme.of(context).cardColor,
                                        ),
                                      ),

                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          "Granting location permission will ensure accurate address and hassle-free delivery.",
                                          maxLines: 2,
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).cardColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// GRANT BUTTON
                            CustomButton(
                              height: 50,
                              buttonText: "Grant",
                              color: Colors.white,
                              textColor:
                                  Theme.of(context).primaryColor,
                              onPressed: () {

                                Get.find<LocationController>()
                                    .checkPermission(() async {

                                  Get.dialog(
                                      const CustomLoaderWidget(),
                                      barrierDismissible: false);

                                  AddressModel address =
                                      await Get.find<LocationController>()
                                          .getCurrentLocation(true);

                                  ZoneResponseModel response =
                                      await Get.find<LocationController>()
                                          .getZone(
                                    address.latitude,
                                    address.longitude,
                                    false,
                                  );

                                  if (response.isSuccess) {

                                    Get.find<LocationController>()
                                        .saveAddressAndNavigate(
                                      address,
                                      false,
                                      '',
                                      false,
                                      ResponsiveHelper.isDesktop(
                                          Get.context),
                                    );

                                    Get.find<LocationController>()
                                        .showSuggestedLocation(false);

                                  } else {

                                    Get.back();

                                    Get.toNamed(
                                        RouteHelper.getPickMapRoute(
                                      RouteHelper.accessLocation,
                                      false,
                                    ));

                                    showCustomSnackBar(
                                        'service_not_available_in_current_location'
                                            .tr);
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  /// ADDRESS LIST
                  if (addressController.addressList == null)
                    const CustomLoaderWidget()

                  else if (addressController.addressList!.isEmpty)
                    Column(
                      children: [
                        Image.asset(
                          Images.noAddress,
                          width: fromDialog ? 180 : 150,
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeDefault),
                        SizedBox(
                          width: 280,
                          child: Text(
                            'you_dont_have_any_saved_address_yet'.tr,
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(
                              fontSize:
                                  Dimensions.fontSizeSmall,
                              color:
                                  Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      ],
                    )

                  else
                    Column(
                      children: [

                        Text(
                          "Select the Delivery Address",
                          style: robotoBold.copyWith(
                            fontSize:
                                Dimensions.fontSizeExtraLarge,
                          ),
                        ),

                        const Divider(),

                        ListView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              addressController.addressList!.length > 5
                                  ? 5
                                  : addressController
                                      .addressList!.length,
                          itemBuilder: (context, index) {

                            bool selected = false;

                            if (selectedAddress?.id ==
                                addressController
                                    .addressList![index].id) {
                              selected = true;
                            }

                            return Center(
                              child: SizedBox(
                                width: 700,
                                child: AddressWidget(
                                  address: addressController
                                      .addressList![index],
                                  fromAddress: false,
                                  isSelected: selected,
                                  fromDashBoard: true,
                                  onTap: () {

                                    Get.dialog(
                                        const CustomLoaderWidget(),
                                        barrierDismissible:
                                            false);

                                    AddressModel address =
                                        addressController
                                            .addressList![index];

                                    Get.find<LocationController>()
                                        .saveAddressAndNavigate(
                                      address,
                                      false,
                                      null,
                                      false,
                                      ResponsiveHelper.isDesktop(
                                          context),
                                    );

                                    Get.find<LocationController>()
                                        .showSuggestedLocation(
                                            false);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  /// USE CURRENT LOCATION
                  TextButton.icon(
                    onPressed: () {

                      Get.find<LocationController>()
                          .checkPermission(() async {

                        Get.dialog(
                            const CustomLoaderWidget(),
                            barrierDismissible: false);

                        AddressModel address =
                            await Get.find<LocationController>()
                                .getCurrentLocation(true);

                        ZoneResponseModel response =
                            await Get.find<LocationController>()
                                .getZone(
                          address.latitude,
                          address.longitude,
                          false,
                        );

                        if (response.isSuccess) {

                          Get.find<LocationController>()
                              .saveAddressAndNavigate(
                            address,
                            false,
                            '',
                            false,
                            ResponsiveHelper.isDesktop(
                                Get.context),
                          );

                        } else {

                          Get.back();

                          Get.toNamed(
                              RouteHelper.getPickMapRoute(
                            RouteHelper.accessLocation,
                            false,
                          ));

                          showCustomSnackBar(
                              'service_not_available_in_current_location'
                                  .tr);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.my_location,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      'use_current_location'.tr,
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
// class AddressBottomSheetWidget extends StatelessWidget {
//   final bool fromDialog;
//   const AddressBottomSheetWidget({super.key, this.fromDialog = false});

//   @override
//   Widget build(BuildContext context) {
//     if (Get.find<AddressController>().addressList == null) {
//       Get.find<AddressController>().getAddressList();
//     }
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         // borderRadius : BorderRadius.only(
//         //   topLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
//         //   topRight : Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
//         //   bottomLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
//         //   bottomRight: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
//         // ),
//       ),
//       child: GetBuilder<AddressController>(builder: (addressController) {
//         AddressModel? selectedAddress =
//             AddressHelper.getUserAddressFromSharedPref();
//         return Column(mainAxisSize: MainAxisSize.min, children: [
//           // fromDialog ? Row(
//           //   mainAxisAlignment: MainAxisAlignment.end,
//           //   children: [
//           //     IconButton(
//           //       onPressed: () {
//           //         Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
//           //         Get.back();
//           //         },
//           //       icon: const Icon(Icons.clear),
//           //     )
//           //   ]
//           // ) : const SizedBox(),

//           // fromDialog ? const SizedBox() : Center(
//           //   child: Container(
//           //     margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
//           //     height: 3, width: 40,
//           //     decoration: BoxDecoration(
//           //       color: Theme.of(context).highlightColor,
//           //       borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//           //     ),
//           //   ),
//           // ),

//           Flexible(
//             child: SingleChildScrollView(
//               // padding: EdgeInsets.symmetric(horizontal: fromDialog ? 50 : Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         // borderRadius: const BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
//                         gradient: LinearGradient(
//                           colors: [
//                             // Colors.blue,
//                             // Colors.blue.withAlpha(150)
//                             Theme.of(context)
//                                 .primaryColor, // main/primary color
//                             Theme.of(context)
//                                 .primaryColor
//                                 .withAlpha(150), // lighter shade
//                             // darker blue (end)
//                           ],
//                           begin: Alignment.topCenter, // gradient start (left)
//                           end: Alignment.bottomCenter, // gradient end (right)
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(
//                                         decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.grey.withAlpha(120)),
//                                         child: const Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Icon(
//                                             Icons.location_off_outlined,
//                                             color: Colors.white,
//                                           ),
//                                         )),
//                                     const SizedBox(
//                                       width: 10,
//                                     ),
//                                     Expanded(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text("Location Permission Is Off",
//                                               style: robotoBold.copyWith(
//                                                   fontSize: Dimensions
//                                                       .fontSizeExtraLarge,
//                                                   color: Theme.of(context)
//                                                       .cardColor)),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 5),
//                                             child: Text(
//                                               "Granting location permission will ensure accurate address and hassel-free delivery,",
//                                               maxLines: 2,
//                                               style: robotoRegular.copyWith(
//                                                   fontSize: Dimensions
//                                                       .fontSizeDefault,
//                                                   color: Theme.of(context)
//                                                       .cardColor),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 4),
//                               child: CustomButton(
//                                 height: 50,
//                                 buttonText: "Grant",
//                                 color: Colors.white, // background color
//                                 //textColor: Colors.blue,
//                                 textColor: Theme.of(context)
//                                     .primaryColor, // foreground color
//                                 onPressed: () {
//                                   Get.find<LocationController>()
//                                       .checkPermission(() async {
//                                     Get.dialog(const CustomLoaderWidget(),
//                                         barrierDismissible: false);
//                                     AddressModel address =
//                                         await Get.find<LocationController>()
//                                             .getCurrentLocation(true);
//                                     ZoneResponseModel response =
//                                         await Get.find<LocationController>()
//                                             .getZone(address.latitude,
//                                                 address.longitude, false);
//                                     if (response.isSuccess) {
//                                       if (ResponsiveHelper.isDesktop(
//                                           Get.context)) {
//                                         Get.find<SplashController>()
//                                             .saveWebSuggestedLocationStatus(
//                                                 true);
//                                       }
//                                       Get.find<LocationController>()
//                                           .saveAddressAndNavigate(
//                                         address,
//                                         false,
//                                         '',
//                                         false,
//                                         ResponsiveHelper.isDesktop(Get.context),
//                                       );
//                                       Get.find<LocationController>()
//                                           .showSuggestedLocation(false);
//                                     } else {
//                                       Get.back();
//                                       if (ResponsiveHelper.isDesktop(
//                                           Get.context)) {
//                                         Get.find<SplashController>()
//                                             .saveWebSuggestedLocationStatus(
//                                                 true);
//                                         showGeneralDialog(
//                                             context: Get.context!,
//                                             pageBuilder: (_, __, ___) {
//                                               return const SizedBox(
//                                                 height: 300,
//                                                 width: 300,
//                                                 child: PickMapScreen(
//                                                     fromSignUp: false,
//                                                     canRoute: false,
//                                                     fromAddAddress: true,
//                                                     route: null),
//                                               );
//                                             });
//                                       } else {
//                                         Get.toNamed(RouteHelper.getPickMapRoute(
//                                             RouteHelper.accessLocation, false));
//                                       }
//                                       showCustomSnackBar(
//                                           'service_not_available_in_current_location'
//                                               .tr);
//                                     }
//                                   });
//                                 },
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: Dimensions.paddingSizeLarge),
//                     Center(
//                       child: addressController.addressList != null &&
//                               addressController.addressList!.isEmpty
//                           ? Column(
//                               mainAxisSize: MainAxisSize.max,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                   Image.asset(Images.noAddress,
//                                       width: fromDialog ? 180 : 150),
//                                   fromDialog
//                                       ? const SizedBox(
//                                           height: Dimensions.paddingSizeDefault)
//                                       : const SizedBox(),
//                                   SizedBox(
//                                     width: 280,
//                                     child: Text(
//                                       'you_dont_have_any_saved_address_yet'.tr,
//                                       textAlign: TextAlign.center,
//                                       style: robotoRegular.copyWith(
//                                           fontSize: Dimensions.fontSizeSmall,
//                                           color:
//                                               Theme.of(context).disabledColor),
//                                     ),
//                                   ),
//                                 ])
//                           : const SizedBox(),
//                     ),

//                     addressController.addressList != null &&
//                             addressController.addressList!.isEmpty
//                         ? const SizedBox(height: Dimensions.paddingSizeLarge)
//                         : const SizedBox(),

//                     addressController.addressList != null
//                         ? addressController.addressList!.isNotEmpty
//                             ? Column(
//                                 children: [
//                                   Text(
//                                     "Select the Delivery Address",
//                                     style: robotoBold.copyWith(
//                                         fontSize:
//                                             Dimensions.fontSizeExtraLarge),
//                                   ),
//                                   const Divider()
//                                 ],
//                               )
//                             : const SizedBox.shrink()
//                         : const SizedBox(height: Dimensions.paddingSizeSmall),

//                     addressController.addressList != null
//                         ? addressController.addressList!.isNotEmpty
//                             ? Container(
//                                 decoration: BoxDecoration(
//                                   // color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
//                                   borderRadius: BorderRadius.circular(
//                                       Dimensions.radiusDefault),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: Dimensions.paddingSizeSmall,
//                                     vertical: Dimensions.paddingSizeSmall),
//                                 child: ListView.builder(
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   padding: EdgeInsets.zero,
//                                   shrinkWrap: true,
//                                   itemCount:
//                                       addressController.addressList!.length > 5
//                                           ? 5
//                                           : addressController
//                                               .addressList!.length,
//                                   itemBuilder: (context, index) {
//                                     bool selected = false;
//                                     if (selectedAddress!.id ==
//                                         addressController
//                                             .addressList![index].id) {
//                                       selected = true;
//                                     }
//                                     return Center(
//                                         child: SizedBox(
//                                             width: 700,
//                                             child: AddressWidget(
//                                               address: addressController
//                                                   .addressList![index],
//                                               fromAddress: false,
//                                               isSelected: selected,
//                                               fromDashBoard: true,
//                                               onTap: () {
//                                                 Get.dialog(
//                                                     const CustomLoaderWidget(),
//                                                     barrierDismissible: false);
//                                                 AddressModel address =
//                                                     addressController
//                                                         .addressList![index];
//                                                 Get.find<LocationController>()
//                                                     .saveAddressAndNavigate(
//                                                   address,
//                                                   false,
//                                                   null,
//                                                   false,
//                                                   ResponsiveHelper.isDesktop(
//                                                       context),
//                                                 );

//                                                 Get.find<LocationController>()
//                                                     .showSuggestedLocation(
//                                                         false);
//                                                 Get.find<SplashController>()
//                                                     .saveWebSuggestedLocationStatus(
//                                                         true);
//                                               },
//                                             )));
//                                   },
//                                 ),
//                               )
//                             : const SizedBox()
//                         : Shimmer(
//                             duration: const Duration(seconds: 2),
//                             interval: const Duration(seconds: 0),
//                             color: Colors.grey.shade300,
//                             colorOpacity: 0.3,
//                             enabled: true,
//                             direction: const ShimmerDirection.fromLeftToRight(),
//                             child: Container(
//                               width: 700,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeSmall,
//                                 vertical: Dimensions.paddingSizeSmall,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade300,
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.radiusDefault),
//                               ),
//                               child: Column(
//                                 children: List.generate(
//                                   2,
//                                   (index) => Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical:
//                                             Dimensions.paddingSizeSmall / 2),
//                                     child: Container(
//                                       height:
//                                           30, // approximate height of AddressWidget
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(
//                                             Dimensions.radiusDefault),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                     // SizedBox(height: addressController.addressList != null && addressController.addressList!.isEmpty ? 0 : Dimensions.paddingSizeSmall),
//                     // (addressController.addressList != null && fromDialog) ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),
//                     Align(
//                       alignment: addressController.addressList != null &&
//                               addressController.addressList!.isEmpty &&
//                               !fromDialog
//                           ? Alignment.center
//                           : Alignment.topCenter,
//                       child: TextButton.icon(
//                         onPressed: () {
//                           Get.find<LocationController>()
//                               .checkPermission(() async {
//                             Get.dialog(const CustomLoaderWidget(),
//                                 barrierDismissible: false);
//                             AddressModel address =
//                                 await Get.find<LocationController>()
//                                     .getCurrentLocation(true);
//                             ZoneResponseModel response =
//                                 await Get.find<LocationController>().getZone(
//                                     address.latitude, address.longitude, false);
//                             if (response.isSuccess) {
//                               if (ResponsiveHelper.isDesktop(Get.context)) {
//                                 Get.find<SplashController>()
//                                     .saveWebSuggestedLocationStatus(true);
//                               }
//                               Get.find<LocationController>()
//                                   .saveAddressAndNavigate(
//                                 address,
//                                 false,
//                                 '',
//                                 false,
//                                 ResponsiveHelper.isDesktop(Get.context),
//                               );
//                               Get.find<LocationController>()
//                                   .showSuggestedLocation(false);
//                             } else {
//                               Get.back();
//                               if (ResponsiveHelper.isDesktop(Get.context)) {
//                                 Get.find<SplashController>()
//                                     .saveWebSuggestedLocationStatus(true);
//                                 showGeneralDialog(
//                                     context: Get.context!,
//                                     pageBuilder: (_, __, ___) {
//                                       return const SizedBox(
//                                         height: 300,
//                                         width: 300,
//                                         child: PickMapScreen(
//                                             fromSignUp: false,
//                                             canRoute: false,
//                                             fromAddAddress: true,
//                                             route: null),
//                                       );
//                                     });
//                               } else {
//                                 Get.toNamed(RouteHelper.getPickMapRoute(
//                                     RouteHelper.accessLocation, false));
//                               }
//                               showCustomSnackBar(
//                                   'service_not_available_in_current_location'
//                                       .tr);
//                             }
//                           });
//                         },
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(
//                                   Radius.circular(Dimensions.radiusDefault))),
//                           fixedSize: const Size(230, 40),
//                           backgroundColor:
//                               addressController.addressList != null &&
//                                       addressController.addressList!.isEmpty
//                                   ? Theme.of(context).primaryColor
//                                   : Colors.transparent,
//                         ),
//                         icon: Icon(Icons.my_location,
//                             color: addressController.addressList != null &&
//                                     addressController.addressList!.isEmpty
//                                 ? Theme.of(context).cardColor
//                                 : Theme.of(context).primaryColor),
//                         label: Text('use_current_location'.tr,
//                             style: fromDialog
//                                 ? robotoRegular.copyWith(
//                                     fontSize: Dimensions.fontSizeExtraSmall,
//                                     color:
//                                         addressController.addressList != null &&
//                                                 addressController
//                                                     .addressList!.isEmpty
//                                             ? Theme.of(context).cardColor
//                                             : Theme.of(context).primaryColor)
//                                 : robotoMedium.copyWith(
//                                     color:
//                                         addressController.addressList != null &&
//                                                 addressController
//                                                     .addressList!.isEmpty
//                                             ? Theme.of(context).cardColor
//                                             : Theme.of(context).primaryColor)),
//                       ),
//                     ),
//                     // addressController.addressList != null && addressController.addressList!.isNotEmpty ? Center(
//                     //   child: TextButton.icon(
//                     //     onPressed: () {
//                     //       Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
//                     //       Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0));
//                     //     },
//                     //     icon: const Icon(Icons.add_circle_outline_sharp),
//                     //     label: Text('add_new_address'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
//                     //   ),
//                     // ) : const SizedBox(),
//                   ]),
//             ),
//           ),
//         ]);
//       }),
//     );
//   }
// }
