import 'package:flutter/material.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'custom_drop_dow2_widget.dart';


class ParcelAddressPickerWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final List<DropdownItem2<int>> addressList;
  final Widget? widget;
  final Future<void> Function(int? value, int index) onChange;
  const ParcelAddressPickerWidget({
    super.key,
    required this.title,
    required this.onTap,
    required this.addressList,
    this.widget,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 12, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- HEADER ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bookmark_border,
                        color: Colors.pink.shade400, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // ADD NEW Button
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                      Border.all(color: Colors.pink.shade200, width: 0.9),
                      color: Colors.pink.shade50,
                    ),
                    child: Row(
                      spacing: 1,
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 16, color: Colors.pink.shade400),
                        Text(
                          "ADD NEW",
                          style: robotoBold.copyWith(
                            fontSize: 12,
                            color: Colors.pink.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (addressList.isNotEmpty || widget!=null)    Divider(
            height: 10,
            thickness: 0.9,
            color: Colors.grey.shade100,
          ),

          if (addressList.isNotEmpty || widget!= null)  CustomDropdown2<int>(
            onChange: onChange,
            dropdownButtonStyle: DropdownButtonStyle2(
              height: 117,
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall,
                horizontal: Dimensions.paddingSizeExtraSmall,
              ),
              primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            dropdownStyle: DropdownStyle2(
              elevation: 10,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            ),
            items: addressList,
            child: widget!,
          ),
        ],
      ),
    );
  }
}

// class ParcelAddressPickerWidget extends StatefulWidget {
//   final String title;
//   final int zoneId;
//   final VoidCallback onTap;
//   final Future<void> Function(int? value, int index) onChange;
//
//   const ParcelAddressPickerWidget({
//     super.key,
//     required this.title,
//     required this.onTap,
//     required this.widget,
//     required this.onChange, required this.zoneId,
//   });
//
//   @override
//   State<ParcelAddressPickerWidget> createState() => _ParcelAddressPickerWidgetState();
// }
// late List<AddressModel>? alladdress;
// late List<DropdownItem2<int>>? addressList;
// class _ParcelAddressPickerWidgetState extends State<ParcelAddressPickerWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AddressController>(
//         builder: (addressController) {
//           return GetBuilder<ParcelController>(
//             builder: (parcelController) {
//               final selectedIndex = parcelController.senderAddressIndex ?? 0;
//               List<DropdownItem2<int>> senderAddressList =
//               _getDropdownAddressList(
//                 context: context,
//                 addressList: addressController.addressList,
//                 isSender: true,
//                 pickupAddress: parcelController.pickupAddress,
//                 destinationAddress: parcelController.destinationAddress,
//               );
//
//               List<AddressModel> senderAddress = _getAddressList(
//                 addressList: addressController.addressList,
//                 isSender: true,
//                 pickupAddress: parcelController.pickupAddress,
//                 destinationAddress: parcelController.destinationAddress,
//               );
//               final hasAddress =
//                   senderAddress != null &&
//                       senderAddress!.isNotEmpty &&
//                       selectedIndex < senderAddress!.length &&
//                       senderAddress![selectedIndex].id != null;
//
//               debugPrint(
//                 "SenderAddressId => ${hasAddress ? alladdress![selectedIndex].id : 'NULL'}",
//               );
//
//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 margin: const EdgeInsets.only(bottom: 12, top: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// Header
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.bookmark_border,
//                                 color: Colors.pink.shade400,
//                                 size: 22,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 widget.title,
//                                 style: robotoRegular.copyWith(
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           /// Add Address
//                           GestureDetector(
//                             onTap: () async {
//                               await Get.toNamed(
//                                 RouteHelper.getAddAddressRoute(
//                                   true,
//                                   false,
//                                   widget.zoneId,
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 7,
//                                 vertical: 7,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Colors.pink.shade200,
//                                   width: 0.9,
//                                 ),
//                                 color: Colors.pink.shade50,
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.add_circle_outline,
//                                     size: 16,
//                                     color: Colors.pink.shade400,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     "ADD NEW",
//                                     style: robotoBold.copyWith(
//                                       fontSize: 12,
//                                       color: Colors.pink.shade400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 5),
//
//                     /// Divider
//                     if (hasAddress)
//                       Divider(
//                         height: 10,
//                         thickness: 0.9,
//                         color: Colors.grey.shade100,
//                       ),
//
//                     /// Dropdown
//                     if (hasAddress)
//                       CustomDropdown2<int>(
//                         onChange: widget.onChange,
//                         dropdownButtonStyle: DropdownButtonStyle2(
//                           height: 117,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: Dimensions.paddingSizeExtraSmall,
//                             horizontal: Dimensions.paddingSizeExtraSmall,
//                           ),
//                           primaryColor:
//                           Theme.of(context).textTheme.bodyLarge!.color,
//                         ),
//                         dropdownStyle: DropdownStyle2(
//                           elevation: 10,
//                           borderRadius:
//                           BorderRadius.circular(Dimensions.radiusDefault),
//                           padding: const EdgeInsets.all(
//                             Dimensions.paddingSizeExtraSmall,
//                           ),
//                         ),
//                         items: addressList!,
//                         child:  AddressWidgetCustom(
//                           address: senderAddress[
//                           parcelController.senderAddressIndex!],
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           );});}
//
//   List<AddressModel> _getAddressList(
//       {required List<AddressModel>? addressList,
//         required bool isSender,
//         required AddressModel? pickupAddress,
//         required AddressModel? destinationAddress}) {
//     List<AddressModel> address = [];
//
//     if (isSender) {
//       address.add(pickupAddress!);
//     } else if (!isSender) {
//       address.add(
//           destinationAddress ?? AddressHelper.getUserAddressFromSharedPref()!);
//     }
//
//     if (addressList != null && AuthHelper.isLoggedIn()) {
//       for (int index = 0; index < addressList.length; index++) {
//         address.add(addressList[index]);
//       }
//     }
//     return address;
//   }
//
//   List<DropdownItem2<int>> _getDropdownAddressList(
//       {required BuildContext context,
//         required List<AddressModel>? addressList,
//         required bool isSender,
//         required AddressModel? pickupAddress,
//         required AddressModel? destinationAddress}) {
//     List<DropdownItem2<int>> dropDownAddressList = [];
//
//     if (isSender) {
//       dropDownAddressList.add(
//         DropdownItem2<int>(
//           value: 0,
//           child: SizedBox(
//             width: context.width > Dimensions.webMaxWidth
//                 ? Dimensions.webMaxWidth - 50
//                 : context.width - 50,
//             child: AddressWidgetCustom2(
//               address:
//               pickupAddress ?? AddressHelper.getUserAddressFromSharedPref(),
//             ),
//           ),
//         ),
//       );
//     } else {
//       dropDownAddressList.add(
//         DropdownItem2<int>(
//           value: 0,
//           child: SizedBox(
//             width: context.width > Dimensions.webMaxWidth
//                 ? Dimensions.webMaxWidth - 50
//                 : context.width - 50,
//             child: AddressWidgetCustom2(
//               address: destinationAddress ??
//                   AddressHelper.getUserAddressFromSharedPref(),
//             ),
//           ),
//         ),
//       );
//     }
//
//     if (addressList != null && AuthHelper.isLoggedIn()) {
//       for (int index = 0; index < addressList.length; index++) {
//         dropDownAddressList.add(
//           DropdownItem2<int>(
//             value: index + 1,
//             child: SizedBox(
//               width: context.width > Dimensions.webMaxWidth
//                   ? Dimensions.webMaxWidth - 50
//                   : context.width - 50,
//               child: AddressWidgetCustom2(
//                 address: addressList[index],
//               ),
//             ),
//           ),
//         );
//       }
//     }
//     return dropDownAddressList;
//   }
// }
