import 'package:flutter/material.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
class StoreFilterButtonWidget extends StatelessWidget {
  const StoreFilterButtonWidget({super.key, this.isSelected, this.onTap, required this.buttonText, required this.iconsnew});

  final bool? isSelected;
  final void Function()? onTap;
  final String buttonText;
  final IconData? iconsnew;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            // border: Border.all(
            //   color: isSelected == true
            //       ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
            //       : Theme.of(context).disabledColor.withValues(alpha: 0.3),
            // ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.08), // soft shadow
            //     blurRadius: 6, // spread of the shadow
            //     offset: const Offset(0, 3), // horizontal, vertical offset
            //   ),
            // ],
          ),
          child: Center(
            child: Row(
              children: [
                Text(
                  buttonText,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: isSelected == true ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected == true
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(width: 5,),
                Icon(
                  iconsnew??Icons.all_out_sharp,
                  color: isSelected == true
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,)
              ],
            ),
          ),
        ),
      ),

    );
  }
}

// class StoreFilterButtonWidget extends StatelessWidget {
//   const StoreFilterButtonWidget({super.key, this.isSelected, this.onTap, required this.buttonText});
//
//   final bool? isSelected;
//   final void Function()? onTap;
//   final String buttonText;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 45,
//         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//           border: Border.all(
//             color: isSelected == true
//                 ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
//                 : Theme.of(context).disabledColor.withValues(alpha: 0.3),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08), // soft shadow
//               blurRadius: 6, // spread of the shadow
//               offset: const Offset(0, 3), // horizontal, vertical offset
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             buttonText,
//             style: robotoRegular.copyWith(
//               fontSize: Dimensions.fontSizeDefault,
//               fontWeight: isSelected == true ? FontWeight.w500 : FontWeight.w400,
//               color: isSelected == true
//                   ? Theme.of(context).primaryColor
//                   : Theme.of(context).disabledColor,
//             ),
//           ),
//         ),
//       ),
//
//     );
//   }
// }
