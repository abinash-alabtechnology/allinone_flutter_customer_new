import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/common/widgets/address_widget.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_dropdown.dart';
import 'package:handy_allinone/features/checkout/widgets/guest_delivery_address.dart';

class DeliverySection extends StatelessWidget {
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  const DeliverySection({
    super.key,
    required this.checkoutController,
    required this.address,
    required this.addressList,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
  });

  @override
  Widget build(BuildContext context) {

    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);


    return Column(
      children: [
        isGuestLoggedIn
            ? GuestDeliveryAddress(
                checkoutController: checkoutController,
                guestNumberNode: guestNumberNode,
                guestNameTextEditingController: guestNameTextEditingController,
                guestNumberTextEditingController:
                    guestNumberTextEditingController,
                guestEmailController: guestEmailController,
                guestEmailNode: guestEmailNode,
              )
            : !takeAway
            ? Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                  vertical: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text(
                              'deliver_to'.tr.toUpperCase(),
                              style: robotoBold,
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            var address = await Get.toNamed(
                              RouteHelper.getAddAddressRoute(
                                true,
                                false,
                                checkoutController.store!.zoneId,
                              ),
                            );

                            if (address != null) {
                              checkoutController.getDistanceInKM(
                                LatLng(
                                  double.parse(address.latitude),
                                  double.parse(address.longitude),
                                ),
                                LatLng(
                                  double.parse(
                                    checkoutController.store!.latitude!,
                                  ),
                                  double.parse(
                                    checkoutController.store!.longitude!,
                                  ),
                                ),
                              );

                              checkoutController.streetNumberController.text =
                                  address.streetNumber ?? '';
                              checkoutController.cityController.text =
                                  address.city ?? '';
                              checkoutController.stateController.text =
                                  address.state ?? '';
                              checkoutController.countryController.text =
                                  address.country ?? '';
                              checkoutController.pincodeController.text =
                                  address.pincode ?? '';
                              checkoutController.houseController.text =
                                  address.house ?? '';
                              checkoutController.floorController.text =
                                  address.floor ?? '';
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'add_new'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    isDesktop
                        ? Stack(
                            children: [
                            if(address.isNotEmpty)  Container(
                                constraints: const BoxConstraints(
                                  minHeight: 90,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                ),
                                child: Container(
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: AddressWidget(
                                    address:
                                        address[checkoutController
                                            .addressIndex!],
                                    fromAddress: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              ),

                              if(address.isNotEmpty)  Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: PopupMenuButton(
                                    position: PopupMenuPosition.under,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    onSelected: (value) {},
                                    itemBuilder: (context) => List.generate(
                                      address.length,
                                      (index) => PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            checkoutController.getDistanceInKM(
                                              LatLng(
                                                double.parse(
                                                  address[index].latitude!,
                                                ),
                                                double.parse(
                                                  address[index].longitude!,
                                                ),
                                              ),
                                              LatLng(
                                                double.parse(
                                                  checkoutController
                                                      .store!
                                                      .latitude!,
                                                ),
                                                double.parse(
                                                  checkoutController
                                                      .store!
                                                      .longitude!,
                                                ),
                                              ),
                                            );
                                            checkoutController.setAddressIndex(
                                              index,
                                            );
                                            checkoutController
                                                    .streetNumberController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .streetNumber ??
                                                '';
                                            checkoutController
                                                    .houseController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .house ??
                                                '';
                                            checkoutController
                                                    .floorController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .floor ??
                                                '';
                                            checkoutController
                                                    .cityController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .city ??
                                                '';
                                            checkoutController
                                                    .stateController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .state ??
                                                '';
                                            checkoutController
                                                    .countryController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .country ??
                                                '';
                                            checkoutController
                                                    .pincodeController
                                                    .text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .pincode ??
                                                '';
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 20,
                                                width: 20,
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        checkoutController
                                                                .addressIndex ==
                                                            index
                                                        ? Theme.of(
                                                            context,
                                                          ).primaryColor
                                                        : Theme.of(
                                                            context,
                                                          ).disabledColor,
                                                  ),
                                                ),
                                                child:
                                                    checkoutController
                                                            .addressIndex ==
                                                        index
                                                    ? Container(
                                                        height: 15,
                                                        width: 15,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                            ),
                                                      )
                                                    : const SizedBox(),
                                              ),

                                              const SizedBox(
                                                width:
                                                    Dimensions.paddingSizeSmall,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      address[index]
                                                          .addressType!
                                                          .tr,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Text(
                                                      address[index].address!,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeExtraSmall,
                                                        color: Theme.of(
                                                          context,
                                                        ).disabledColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : (address.isNotEmpty)? Container(
                            padding: EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                            ),
                            child: CustomDropdown<int>(
                              onChange: (int? value, int index) {
                                checkoutController.getDistanceInKM(
                                  LatLng(
                                    double.parse(address[index].latitude!),
                                    double.parse(address[index].longitude!),
                                  ),
                                  LatLng(
                                    double.parse(
                                      checkoutController.store!.latitude!,
                                    ),
                                    double.parse(
                                      checkoutController.store!.longitude!,
                                    ),
                                  ),
                                );
                                checkoutController.setAddressIndex(index);

                                checkoutController.streetNumberController.text =
                                    address[checkoutController.addressIndex!]
                                        .streetNumber ??
                                    '';
                                checkoutController.houseController.text =
                                    address[checkoutController.addressIndex!]
                                        .house ??
                                    '';

                                checkoutController.floorController.text =
                                    address[checkoutController.addressIndex!]
                                        .floor ??
                                    '';
                                ///
                                checkoutController.cityController.text =
                                    address[checkoutController.addressIndex!]
                                        .city ??
                                        '';
                                checkoutController.stateController.text =
                                    address[checkoutController.addressIndex!]
                                        .state ??
                                        ''; checkoutController.countryController.text =
                                    address[checkoutController.addressIndex!]
                                        .country ??
                                        ''; checkoutController.pincodeController.text =
                                    address[checkoutController.addressIndex!]
                                        .pincode ??
                                        '';
                              },
                              dropdownButtonStyle: DropdownButtonStyle(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                  horizontal: Dimensions.paddingSizeExtraSmall,
                                ),
                                primaryColor: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                              dropdownStyle: DropdownStyle(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                              ),
                              items: addressList,
                              child: IntrinsicHeight(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                  ),
                                  child: AddressWidget(
                                    address:
                                        address[checkoutController
                                            .addressIndex!],
                                    fromAddress: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              ),
                            ),
                          ):SizedBox(),
                    // const SizedBox(height: Dimensions.paddingSizeLarge),

                    // !isDesktop
                    //     ? Row(
                    //         children: [
                    //           Expanded(
                    //             child: CustomTextField(
                    //               labelText: "City",
                    //               titleText: "write your city name",
                    //               inputType: TextInputType.streetAddress,
                    //               focusNode: checkoutController.cityNode,
                    //               nextFocus: checkoutController.stateNode,
                    //               controller: checkoutController.cityController,
                    //             ),
                    //           ),
                    //           const SizedBox(
                    //             width: Dimensions.paddingSizeSmall,
                    //           ),
                    //           Expanded(
                    //             child: CustomTextField(
                    //               labelText: 'State',
                    //               titleText: 'Write your state name',
                    //               inputType: TextInputType.streetAddress,
                    //               focusNode: checkoutController.stateNode,
                    //               nextFocus: checkoutController.countryNode,
                    //               controller:
                    //                   checkoutController.stateController,
                    //             ),
                    //           ),
                    //         ],
                    //       )
                    //     : const SizedBox(),
                    // SizedBox(
                    //   height: !isDesktop ? Dimensions.paddingSizeLarge : 0,
                    // ),
                    //
                    // Row(
                    //   children: [
                    //     isDesktop
                    //         ? Expanded(
                    //             child: CustomTextField(
                    //               labelText: "City",
                    //               titleText: "write your city name",
                    //               inputType: TextInputType.streetAddress,
                    //               focusNode: checkoutController.cityNode,
                    //               nextFocus: checkoutController.stateNode,
                    //               controller: checkoutController.cityController,
                    //             ),
                    //           )
                    //         : const SizedBox(),
                    //
                    //     SizedBox(
                    //       width: isDesktop ? Dimensions.paddingSizeSmall : 0,
                    //     ),
                    //     isDesktop
                    //         ? Expanded(
                    //             child: CustomTextField(
                    //               labelText: 'State',
                    //               titleText: 'Write your state name',
                    //               inputType: TextInputType.streetAddress,
                    //               focusNode: checkoutController.stateNode,
                    //               nextFocus: checkoutController.countryNode,
                    //               controller:
                    //                   checkoutController.stateController,
                    //             ),
                    //           )
                    //         : SizedBox(),
                    //
                    //     Expanded(
                    //       child: CustomTextField(
                    //         titleText: "Write your country name",
                    //         labelText: "Country",
                    //         inputType: TextInputType.text,
                    //         focusNode: checkoutController.countryNode,
                    //         nextFocus: checkoutController.pincodeNode,
                    //         controller: checkoutController.countryController,
                    //       ),
                    //     ),
                    //     const SizedBox(width: Dimensions.paddingSizeSmall),
                    //
                    //     Expanded(
                    //       child: CustomTextField(
                    //         titleText: "Write your PinCode",
                    //         labelText: 'PinCode',
                    //         inputType: TextInputType.text,
                    //         focusNode: checkoutController.pincodeNode,
                    //         inputAction: TextInputAction.done,
                    //         controller: checkoutController.pincodeController,
                    //       ),
                    //     ),
                    //     //const SizedBox(height: Dimensions.paddingSizeLarge),
                    //   ],
                    // ),
                    // const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
