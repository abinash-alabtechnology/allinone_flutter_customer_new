import 'package:flutter/material.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';

class DeliverItemCardWidget extends StatelessWidget {
  final String image;
  final String itemName;
  final String description;
  final bool isDeliverItem;
  final bool? sheet;
  const DeliverItemCardWidget(
      {super.key,
        required this.image,
        required this.itemName,
        required this.description,
        this.isDeliverItem = false,
        this.sheet = false,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: isDeliverItem
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Theme.of(context).cardColor,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 1, // How much the shadow spreads
            blurRadius: 6, // How blurred the shadow is
            offset: Offset(0, 3), // Shadow position (x, y)
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomImage(
              image: image,
              height:!sheet! ? 120 : 30,
              width: !sheet! ? 120 : 30,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium),
            SizedBox(
                height: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.paddingSizeSmall
                    : 0),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
          // Positioned(
          //   top: 0, // Adjust position as needed
          //   right: 0, // Adjust position as needed
          //   child: Container(
          //
          //     child: IconButton(
          //       icon: Icon(Icons.arrow_forward),
          //       onPressed: () {
          //         // Define the action you want to perform on button press
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// class DeliverItemCardWidget extends StatelessWidget {
//   final String image;
//   final String itemName;
//   final String description;
//   final bool isDeliverItem;
//   const DeliverItemCardWidget({super.key, required this.image, required this.itemName, required this.description, this.isDeliverItem = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//       decoration: BoxDecoration(
//         color: isDeliverItem ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Theme.of(context).cardColor.withValues(alpha: 0.5),
//         border: Border.all(color: isDeliverItem ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor),
//         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         CustomImage(
//           image: image,
//           height: 30, width: 30,
//         ),
//         const SizedBox(width: Dimensions.paddingSizeSmall),
//
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: ResponsiveHelper.isDesktop(context) ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, children: [
//             Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),
//             SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),
//
//             Text(
//               description,
//               maxLines: 2, overflow: TextOverflow.ellipsis,
//               style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
//             ),
//           ]),
//         ),
//
//       ]),
//     );
//   }
// }
