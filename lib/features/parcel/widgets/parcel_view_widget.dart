import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:handy_allinone/common/widgets/address_widget.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_dropdown.dart';
import 'package:handy_allinone/common/widgets/custom_text_field.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/features/location/screens/pick_map_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/widgets/custom_button.dart';
class ParcelViewWidget extends StatefulWidget {
  final bool isSender;
  final Widget bottomButton;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController? guestEmailController;
  final String? countryCode;

  const ParcelViewWidget(
      {super.key,
        required this.isSender,
        required this.nameController,
        required this.phoneController,
        required this.streetController,
        required this.houseController,
        required this.floorController,
        required this.bottomButton,
        required this.countryCode,
        this.guestEmailController});

  @override
  State<ParcelViewWidget> createState() => _ParcelViewWidgetState();
}

class _ParcelViewWidgetState extends State<ParcelViewWidget> {
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  final FocusNode nameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  String? _countryCode;
  String? _addressCountryCode;
  final FlutterNativeContactPicker   _contactPicker = FlutterNativeContactPicker  ();

  @override
  void initState() {
    super.initState();
    _addressCountryCode = null;
    _countryCode = _addressCountryCode ?? widget.countryCode;
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    _countryCode = _addressCountryCode ?? widget.countryCode;
    String? countryDialCode;

    bool isLoading = false;

    Future<void> loadData() async {
      // Replace this with your actual data loading logic
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    }
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: GetBuilder<AddressController>(builder: (addressController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          List<DropdownItem<int>> senderAddressList = _getDropdownAddressList(
              context: context,
              addressList: addressController.addressList,
              isSender: true,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<DropdownItem<int>> receiverAddressList = _getDropdownAddressList(
              context: context,
              addressList: addressController.addressList,
              isSender: false,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<AddressModel> senderAddress = _getAddressList(
              addressList: addressController.addressList,
              isSender: true,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<AddressModel> receiverAddress = _getAddressList(
              addressList: addressController.addressList,
              isSender: false,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);

          return SingleChildScrollView(
            controller: ScrollController(),
            child: Center(
                child: FooterView(
                  child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(children: [
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Container(
                            decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                            padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        widget.isSender
                                            ? 'pickup_location'.tr
                                            : 'delivery_location'.tr,
                                        style: robotoMedium),
                                    TextButton.icon(
                                      onPressed: () async {
                                        if (ResponsiveHelper.isDesktop(
                                            Get.context)) {
                                          showGeneralDialog(
                                              context: context,
                                              pageBuilder: (_, __, ___) {
                                                return SizedBox(
                                                    height: 300,
                                                    width: 300,
                                                    child: PickMapScreen(
                                                      fromSignUp: false,
                                                      canRoute: false,
                                                      fromAddAddress: false,
                                                      route: '',
                                                      onPicked: (AddressModel
                                                      address) async {
                                                        ZoneResponseModel
                                                        responseModel =
                                                        await Get.find<
                                                            LocationController>()
                                                            .getZone(
                                                          address.latitude
                                                              .toString(),
                                                          address.longitude
                                                              .toString(),
                                                          false,
                                                        );

                                                        AddressModel a =
                                                        AddressModel(
                                                          id: address.id,
                                                          addressType:
                                                          address.addressType,
                                                          contactPersonNumber: address
                                                              .contactPersonNumber,
                                                          contactPersonName: address
                                                              .contactPersonName,
                                                          address: address.address,
                                                          latitude:
                                                          address.latitude,
                                                          longitude:
                                                          address.longitude,
                                                          zoneId: responseModel
                                                              .isSuccess
                                                              ? responseModel
                                                              .zoneIds[0]
                                                              : 0,
                                                          zoneIds: address.zoneIds,
                                                          method: address.method,
                                                          streetNumber:
                                                          address.streetNumber,
                                                          house: address.house,
                                                          floor: address.floor,
                                                        );

                                                        if (parcelController
                                                            .isPickedUp!) {
                                                          parcelController
                                                              .setPickupAddress(
                                                              a, true);
                                                        }
                                                        // Remove the else block to only set pickupAddress
                                                      },
                                                    ));
                                              });
                                        } else {
                                          Get.toNamed(
                                              RouteHelper.getPickMapRoute(
                                                  'parcel', false),
                                              arguments: PickMapScreen(
                                                fromSignUp: false,
                                                fromAddAddress: false,
                                                canRoute: false,
                                                route: '',
                                                onPicked:
                                                    (AddressModel address) async {
                                                  if (parcelController
                                                      .isPickedUp!) {
                                                    ZoneResponseModel
                                                    responseModel =
                                                    await Get.find<
                                                        LocationController>()
                                                        .getZone(
                                                        address.latitude
                                                            .toString(),
                                                        address.longitude
                                                            .toString(),
                                                        false);
                                                    AddressModel pickupAddress =
                                                    AddressModel(
                                                      id: address.id,
                                                      addressType:
                                                      address.addressType,
                                                      contactPersonNumber: address
                                                          .contactPersonNumber,
                                                      contactPersonName:
                                                      address.contactPersonName,
                                                      address: address.address,
                                                      latitude: address.latitude,
                                                      longitude: address.longitude,
                                                      zoneId: responseModel
                                                          .isSuccess
                                                          ? responseModel.zoneIds[0]
                                                          : 0,
                                                      zoneIds:
                                                      responseModel.zoneIds,
                                                      method: address.method,
                                                      streetNumber:
                                                      address.streetNumber,
                                                      house: address.house,
                                                      floor: address.floor,
                                                    );
                                                    parcelController
                                                        .setPickupAddress(
                                                        pickupAddress, true);
                                                    parcelController
                                                        .setSenderAddressIndex(0);
                                                  } else {
                                                    ZoneResponseModel
                                                    responseModel =
                                                    await Get.find<
                                                        LocationController>()
                                                        .getZone(
                                                        address.latitude
                                                            .toString(),
                                                        address.longitude
                                                            .toString(),
                                                        false);
                                                    AddressModel a = AddressModel(
                                                      id: address.id,
                                                      addressType:
                                                      address.addressType,
                                                      contactPersonNumber: address
                                                          .contactPersonNumber,
                                                      contactPersonName:
                                                      address.contactPersonName,
                                                      address: address.address,
                                                      latitude: address.latitude,
                                                      longitude: address.longitude,
                                                      zoneId: responseModel
                                                          .isSuccess
                                                          ? responseModel.zoneIds[0]
                                                          : 0,
                                                      zoneIds:
                                                      responseModel.zoneIds,
                                                      method: address.method,
                                                      streetNumber:
                                                      address.streetNumber,
                                                      house: address.house,
                                                      floor: address.floor,
                                                    );
                                                    parcelController
                                                        .setDestinationAddress(a);
                                                    parcelController
                                                        .setReceiverAddressIndex(0);
                                                  }
                                                },
                                              ));
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 20),
                                      label: Text('add_new'.tr,
                                          style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall)),
                                    ),
                                  ]),
                              Container(
                                  constraints: BoxConstraints(
                                      minHeight: ResponsiveHelper.isDesktop(context)
                                          ? 120
                                          : 95),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                  ),
                                  child: CustomDropdown<int>(
                                    onChange: (int? value, int index) async {
                                      try {
                                        // Check if senderAddress list contains the index
                                        if (index >= 0 &&
                                            index < senderAddress.length) {
                                          // Set pickup address for the sender
                                          parcelController.setPickupAddress(
                                              senderAddress[index], true);
                                          parcelController
                                              .setSenderAddressIndex(index);

                                          // Populate the fields with the selected sender's information
                                          widget.nameController.text =
                                              senderAddress[index]
                                                  .contactPersonName ??
                                                  '';
                                          await _splitPhoneNumber(
                                              senderAddress[index]
                                                  .contactPersonNumber ??
                                                  '');

                                          // Set country code for the sender
                                          if (_addressCountryCode != null) {
                                            parcelController.setCountryCode(
                                                _addressCountryCode!, true);
                                          } else {
                                            debugPrint(
                                                "Country code for sender address is null.");
                                          }

                                          debugPrint(
                                              "Sender Address Selected: ${senderAddress[index].contactPersonName}, "
                                                  "Phone: ${senderAddress[index].contactPersonNumber}");
                                        } else {
                                          debugPrint(
                                              "Index out of range for senderAddress array.");
                                        }
                                      } catch (e) {
                                        debugPrint(
                                            "An error occurred in onChange function: $e");
                                      }
                                    },
                                    dropdownButtonStyle: DropdownButtonStyle(
                                      height: 75,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeExtraSmall,
                                        horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                      ),
                                      primaryColor: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                    dropdownStyle: DropdownStyle(
                                      elevation: 10,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                      padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall),
                                    ),
                                    items: senderAddressList,
                                    child: AddressWidget(
                                      address: senderAddress[
                                      parcelController.senderAddressIndex!],
                                      fromAddress: false,
                                      fromCheckout: true,
                                    ),
                                  )
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Text(
                                  widget.isSender
                                      ? 'sender_information'.tr
                                      : 'receiver_information'.tr,
                                  style: robotoMedium),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              CustomTextField(
                                labelText: widget.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                                titleText: widget.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                                inputType: TextInputType.name,
                                focusNode: nameNode,
                                nextFocus: phoneNode,
                                controller: widget.nameController,
                                suffixImage: Images.Contactbook,
                                suffixOnPressed: () async {
                          debugPrint("it is ontapped 1");
                          PermissionStatus permissionStatus = await Permission.contacts.request();

                          if (permissionStatus.isGranted) {
                          debugPrint("it is ontapped 2");
                          try {
                          final contact = await _contactPicker.selectContact();

                          if (contact != null) {
                          if (contact.fullName != null) {
                          debugPrint("it is ontapped 3");
                          widget.nameController.text = contact.fullName!;
                          }

                          if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
                          // Get the first phone number
                          String rawPhone = contact.phoneNumbers!.first;

                          // Clean it: remove all non-digit characters
                          String cleanedPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

                          // Remove leading country code if it's +91 or any other country code
                          // Assuming Indian number usually starts with 91
                          if (cleanedPhone.startsWith('91') && cleanedPhone.length > 10) {
                          cleanedPhone = cleanedPhone.substring(cleanedPhone.length - 10);
                          }

                          widget.phoneController.text = cleanedPhone;
                          }

                          setState(() {});
                          }
                          } catch (e) {
                          debugPrint("it is ontapped 4");
                          debugPrint("Error picking contact: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error picking contact: $e")),
                          );
                          }
                          } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contacts permission denied')),
                          );
                          }
                          },

                          ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              CustomTextField(
                                titleText: widget.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                                labelText: widget.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                                controller: widget.phoneController,
                                focusNode: phoneNode,
                                inputType: TextInputType.phone,
                                inputAction: AuthHelper.isGuestLoggedIn()
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                isPhone: true,
                                onCountryChanged: (CountryCode countryCode) {
                                  countryDialCode = countryCode.dialCode;
                                  parcelController.setCountryCode(
                                    countryDialCode!, parcelController.isSender,
                                  );
                                },
                                countryDialCode: countryDialCode ?? _countryCode,
                              ),

//
//                               CustomTextField(
//                                 labelText: widget.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
//                                 titleText: widget.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
//                                 inputType: TextInputType.name,
//                                 focusNode: nameNode,
//                                 nextFocus: phoneNode,
//                                 controller: widget.nameController,
//                                 suffixImage: Images.Contactbook,
//                                 suffixOnPressed: () async {
//                                   debugPrint("it is ontapped 1");
//                                   PermissionStatus permissionStatus = await Permission.contacts.request();
//
//                                   if (permissionStatus.isGranted) {
//                                     debugPrint("it is ontapped 2");
//                                     try {
//                                       Contact? contact = await ContactsService.openDeviceContactPicker();
//
//                                       if (contact != null) {
//                                         if (contact.displayName != null) {
//                                           debugPrint("it is ontapped 3");
//                                           widget.nameController.text = contact.displayName!;
//                                         }
//
//                                         if (contact.phones != null && contact.phones!.isNotEmpty) {
//                                           widget.phoneController.text = contact.phones!.first.value ?? '';
//                                         }
//                                       }
//                                     } catch (e) {
//                                       debugPrint("it is ontapped 4");
//                                       debugPrint("Error picking contact: $e");
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(content: Text("Error picking contact: $e")),
//                                       );
//                                     }
//                                   } else {
// // Permission denied
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('Contacts permission denied')),
//                                     );
//                                   }
//                                 },
//                               ),
//                               const SizedBox(height: Dimensions.paddingSizeLarge),
//                               CustomTextField(
//                                 titleText: widget.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
//                                 labelText: widget.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
//                                 controller: widget.phoneController,
//                                 focusNode: phoneNode,
//                                 inputType: TextInputType.phone,
//                                 inputAction: AuthHelper.isGuestLoggedIn()
//                                     ? TextInputAction.next
//                                     : TextInputAction.done,
//                                 isPhone: true,
//                                 onCountryChanged: (CountryCode countryCode) {
//                                   countryDialCode = countryCode.dialCode;
//                                   parcelController.setCountryCode(
//                                       countryDialCode!, parcelController.isSender);
//                                 },
//                                 countryDialCode: countryDialCode ?? _countryCode,
//                               ),
                              // CustomTextField(
                              //   labelText:     widget.isSender
                              //       ? 'sender_name'.tr
                              //       : 'receiver_name'.tr,
                              //   titleText:     widget.isSender
                              //       ? 'sender_name'.tr
                              //       : 'receiver_name'.tr,
                              //   inputType: TextInputType.name,
                              //   focusNode: nameNode,
                              //   nextFocus: phoneNode,
                              //   controller: widget.nameController,
                              //   suffixImage:
                              //     Images.Contactbook ,
                              //   suffixOnPressed: () async {
                              //
                              //   },
                              // ),
                              // const SizedBox(
                              //     height: Dimensions.paddingSizeLarge),
                              // CustomTextField(
                              //   titleText:     widget.isSender
                              //       ? 'sender_phone_number'.tr
                              //       : 'receiver_phone_number'.tr,
                              //   labelText:     widget.isSender
                              //       ? 'sender_phone_number'.tr
                              //       : 'receiver_phone_number'.tr,
                              //   controller: widget.phoneController,
                              //   focusNode: phoneNode,
                              //   inputType: TextInputType.phone,
                              //   inputAction: AuthHelper.isGuestLoggedIn()
                              //       ? TextInputAction.next
                              //       : TextInputAction.done,
                              //   isPhone: true,
                              //   onCountryChanged: (CountryCode countryCode) {
                              //     countryDialCode = countryCode.dialCode;
                              //     parcelController.setCountryCode(
                              //         countryDialCode!,
                              //         parcelController.isSender);
                              //   },
                              //   countryDialCode:
                              //   countryDialCode ?? _countryCode,
                              // ),
                              SizedBox(
                                  height: AuthHelper.isGuestLoggedIn()
                                      ? Dimensions.paddingSizeLarge
                                      : 0),
                              AuthHelper.isGuestLoggedIn()
                                  ? CustomTextField(
                                titleText: parcelController.isSender
                                    ? 'sender_email'.tr
                                    : 'receiver_email'.tr,
                                labelText: parcelController.isSender
                                    ? 'sender_email'.tr
                                    : 'receiver_email'.tr,
                                controller: widget.guestEmailController,
                                inputType: TextInputType.emailAddress,
                                focusNode: guestEmailNode,
                                prefixImage: Images.mail,
                                inputAction: TextInputAction.done,
                              )
                                  : const SizedBox(),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),

                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                            ),
                            padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  !isDesktop
                                      ? CustomTextField(
                                    titleText: 'street_number'.tr,
                                    labelText: 'street_number'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode: streetNode,
                                    nextFocus: houseNode,
                                    controller: widget.streetController,
                                  )
                                      : const SizedBox(),
                                  SizedBox(
                                      height:
                                      !isDesktop ? Dimensions.paddingSizeLarge : 0),
                                  Row(children: [
                                    isDesktop
                                        ? Expanded(
                                      child: CustomTextField(
                                        labelText: 'street_number'.tr,
                                        titleText: 'street_number'.tr,
                                        inputType: TextInputType.streetAddress,
                                        focusNode: streetNode,
                                        nextFocus: houseNode,
                                        controller: widget.streetController,
                                      ),
                                    )
                                        : const SizedBox(),
                                    SizedBox(
                                        width: isDesktop
                                            ? Dimensions.paddingSizeSmall
                                            : 0),

                                    Expanded(
                                      child: CustomTextField(
                                        labelText: 'house'.tr,
                                        titleText: 'house'.tr,
                                        inputType: TextInputType.text,
                                        focusNode: houseNode,
                                        nextFocus: floorNode,
                                        controller: widget.houseController,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                    Expanded(
                                      child: CustomTextField(
                                        labelText: 'floor'.tr,
                                        titleText: 'floor'.tr,
                                        inputType: TextInputType.text,
                                        focusNode: floorNode,
                                        nextFocus: nameNode,
                                        controller: widget.floorController,
                                      ),
                                    ),
                                    //const SizedBox(height: Dimensions.paddingSizeLarge),
                                  ]),
                                ]),
                          ),
                          CustomButton(
                            margin: ResponsiveHelper.isDesktop(context)
                                ? null
                                : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            buttonText: isLoading ? 'Loading...' : 'Continue',
                            onPressed: () async {
                              if (!isLoading) {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  // Simulate data loading
                                  await loadData();
                                  debugPrint("pickup address");
                                  debugPrint(parcelController.pickupAddress!.address
                                      .toString());
                                  // Once data is successfully loaded, navigate back
                                  Navigator.pop(context);
                                } catch (e) {
                                  // Optionally handle any errors here
                                  debugPrint('Error loading data: $e');
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                          )

                          // CustomButton(
                          //   margin: ResponsiveHelper.isDesktop(context)
                          //       ? null
                          //       : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          //   buttonText: 'Continue',
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          // ),
                          ,
                          ResponsiveHelper.isDesktop(context)
                              ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.fontSizeSmall),
                            child: widget.bottomButton,
                          )
                              : const SizedBox(),
                        ]),
                      )),
                )),
          );
        });
      }),
    );
  }

  List<DropdownItem<int>> _getDropdownAddressList(
      {required BuildContext context,
        required List<AddressModel>? addressList,
        required bool isSender,
        required AddressModel? pickupAddress,
        required AddressModel? destinationAddress}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    if (isSender) {
      dropDownAddressList.add(DropdownItem<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidget(
              address: pickupAddress,
              fromAddress: false,
              fromCheckout: true,
            ),
          )));
    } else {
      dropDownAddressList.add(DropdownItem<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidget(
              address: destinationAddress ??
                  AddressHelper.getUserAddressFromSharedPref(),
              fromAddress: false,
              fromCheckout: true,
            ),
          )));
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        dropDownAddressList.add(DropdownItem<int>(
            value: index + 1,
            child: SizedBox(
              width: context.width > Dimensions.webMaxWidth
                  ? Dimensions.webMaxWidth - 50
                  : context.width - 50,
              child: AddressWidget(
                address: addressList[index],
                fromAddress: false,
                fromCheckout: true,
              ),
            )));
      }
    }
    return dropDownAddressList;
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

  Future<void> _splitPhoneNumber(String number) async {
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      _addressCountryCode = '+${phoneNumber.countryCode}';
      widget.phoneController.text =
          phoneNumber.international.substring(_addressCountryCode!.length);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
  }
}



// class ParcelViewWidget extends StatefulWidget {
//   final bool isSender ;
//   final Widget bottomButton;
//   final TextEditingController nameController;
//   final TextEditingController phoneController;
//   final TextEditingController streetController;
//   final TextEditingController houseController;
//   final TextEditingController floorController;
//   final TextEditingController? guestEmailController;
//   final String? countryCode;
//
//   const ParcelViewWidget({super.key, required this.isSender, required this.nameController, required this.phoneController,
//     required this.streetController, required this.houseController, required this.floorController, required this.bottomButton, required this.countryCode,
//     this.guestEmailController});
//
//   @override
//   State<ParcelViewWidget> createState() => _ParcelViewWidgetState();
// }
//
// class _ParcelViewWidgetState extends State<ParcelViewWidget> {
//   final FocusNode streetNode = FocusNode();
//   final FocusNode houseNode = FocusNode();
//   final FocusNode floorNode = FocusNode();
//   final FocusNode nameNode = FocusNode();
//   final FocusNode phoneNode = FocusNode();
//   final FocusNode guestEmailNode = FocusNode();
//   String? _countryCode;
//   String? _addressCountryCode;
//
//   @override
//   void initState() {
//     super.initState();
//     _addressCountryCode = null;
//     _countryCode = _addressCountryCode ?? widget.countryCode;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     bool isDesktop = ResponsiveHelper.isDesktop(context);
//     _countryCode = _addressCountryCode ?? widget.countryCode;
//     String? countryDialCode;
//
//     return SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<AddressController>(builder: (addressController) {
//         return GetBuilder<ParcelController>(builder: (parcelController) {
//           List<DropdownItem<int>> senderAddressList = _getDropdownAddressList(context: context, addressList: addressController.addressList, isSender: true, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);
//           List<DropdownItem<int>> receiverAddressList = _getDropdownAddressList(context: context, addressList: addressController.addressList, isSender: false, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);
//           List<AddressModel> senderAddress = _getAddressList(addressList: addressController.addressList, isSender: true, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);
//           List<AddressModel> receiverAddress = _getAddressList(addressList: addressController.addressList, isSender: false, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);
//
//           return SingleChildScrollView(
//               controller: ScrollController(),
//               child: Center(child: FooterView(
//                 child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
//                   padding: const EdgeInsets.all(0),
//                   child: Column(children: [
//                     const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                     Container(
//                       decoration: BoxDecoration(color: Theme.of(context).cardColor),
//                       padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                       child: Column(children: [
//
//                         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                           Text(widget.isSender ? 'pickup_location'.tr : 'delivery_location'.tr, style: robotoMedium),
//
//                           TextButton.icon(
//                             onPressed: () async {
//                               if(ResponsiveHelper.isDesktop(Get.context)){
//                                 showGeneralDialog(context: context, pageBuilder: (_,__,___) {
//                                   return SizedBox(
//                                     height: 300, width: 300,
//                                     child: PickMapScreen(fromSignUp: false, canRoute: false, fromAddAddress: false, route:'', onPicked: (AddressModel address) async {
//
//                                       ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
//
//                                       AddressModel a = AddressModel(
//                                         id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
//                                         address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
//                                         zoneIds: address.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
//                                         zoneData: responseModel.zoneData,
//                                       );
//
//                                       if(parcelController.isPickedUp!) {
//                                         parcelController.setPickupAddress(a, true);
//                                       }else {
//                                         parcelController.setDestinationAddress(a);
//                                       }
//                                     }),
//                                   );
//                                 });
//                               }else{
//                                 Get.toNamed(RouteHelper.getPickMapRoute('parcel', false), arguments: PickMapScreen(
//                                   fromSignUp: false, fromAddAddress: false, canRoute: false, route: '', onPicked: (AddressModel address) async {
//
//                                   if(parcelController.isPickedUp!) {
//                                     ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
//                                     AddressModel pickupAddress = AddressModel(
//                                       id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
//                                       address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
//                                       zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
//                                       zoneData: responseModel.zoneData,
//                                     );
//                                     parcelController.setPickupAddress(pickupAddress, true);
//                                     parcelController.setSenderAddressIndex(0);
//                                   }else {
//                                     ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
//                                     AddressModel a = AddressModel(
//                                       id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
//                                       address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
//                                       zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
//                                       zoneData: responseModel.zoneData,
//                                     );
//                                     parcelController.setDestinationAddress(a);
//                                     parcelController.setReceiverAddressIndex(0);
//                                   }
//                                 },
//                                 ));
//                               }
//                             },
//                             icon: const Icon(Icons.add, size: 20),
//                             label: Text('add_new'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                           ),
//                         ]),
//
//                         Container(
//                           constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                             color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
//                           ),
//                           child: CustomDropdown<int>(
//                             onChange: (int? value, int index) async {
//
//                               if(parcelController.isSender){
//                                 ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(senderAddress[index].latitude.toString(), senderAddress[index].longitude.toString(), false);
//                                 AddressModel pickupAddress = AddressModel(
//                                   id: senderAddress[index].id, addressType: senderAddress[index].addressType, contactPersonNumber: senderAddress[index].contactPersonNumber, contactPersonName: senderAddress[index].contactPersonName,
//                                   address: senderAddress[index].address, latitude: senderAddress[index].latitude, longitude: senderAddress[index].longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
//                                   zoneIds: responseModel.zoneIds, method: senderAddress[index].method, streetNumber: senderAddress[index].streetNumber, house: senderAddress[index].house, floor: senderAddress[index].floor,
//                                   zoneData: responseModel.zoneData,
//                                 );
//                                 parcelController.setPickupAddress(pickupAddress, true);
//                                 parcelController.setSenderAddressIndex(index);
//                                 widget.streetController.text = senderAddress[index].streetNumber ?? '';
//                                 widget.houseController.text = senderAddress[index].house ?? '';
//                                 widget.floorController.text = senderAddress[index].floor ?? '';
//                                 widget.nameController.text = senderAddress[index].contactPersonName ?? '';
//                                 await _splitPhoneNumber(senderAddress[index].contactPersonNumber??'');
//                                 parcelController.setCountryCode(_addressCountryCode?? _countryCode!, true);
//
//                                 // widget.phoneController.text = senderAddress[index].contactPersonNumber ?? '';
//                               }else{
//                                 ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(receiverAddress[index].latitude.toString(), receiverAddress[index].longitude.toString(), false);
//                                 AddressModel a = AddressModel(
//                                   id: receiverAddress[index].id, addressType: receiverAddress[index].addressType, contactPersonNumber: receiverAddress[index].contactPersonNumber, contactPersonName: receiverAddress[index].contactPersonName,
//                                   address: receiverAddress[index].address, latitude: receiverAddress[index].latitude, longitude: receiverAddress[index].longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
//                                   zoneIds: responseModel.zoneIds, method: receiverAddress[index].method, streetNumber: receiverAddress[index].streetNumber, house: receiverAddress[index].house, floor: receiverAddress[index].floor,
//                                   zoneData: responseModel.zoneData,
//                                 );
//                                 parcelController.setDestinationAddress(a);
//                                 parcelController.setReceiverAddressIndex(index);
//                                 widget.streetController.text = receiverAddress[index].streetNumber ?? '';
//                                 widget.houseController.text = receiverAddress[index].house ?? '';
//                                 widget.floorController.text = receiverAddress[index].floor ?? '';
//                               }
//                             },
//                             dropdownButtonStyle: DropdownButtonStyle(
//                               height: 45,
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: Dimensions.paddingSizeExtraSmall,
//                                 horizontal: Dimensions.paddingSizeExtraSmall,
//                               ),
//                               primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
//                             ),
//                             dropdownStyle: DropdownStyle(
//                               elevation: 10,
//                               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                               padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                             ),
//                             items: parcelController.isSender ? senderAddressList : receiverAddressList,
//                             child: AddressWidget(
//                               address: parcelController.isSender ? senderAddress[parcelController.senderAddressIndex!] : receiverAddress[parcelController.receiverAddressIndex!],
//                               fromAddress: false, fromCheckout: true,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                         !isDesktop ? CustomTextField(
//                           titleText: 'street_number'.tr,
//                           labelText: 'street_number'.tr,
//                           inputType: TextInputType.streetAddress,
//                           focusNode: streetNode,
//                           nextFocus: houseNode,
//                           controller: widget.streetController,
//                         ) : const SizedBox(),
//                         SizedBox(height: !isDesktop ? Dimensions.paddingSizeLarge : 0),
//
//                         Row(
//                             children: [
//                               isDesktop ? Expanded(
//                                 child: CustomTextField(
//                                   labelText: 'street_number'.tr,
//                                   titleText: 'street_number'.tr,
//                                   inputType: TextInputType.streetAddress,
//                                   focusNode: streetNode,
//                                   nextFocus: houseNode,
//                                   controller: widget.streetController,
//                                 ),
//                               ) : const SizedBox(),
//                               SizedBox(width: isDesktop ? Dimensions.paddingSizeSmall : 0),
//
//                               Expanded(
//                                 child: CustomTextField(
//                                   labelText: 'house'.tr,
//                                   titleText: 'house'.tr,
//                                   inputType: TextInputType.text,
//                                   focusNode: houseNode,
//                                   nextFocus: floorNode,
//                                   controller: widget.houseController,
//                                 ),
//                               ),
//                               const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                               Expanded(
//                                 child: CustomTextField(
//                                   labelText: 'floor'.tr,
//                                   titleText: 'floor'.tr,
//                                   inputType: TextInputType.text,
//                                   focusNode: floorNode,
//                                   nextFocus: nameNode,
//                                   controller: widget.floorController,
//                                 ),
//                               ),
//                               //const SizedBox(height: Dimensions.paddingSizeLarge),
//                             ]
//                         ),
//                       ]),
//                     ),
//
//                     const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).cardColor,
//                       ),
//                       padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                         Text(parcelController.isSender ? 'sender_information'.tr : 'receiver_information'.tr, style: robotoMedium),
//                         const SizedBox(height: Dimensions.paddingSizeDefault),
//
//                         CustomTextField(
//                           labelText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
//                           titleText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
//                           inputType: TextInputType.name,
//                           focusNode: nameNode,
//                           nextFocus: phoneNode,
//                           controller: widget.nameController,
//                         ),
//                         const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                         CustomTextField(
//                           titleText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
//                           labelText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
//                           controller: widget.phoneController,
//                           focusNode: phoneNode,
//                           inputType: TextInputType.phone,
//                           inputAction: AuthHelper.isGuestLoggedIn() ? TextInputAction.next : TextInputAction.done,
//                           isPhone: true,
//                           onCountryChanged: (CountryCode countryCode) {
//                             countryDialCode = countryCode.dialCode;
//                             parcelController.setCountryCode(countryDialCode!, parcelController.isSender);
//                           },
//                           countryDialCode: countryDialCode ?? _countryCode,
//                         ),
//                         SizedBox(height: AuthHelper.isGuestLoggedIn() ? Dimensions.paddingSizeLarge : 0),
//
//                         AuthHelper.isGuestLoggedIn() ? CustomTextField(
//                           titleText: parcelController.isSender ? 'sender_email'.tr : 'receiver_email'.tr,
//                           labelText: parcelController.isSender ? 'sender_email'.tr : 'receiver_email'.tr,
//                           controller: widget.guestEmailController,
//                           inputType: TextInputType.emailAddress,
//                           focusNode: guestEmailNode,
//                           prefixImage: Images.mail,
//                           inputAction: TextInputAction.done,
//                         ) : const SizedBox(),
//
//                         const SizedBox(height: Dimensions.paddingSizeDefault),
//
//                       ]),
//                     ),
//
//                     ResponsiveHelper.isDesktop(context) ? Padding(
//                       padding: EdgeInsets.symmetric(vertical: Dimensions.fontSizeSmall),
//                       child: widget.bottomButton,
//                     ) : const SizedBox(),
//
//                   ]),
//                 )),
//               )),
//             );
//             }
//           );
//       }
//     ),
//     );
//   }
//
//   List<DropdownItem<int>> _getDropdownAddressList({required BuildContext context, required List<AddressModel>? addressList, required bool isSender, required AddressModel? pickupAddress, required AddressModel? destinationAddress}) {
//     List<DropdownItem<int>> dropDownAddressList = [];
//
//     if(isSender) {
//       dropDownAddressList.add(DropdownItem<int>(value: 0, child: SizedBox(
//         width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 50 : context.width - 50,
//         child: AddressWidget(
//           address: pickupAddress,
//           fromAddress: false, fromCheckout: true,
//         ),
//       )));
//     } else {
//       dropDownAddressList.add(DropdownItem<int>(value: 0, child: SizedBox(
//         width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 50 : context.width - 50,
//         child: AddressWidget(
//           address: destinationAddress ?? AddressHelper.getUserAddressFromSharedPref(),
//           fromAddress: false, fromCheckout: true,
//         ),
//       )));
//     }
//
//     if(addressList != null && AuthHelper.isLoggedIn()) {
//       for(int index=0; index<addressList.length; index++) {
//
//         dropDownAddressList.add(DropdownItem<int>(value: index + 1, child: SizedBox(
//           width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
//           child: AddressWidget(
//             address: addressList[index],
//             fromAddress: false, fromCheckout: true,
//           ),
//         )));
//       }
//     }
//     return dropDownAddressList;
//   }
//
//   List<AddressModel> _getAddressList({required List<AddressModel>? addressList, required bool isSender, required AddressModel? pickupAddress, required AddressModel? destinationAddress}) {
//     List<AddressModel> address = [];
//
//     if(isSender) {
//       address.add(pickupAddress!);
//     } else if(!isSender) {
//       address.add(destinationAddress ?? AddressHelper.getUserAddressFromSharedPref()!);
//     }
//
//     if(addressList != null && AuthHelper.isLoggedIn()) {
//       for(int index=0; index<addressList.length; index++) {
//         address.add(addressList[index]);
//       }
//     }
//     return address;
//   }
//
//   Future<void> _splitPhoneNumber(String number) async {
//     try {
//       PhoneNumber phoneNumber = PhoneNumber.parse(number);
//       _addressCountryCode = '+${phoneNumber.countryCode}';
//       widget.phoneController.text = phoneNumber.international.substring(_addressCountryCode!.length);
//     } catch (e) {
//       debugdebugPrint('number can\'t parse : $e');
//     }
//   }
// }
class ParcelViewWidget1 extends StatefulWidget {
  final Widget bottomButton;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController? guestEmailController;
  final String? countryCode;

  const ParcelViewWidget1(
      {super.key,
        required this.nameController,
        required this.phoneController,
        required this.streetController,
        required this.houseController,
        required this.floorController,
        required this.bottomButton,
        required this.countryCode,
        this.guestEmailController});

  @override
  State<ParcelViewWidget1> createState() => _ParcelViewWidget1State();
}

class _ParcelViewWidget1State extends State<ParcelViewWidget1> {
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  final FocusNode nameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  String? _countryCode;
  String? _addressCountryCode;

  @override
  void initState() {
    super.initState();
    _addressCountryCode = null;
    _countryCode = _addressCountryCode ?? widget.countryCode;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    _countryCode = _addressCountryCode ?? widget.countryCode;
    String? countryDialCode;

    bool isLoading = false;

    Future<void> loadData() async {
      // Replace this with your actual data loading logic
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    }

    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: GetBuilder<AddressController>(builder: (addressController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          List<DropdownItem<int>> senderAddressList = _getDropdownAddressList(
              context: context,
              addressList: addressController.addressList,
              isSender: true,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<DropdownItem<int>> receiverAddressList = _getDropdownAddressList(
              context: context,
              addressList: addressController.addressList,
              isSender: false,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<AddressModel> senderAddress = _getAddressList(
              addressList: addressController.addressList,
              isSender: true,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<AddressModel> receiverAddress = _getAddressList(
              addressList: addressController.addressList,
              isSender: false,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);

          return SingleChildScrollView(
            controller: ScrollController(),
            child: Center(
                child: FooterView(
                  child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(children: [
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Container(
                            decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                            padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('delivery_location'.tr,
                                        style: robotoMedium),
                                    TextButton.icon(
                                      onPressed: () async {
                                        if (ResponsiveHelper.isDesktop(
                                            Get.context)) {
                                          showGeneralDialog(
                                              context: context,
                                              pageBuilder: (_, __, ___) {
                                                return SizedBox(
                                                  height: 300,
                                                  width: 300,
                                                  child: PickMapScreen(
                                                      fromSignUp: false,
                                                      canRoute: false,
                                                      fromAddAddress: false,
                                                      route: '',
                                                      onPicked: (AddressModel
                                                      address) async {
                                                        ZoneResponseModel
                                                        responseModel =
                                                        await Get.find<
                                                            LocationController>()
                                                            .getZone(
                                                            address.latitude
                                                                .toString(),
                                                            address
                                                                .longitude
                                                                .toString(),
                                                            false);

                                                        AddressModel a =
                                                        AddressModel(
                                                          id: address.id,
                                                          addressType:
                                                          address.addressType,
                                                          contactPersonNumber: address
                                                              .contactPersonNumber,
                                                          contactPersonName: address
                                                              .contactPersonName,
                                                          address: address.address,
                                                          latitude:
                                                          address.latitude,
                                                          longitude:
                                                          address.longitude,
                                                          zoneId: responseModel
                                                              .isSuccess
                                                              ? responseModel
                                                              .zoneIds[0]
                                                              : 0,
                                                          zoneIds: address.zoneIds,
                                                          method: address.method,
                                                          streetNumber:
                                                          address.streetNumber,
                                                          house: address.house,
                                                          floor: address.floor,
                                                        );

                                                        parcelController
                                                            .setDestinationAddress(
                                                            a);
                                                      }),
                                                );
                                              });
                                        } else {
                                          Get.toNamed(
                                            RouteHelper.getPickMapRoute(
                                                'parcel', false),
                                            arguments: PickMapScreen(
                                              fromSignUp: false,
                                              fromAddAddress: false,
                                              canRoute: false,
                                              route: '',
                                              onPicked:
                                                  (AddressModel address) async {
                                                ZoneResponseModel responseModel =
                                                await Get.find<
                                                    LocationController>()
                                                    .getZone(
                                                    address.latitude
                                                        .toString(),
                                                    address.longitude
                                                        .toString(),
                                                    false);

                                                AddressModel a = AddressModel(
                                                  id: address.id,
                                                  addressType: address.addressType,
                                                  contactPersonNumber:
                                                  address.contactPersonNumber,
                                                  contactPersonName:
                                                  address.contactPersonName,
                                                  address: address.address,
                                                  latitude: address.latitude,
                                                  longitude: address.longitude,
                                                  zoneId: responseModel.isSuccess
                                                      ? responseModel.zoneIds[0]
                                                      : 0,
                                                  zoneIds: responseModel.zoneIds,
                                                  method: address.method,
                                                  streetNumber:
                                                  address.streetNumber,
                                                  house: address.house,
                                                  floor: address.floor,
                                                );

                                                parcelController
                                                    .setDestinationAddress(a);
                                                parcelController
                                                    .setReceiverAddressIndex(0);
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 20),
                                      label: Text('add_new'.tr,
                                          style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall)),
                                    ),
                                  ]),
                              Container(
                                constraints: BoxConstraints(
                                    minHeight: ResponsiveHelper.isDesktop(context)
                                        ? 120
                                        : 95),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                ),
                                child: CustomDropdown<int>(
                                  onChange: (int? value, int index) async {
                                    try {
                                      // Check if senderAddress or receiverAddress list contains the index
                                      if (parcelController.isSender) {
                                        if (index >= 0 &&
                                            index < senderAddress.length) {
                                          // Set pickup address for the sender
                                          parcelController.setPickupAddress(
                                              senderAddress[index], true);
                                          parcelController
                                              .setSenderAddressIndex(index);

                                          // Populate the fields with the selected sender's information
                                          widget.nameController.text =
                                              senderAddress[index]
                                                  .contactPersonName ??
                                                  '';
                                          await _splitPhoneNumber(
                                              senderAddress[index]
                                                  .contactPersonNumber ??
                                                  '');

                                          // Set country code for the sender
                                          if (_addressCountryCode != null) {
                                            parcelController.setCountryCode(
                                                _addressCountryCode!, true);
                                          } else {
                                            debugPrint(
                                                "Country code for sender address is null.");
                                          }

                                          debugPrint(
                                              "Sender Address Selected: ${senderAddress[index].contactPersonName}, "
                                                  "Phone: ${senderAddress[index].contactPersonNumber}");
                                        } else {
                                          debugPrint(
                                              "Index out of range for senderAddress array.");
                                        }
                                      } else {
                                        if (index >= 0 &&
                                            index < receiverAddress.length) {
                                          // Set destination address for the receiver
                                          parcelController.setDestinationAddress(
                                              receiverAddress[index]);
                                          parcelController
                                              .setReceiverAddressIndex(index);

                                          // Uncomment and assign other fields if needed for receiver's address
                                          // widget.streetController.text = receiverAddress[index].streetNumber ?? '';
                                          // widget.houseController.text = receiverAddress[index].house ?? '';
                                          // widget.floorController.text = receiverAddress[index].floor ?? '';

                                          debugPrint(
                                              "Receiver Address Selected: ${receiverAddress[index].contactPersonName}, "
                                                  "Phone: ${receiverAddress[index].contactPersonNumber}");
                                        } else {
                                          debugPrint(
                                              "Index out of range for receiverAddress array.");
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint(
                                          "An error occurred in onChange function: $e");
                                    }
                                  },
                                  dropdownButtonStyle: DropdownButtonStyle(
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeExtraSmall,
                                      horizontal: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    primaryColor: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  dropdownStyle: DropdownStyle(
                                    elevation: 10,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                  ),
                                  items: parcelController.isSender
                                      ? senderAddressList
                                      : receiverAddressList,
                                  child: AddressWidget(
                                    address: parcelController.isSender
                                        ? senderAddress[
                                    parcelController.senderAddressIndex!]
                                        : receiverAddress[
                                    parcelController.receiverAddressIndex!],
                                    fromAddress: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              !isDesktop
                                  ? CustomTextField(
                                titleText: 'street_number'.tr,
                                labelText: 'street_number'.tr,
                                inputType: TextInputType.streetAddress,
                                focusNode: streetNode,
                                nextFocus: houseNode,
                                controller: widget.streetController,
                              )
                                  : const SizedBox(),
                              SizedBox(
                                  height:
                                  !isDesktop ? Dimensions.paddingSizeLarge : 0),
                              Row(children: [
                                isDesktop
                                    ? Expanded(
                                  child: CustomTextField(
                                    labelText: 'street_number'.tr,
                                    titleText: 'street_number'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode: streetNode,
                                    nextFocus: houseNode,
                                    controller: widget.streetController,
                                  ),
                                )
                                    : const SizedBox(),
                                SizedBox(
                                    width: isDesktop
                                        ? Dimensions.paddingSizeSmall
                                        : 0),

                                Expanded(
                                  child: CustomTextField(
                                    labelText: 'house'.tr,
                                    titleText: 'house'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: houseNode,
                                    nextFocus: floorNode,
                                    controller: widget.houseController,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(
                                  child: CustomTextField(
                                    labelText: 'floor'.tr,
                                    titleText: 'floor'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: floorNode,
                                    nextFocus: nameNode,
                                    controller: widget.floorController,
                                  ),
                                ),
                                //const SizedBox(height: Dimensions.paddingSizeLarge),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                            ),
                            padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  Text(
                                      parcelController.isSender
                                          ? 'sender_information'.tr
                                          : 'receiver_information'.tr,
                                      style: robotoMedium),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  CustomTextField(
                                    labelText: parcelController.isSender
                                        ? 'sender_name'.tr
                                        : 'receiver_name'.tr,
                                    titleText: parcelController.isSender
                                        ? 'sender_name'.tr
                                        : 'receiver_name'.tr,
                                    inputType: TextInputType.name,
                                    focusNode: nameNode,
                                    nextFocus: phoneNode,
                                    controller: widget.nameController,
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeLarge),
                                  CustomTextField(
                                    titleText: parcelController.isSender
                                        ? 'sender_phone_number'.tr
                                        : 'receiver_phone_number'.tr,
                                    labelText: parcelController.isSender
                                        ? 'sender_phone_number'.tr
                                        : 'receiver_phone_number'.tr,
                                    controller: widget.phoneController,
                                    focusNode: phoneNode,
                                    inputType: TextInputType.phone,
                                    inputAction: AuthHelper.isGuestLoggedIn()
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    isPhone: true,
                                    onCountryChanged: (CountryCode countryCode) {
                                      countryDialCode = countryCode.dialCode;
                                      parcelController.setCountryCode(
                                          countryDialCode!,
                                          parcelController.isSender);
                                    },
                                    countryDialCode:
                                    countryDialCode ?? _countryCode,
                                  ),
                                  SizedBox(
                                      height: AuthHelper.isGuestLoggedIn()
                                          ? Dimensions.paddingSizeLarge
                                          : 0),
                                  AuthHelper.isGuestLoggedIn()
                                      ? CustomTextField(
                                    titleText: parcelController.isSender
                                        ? 'sender_email'.tr
                                        : 'receiver_email'.tr,
                                    labelText: parcelController.isSender
                                        ? 'sender_email'.tr
                                        : 'receiver_email'.tr,
                                    controller: widget.guestEmailController,
                                    inputType: TextInputType.emailAddress,
                                    focusNode: guestEmailNode,
                                    prefixImage: Images.mail,
                                    inputAction: TextInputAction.done,
                                  )
                                      : const SizedBox(),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                ]),
                          ),
                          CustomButton(
                            margin: ResponsiveHelper.isDesktop(context)
                                ? null
                                : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            buttonText: isLoading ? 'Loading...' : 'Continue',
                            onPressed: () async {
                              if (!isLoading) {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  // Simulate data loading
                                  await loadData();
                                  debugPrint("drop address");
                                  debugPrint(parcelController.destinationAddress!.address
                                      .toString());
                                  debugPrint("dfdvdvg");
                                  // Once data is successfully loaded, navigate back
                                  Navigator.pop(context);
                                } catch (e) {
                                  // Optionally handle any errors here
                                  debugPrint('Error loading data: $e');
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                          ),

                          // CustomButton(
                          //   margin: ResponsiveHelper.isDesktop(context)
                          //       ? null
                          //       : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          //   buttonText: 'Continue',
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          // ),
                          ResponsiveHelper.isDesktop(context)
                              ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.fontSizeSmall),
                            child: widget.bottomButton,
                          )
                              : const SizedBox(),
                        ]),
                      )),
                )),
          );
        });
      }),
    );
  }

  List<DropdownItem<int>> _getDropdownAddressList(
      {required BuildContext context,
        required List<AddressModel>? addressList,
        required bool isSender,
        required AddressModel? pickupAddress,
        required AddressModel? destinationAddress}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    if (isSender) {
      dropDownAddressList.add(DropdownItem<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidget(
              address: pickupAddress,
              fromAddress: false,
              fromCheckout: true,
            ),
          )));
    } else {
      dropDownAddressList.add(DropdownItem<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidget(
              address: destinationAddress ??
                  AddressHelper.getUserAddressFromSharedPref(),
              fromAddress: false,
              fromCheckout: true,
            ),
          )));
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        dropDownAddressList.add(DropdownItem<int>(
            value: index + 1,
            child: SizedBox(
              width: context.width > Dimensions.webMaxWidth
                  ? Dimensions.webMaxWidth - 50
                  : context.width - 50,
              child: AddressWidget(
                address: addressList[index],
                fromAddress: false,
                fromCheckout: true,
              ),
            )));
      }
    }
    return dropDownAddressList;
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

  Future<void> _splitPhoneNumber(String number) async {
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      _addressCountryCode = '+${phoneNumber.countryCode}';
      widget.phoneController.text =
          phoneNumber.international.substring(_addressCountryCode!.length);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
  }
}