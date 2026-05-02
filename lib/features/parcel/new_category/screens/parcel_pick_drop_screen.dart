import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:handy_allinone/common/widgets/address_widget.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/features/location/screens/pick_map_screen.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/parcel/domain/models/parcel_category_model.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/custom_validator.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../../../common/widgets/custom_app_bar.dart';
import '../widget_category/parcel_pick_drop_widget/custom_drop_dow2_widget.dart';
import '../widget_category/parcel_pick_drop_widget/parcel_address_details_widget.dart';
import '../widget_category/parcel_pick_drop_widget/parcel_address_picker_widget.dart';
import '../widget_category/parcel_pick_drop_widget/parcel_app_bar_widget.dart';
import '../widget_category/parcel_pick_drop_widget/parcel_receiver_details_widget.dart';
import '../widget_category/parcel_pick_drop_widget/parcel_select_delivery_widget.dart';
import '../widget_category/parcel_snack_bar_widget.dart';

class ParcelPickDropScreen extends StatefulWidget {
  final ParcelCategoryModel category;

  const ParcelPickDropScreen({super.key, required this.category});

  @override
  State<ParcelPickDropScreen> createState() => _ParcelPickDropScreenState();
}

class _ParcelPickDropScreenState extends State<ParcelPickDropScreen>
    with SingleTickerProviderStateMixin {
  ///
  /// below the controller for sender details
  ///
  late TextEditingController _streetNameControllerSender;
  late TextEditingController _houseNumberControllerSender;
  late TextEditingController _floorControllerSender;
  late TextEditingController _senderNameControllerSender;
  late TextEditingController _phoneNumberControllerSender;
  late TextEditingController _emailIDControllerSender;

  ///
  /// below the controller for receiver details
  ///
  late TextEditingController _streetNameControllerReceiver;
  late TextEditingController _houseNumberControllerReceiver;
  late TextEditingController _floorControllerReceiver;
  late TextEditingController _receiverNameControllerReceiver;
  late TextEditingController _phoneNumberControllerReceiver;
  late TextEditingController _emailIDControllerReceiver;

  ///
  /// below the controller for parcel details
  ///
  final ParcelController _parcelController = Get.find<ParcelController>();

  late AnimationController _controller;
  late Animation<AlignmentGeometry> _alignAnimation;
  late Worker _worker;


  @override
  void initState() {
    super.initState();
    _streetNameControllerSender = TextEditingController();
    _houseNumberControllerSender = TextEditingController();
    _floorControllerSender = TextEditingController();
    _senderNameControllerSender = TextEditingController();
    _phoneNumberControllerSender = TextEditingController();
    _emailIDControllerSender = TextEditingController();
    
    if (Get.find<ProfileController>().userInfoModel != null) {
      _senderNameControllerSender.text = '${Get.find<ProfileController>().userInfoModel!.fName ?? ''} ${Get.find<ProfileController>().userInfoModel!.lName ?? ''}'.trim();
      _emailIDControllerSender.text = Get.find<ProfileController>().userInfoModel!.email ?? '';
      String phone = Get.find<ProfileController>().userInfoModel!.phone ?? '';
      if (phone.isNotEmpty) {
        try {
          PhoneNumber phoneNumber = PhoneNumber.parse(phone);
          _phoneNumberControllerSender.text = phoneNumber.nsn;
        } catch (e) {
          _phoneNumberControllerSender.text = phone;
        }
      }
    }

    //receiver
    _streetNameControllerReceiver = TextEditingController();
    _houseNumberControllerReceiver = TextEditingController();
    _floorControllerReceiver = TextEditingController();
    _receiverNameControllerReceiver = TextEditingController();
    _phoneNumberControllerReceiver = TextEditingController();
    _emailIDControllerReceiver = TextEditingController();
    initAnimation();
    listenToIndex();
  }

  @override
  void dispose() {
    _streetNameControllerSender.dispose();
    _houseNumberControllerSender.dispose();
    _floorControllerSender.dispose();
    _senderNameControllerSender.dispose();
    _phoneNumberControllerSender.dispose();
    _emailIDControllerSender.dispose();
    // receiver
    _streetNameControllerReceiver.dispose();
    _houseNumberControllerReceiver.dispose();
    _floorControllerReceiver.dispose();
    _receiverNameControllerReceiver.dispose();
    _phoneNumberControllerReceiver.dispose();
    _emailIDControllerReceiver.dispose();
    _worker.dispose();
    _controller.dispose();
    super.dispose();
  }

  RxInt selectedIndex = 0.obs;


  void initAnimation() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _alignAnimation = AlignmentTween(
        begin: const Alignment(-0.87, 0.0), end: const Alignment(0.87, 0.0))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuart,
      ),
    );
  }

  void listenToIndex() {
    _worker = ever(selectedIndex, (i) {
      if (i == 0) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Obx(
          () =>
          Scaffold(
            appBar: CustomAppBar3(
              title: "DELIVERY DETAILS",
              backButton: true,
            ),
            backgroundColor: Colors.grey.shade100,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 53,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      AlignTransition(
                        alignment: _alignAnimation,
                        child: Container(
                          height: 45,
                          width: context.width / 2.3 - 12,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 28, 3, 101),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(97, 44, 7, 153),
                                  blurRadius: 8,
                                  spreadRadius: 0.1,
                                  offset: Offset(0, 0),
                                ),
                              ]),
                        ),
                      ),
                      Obx(
                            () =>
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _controller.reverse();
                                    selectedIndex.value = 0;
                                  },
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 350),
                                    style: selectedIndex.value == 0
                                        ? robotoBold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    )
                                        : robotoBlack.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    curve: Curves.easeIn,
                                    child: const Text(
                                      "Sender",
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_senderNameControllerSender.text
                                        .trim()
                                        .isEmpty) {
                                      showSnackBarError(
                                        "Sender Name",
                                        context,
                                        "Sender Name is required",
                                      );
                                      return;
                                    }

                                    if (_phoneNumberControllerSender.text
                                        .trim()
                                        .length < 10) {
                                      showSnackBarError(
                                        "Sender Phone Number",
                                        context,
                                        "Sender Phone Number is required",
                                      );
                                      return;
                                    }
                                    if (_parcelController.pickupAddress ==
                                        null ||
                                        (_parcelController.pickupAddress!
                                            .id==null)) {
                                      showSnackBarError(
                                        "Pickup Address",
                                        context,
                                        "Pickup address is required",
                                      );
                                      return;
                                    }

                                    _controller.forward();
                                    selectedIndex.value = 1;
                                  },
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 350),
                                    style: selectedIndex.value == 1
                                        ? robotoBold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    )
                                        : robotoBlack.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    curve: Curves.easeIn,
                                    child: const Text("Receiver",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeInBack,
                      transitionBuilder: (child, animation) {
                        final key = (child.key as ValueKey).value;
                        final isSender = key == 0;

                        final slideIn = Tween<Offset>(
                          begin:
                          isSender ? const Offset(-0.3, 0.1) : const Offset(0.3,
                              0.1),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slideIn,
                            child: child,
                          ),
                        );
                      },
                      child: selectedIndex.value == 0
                          ? SenderDetailsWidget(
                        key: const ValueKey(0),
                        streetNameControllerSender: _streetNameControllerSender,
                        houseNumberControllerSender: _houseNumberControllerSender,
                        floorControllerSender: _floorControllerSender,
                        senderNameControllerSender: _senderNameControllerSender,
                        phoneNumberControllerSender: _phoneNumberControllerSender,
                        emailIDControllerSender: _emailIDControllerSender,
                      )
                          : ReceiverDetailsWidget(
                        key: const ValueKey(1),
                        streetNameControllerReceiver: _streetNameControllerReceiver,
                        houseNumberControllerReceiver: _houseNumberControllerReceiver,
                        floorControllerReceiver: _floorControllerReceiver,
                        receiverNameControllerReceiver: _receiverNameControllerReceiver,
                        phoneNumberControllerReceiver: _phoneNumberControllerReceiver,
                        emailIDControllerReceiver: _emailIDControllerReceiver,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ParcelPicDropBottomButton(
              title: selectedIndex.value == 0
                  ? "CONTINUE"
                  : "CONFIRM & CONTINUE",
              onPressed: selectedIndex.value == 0
                  ? () {
                if (_senderNameControllerSender.text.isEmpty) {
                  showSnackBarError(
                      "Sender Name", context, "Sender Name is required");
                  return;
                } else if (_phoneNumberControllerSender.text.isEmpty ||
                    _phoneNumberControllerSender.text.length < 10) {
                  showSnackBarError("Sender Phone Number", context,
                      "Sender Phone Number is required");
                  return;
                } if (_parcelController.pickupAddress ==
                    null ||
                    (_parcelController.pickupAddress!
                        .id==null)) {
                  showSnackBarError(
                    "Pickup Address",
                    context,
                    "Pickup address is required",
                  );
                  return;
                }

                else if (AuthHelper.isGuestLoggedIn() &&
                    _emailIDControllerSender.text.isEmpty) {
                  showSnackBarError(
                      "Sender Email", context, "Sender Email is required");
                  return;
                } else if (AuthHelper.isGuestLoggedIn() &&
                    !CustomValidator.isEmailValid(
                        _emailIDControllerSender.text.trim())) {
                  showSnackBarError(
                      "Sender Email", context, "Sender Email is invalid");
                  return;
                }
                AddressModel pickup = AddressModel(
                  address: _parcelController.pickupAddress!.address,
                  additionalAddress:
                  _parcelController.pickupAddress!.additionalAddress,
                  addressType: _parcelController.pickupAddress!.addressType,
                  contactPersonName: _senderNameControllerSender.text.trim(),
                  contactPersonNumber:
                  _phoneNumberControllerSender.text.trim(),
                  latitude: _parcelController.pickupAddress!.latitude,
                  longitude: _parcelController.pickupAddress!.longitude,
                  method: _parcelController.pickupAddress!.method,
                  zoneId: _parcelController.pickupAddress!.zoneId,
                  id: _parcelController.pickupAddress!.id,
                  zoneIds: _parcelController.pickupAddress!.zoneIds,
                  streetNumber: _streetNameControllerSender.text.trim(),
                  house: _houseNumberControllerSender.text.trim(),
                  floor: _floorControllerSender.text.trim(),
                  email: _emailIDControllerSender.text.trim(),
                );
                _parcelController.setPickupAddress(pickup, true);
                selectedIndex.value = 1;
              }
                  : () {
                if (_receiverNameControllerReceiver.text.isEmpty) {
                  showSnackBarError(
                      "Receiver Name", context, "Receiver Name is required");
                  return;
                } else if (_phoneNumberControllerReceiver.text.isEmpty ||
                    _phoneNumberControllerReceiver.text.length < 10) {
                  showSnackBarError("Receiver Phone Number", context,
                      "Receiver Phone Number is required");
                  return;
                }
                // else if (_parcelController.senderAddressIndex ==
                //     _parcelController.receiverAddressIndex) {
                //   showSnackBarError("Address", context,
                //       "Sender and Receiver Address can't be same");
                //   return;
                // }
                else if (AuthHelper.isGuestLoggedIn() &&
                    _emailIDControllerReceiver.text.isEmpty) {
                  showSnackBarError("Receiver Email", context,
                      "Receiver Email is required");
                  return;
                } else if (AuthHelper.isGuestLoggedIn() &&
                    !CustomValidator.isEmailValid(
                        _emailIDControllerReceiver.text.trim())) {
                  showSnackBarError(
                      "Receiver Email", context, "Receiver Email is invalid");
                  return;
                }
                AddressModel destination = AddressModel(
                  address: _parcelController.destinationAddress!.address,
                  additionalAddress:
                  _parcelController.destinationAddress!.additionalAddress,
                  addressType:
                  _parcelController.destinationAddress!.addressType,
                  contactPersonName:
                  _receiverNameControllerReceiver.text.trim(),
                  contactPersonNumber:
                  _phoneNumberControllerReceiver.text.trim(),
                  latitude: _parcelController.destinationAddress!.latitude,
                  longitude: _parcelController.destinationAddress!.longitude,
                  method: _parcelController.destinationAddress!.method,
                  zoneId: _parcelController.destinationAddress!.zoneId,
                  zoneIds: _parcelController.destinationAddress!.zoneIds,
                  id: _parcelController.destinationAddress!.id,
                  streetNumber: _streetNameControllerReceiver.text.trim(),
                  house: _houseNumberControllerReceiver.text.trim(),
                  floor: _floorControllerReceiver.text.trim(),
                  email: _emailIDControllerReceiver.text.trim(),
                );

                _parcelController.setDestinationAddress(destination);

                Get.toNamed(
                  RouteHelper.getParcelRequestRoute(
                    widget.category,
                    _parcelController.pickupAddress!,
                    _parcelController.destinationAddress!,
                  ),
                );
              },
            ),
          ),
    );
  }
}

///
/// Parcel Button Widget
///
class ParcelPicDropBottomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;

  const ParcelPicDropBottomButton(
      {super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery
        .viewInsetsOf(context)
        .bottom;
    return Container(
      height: 80,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: bottom),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 0.8),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              title.contains("CONFIRM & CONTINUE")
                  ? const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              )
                  : const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
              Text(
                title,
                style: robotoBold.copyWith(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///
/// Sender Details Widget
///
class SenderDetailsWidget extends StatefulWidget {
  final TextEditingController streetNameControllerSender;
  final TextEditingController houseNumberControllerSender;
  final TextEditingController floorControllerSender;
  final TextEditingController senderNameControllerSender;
  final TextEditingController phoneNumberControllerSender;
  final TextEditingController emailIDControllerSender;

  const SenderDetailsWidget({
    super.key,
    required this.streetNameControllerSender,
    required this.houseNumberControllerSender,
    required this.floorControllerSender,
    required this.senderNameControllerSender,
    required this.phoneNumberControllerSender,
    required this.emailIDControllerSender,
  });

  @override
  State<SenderDetailsWidget> createState() => _SenderDetailsWidgetState();
}

class _SenderDetailsWidgetState extends State<SenderDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GetBuilder<AddressController>(
          builder: (addressController) {
            return GetBuilder<ParcelController>(
              builder: (parcelController) {
                List<DropdownItem2<int>> senderAddressList =
                _getDropdownAddressList(
                  context: context,
                  addressList: addressController.addressList,
                  isSender: true,
                  pickupAddress: parcelController.pickupAddress,
                  destinationAddress: parcelController.destinationAddress,
                );

                if (senderAddressList.isNotEmpty) {
                  senderAddressList.removeAt(0);
                }
                List<AddressModel> senderAddress = _getAddressList(
                  addressList: addressController.addressList,
                  isSender: true,
                  pickupAddress: parcelController.pickupAddress,
                  destinationAddress: parcelController.destinationAddress,
                );
                List<AddressModel> firstsenderAddress = _getAddressList(
                  addressList: addressController.addressList,
                  isSender: true,
                  pickupAddress: parcelController.pickupAddress,
                  destinationAddress: parcelController.destinationAddress,
                );
                if (senderAddress.isNotEmpty) {
                  senderAddress.removeAt(0);
                }
                if (senderAddress.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    parcelController.setSenderAddressIndex(parcelController.senderAddressIndex??0);
                    AddressModel pickupAddress=senderAddress[parcelController.senderAddressIndex??0];
                    parcelController.setPickupAddress(pickupAddress, true);
                  });
                }
                return Column(
                  children: [
                    // ParcelSelectDeliveryWidget(
                    //   onTap: () {
                    //     /**
                    //      * implemented sender(picker) address details
                    //      */
                    //     Get.toNamed(
                    //       RouteHelper.getPickMapRoute('parcel', false),
                    //       arguments: PickMapScreen(
                    //         fromSignUp: false,
                    //         fromAddAddress: false,
                    //         canRoute: false,
                    //         route: '',
                    //         onPicked: (AddressModel address) async {
                    //           ZoneResponseModel responseModel =
                    //           await Get.find<LocationController>().getZone(
                    //               address.latitude.toString(),
                    //               address.longitude.toString(),
                    //               false);
                    //           AddressModel pickupAddress = AddressModel(
                    //             id: address.id,
                    //             addressType: address.addressType,
                    //             contactPersonNumber:
                    //             address.contactPersonNumber,
                    //             contactPersonName: address.contactPersonName,
                    //             address: address.address,
                    //             latitude: address.latitude,
                    //             longitude: address.longitude,
                    //             zoneId: responseModel.isSuccess
                    //                 ? responseModel.zoneIds[0]
                    //                 : 0,
                    //             zoneIds: responseModel.zoneIds,
                    //             method: address.method,
                    //             streetNumber: address.streetNumber,
                    //             house: address.house,
                    //             floor: address.floor,
                    //           );
                    //           parcelController.setPickupAddress(
                    //               pickupAddress, true);
                    //           parcelController.setSenderAddressIndex(0);
                    //         },
                    //       ),
                    //     );
                    //     /**
                    //      * Till here it working fine
                    //      *
                    //      * HOW IT WORKS ??
                    //      *  it get user point location on map and save in the
                    //      *  parcelController.pickupAddress
                    //      *
                    //      * DOUBT ??
                    //      *  i have now idea what is the purpose of saveing index i have kept it 0
                    //      *  beacuse the previous code doing the same thing parcelController.setSenderAddressIndex(0);
                    //      *
                    //      */
                    //   },
                    // ),
                    ParcelAddressPickerWidget(
                      onChange: (int? value, int index) async {
                        if (index >= 0 && index < senderAddress.length) {
                          AddressModel _selectedAddress = senderAddress[index];
                          parcelController.setPickupAddress(
                            _selectedAddress,
                            true,
                          );
                          parcelController.setSenderAddressIndex(index);

                          if (_selectedAddress.contactPersonName != null &&
                              _selectedAddress.contactPersonName!.isNotEmpty) {
                            widget.senderNameControllerSender.text =
                            _selectedAddress.contactPersonName!;
                          } else {
                            widget.senderNameControllerSender.text = '';
                          }

                          if (_selectedAddress.contactPersonNumber != null &&
                              _selectedAddress
                                  .contactPersonNumber!.isNotEmpty &&
                              !_selectedAddress.contactPersonNumber!
                                  .contains("null")) {
                            _splitPhoneNumber(
                                _selectedAddress.contactPersonNumber!);
                          } else {
                            widget.phoneNumberControllerSender.text = '';
                          }

                          if (_selectedAddress.email != null &&
                              _selectedAddress.email!.isNotEmpty) {
                            widget.emailIDControllerSender.text =
                            _selectedAddress.email!;
                          } else {
                            widget.emailIDControllerSender.text = '';
                          }
                        }
                      },
                      title: "SAVED ADDRESS",
                      /**
                       *  the addressController hold the all address list
                       *  where we saved it
                       */
                      addressList: senderAddressList,
                      widget: senderAddressList.isNotEmpty?AddressWidgetCustom(
                        address: senderAddress[parcelController.senderAddressIndex!],
                      ):null,
                      onTap: () async {
                        debugPrint("snjdnd${firstsenderAddress?[0].zoneId}");
                        await Get.toNamed(
                          RouteHelper.getAddAddressRoute(
                            true,
                            false,
                            firstsenderAddress?[0].zoneId??0,
                          ),
                        );


                        // Get.toNamed(
                        //   RouteHelper.getPickMapRoute('parcel', false),
                        //   arguments: PickMapScreen(
                        //     fromSignUp: false,
                        //     fromAddAddress: false,
                        //     canRoute: false,
                        //     route: '',
                        //     onPicked: (AddressModel address) async {
                        //       ZoneResponseModel responseModel =
                        //       await Get.find<LocationController>().getZone(
                        //           address.latitude.toString(),
                        //           address.longitude.toString(),
                        //           false);
                        //       AddressModel pickupAddress = AddressModel(
                        //         id: address.id,
                        //         addressType: address.addressType,
                        //         contactPersonNumber:
                        //         address.contactPersonNumber,
                        //         contactPersonName: address.contactPersonName,
                        //         address: address.address,
                        //         latitude: address.latitude,
                        //         longitude: address.longitude,
                        //         zoneId: responseModel.isSuccess
                        //             ? responseModel.zoneIds[0]
                        //             : 0,
                        //         zoneIds: responseModel.zoneIds,
                        //         method: address.method,
                        //         streetNumber: address.streetNumber,
                        //         house: address.house,
                        //         floor: address.floor,
                        //       );
                        //       parcelController.setPickupAddress(
                        //           pickupAddress, true);
                        //       parcelController.setSenderAddressIndex(0);
                        //     },
                        //   ),
                        // );
                        /**
                         * Till here it working fine
                         *
                         * HOW IT WORKS ??
                         *  it get user point location on map and save in the
                         *  parcelController.pickupAddress
                         *
                         * DOUBT ??
                         *  i have now idea what is the purpose of saveing index i have kept it 0
                         *  beacuse the previous code doing the same thing parcelController.setSenderAddressIndex(0);
                         *
                         **/
                      },
                    ),
                    // ParcelAddressDetailsWidget(
                    //   title: "ADDRESS DETAILS",
                    //   streetName: widget.streetNameControllerSender,
                    //   houseNumber: widget.houseNumberControllerSender,
                    //   floor: widget.floorControllerSender,
                    // ),
                    ParcelReceiverDetailsWidget(
                      title: "SENDER DETAILS",
                      emailId: widget.emailIDControllerSender,
                      phoneNumber: widget.phoneNumberControllerSender,
                      senderName: widget.senderNameControllerSender,
                      isGestuLogin: AuthHelper.isGuestLoggedIn(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _splitPhoneNumber(String number) {
    debugPrint("\u001B[32m number : $number \u001B[0m");
    String addressCountryCode = '';
    PhoneNumber phoneNumber = PhoneNumber.parse(number);
    addressCountryCode = '+${phoneNumber.countryCode}';
    widget.phoneNumberControllerSender.text =
        phoneNumber.international.substring(addressCountryCode.length);
  }

  List<AddressModel> _getAddressList(
      {required List<AddressModel>? addressList,
        required bool isSender,
        required AddressModel? pickupAddress,
        required AddressModel? destinationAddress}) {
    List<AddressModel> address = [];

    if (isSender) {
      address.add(pickupAddress!);
    } else if (!isSender) {
      address.add(
          destinationAddress ?? AddressHelper.getUserAddressFromSharedPref()!);
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        address.add(addressList[index]);
      }
    }
    return address;
  }

  List<DropdownItem2<int>> _getDropdownAddressList(
      {required BuildContext context,
        required List<AddressModel>? addressList,
        required bool isSender,
        required AddressModel? pickupAddress,
        required AddressModel? destinationAddress}) {
    List<DropdownItem2<int>> dropDownAddressList = [];

    if (isSender) {
      dropDownAddressList.add(
        DropdownItem2<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidgetCustom2(
              address:
              pickupAddress ?? AddressHelper.getUserAddressFromSharedPref(),
            ),
          ),
        ),
      );
    } else {
      dropDownAddressList.add(
        DropdownItem2<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidgetCustom2(
              address: destinationAddress ??
                  AddressHelper.getUserAddressFromSharedPref(),
            ),
          ),
        ),
      );
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        dropDownAddressList.add(
          DropdownItem2<int>(
            value: index + 1,
            child: SizedBox(
              width: context.width > Dimensions.webMaxWidth
                  ? Dimensions.webMaxWidth - 50
                  : context.width - 50,
              child: AddressWidgetCustom2(
                address: addressList[index],
              ),
            ),
          ),
        );
      }
    }
    return dropDownAddressList;
  }
}

///
/// Receiver Details widget
///
class ReceiverDetailsWidget extends StatefulWidget {
  final TextEditingController streetNameControllerReceiver;
  final TextEditingController houseNumberControllerReceiver;
  final TextEditingController floorControllerReceiver;
  final TextEditingController receiverNameControllerReceiver;
  final TextEditingController phoneNumberControllerReceiver;
  final TextEditingController emailIDControllerReceiver;

  const ReceiverDetailsWidget({
    super.key,
    required this.streetNameControllerReceiver,
    required this.houseNumberControllerReceiver,
    required this.floorControllerReceiver,
    required this.receiverNameControllerReceiver,
    required this.phoneNumberControllerReceiver,
    required this.emailIDControllerReceiver,
  });

  @override
  State<ReceiverDetailsWidget> createState() => _ReceiverDetailsWidgetState();
}

class _ReceiverDetailsWidgetState extends State<ReceiverDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GetBuilder<AddressController>(
          builder: (addressController) {
            return GetBuilder<ParcelController>(
              builder: (parcelController) {
                List<DropdownItem2<int>> receiverAddressList =
                _getDropdownAddressList(
                  context: context,
                  addressList: addressController.addressList,
                  isSender: false,
                  pickupAddress: parcelController.pickupAddress,
                  destinationAddress: parcelController.destinationAddress,
                );
                if (receiverAddressList.isNotEmpty) {
                  receiverAddressList.removeAt(0);
                }

                List<AddressModel> reciverAddress = _getAddressList(
                  addressList: addressController.addressList,
                  isSender: false,
                  pickupAddress: parcelController.pickupAddress,
                  destinationAddress: parcelController.destinationAddress,
                );
                if (reciverAddress.isNotEmpty) {
                  reciverAddress.removeAt(0);
                }
                if (reciverAddress.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    parcelController.setReceiverAddressIndex(parcelController.receiverAddressIndex??0);
                    AddressModel recieverAddress=reciverAddress[parcelController.receiverAddressIndex??0];
                    parcelController.setDestinationAddress(recieverAddress, notify: true);
                  });
                }
                return Column(
                  children: [
                    // ParcelSelectDeliveryWidget(
                    //   onTap: () {
                    //     /**
                    //      * implemented Reciver(Destination) address details
                    //      */
                    //     Get.toNamed(
                    //       RouteHelper.getPickMapRoute('parcel', false),
                    //       arguments: PickMapScreen(
                    //         fromSignUp: false,
                    //         fromAddAddress: false,
                    //         canRoute: false,
                    //         route: '',
                    //         onPicked: (AddressModel address) async {
                    //           ZoneResponseModel responseModel =
                    //           await Get.find<LocationController>().getZone(
                    //               address.latitude.toString(),
                    //               address.longitude.toString(),
                    //               false);
                    //           AddressModel pickupAddress = AddressModel(
                    //             id: address.id,
                    //             addressType: address.addressType,
                    //             contactPersonNumber:
                    //             address.contactPersonNumber,
                    //             contactPersonName: address.contactPersonName,
                    //             address: address.address,
                    //             latitude: address.latitude,
                    //             longitude: address.longitude,
                    //             zoneId: responseModel.isSuccess
                    //                 ? responseModel.zoneIds[0]
                    //                 : 0,
                    //             zoneIds: responseModel.zoneIds,
                    //             method: address.method,
                    //             streetNumber: address.streetNumber,
                    //             house: address.house,
                    //             floor: address.floor,
                    //           );
                    //           parcelController.setDestinationAddress(
                    //               pickupAddress,
                    //               notify: true);
                    //           parcelController.setReceiverAddressIndex(0);
                    //         },
                    //       ),
                    //     );
                    //     /**
                    //      * Till here it working fine
                    //      *
                    //      * HOW IT WORKS ??
                    //      *  it get user point location on map and save in the
                    //      *  parcelController.destinationAddress
                    //      *
                    //      * DOUBT ??
                    //      *  i have now idea what is the purpose of saveing index i have kept it 0
                    //      *  beacuse the previous code doing the same thing parcelController.setReceiverAddressIndex(0);
                    //      *
                    //      */
                    //   },
                    // ),
                    ParcelAddressPickerWidget(

                      onChange: (int? value, int index) async {
                        if (index >= 0 && index < reciverAddress.length) {
                          AddressModel _selectedAddress = reciverAddress[index];
                          parcelController.setDestinationAddress(
                            _selectedAddress,
                            notify: true,
                          );
                          parcelController.setReceiverAddressIndex(index);

                          if (_selectedAddress.contactPersonName != null &&
                              _selectedAddress.contactPersonName!.isNotEmpty) {
                            widget.receiverNameControllerReceiver.text =
                            _selectedAddress.contactPersonName!;
                          } else {
                            widget.receiverNameControllerReceiver.text = '';
                          }

                          if (_selectedAddress.contactPersonNumber != null &&
                              _selectedAddress
                                  .contactPersonNumber!.isNotEmpty &&
                              !_selectedAddress.contactPersonNumber!
                                  .contains("null")) {
                            _splitPhoneNumber(
                                _selectedAddress.contactPersonNumber!);
                          } else {
                            widget.phoneNumberControllerReceiver.text = '';
                          }

                          if (_selectedAddress.email != null &&
                              _selectedAddress.email!.isNotEmpty) {
                            widget.emailIDControllerReceiver.text =
                            _selectedAddress.email!;
                          } else {
                            widget.emailIDControllerReceiver.text = '';
                          }
                        }
                      },
                      title: "SAVED ADDRESS",
                      /**
                       *  the addressController hold the all address list
                       *  where we saved it
                       */
                      addressList: receiverAddressList,
                      widget: receiverAddressList.isNotEmpty?AddressWidgetCustom(
                        address: reciverAddress[
                        parcelController.receiverAddressIndex!],
                      ):null,
                      onTap: () async {
                        debugPrint("snjdnd${addressController.addressList?[0].zoneId}");

                        await Get.toNamed(
                          RouteHelper.getAddAddressRoute(
                            true,
                            false,
                            addressController.addressList?[0].zoneId??0,
                          ),
                        );

                        /**
                         * implemented Reciver(Destination) address details
                         */
                        // Get.toNamed(
                        //   RouteHelper.getPickMapRoute('parcel', false),
                        //   arguments: PickMapScreen(
                        //     fromSignUp: false,
                        //     fromAddAddress: false,
                        //     canRoute: false,
                        //     route: '',
                        //     onPicked: (AddressModel address) async {
                        //       ZoneResponseModel responseModel =
                        //       await Get.find<LocationController>().getZone(
                        //           address.latitude.toString(),
                        //           address.longitude.toString(),
                        //           false);
                        //       AddressModel pickupAddress = AddressModel(
                        //         id: address.id,
                        //         addressType: address.addressType,
                        //         contactPersonNumber:
                        //         address.contactPersonNumber,
                        //         contactPersonName: address.contactPersonName,
                        //         address: address.address,
                        //         latitude: address.latitude,
                        //         longitude: address.longitude,
                        //         zoneId: responseModel.isSuccess
                        //             ? responseModel.zoneIds[0]
                        //             : 0,
                        //         zoneIds: responseModel.zoneIds,
                        //         method: address.method,
                        //         streetNumber: address.streetNumber,
                        //         house: address.house,
                        //         floor: address.floor,
                        //       );
                        //       parcelController.setDestinationAddress(
                        //           pickupAddress,
                        //           notify: true);
                        //       parcelController.setReceiverAddressIndex(0);
                        //     },
                        //   ),
                        // );
                        /**
                         * Till here it working fine
                         *
                         * HOW IT WORKS ??
                         *  it get user point location on map and save in the
                         *  parcelController.destinationAddress
                         *
                         * DOUBT ??
                         *  i have now idea what is the purpose of saveing index i have kept it 0
                         *  beacuse the previous code doing the same thing parcelController.setReceiverAddressIndex(0);
                         *
                         */
                      },
                    ),
                    // ParcelAddressDetailsWidget(
                    //   title: "ADDRESS DETAILS",
                    //   streetName: widget.streetNameControllerReceiver,
                    //   houseNumber: widget.houseNumberControllerReceiver,
                    //   floor: widget.floorControllerReceiver,
                    // ),
                    ParcelReceiverDetailsWidget(
                      isSender: false,
                      title: "RECEIVER DETAILS",
                      emailId: widget.emailIDControllerReceiver,
                      phoneNumber: widget.phoneNumberControllerReceiver,
                      senderName: widget.receiverNameControllerReceiver,
                      isGestuLogin: AuthHelper.isGuestLoggedIn(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _splitPhoneNumber(String number) {
    String addressCountryCode = '';
    PhoneNumber phoneNumber = PhoneNumber.parse(number);
    addressCountryCode = '+${phoneNumber.countryCode}';
    widget.phoneNumberControllerReceiver.text =
        phoneNumber.international.substring(addressCountryCode.length);
  }

  List<AddressModel> _getAddressList(
      {required List<AddressModel>? addressList,
        required bool isSender,
        required AddressModel? pickupAddress,
        required AddressModel? destinationAddress}) {
    List<AddressModel> address = [];

    if (isSender) {
      address.add(pickupAddress!);
    } else if (!isSender) {
      address.add(
          destinationAddress ?? AddressHelper.getUserAddressFromSharedPref()!);
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        address.add(addressList[index]);
      }
    }
    return address;
  }

  List<DropdownItem2<int>> _getDropdownAddressList(
      {required BuildContext context,
        required List<AddressModel>? addressList,
        required bool isSender,
        required AddressModel? pickupAddress,
        required AddressModel? destinationAddress}) {
    List<DropdownItem2<int>> dropDownAddressList = [];

    if (isSender) {
      dropDownAddressList.add(
        DropdownItem2<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidgetCustom2(
              address:
              pickupAddress ?? AddressHelper.getUserAddressFromSharedPref(),
            ),
          ),
        ),
      );
    } else {
      dropDownAddressList.add(
        DropdownItem2<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidgetCustom2(
              address: destinationAddress ??
                  AddressHelper.getUserAddressFromSharedPref(),
            ),
          ),
        ),
      );
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        dropDownAddressList.add(
          DropdownItem2<int>(
            value: index + 1,
            child: SizedBox(
              width: context.width > Dimensions.webMaxWidth
                  ? Dimensions.webMaxWidth - 50
                  : context.width - 50,
              child: AddressWidgetCustom2(
                address: addressList[index],
              ),
            ),
          ),
        );
      }
    }
    return dropDownAddressList;
  }
}
