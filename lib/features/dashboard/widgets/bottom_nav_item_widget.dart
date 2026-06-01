import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/util/styles.dart';

// class BottomNavItemWidget extends StatelessWidget {
//   final String selectedIcon;
//   final String unSelectedIcon;
//   final String title;
//   final Function? onTap;
//   final bool isSelected;
//   const BottomNavItemWidget({super.key, this.onTap, this.isSelected = false, required this.title, required this.selectedIcon, required this.unSelectedIcon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap as void Function()?,
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//
//           Image.asset(
//             isSelected ? selectedIcon : unSelectedIcon, height: 25, width: 25,
//             color: isSelected ? Theme.of(context).primaryColor : Colors.black,
//           ),
//
//           SizedBox(height: isSelected ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),
//
//           Text(
//             title,
//             style: robotoRegular.copyWith(color: isSelected ? Theme.of(context).primaryColor : Colors.black, fontSize: 12),
//           ),
//
//         ]),
//       ),
//     );
//   }
// }
// class BottomNavItemWidget extends StatelessWidget {
//   final String selectedIcon;
//   final String unSelectedIcon;
//   final String title;
//   final Function? onTap;
//   final bool isSelected;
//
//   const BottomNavItemWidget({
//     super.key,
//     this.onTap,
//     this.isSelected = false,
//     required this.title,
//     required this.selectedIcon,
//     required this.unSelectedIcon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap as void Function()?,
//       child:AnimatedContainer(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOutCubic,
//         width: isSelected ? 130 : 50,
//         height: GetPlatform.isIOS ? 50 : 45,
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Theme.of(context).primaryColor
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: isSelected
//               ? [
//             BoxShadow(
//               color: Theme.of(context)
//                   .primaryColor
//                   .withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ]
//               : [],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, anim) => ScaleTransition(
//                 scale: anim,
//                 child: child,
//               ),
//               child: CustomAssetImageWidget(
//                 isSelected ? selectedIcon : unSelectedIcon,
//                 key: ValueKey(isSelected),
//                 height: 25,
//                 width: 25,
//                 color: isSelected
//                     ? Theme.of(context).cardColor
//                     : Theme.of(context).primaryColor,
//               ),
//             ),
//             AnimatedSize(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               child: isSelected
//                   ? Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Text(
//                   title,
//                   style: robotoBold.copyWith(
//                     color: Theme.of(context).cardColor,
//                     fontSize: 14,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               )
//                   : const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final IconData? icon;
  final String title;
  final Function? onTap;
  final bool isSelected;
  final Color? activeColor;

  const BottomNavItemWidget({
    super.key,
    this.onTap,
    this.isSelected = false,
    required this.title,
    required this.selectedIcon,
    required this.unSelectedIcon,
    this.icon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double widthFactor = size.width / 430; // base width reference
    final double heightFactor = size.height / 932; // base height reference

    final double iconSize = 28 * widthFactor.clamp(0.8, 1.2);
    final double textSize = 12 * widthFactor.clamp(0.8, 1.1);
    final double containerHeight =
        (GetPlatform.isIOS ? 90 : 73) * heightFactor.clamp(0.9, 1.1);

    final Color primaryColor = activeColor ?? Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap as void Function()?,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 40),
        curve: Curves.easeInOutCubic,
        height: containerHeight,
        decoration: BoxDecoration(
          color:
          isSelected ? primaryColor.withAlpha(15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 30),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: icon != null
                    ? Icon(
                        icon,
                        key: ValueKey(isSelected),
                        size: iconSize,
                        color: isSelected ? primaryColor : Colors.black,
                      )
                    : CustomAssetImageWidget(
                        isSelected ? selectedIcon : unSelectedIcon,
                        key: ValueKey(isSelected),
                        height: iconSize,
                        width: iconSize,
                        color: isSelected
                            ? primaryColor
                            : Colors.black,
                      ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 30),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: EdgeInsets.only(left: 2 * widthFactor),
                  child: Text(
                    title,
                    style: robotoBold.copyWith(
                      color:Colors.grey.shade700,
                      fontSize: textSize,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}