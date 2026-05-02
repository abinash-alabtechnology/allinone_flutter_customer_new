import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

// void showCategoryPopup(BuildContext context, StoreController storeController, GlobalKey<State<StatefulWidget>> menuKey) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     builder: (context) {
//       if (storeController.categoryList == null ||
//           storeController.categoryList!.isEmpty) {
//         return Container();
//       }
//       final totalItemCount = storeController.storeItemModel?.countData
//               ?.fold<int>(0, (sum, count) => sum + (count.productCount ?? 0)) ??
//           0;
//       return Stack(
//         children: [
//           Align(
//             alignment: Alignment.bottomRight,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 10, right: 10),
//               child: Material(
//                 color: Colors.white,
//                 elevation: 5,
//                 borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                 child: Container(
//                   width: 250, // Fixed width for a smaller view
//                   height: 360, // Static height of 400
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: storeController.categoryList?.length ?? 0,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: Dimensions.paddingSizeSmall,
//                     ),
//                     itemBuilder: (context, index) {
//                       final categoryId =
//                           storeController.categoryList![index].id;
//
//                       // Get the count for the current category from countData
//                       final countData =
//                           storeController.storeItemModel?.countData;
//                       final categoryCount = countData
//                               ?.firstWhere(
//                                   (count) =>
//                                       count.categoryName ==
//                                       storeController.categoryList![index].name,
//                                   orElse: () => CountData(
//                                       categoryName: storeController
//                                           .categoryList![index].name,
//                                       productCount:
//                                           0)) // Default to 0 if not found
//                               .productCount ??
//                           0;
//
//                       return InkWell(
//                         onTap: () {
//                           storeController.setCategoryIndex(index);
//                           Navigator.pop(
//                               context); // Close the popup after selecting
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: Dimensions.paddingSizeSmall,
//                             vertical: Dimensions.paddingSizeExtraSmall,
//                           ),
//                           decoration: BoxDecoration(
//                             color: index == storeController.categoryIndex
//                                 ? Theme.of(context)
//                                     .primaryColor
//                                     .withOpacity(0.1)
//                                 : Colors.transparent,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 '${storeController.categoryList![index].name!}',
//                                 style: index == storeController.categoryIndex
//                                     ? robotoBold.copyWith(
//                                         fontSize: Dimensions.fontSizeExtraLarge,
//                                         color: Theme.of(context).primaryColor,
//                                       )
//                                     : robotoBold.copyWith(
//                                         fontSize: Dimensions.fontSizeExtraLarge,
//                                       ),
//                               ),
//                               Text(
//                                 index == 0
//                                     ? '$totalItemCount' // Display total item count in the first category
//                                     : '$categoryCount', // Show only category count for the rest
//                                 style: index == storeController.categoryIndex
//                                     ? robotoBold.copyWith(
//                                         fontSize: Dimensions.fontSizeExtraLarge,
//                                         color: Theme.of(context).primaryColor,
//                                       )
//                                     : robotoBold.copyWith(
//                                         fontSize: Dimensions.fontSizeExtraLarge,
//                                       ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: MediaQuery.sizeOf(context).height -
//                 420, // Adjust button position based on static height
//             right: 115,
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Theme.of(context).primaryColor.withOpacity(0.5),
//               ),
//               child: IconButton(
//                 icon: Icon(Icons.close),
//                 iconSize: 28.0,
//                 color: Theme.of(context).cardColor,
//                 onPressed: () {
//                   Navigator.pop(context); // Close the popup
//                 },
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
void showCategoryPopup(
  BuildContext context,
  StoreController storeController,
  GlobalKey key,
) {
  final RenderBox buttonBox =
      key.currentContext!.findRenderObject() as RenderBox;
  final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
  final Size buttonSize = buttonBox.size;

  OverlayEntry? overlayEntry;
  void removeOverlay() {
    if (overlayEntry != null) {
      try {
        overlayEntry!.remove();
      } catch (e) {
        debugPrint('⚠️ Overlay already removed: $e');
      } finally {
        overlayEntry = null;
      }
    }
  }
  final overlayState = Overlay.of(context);

  overlayEntry = OverlayEntry(
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      const double verticalMargin = 10;
      final double availableHeight = buttonPosition.dy - verticalMargin;
      final double bottomPosition = kIsWeb
          ? (screenHeight - (buttonPosition.dy + buttonSize.height))
          : screenHeight - (buttonPosition.dy + buttonSize.height);

      return Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: removeOverlay,
          ),
          Positioned(
            bottom: bottomPosition,
            right: MediaQuery.of(context).size.width -
                (buttonPosition.dx + buttonSize.width),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: availableHeight,
                  minWidth: 270,
                  maxWidth: 270,
                ),
                child: GetBuilder<StoreController>(
                  builder: (controller) {
                    final totalItems = controller.categoryList?.length ?? 0;
                    final totalItemCount = controller.storeItemModel?.countData
                            ?.fold<int>(
                                0,
                                (sum, count) =>
                                    sum + (count.productCount ?? 0)) ??
                        0;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall,
                                  ),
                                  physics: totalItems * 50 >
                                          constraints.maxHeight
                                      ? const BouncingScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  itemCount: totalItems,
                                  itemBuilder: (context, index) {
                                    final countData =
                                        controller.storeItemModel?.countData;
                                    final categoryCount = countData
                                            ?.firstWhere(
                                              (count) =>
                                                  count.categoryName ==
                                                  controller
                                                      .categoryList![index]
                                                      .name,
                                              orElse: () => CountData(
                                                categoryName: controller
                                                    .categoryList![index].name,
                                                productCount: 0,
                                              ),
                                            )
                                            .productCount ??
                                        0;

                                    return InkWell(
                                      onTap: () {
                                        controller.setSearching(false);
                                        controller.setCategoryIndex(index);
                                        overlayEntry?.remove();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical: Dimensions.paddingSizeSmall,
                                        ),
                                        color: index == controller.categoryIndex
                                            ? Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1)
                                            : Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              controller
                                                  .categoryList![index].name!,
                                              style: index ==
                                                      controller.categoryIndex
                                                  ? robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                    )
                                                  : robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                            controller.isLoading
                                                ? const SizedBox(
                                              height: 14,
                                              width: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // custom color
                                              ),
                                            )
                                                : AnimatedFlipCounter(
                                                    duration: const Duration(
                                                        milliseconds: 900),
                                                    value: index == 0
                                                        ? totalItemCount
                                                        : categoryCount,
                                                    curve: Curves.easeOutBack,
                                                    textStyle: index ==
                                                            controller
                                                                .categoryIndex
                                                        ? robotoMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                          )
                                                        : robotoMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                            color: Colors.white,
                                                          ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  if (overlayEntry != null) {
    overlayState.insert(overlayEntry!);
  } else {
    debugPrint('⚠️ Overlay state not found. Popup not inserted.');
  }}
