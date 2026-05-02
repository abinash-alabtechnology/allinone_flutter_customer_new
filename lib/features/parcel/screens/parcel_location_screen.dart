import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/parcel/domain/models/parcel_category_model.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/custom_validator.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/features/parcel/widgets/parcel_view_widget.dart';

import '../new_category/screens/parcel_pick_drop_screen.dart';

class ParcelLocationScreen extends StatefulWidget {
  final ParcelCategoryModel category;

  const ParcelLocationScreen({super.key, required this.category});

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _senderStreetNumberController =
      TextEditingController();
  final TextEditingController _senderHouseController = TextEditingController();
  final TextEditingController _senderFloorController = TextEditingController();
  final TextEditingController _receiverStreetNumberController =
      TextEditingController();
  final TextEditingController _receiverHouseController =
      TextEditingController();
  final TextEditingController _receiverFloorController =
      TextEditingController();
  final TextEditingController _guestSenderEmailController =
      TextEditingController();
  final TextEditingController _guestReceiverEmailController =
      TextEditingController();
  final ParcelController parcelController = Get.find<ParcelController>();

  TabController? _tabController;
  String? _countryDialCode;
  bool firstTime = true;
  bool isSender = true;
  bool isPickupSelected = false;
  bool isDropSelected = false;
  // bool isSelected = true;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    _countryDialCode =
        Get.find<AuthController>().getUserCountryCode().isNotEmpty
            ? Get.find<AuthController>().getUserCountryCode()
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>().configModel!.country!)
                .dialCode;

    Get.find<ParcelController>()
        .setPickupAddress(AddressHelper.getUserAddressFromSharedPref(), false);
    Get.find<ParcelController>().setDestinationAddress(
        AddressHelper.getUserAddressFromSharedPref(),
        notify: false);
    Get.find<ParcelController>().setIsPickedUp(true, false);
    Get.find<ParcelController>().setIsSender(true, false);
    Get.find<ParcelController>().setSenderAddressIndex(0, canUpdate: false);
    Get.find<ParcelController>().setReceiverAddressIndex(0, canUpdate: false);
    Get.find<ParcelController>().setCountryCode(_countryDialCode!, true);
    Get.find<ParcelController>().setCountryCode(_countryDialCode!, false);
    if (AuthHelper.isLoggedIn() &&
        Get.find<AddressController>().addressList == null) {
      Get.find<AddressController>().getAddressList();
    }
    if (AuthHelper.isLoggedIn()) {
      if (Get.find<ProfileController>().userInfoModel == null) {
        await Get.find<ProfileController>().getUserInfo();
        _senderNameController.text = Get.find<ProfileController>()
                    .userInfoModel !=
                null
            ? '${Get.find<ProfileController>().userInfoModel!.fName!} ${Get.find<ProfileController>().userInfoModel!.lName!}'
            : '';
        _countryDialCode = await splitPhoneNumber(
            Get.find<ProfileController>().userInfoModel != null
                ? Get.find<ProfileController>().userInfoModel!.phone!
                : '',
            true);
        _senderPhoneController.text = await splitPhoneNumber(
            Get.find<ProfileController>().userInfoModel != null
                ? Get.find<ProfileController>().userInfoModel!.phone!
                : '',
            false);
      } else {
        _senderNameController.text =
            '${Get.find<ProfileController>().userInfoModel!.fName!} ${Get.find<ProfileController>().userInfoModel!.lName!}';
        _countryDialCode = await splitPhoneNumber(
            Get.find<ProfileController>().userInfoModel != null
                ? Get.find<ProfileController>().userInfoModel!.phone!
                : '',
            true);
        _senderPhoneController.text = await splitPhoneNumber(
            Get.find<ProfileController>().userInfoModel != null
                ? Get.find<ProfileController>().userInfoModel!.phone!
                : '',
            false);
      }
      Get.find<ParcelController>().setCountryCode(_countryDialCode!, true);
      Get.find<ParcelController>().setCountryCode(_countryDialCode!, false);
      setState(() {});
    }

    _tabController?.addListener(() {
      Get.find<ParcelController>()
          .setIsPickedUp(_tabController!.index == 0, false);
      Get.find<ParcelController>()
          .setIsSender(_tabController!.index == 0, true);
    });
  }

  Future<String> splitPhoneNumber(String number, bool returnCountyCode) async {
    String code = '';
    String pNumber = '';
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      code = '+${phoneNumber.countryCode}';
      pNumber = phoneNumber.international.substring(_countryDialCode!.length);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
    if (returnCountyCode) {
      return code;
    } else {
      return pNumber;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _senderStreetNumberController.dispose();
    _senderHouseController.dispose();
    _senderFloorController.dispose();
    _receiverStreetNumberController.dispose();
    _receiverHouseController.dispose();
    _receiverFloorController.dispose();
    _guestSenderEmailController.dispose();
    _guestReceiverEmailController.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                'Pick up or Send anything',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Colors.black,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          isPickupSelected
                              ? Stack(
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 20),
                                        Icon(
                                          CupertinoIcons.arrow_up_circle_fill,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                const BoxShadow(
                                                    color: Colors.black12,
                                                    spreadRadius: 2,
                                                    blurRadius: 4)
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 20),
                                            child: Row(
                                              children: [
                                                // const SizedBox(width: 20),
                                                // Icon(
                                                //   CupertinoIcons.arrow_up_square_fill,
                                                //   color: Theme.of(context).primaryColor,
                                                // ),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _senderNameController
                                                          .text,
                                                      style:
                                                          robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Text(
                                                        parcelController
                                                            .pickupAddress!
                                                            .address
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Colors
                                                              .grey.shade800,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 0.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.57,
                                                      color: Colors.grey[300],
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5),
                                                    ),
                                                    Text(
                                                      _senderPhoneController
                                                          .text,
                                                      style:
                                                          robotoBold.copyWith(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      right: 10,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            isPickupSelected = true;
                                          });
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ParcelViewWidget(
                                                isSender: true,
                                                nameController:
                                                    _senderNameController,
                                                phoneController:
                                                    _senderPhoneController,
                                                bottomButton: _bottomButton(),
                                                streetController:
                                                    _senderStreetNumberController,
                                                floorController:
                                                    _senderFloorController,
                                                houseController:
                                                    _senderHouseController,
                                                countryCode: parcelController
                                                    .senderCountryCode,
                                                guestEmailController:
                                                    _guestSenderEmailController,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Change',
                                          style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      setState(() {
                                        isPickupSelected = true;
                                      });
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ParcelViewWidget(
                                          isSender: true,
                                          nameController: _senderNameController,
                                          phoneController:
                                              _senderPhoneController,
                                          bottomButton: _bottomButton(),
                                          streetController:
                                              _senderStreetNumberController,
                                          floorController:
                                              _senderFloorController,
                                          houseController:
                                              _senderHouseController,
                                          countryCode: parcelController
                                              .senderCountryCode,
                                          guestEmailController:
                                              _guestSenderEmailController,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      const Icon(
                                        CupertinoIcons.arrow_up_circle_fill,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              const BoxShadow(
                                                  color: Colors.black12,
                                                  spreadRadius: 2,
                                                  blurRadius: 4)
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 15),
                                          child: Row(
                                            children: [
                                              // const SizedBox(width: 20),
                                              // const Icon(
                                              //   CupertinoIcons.arrow_up_square_fill,
                                              //   color: Colors.white,
                                              // ),

                                              Text(
                                                'Add pickup details',
                                                style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          isDropSelected
                              ? Stack(
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 20),
                                        Icon(
                                          CupertinoIcons.arrow_down_circle_fill,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                const BoxShadow(
                                                    color: Colors.black12,
                                                    spreadRadius: 2,
                                                    blurRadius: 4)
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 20),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _receiverNameController
                                                          .text,
                                                      style:
                                                          robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Text(
                                                        parcelController
                                                            .destinationAddress!
                                                            .address
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style:
                                                            robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Colors
                                                              .grey.shade800,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 0.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.57,
                                                      color: Colors.grey[300],
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5),
                                                    ),
                                                    Text(
                                                      _receiverPhoneController
                                                          .text,
                                                      style:
                                                          robotoBold.copyWith(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      right: 10,
                                      child: TextButton(
                                        onPressed: () {
                                          if (!isSender) {
                                            _validateSender(parcelController);
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ParcelViewWidget(
                                                nameController:
                                                    _receiverNameController,
                                                phoneController:
                                                    _receiverPhoneController,
                                                bottomButton: _bottomButton(),
                                                streetController:
                                                    _receiverStreetNumberController,
                                                floorController:
                                                    _receiverFloorController,
                                                houseController:
                                                    _receiverHouseController,
                                                countryCode: parcelController
                                                    .receiverCountryCode,
                                                guestEmailController:
                                                    _guestReceiverEmailController,
                                                isSender: false,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Change',
                                          style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      setState(() {
                                        isDropSelected = true;
                                      });
                                    });
                                    // setState(() {
                                    //   isDropSelected = true;
                                    // });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ParcelViewWidget(
                                          nameController:
                                              _receiverNameController,
                                          phoneController:
                                              _receiverPhoneController,
                                          bottomButton: _bottomButton(),
                                          streetController:
                                              _receiverStreetNumberController,
                                          floorController:
                                              _receiverFloorController,
                                          houseController:
                                              _receiverHouseController,
                                          countryCode: parcelController
                                              .receiverCountryCode,
                                          guestEmailController:
                                              _guestReceiverEmailController,
                                          isSender: false,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      Icon(
                                        CupertinoIcons.arrow_down_circle_fill,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              const BoxShadow(
                                                  color: Colors.black12,
                                                  spreadRadius: 2,
                                                  blurRadius: 4)
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 20),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Add Drop Details',
                                                style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                      Positioned(
                        left: 22,
                        top: isPickupSelected ? 71 : 38,
                        child: Container(
                          width: 20,
                          height: isDropSelected
                              ? 150 // taller when drop is selected
                              : isPickupSelected
                                  ? 100 // medium height when pickup is selected
                                  : 90, // total height of the line
                          child: Column(
                            children: List.generate(
                                isDropSelected
                                    ? 25 // more dashes for drop
                                    : isPickupSelected
                                        ? 20 // medium dashes for pickup
                                        : 15, (index) {
                              return Container(
                                width: 1,
                                height: 3, // very small dash
                                margin: const EdgeInsets.only(
                                    bottom: 2), // small gap between dashes
                                color: Colors.blueGrey,
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                  // Things to keep in mind section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Things to keep in mind',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        const Row(
                          children: [
                            Icon(Icons.wallet_travel),
                            SizedBox(width: 8),
                            Flexible(
                                child: Text(
                                    'Avoid sending expensive or fragile items')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.pedal_bike),
                            SizedBox(width: 10),
                            Text('Items should fit in a backpack'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.no_drinks),
                            SizedBox(width: 10),
                            Text('No alcohol, illegal or restricted items'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 10),
                            Flexible(
                                child: Text(
                                    'Order before 7PM to avoid delays in delivery')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ResponsiveHelper.isDesktop(context)
                      ? const SizedBox()
                      : _bottomButton(),
                ],
              ),
            ),
          )
        : ParcelPickDropScreen(
            category: widget.category,
          );
  }

  // Widget build (BuildContext context) {
  //   return Scaffold(
  //     appBar: CustomAppBar(title: 'parcel_location'.tr),
  //     endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
  //     body: SafeArea(
  //       child: GetBuilder<ParcelController>(builder: (parcelController) {
  //         return Column(children: [
  //
  //           Expanded(child: Column(children: [
  //
  //             Center(
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
  //                 width: Dimensions.webMaxWidth,
  //                 color: Theme.of(context).cardColor,
  //                 child: Column(
  //                   children: [
  //
  //                     TabBar(
  //                       controller: _tabController,
  //                       labelColor: Theme.of(context).primaryColor,
  //                       unselectedLabelColor: Colors.black,
  //                       onTap: (int index) {
  //                         if(index == 1) {
  //                           _validateSender(parcelController);
  //                         }
  //                       },
  //                       unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
  //                       labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
  //                       tabs: [
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
  //                           child: Text(
  //                             'sender_info'.tr,
  //                             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: parcelController.isSender ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
  //                           ),
  //                         ),
  //                         Text(
  //                           'receiver_info'.tr,
  //                           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !parcelController.isSender ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
  //                         ),
  //                       ],
  //                     ),
  //                     // Container(height: 3, width: Dimensions.webMaxWidth, decoration: BoxDecoration(color: Theme.of(context).primaryColor))
  //                   ],
  //                 ),
  //               ),
  //             ),
  //
  //             Expanded(child: TabBarView(
  //               controller: _tabController,
  //               physics: const NeverScrollableScrollPhysics(),
  //               children: [
  //                 ParcelViewWidget(
  //                   isSender: true, nameController: _senderNameController, phoneController: _senderPhoneController, bottomButton: _bottomButton(),
  //                   streetController: _senderStreetNumberController, floorController: _senderFloorController, houseController: _senderHouseController,
  //                   countryCode: parcelController.senderCountryCode, guestEmailController: _guestSenderEmailController,
  //                 ),
  //                 ParcelViewWidget(
  //                   isSender: false, nameController: _receiverNameController, phoneController: _receiverPhoneController, bottomButton: _bottomButton(),
  //                   streetController: _receiverStreetNumberController, floorController: _receiverFloorController, houseController: _receiverHouseController,
  //                   countryCode: parcelController.receiverCountryCode, guestEmailController: _guestReceiverEmailController,
  //                 ),
  //               ],
  //             )),
  //           ])),
  //
  //           ResponsiveHelper.isDesktop(context) ? const SizedBox() : _bottomButton(),
  //
  //         ]);
  //       }),
  //     ),
  //   );
  // }

  Widget _bottomButton() {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return CustomButton(
        margin: ResponsiveHelper.isDesktop(context)
            ? null
            : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        buttonText: /*parcelController.isSender ? 'continue'.tr :*/
            'save_and_continue'.tr,
        onPressed: () async {
          if (_tabController!.index == 0) {
            _validateSender(parcelController);
          } else {
            String numberWithCountryCode =
                '${parcelController.receiverCountryCode ?? ''}${_receiverPhoneController.text.trim()}';
            PhoneValid phoneValid =
                await CustomValidator.isPhoneValid(numberWithCountryCode);
            numberWithCountryCode = phoneValid.phone;

            if (parcelController.destinationAddress == null) {
              showCustomSnackBar('select_destination_address'.tr);
            } else if (_receiverNameController.text.isEmpty) {
              showCustomSnackBar('enter_receiver_name'.tr);
            } else if (_receiverPhoneController.text.isEmpty) {
              showCustomSnackBar('enter_receiver_phone_number'.tr);
            } else if (!phoneValid.isValid) {
              showCustomSnackBar('invalid_phone_number'.tr);
            } else {
              print(parcelController.destinationAddress!.address.toString());
              print("dcscfd");
              AddressModel destination = AddressModel(
                address: parcelController.destinationAddress!.address,
                additionalAddress:
                    parcelController.destinationAddress!.additionalAddress,
                addressType: parcelController.destinationAddress!.addressType,
                contactPersonName: _receiverNameController.text.trim(),
                contactPersonNumber: numberWithCountryCode,
                latitude: parcelController.destinationAddress!.latitude,
                longitude: parcelController.destinationAddress!.longitude,
                method: parcelController.destinationAddress!.method,
                zoneId: parcelController.destinationAddress!.zoneId,
                zoneIds: parcelController.destinationAddress!.zoneIds,
                id: parcelController.destinationAddress!.id,
                streetNumber: _receiverStreetNumberController.text.trim(),
                house: _receiverHouseController.text.trim(),
                floor: _receiverFloorController.text.trim(),
                email: _guestReceiverEmailController.text.trim(),
              );

              parcelController.setDestinationAddress(destination);

              Get.toNamed(RouteHelper.getParcelRequestRoute(
                widget.category,
                parcelController.pickupAddress!,
                parcelController.destinationAddress!,
              ));
            }
          }
        },
      );
    });
  }

  Future<void> _validateSender(ParcelController parcelController) async {
    String numberWithCountryCode =
        '${parcelController.senderCountryCode ?? ''}${_senderPhoneController.text.trim()}';
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (parcelController.pickupAddress == null) {
      showCustomSnackBar('select_pickup_address'.tr);
      _tabController!.animateTo(0);
    } else if (_senderNameController.text.isEmpty) {
      showCustomSnackBar('enter_sender_name'.tr);
      _tabController!.animateTo(0);
    } else if (_senderPhoneController.text.isEmpty) {
      showCustomSnackBar('enter_sender_phone_number'.tr);
      _tabController!.animateTo(0);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
      _tabController!.animateTo(0);
    } else if (AuthHelper.isGuestLoggedIn() &&
        _guestSenderEmailController.text.isEmpty) {
      showCustomSnackBar('please_enter_sender_email'.tr);
      _tabController!.animateTo(0);
    } else if (AuthHelper.isGuestLoggedIn() &&
        !CustomValidator.isEmailValid(
            _guestSenderEmailController.text.trim())) {
      showCustomSnackBar('enter_valid_email_address'.tr);
      _tabController!.animateTo(0);
    } else {
      AddressModel pickup = AddressModel(
        address: parcelController.pickupAddress!.address,
        additionalAddress: parcelController.pickupAddress!.additionalAddress,
        addressType: parcelController.pickupAddress!.addressType,
        contactPersonName: _senderNameController.text.trim(),
        contactPersonNumber: numberWithCountryCode,
        latitude: parcelController.pickupAddress!.latitude,
        longitude: parcelController.pickupAddress!.longitude,
        method: parcelController.pickupAddress!.method,
        zoneId: parcelController.pickupAddress!.zoneId,
        id: parcelController.pickupAddress!.id,
        zoneIds: parcelController.pickupAddress!.zoneIds,
        streetNumber: _senderStreetNumberController.text.trim(),
        house: _senderHouseController.text.trim(),
        floor: _senderFloorController.text.trim(),
        email: _guestSenderEmailController.text.trim(),
      );
      parcelController.setPickupAddress(pickup, true);
      _tabController!.animateTo(1);
    }
  }
}

// class ParcelLocationScreen extends StatefulWidget {
//   final ParcelCategoryModel category;
//   const ParcelLocationScreen({super.key, required this.category});
//
//   @override
//   State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
// }
//
// class _ParcelLocationScreenState extends State<ParcelLocationScreen> with TickerProviderStateMixin {
//    final TextEditingController _senderNameController = TextEditingController();
//    final TextEditingController _senderPhoneController = TextEditingController();
//    final TextEditingController _receiverNameController = TextEditingController();
//    final TextEditingController _receiverPhoneController = TextEditingController();
//    final TextEditingController _senderStreetNumberController = TextEditingController();
//    final TextEditingController _senderHouseController = TextEditingController();
//    final TextEditingController _senderFloorController = TextEditingController();
//    final TextEditingController _receiverStreetNumberController = TextEditingController();
//    final TextEditingController _receiverHouseController = TextEditingController();
//    final TextEditingController _receiverFloorController = TextEditingController();
//    final TextEditingController _guestSenderEmailController = TextEditingController();
//     final TextEditingController _guestReceiverEmailController = TextEditingController();
//
//   TabController? _tabController;
//   String? _countryDialCode;
//   bool firstTime = true;
//
//   @override
//   void initState() {
//     super.initState();
//     initCall();
//   }
//
//   Future<void> initCall() async {
//     _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
//
//     _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
//         : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
//
//     Get.find<ParcelController>().setPickupAddress(AddressHelper.getUserAddressFromSharedPref(), false);
//     Get.find<ParcelController>().setDestinationAddress(AddressHelper.getUserAddressFromSharedPref(), notify: false);
//     Get.find<ParcelController>().setIsPickedUp(true, false);
//     Get.find<ParcelController>().setIsSender(true, false);
//     Get.find<ParcelController>().setSenderAddressIndex(0, canUpdate: false);
//     Get.find<ParcelController>().setReceiverAddressIndex(0, canUpdate: false);
//     Get.find<ParcelController>().setCountryCode(_countryDialCode!, true);
//     Get.find<ParcelController>().setCountryCode(_countryDialCode!, false);
//     if(AuthHelper.isLoggedIn() && Get.find<AddressController>().addressList == null) {
//       Get.find<AddressController>().getAddressList();
//     }
//     if (AuthHelper.isLoggedIn()){
//       if(Get.find<ProfileController>().userInfoModel == null){
//         await Get.find<ProfileController>().getUserInfo();
//         _senderNameController.text = Get.find<ProfileController>().userInfoModel != null ? '${Get.find<ProfileController>().userInfoModel!.fName!} ${Get.find<ProfileController>().userInfoModel!.lName!}' : '';
//         _countryDialCode = await splitPhoneNumber(Get.find<ProfileController>().userInfoModel != null ? Get.find<ProfileController>().userInfoModel!.phone! : '', true);
//         _senderPhoneController.text = await splitPhoneNumber(Get.find<ProfileController>().userInfoModel != null ? Get.find<ProfileController>().userInfoModel!.phone! : '', false);
//       }else{
//         _senderNameController.text = '${Get.find<ProfileController>().userInfoModel!.fName!} ${Get.find<ProfileController>().userInfoModel!.lName!}';
//         _countryDialCode = await splitPhoneNumber(Get.find<ProfileController>().userInfoModel != null ? Get.find<ProfileController>().userInfoModel!.phone! : '', true);
//         _senderPhoneController.text = await splitPhoneNumber(Get.find<ProfileController>().userInfoModel != null ? Get.find<ProfileController>().userInfoModel!.phone! : '', false);
//       }
//       Get.find<ParcelController>().setCountryCode(_countryDialCode!, true);
//       Get.find<ParcelController>().setCountryCode(_countryDialCode!, false);
//       setState(() {});
//
//     }
//
//     _tabController?.addListener((){
//       Get.find<ParcelController>().setIsPickedUp(_tabController!.index == 0, false);
//       Get.find<ParcelController>().setIsSender(_tabController!.index == 0, true);
//     });
//   }
//
//    Future<String> splitPhoneNumber(String number, bool returnCountyCode) async {
//     String code = '';
//     String pNumber = '';
//     try {
//       PhoneNumber phoneNumber = PhoneNumber.parse(number);
//       code = '+${phoneNumber.countryCode}';
//       pNumber = phoneNumber.international.substring(_countryDialCode!.length);
//     } catch (e) {
//       debugPrint('number can\'t parse : $e');
//     }
//      if(returnCountyCode) {
//        return code;
//      } else {
//        return pNumber;
//      }
//    }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _senderNameController.dispose();
//     _senderPhoneController.dispose();
//     _receiverNameController.dispose();
//     _receiverPhoneController.dispose();
//     _senderStreetNumberController.dispose();
//     _senderHouseController.dispose();
//     _senderFloorController.dispose();
//     _receiverStreetNumberController.dispose();
//     _receiverHouseController.dispose();
//     _receiverFloorController.dispose();
//     _guestSenderEmailController.dispose();
//     _guestReceiverEmailController.dispose();
//     _tabController?.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: 'parcel_location'.tr),
//       endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
//       body: SafeArea(
//         child: GetBuilder<ParcelController>(builder: (parcelController) {
//           return Column(children: [
//
//             Expanded(child: Column(children: [
//
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//                   width: Dimensions.webMaxWidth,
//                   color: Theme.of(context).cardColor,
//                   child: Column(
//                     children: [
//
//                       TabBar(
//                         controller: _tabController,
//                         labelColor: Theme.of(context).primaryColor,
//                         unselectedLabelColor: Colors.black,
//                         onTap: (int index) {
//                           if(index == 1) {
//                             _validateSender(parcelController);
//                           }
//                         },
//                         unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
//                         labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
//                         tabs: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//                             child: Text(
//                               'sender_info'.tr,
//                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: parcelController.isSender ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
//                             ),
//                           ),
//                           Text(
//                             'receiver_info'.tr,
//                             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !parcelController.isSender ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
//                           ),
//                         ],
//                       ),
//                       // Container(height: 3, width: Dimensions.webMaxWidth, decoration: BoxDecoration(color: Theme.of(context).primaryColor))
//                     ],
//                   ),
//                 ),
//               ),
//
//               Expanded(child: TabBarView(
//                 controller: _tabController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   ParcelViewWidget(
//                     isSender: true, nameController: _senderNameController, phoneController: _senderPhoneController, bottomButton: _bottomButton(),
//                     streetController: _senderStreetNumberController, floorController: _senderFloorController, houseController: _senderHouseController,
//                     countryCode: parcelController.senderCountryCode, guestEmailController: _guestSenderEmailController,
//                   ),
//                   ParcelViewWidget(
//                     isSender: false, nameController: _receiverNameController, phoneController: _receiverPhoneController, bottomButton: _bottomButton(),
//                     streetController: _receiverStreetNumberController, floorController: _receiverFloorController, houseController: _receiverHouseController,
//                     countryCode: parcelController.receiverCountryCode, guestEmailController: _guestReceiverEmailController,
//                   ),
//                 ],
//               )),
//             ])),
//
//             ResponsiveHelper.isDesktop(context) ? const SizedBox() : _bottomButton(),
//
//           ]);
//         }),
//       ),
//     );
//   }
//
//   Widget _bottomButton() {
//     return GetBuilder<ParcelController>(
//       builder: (parcelController) {
//         return CustomButton(
//           margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
//           buttonText: parcelController.isSender ? 'continue'.tr : 'save_and_continue'.tr,
//           onPressed: () async {
//             if( _tabController!.index == 0 ) {
//               _validateSender(parcelController);
//             }
//             else{
//               String numberWithCountryCode = '${parcelController.receiverCountryCode??''}${_receiverPhoneController.text.trim()}';
//               PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
//               numberWithCountryCode = phoneValid.phone;
//
//               if(parcelController.destinationAddress == null) {
//                   showCustomSnackBar('select_destination_address'.tr);
//               }
//               else if(_receiverNameController.text.isEmpty){
//                 showCustomSnackBar('enter_receiver_name'.tr);
//               }
//               else if(_receiverPhoneController.text.isEmpty){
//                 showCustomSnackBar('enter_receiver_phone_number'.tr);
//               }
//               else if (!phoneValid.isValid) {
//                 showCustomSnackBar('invalid_phone_number'.tr);
//               }
//               else {
//                 AddressModel destination = AddressModel(
//                   address: parcelController.destinationAddress!.address,
//                   additionalAddress: parcelController.destinationAddress!.additionalAddress,
//                   addressType: parcelController.destinationAddress!.addressType,
//                   contactPersonName: _receiverNameController.text.trim(),
//                   contactPersonNumber: numberWithCountryCode,
//                   latitude: parcelController.destinationAddress!.latitude,
//                   longitude: parcelController.destinationAddress!.longitude,
//                   method: parcelController.destinationAddress!.method,
//                   zoneId: parcelController.destinationAddress!.zoneId,
//                   zoneIds: parcelController.destinationAddress!.zoneIds,
//                   id: parcelController.destinationAddress!.id,
//                   streetNumber: _receiverStreetNumberController.text.trim(),
//                   house: _receiverHouseController.text.trim(),
//                   floor: _receiverFloorController.text.trim(),
//                   email: _guestReceiverEmailController.text.trim(),
//                   zoneData: parcelController.destinationAddress!.zoneData,
//                 );
//
//                 parcelController.setDestinationAddress(destination);
//
//                 Get.toNamed(RouteHelper.getParcelRequestRoute(
//                   widget.category,
//                   parcelController.pickupAddress!,
//                   parcelController.destinationAddress!,
//                 ));
//                 Get.find<CheckoutController>().updateFirstTime();
//               }
//            }
//           },
//         );
//       }
//     );
//   }
//
//   Future<void> _validateSender(ParcelController parcelController) async {
//     String numberWithCountryCode = '${parcelController.senderCountryCode??''}${_senderPhoneController.text.trim()}';
//     PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
//     numberWithCountryCode = phoneValid.phone;
//
//     if(parcelController.pickupAddress == null) {
//       showCustomSnackBar('select_pickup_address'.tr);
//       _tabController!.animateTo(0);
//     } else if(_senderNameController.text.isEmpty){
//       showCustomSnackBar('enter_sender_name'.tr);
//       _tabController!.animateTo(0);
//     } else if(_senderPhoneController.text.isEmpty){
//       showCustomSnackBar('enter_sender_phone_number'.tr);
//       _tabController!.animateTo(0);
//     } else if (!phoneValid.isValid) {
//       showCustomSnackBar('invalid_phone_number'.tr);
//       _tabController!.animateTo(0);
//     }else if(AuthHelper.isGuestLoggedIn() && _guestSenderEmailController.text.isEmpty){
//       showCustomSnackBar('please_enter_sender_email'.tr);
//       _tabController!.animateTo(0);
//     }else if(AuthHelper.isGuestLoggedIn() && !CustomValidator.isEmailValid(_guestSenderEmailController.text.trim())){
//       showCustomSnackBar('enter_valid_email_address'.tr);
//       _tabController!.animateTo(0);
//     } else{
//       AddressModel pickup = AddressModel(
//         address: parcelController.pickupAddress!.address,
//         additionalAddress: parcelController.pickupAddress!.additionalAddress,
//         addressType: parcelController.pickupAddress!.addressType,
//         contactPersonName: _senderNameController.text.trim(),
//         contactPersonNumber: numberWithCountryCode,
//         latitude: parcelController.pickupAddress!.latitude,
//         longitude: parcelController.pickupAddress!.longitude,
//         method: parcelController.pickupAddress!.method,
//         zoneId: parcelController.pickupAddress!.zoneId,
//         id: parcelController.pickupAddress!.id,
//         zoneIds: parcelController.pickupAddress!.zoneIds,
//         streetNumber: _senderStreetNumberController.text.trim(),
//         house: _senderHouseController.text.trim(),
//         floor: _senderFloorController.text.trim(),
//         email: _guestSenderEmailController.text.trim(),
//         zoneData: parcelController.pickupAddress!.zoneData,
//       );
//       parcelController.setPickupAddress(pickup, true);
//       _tabController!.animateTo(1);
//     }
//   }
//
// }
