import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

// class DeliveryInstructionView extends StatefulWidget {
//   const DeliveryInstructionView({super.key});
//
//   @override
//   State<DeliveryInstructionView> createState() => _DeliveryInstructionViewState();
// }
//
// class _DeliveryInstructionViewState extends State<DeliveryInstructionView> {
//   ExpansibleController controller = ExpansibleController();
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
//       child: GetBuilder<CheckoutController>(
//         builder: (orderController) {
//           return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//             Theme(
//               data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//               child: ExpansionTile(
//                 key: widget.key,
//                 controller: controller,
//                 title: Text('add_more_delivery_instruction'.tr, style: robotoMedium),
//                 trailing: Icon(orderController.isExpanded ? Icons.remove : Icons.add, size: 18),
//                 tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                 onExpansionChanged: (value) => orderController.expandedUpdate(value),
//
//                 children: [
//
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: AppConstants.deliveryInstructionList.length,
//                       itemBuilder: (context, index){
//                       bool isSelected = orderController.selectedInstruction == index;
//                     return InkWell(
//                       onTap: () {
//                         orderController.setInstruction(index);
//                         if(controller.isExpanded) {
//                           controller.collapse();
//                         }
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                           // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                         ),
//                         padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                         margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                         child: Row(children: [
//                           Icon(Icons.ac_unit, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 18),
//                           const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                           Expanded(
//                             child: Text(
//                               AppConstants.deliveryInstructionList[index].tr,
//                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
//                             ),
//                           ),
//                         ]),
//
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//
//             orderController.selectedInstruction != -1 ? Padding(
//               padding:  EdgeInsets.symmetric(vertical: orderController.isExpanded ? Dimensions.paddingSizeSmall : 0),
//               child: Row(children: [
//                 Text(
//                   AppConstants.deliveryInstructionList[orderController.selectedInstruction].tr,
//                   style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
//                 ),
//
//                 InkWell(
//                   onTap: ()=> orderController.setInstruction(-1),
//                   child: const Icon(Icons.clear, size: 16),
//                 ),
//               ])
//             ) : const SizedBox(),
//
//           ]);
//         }
//       ),
//     );
//   }
// }
// class DeliveryInstructionView extends StatefulWidget {
//   const DeliveryInstructionView({Key? key}) : super(key: key);
//
//   @override
//   State<DeliveryInstructionView> createState() =>
//       _DeliveryInstructionViewState();
// }
//
// class _DeliveryInstructionViewState extends State<DeliveryInstructionView> {
//   ExpansibleController controller = ExpansibleController();
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CheckoutController>(
//       builder: (orderController) {
//         final items = AppConstants.deliveryInstructionList;
//         final tileWidth = (Get.width - (Dimensions.paddingSizeDefault * 6)) / 4;
//
//         // Create keys to measure each tile
//         List<GlobalKey> keys = List.generate(items.length, (_) => GlobalKey());
//
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           for (var key in keys) {
//             final context = key.currentContext;
//             if (context != null) {
//               final height = context.size?.height ?? 0;
//               orderController.updateTileHeight(height.round());
//             }
//           }
//         });
//
//         return Container(
//           width: Get.width,
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//             boxShadow: [
//               BoxShadow(
//                 color: Theme.of(context).primaryColor.withOpacity(0.05),
//                 blurRadius: 10,
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.symmetric(
//             horizontal: Dimensions.paddingSizeDefault,
//             vertical: Dimensions.paddingSizeDefault,
//           ),
//           child: Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: List.generate(items.length, (index) {
//               final isSelected = orderController.selectedInstruction == index;
//
//               return Container(
//                 key: keys[index],
//                 width: tileWidth,
//                 height: orderController.maxTileHeight != null
//                     ? orderController.maxTileHeight!.toDouble()
//                     : null, // <- APPLY GLOBAL HEIGHT
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? Theme.of(context).primaryColor
//                       : Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       index == 0
//                           ? Icons.door_front_door_outlined
//                           : index == 1
//                           ? Icons.business
//                           : index == 2
//                           ? Bootstrap.whatsapp
//                           : Icons.pets,
//                       size: 20,
//                       color: isSelected ? Colors.white : Colors.grey.shade800,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       items[index].tr,
//                       textAlign: TextAlign.center,
//                       maxLines: 10,
//                       overflow: TextOverflow.visible,
//                       style: robotoMedium.copyWith(
//                         fontSize: 12,
//                         color: isSelected ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         );
//       },
//     );
//   }

// Widget build(BuildContext context) {
  //   final double tileWidth = (Get.width - (Dimensions.paddingSizeDefault*6)) / 4;
  //   return GetBuilder<CheckoutController>(
  //     builder: (orderController) {
  //       return Container(
  //         width: Get.width,
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).cardColor,
  //           borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Theme.of(context).primaryColor.withOpacity(0.05),
  //               blurRadius: 10,
  //             ),
  //           ],
  //         ),
  //         padding: const EdgeInsets.symmetric(
  //           horizontal: Dimensions.paddingSizeDefault,
  //           vertical: Dimensions.paddingSizeDefault,
  //         ),
  //         child: Wrap(
  //           spacing: 12,
  //           runSpacing: 12,
  //           children: List.generate(AppConstants.deliveryInstructionList.length, (index) {
  //             bool isSelected = orderController.selectedInstruction == index;
  //
  //             return IntrinsicHeight( // each tile matches height of largest tile
  //               child: Container(
  //                 width: tileWidth, // all tiles same width
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: isSelected
  //                       ? Theme.of(context).primaryColor
  //                       : Colors.grey.shade200,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(
  //                       index == 0
  //                           ? Icons.door_front_door_outlined
  //                           : index == 1
  //                           ? Icons.business
  //                           : index == 2
  //                           ? Bootstrap.whatsapp
  //                           : Icons.pets,
  //                       size: 20,
  //                       color: isSelected ? Colors.white : Colors.grey.shade800,
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Flexible(
  //                       child: Text(
  //                         AppConstants.deliveryInstructionList[index].tr,
  //                         textAlign: TextAlign.center,
  //                         maxLines: 10,
  //                         overflow: TextOverflow.visible,
  //                         style: robotoMedium.copyWith(
  //                           fontSize: 12,
  //                           color: isSelected ? Colors.white : Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }),
  //         ),
  //       );
  //     },
  //   );
  //
  //   // return Container(
  //   //   width: Get.width,
  //   //   decoration: BoxDecoration(
  //   //     color: Theme.of(context).cardColor,
  //   //     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
  //   //     boxShadow: [
  //   //       BoxShadow(
  //   //           color: Theme.of(context).primaryColor.withOpacity(0.05),
  //   //           blurRadius: 10)
  //   //     ],
  //   //   ),
  //   //   padding: const EdgeInsets.symmetric(
  //   //       horizontal: Dimensions.paddingSizeLarge,
  //   //       vertical: Dimensions.paddingSizeExtraSmall),
  //   //   child: GetBuilder<CheckoutController>(
  //   //     builder: (orderController) {
  //   //       return Column(
  //   //         crossAxisAlignment: CrossAxisAlignment.start,
  //   //         children: [
  //   //           Text('add_more_delivery_instruction'.tr, style: robotoMedium),
  //   //           Padding(
  //   //             padding: const EdgeInsets.symmetric(vertical: 4.0),
  //   //             child: Container(
  //   //               height: 126,
  //   //               child: ListView.builder(
  //   //                 shrinkWrap: true,
  //   //                 physics: const ScrollPhysics(),
  //   //                 scrollDirection: Axis.horizontal,
  //   //                 itemCount: AppConstants.deliveryInstructionList.length,
  //   //                 itemBuilder: (context, index) {
  //   //                   bool isSelected =
  //   //                       orderController.selectedInstruction == index;
  //   //                   return InkWell(
  //   //                     onTap: () {
  //   //                       orderController.setInstruction(index);
  //   //                       if (controller.isExpanded) {
  //   //                         controller.collapse();
  //   //                       }
  //   //                     },
  //   //                     child: Container(
  //   //                       width: 80,
  //   //                       height: 120,
  //   //                       margin: const EdgeInsets.all(8),
  //   //                       decoration: BoxDecoration(
  //   //                         color: isSelected
  //   //                             ? Theme.of(context)
  //   //                             .primaryColor
  //   //                             .withOpacity(0.5)
  //   //                             : Colors.grey[200],
  //   //                         borderRadius: BorderRadius.circular(8),
  //   //                       ),
  //   //                       padding: const EdgeInsets.all(8),
  //   //                       child: Column(
  //   //                         children: [
  //   //                           Align(
  //   //                             alignment: Alignment.topRight,
  //   //                             child: Stack(
  //   //                               children: [
  //   //                                 Icon(
  //   //                                   index == 0
  //   //                                       ? Icons.door_front_door_outlined
  //   //                                       : index == 1
  //   //                                       ? Icons.business
  //   //                                       : index == 2
  //   //                                       ? Bootstrap.whatsapp
  //   //                                       : Icons.pets,
  //   //                                   color: isSelected
  //   //                                       ? Theme.of(context).primaryColor
  //   //                                       : Colors.black,
  //   //                                  size: 18,
  //   //                                  // Optionally set width too
  //   //                                 )
  //   //
  //   //                                 // Icon(
  //   //                                 //   index == 0
  //   //                                 //       ? Icons.door_front_door_outlined
  //   //                                 //       : index == 1
  //   //                                 //           ? Icons.maps_home_work_outlined
  //   //                                 //           : index == 2
  //   //                                 //               ? Icons.do_not_disturb
  //   //                                 //               : Icons.do_not_step_sharp,
  //   //                                 //   color: isSelected
  //   //                                 //       ? Theme.of(context).primaryColor
  //   //                                 //       : Colors.black,
  //   //                                 //   size: 18,
  //   //                                 // ),
  //   //                               ],
  //   //                             ),
  //   //                           ),
  //   //                           const SizedBox(height: 8),
  //   //                           Expanded(
  //   //                             child: Center(
  //   //                               child: Text(
  //   //                                 AppConstants
  //   //                                     .deliveryInstructionList[index].tr,
  //   //                                 style: robotoMedium.copyWith(fontSize: 12),
  //   //                                 maxLines: 4,
  //   //                                 overflow: TextOverflow.ellipsis,
  //   //                               ),
  //   //                             ),
  //   //                           ),
  //   //                         ],
  //   //                       ),
  //   //                     ),
  //   //                   );
  //   //                 },
  //   //               ),
  //   //             ),
  //   //           ),
  //   //         ],
  //   //       );
  //   //     },
  //   //   ),
  //   // );
  // }
class DeliveryInstructionView extends StatefulWidget {
  const DeliveryInstructionView({super.key});

  @override
  State<DeliveryInstructionView> createState() => _DeliveryInstructionViewState();
}

class _DeliveryInstructionViewState extends State<DeliveryInstructionView> {
  List<GlobalKey> _keys = [];
  double? _maxHeight;
  int selectedIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initKeys();
    _measureHeightsAfterBuild();
  }

  void _initKeys() {
    final itemCount = AppConstants.deliveryInstructionList.length;
    if (_keys.length != itemCount) {
      _keys = List.generate(itemCount, (_) => GlobalKey());
      _maxHeight = null;
    }
  }

  void _measureHeightsAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double tallest = 0;
      for (var key in _keys) {
        final ctx = key.currentContext;
        if (ctx != null) {
          final size = ctx.size;
          if (size != null && size.height > tallest) {
            tallest = size.height;
          }
        }
      }
      if (tallest != _maxHeight) {
        setState(() => _maxHeight = tallest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const columns = 4;
    final itemCount = AppConstants.deliveryInstructionList.length;

    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(itemCount, (index) {
          final label = AppConstants.deliveryInstructionList[index].tr;
          final isSelected = selectedIndex == index;

          final icon = index == 0
              ? Icons.door_front_door_outlined
              : index == 1
              ? Icons.business
              : index == 2
              ? Bootstrap.whatsapp
              : Icons.pets;

          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              key: _keys[index],
              width: Get.width/4.7,
              height: _maxHeight,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                    style: robotoMedium.copyWith(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


class DeliveryInstructionView2 extends StatefulWidget {
  const DeliveryInstructionView2({super.key});

  @override
  State<DeliveryInstructionView2> createState() => _DeliveryInstructionView2State();
}

class _DeliveryInstructionView2State extends State<DeliveryInstructionView2> {
  List<GlobalKey> _keys = [];
  double? _maxHeight;
  int selectedIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initKeys();
    _measureHeightsAfterBuild();
  }

  void _initKeys() {
    final itemCount = AppConstants.deliveryInstructionList.length;
    if (_keys.length != itemCount) {
      _keys = List.generate(itemCount, (_) => GlobalKey());
      _maxHeight = null;
    }
  }

  void _measureHeightsAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double tallest = 0;
      for (var key in _keys) {
        final ctx = key.currentContext;
        if (ctx != null) {
          final size = ctx.size;
          if (size != null && size.height > tallest) {
            tallest = size.height;
          }
        }
      }
      if (tallest != _maxHeight) {
        setState(() => _maxHeight = tallest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const columns = 4;
    final itemCount = AppConstants.deliveryInstructionList.length;

    return Container(
      width: Get.width,
      padding: const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeSmall),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(itemCount, (index) {
          final label = AppConstants.deliveryInstructionList[index].tr;
          final isSelected = selectedIndex == index;

          final icon = index == 0
              ? Icons.door_front_door_outlined
              : index == 1
              ? Icons.business
              : index == 2
              ? Bootstrap.whatsapp
              : Icons.pets;

          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              key: _keys[index],
              width: Get.width/4.7,
              height: _maxHeight,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                    style: robotoMedium.copyWith(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
