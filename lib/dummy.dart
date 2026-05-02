// import 'package:flutter/cupertino.dart';
//
// class Dummy extends StatefulWidget {
//   const Dummy({super.key});
//
//   @override
//   State<Dummy> createState() => _DummyState();
// }
//
// class _DummyState extends State<Dummy> {
//   @override
//   Widget build(BuildContext context) {
// return CustomScrollView(
//       controller: widget.scrollController,
//       physics: BouncingScrollPhysics(),
//       slivers: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 Positioned.fill(
//                   child: Image.asset(
//                     Images.doodleveg,
//                     fit: BoxFit.cover,
//                     color: Colors.grey.shade100,
//                     colorBlendMode: BlendMode.srcATop,
//                   ),
//                 ),
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Theme.of(context).primaryColor,
//                           Theme.of(context).primaryColor.withValues(alpha: 0.05),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SafeArea(
//                   child: Column(
//                     children: [
//                       const SizedBox(
//                         height: Dimensions.paddingSizeLarge,
//                       ),
//                       GetBuilder<SplashController>(builder: (splashController) {
//                         return Column(
//                           children: [
//                             Center(
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: SizedBox(
//                                   width: Dimensions.webMaxWidth,
//                                   height: Get.find<LocalizationController>().isLtr
//                                       ? 60
//                                       : 70,
//                                   child: Row(
//                                     children: [
//                                       (splashController.module != null &&
//                                               splashController
//                                                       .configModel!.module ==
//                                                   null)
//                                           ? InkWell(
//                                               onTap: () {
//                                                 splashController.removeModule();
//                                                 Get.find<StoreController>()
//                                                     .resetStoreData();
//                                               },
//                                               child: Image.asset(
//                                                 Images.homeIcon,
//                                                 height: 25,
//                                                 width: 25,
//                                                 color: Colors.white,
//                                               ),
//                                             )
//                                           : const SizedBox(),
//                                       SizedBox(
//                                         width: (splashController.module != null &&
//                                                 splashController
//                                                         .configModel!.module ==
//                                                     null)
//                                             ? Dimensions.paddingSizeSmall
//                                             : 0,
//                                       ),
//                                       Expanded(
//                                         child: InkWell(
//                                           onTap: () =>
//                                               Get.find<LocationController>()
//                                                   .navigateToLocationScreen(
//                                                       'home'),
//                                           child: GetBuilder<LocationController>(
//                                             builder: (locationController) {
//                                               return Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     AuthHelper.isLoggedIn()
//                                                         ? AddressHelper
//                                                                 .getUserAddressFromSharedPref()!
//                                                             .addressType!
//                                                             .tr
//                                                         : 'your_location'.tr,
//                                                     style: robotoMedium.copyWith(
//                                                       fontSize: Dimensions
//                                                           .fontSizeDefault,
//                                                       color: Colors.white,
//                                                     ),
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                   Row(
//                                                     children: [
//                                                       Flexible(
//                                                         child: Text(
//                                                           AddressHelper
//                                                                   .getUserAddressFromSharedPref()!
//                                                               .address!,
//                                                           style: robotoRegular
//                                                               .copyWith(
//                                                             fontSize: Dimensions
//                                                                 .fontSizeSmall,
//                                                             color: Colors.white
//                                                                 .withAlpha(
//                                                                     (255 * 0.85)
//                                                                         .round()),
//                                                           ),
//                                                           maxLines: 1,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                       Icon(Icons.expand_more,
//                                                           size: 18,
//                                                           color: Colors.white),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       InkWell(
//                                         child: GetBuilder<NotificationController>(
//                                           builder: (notificationController) {
//                                             return Stack(
//                                               children: [
//                                                 CircleAvatar(
//                                                   backgroundColor: Colors.white
//                                                       .withAlpha(
//                                                           (255 * 0.12).round()),
//                                                   child: Icon(
//                                                     CupertinoIcons.bell,
//                                                     size: 20,
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                                 notificationController
//                                                         .hasNotification
//                                                     ? Positioned(
//                                                         top: 0,
//                                                         right: 0,
//                                                         child: Container(
//                                                           height: 10,
//                                                           width: 10,
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             color: Colors.white,
//                                                             shape:
//                                                                 BoxShape.circle,
//                                                           ),
//                                                         ),
//                                                       )
//                                                     : const SizedBox(),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                         onTap: () => Get.toNamed(
//                                             RouteHelper.getNotificationRoute()),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: Dimensions.paddingSizeDefault),
//                             Container(
//                               height: 50,
//                               width: Dimensions.webMaxWidth,
//                               color: Colors.transparent,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: Dimensions.paddingSizeSmall),
//                               child: InkWell(
//                                 onTap: () =>
//                                     Get.toNamed(RouteHelper.getSearchRoute()),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: Dimensions.paddingSizeSmall),
//                                   margin: const EdgeInsets.symmetric(vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).cardColor,
//                                     border: Border.all(
//                                       color: Theme.of(context)
//                                           .primaryColor
//                                           .withOpacity(0.2),
//                                       width: 1,
//                                     ),
//                                     borderRadius: BorderRadius.circular(30),
//                                     boxShadow: const [
//                                       BoxShadow(
//                                         color: Colors.black12,
//                                         blurRadius: 5,
//                                         spreadRadius: 1,
//                                       )
//                                     ],
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: <Widget>[
//                                             const SizedBox(
//                                                 width: 10.0, height: 100.0),
//                                             Text(
//                                               'Search for',
//                                               style: robotoRegular.copyWith(
//                                                 fontSize:
//                                                     Dimensions.fontSizeLarge,
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                                 width: 5, height: 100.0),
//                                             GetBuilder<CategoryController>(
//                                               builder: (categoryController) {
//                                                 if (categoryController
//                                                             .categoryList !=
//                                                         null &&
//                                                     categoryController
//                                                         .categoryList!
//                                                         .isNotEmpty) {
//                                                   return AnimatedTextKit(
//                                                     repeatForever: true,
//                                                     animatedTexts:
//                                                         categoryController
//                                                             .categoryList!
//                                                             .map((category) =>
//                                                                 RotateAnimatedText(
//                                                                   ("${(category.name?.capitalizeFirst)}"),
//                                                                   textStyle:
//                                                                       robotoRegular
//                                                                           .copyWith(
//                                                                     fontSize:
//                                                                         Dimensions
//                                                                             .fontSizeLarge,
//                                                                     color: Theme.of(
//                                                                             context)
//                                                                         .primaryColor,
//                                                                   ),
//                                                                 ))
//                                                             .toList(),
//                                                   );
//                                                 } else {
//                                                   return const Text(
//                                                       'Loading categories...');
//                                                 }
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                           width:
//                                               Dimensions.paddingSizeExtraSmall),
//                                       Icon(
//                                         CupertinoIcons.search,
//                                         size: 25,
//                                         color: Theme.of(context).disabledColor,
//                                       ),
//                                       const SizedBox(
//                                           width:
//                                               Dimensions.paddingSizeExtraSmall),
//                                       const SizedBox(
//                                           width: Dimensions.paddingSizeExtraSmall,
//                                           child: Padding(
//                                             padding: EdgeInsets.symmetric(
//                                                 vertical: 6.0),
//                                             child: VerticalDivider(
//                                               color: Colors.grey,
//                                               width: 2,
//                                             ),
//                                           )),
//                                       const SizedBox(
//                                           width:
//                                               Dimensions.paddingSizeExtraSmall),
//                                       Icon(
//                                         CupertinoIcons.mic,
//                                         size: 25,
//                                         color: Theme.of(context).primaryColor,
//                                       ),
//                                       const SizedBox(
//                                           width:
//                                               Dimensions.paddingSizeExtraSmall),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: Dimensions.paddingSizeDefault),
//                           ],
//                         );
//                       }),
//                       const BannerView(isFeatured: false),
//                       const SizedBox(
//                         height: Dimensions.paddingSizeLarge,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const CategoryViewGrocery(),
//             const SizedBox(
//               height: Dimensions.paddingSizeDefault,
//             ),
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFFE8F5E9),
//                     Colors.white,
//                     Color(0xFFC8E6C9),
//                   ],
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 12.0),
//                 child: Column(
//                   children: [
//                     TitleWidget1(
//                       title: "Lowest Prices",
//                       title1: " on Exotic",
//                       onTap: () => Get.toNamed(
//                           RouteHelper.getItemViewAllScreen(false, true)),
//                     ),
//                     const SizedBox(
//                       height: Dimensions.paddingSizeDefault,
//                     ),
//                     GetBuilder<ItemController>(builder: (itemController) {
//                       List<Item>? discountedItemList =
//                           itemController.discountedItemList;
//                       return discountedItemList != null
//                           ? discountedItemList.isNotEmpty
//                               ? SizedBox(
//                                   height: 270,
//                                   width: Get.width,
//                                   child: ListView.builder(
//                                     primary: false,
//                                     scrollDirection: Axis.horizontal,
//                                     physics: const ClampingScrollPhysics(),
//                                     padding: const EdgeInsets.only(
//                                         bottom: Dimensions.paddingSizeSmall,
//                                         left: Dimensions.paddingSizeDefault),
//                                     itemCount: discountedItemList.length,
//                                     itemBuilder: (context, index) {
//                                       return Padding(
//                                         padding: const EdgeInsets.only(
//                                           right: 8.0,
//                                           left: 8.0,
//                                         ),
//                                         child: Get.find<ItemController>()
//                                                 .isAvailable(
//                                                     discountedItemList[index])
//                                             ? ItemCardGrocery(
//                                                 item: discountedItemList[index],
//                                                 isPopularItem: true,
//                                                 isShop: true,
//                                                 index: index,
//                                                 isFood: false,
//                                               )
//                                             : const SizedBox.shrink(),
//                                       );
//                                     },
//                                   ),
//                                 )
//                               : const SizedBox()
//                           : const ItemShimmerView(isPopularItem: false);
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: Dimensions.paddingSizeDefault,),
//             GetBuilder<CategoryController>(
//               builder: (categoryController) {
//                 final categories = categoryController.categoryList ?? [];
//                 if (categories.isEmpty) return const SizedBox();
//                 return SizedBox(
//                   height: 45,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     itemCount: categories.length,
//                     separatorBuilder: (_, __) => const SizedBox(width: 12),
//                     itemBuilder: (context, index) {
//                       final category = categories[index];
//                       return GestureDetector(
//                         onTap: (){
//                           categoryController.setSelectedCategory(category.id ?? -1);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
//                           decoration: BoxDecoration(
//                               color: Colors.purple.shade100,
//                               borderRadius: BorderRadius.circular(20)),
//                           child: Row(
//                             children: [
//                               Text(
//                                 category.name ?? "",
//                                 textAlign: TextAlign.center,
//                                 style: robotoBold.copyWith(fontSize: 11,),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(width: 10),
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(40),
//                                 child: CustomImage(
//                                   image: category.imageFullUrl ?? "",
//                                   height: 40,
//                                   width: 40,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             const CategoryListScreen(),
//             AllStoreFilterWidget(),
//             GetBuilder<StoreController>(
//               builder: (storeController) {
//                 return Padding(
//                   padding: EdgeInsets.only(
//                       bottom: ResponsiveHelper
//                           .isDesktop(
//                           context)
//                           ? 0
//                           : 0),
//                   child:
//                   PaginatedListView(
//                     scrollController:
//                     widget.scrollController,
//                     totalSize:
//                     storeController
//                         .storeModel
//                         ?.totalSize,
//                     offset:
//                     storeController
//                         .storeModel
//                         ?.offset,
//                     onPaginate: (int?
//                     offset) async =>
//                     await storeController
//                         .getStoreList(
//                         offset!,
//                         false),
//                     itemView: ItemsViewFood(
//                       isStore:
//                       true,
//                       items: null,
//                       isFoodOrGrocery:true,
//                       stores: storeController
//                           .storeModel
//                           ?.stores,
//                       padding:
//                       EdgeInsets
//                           .symmetric(
//                         horizontal: ResponsiveHelper.isDesktop(
//                             context)
//                             ? Dimensions
//                             .paddingSizeExtraSmall
//                             : Dimensions
//                             .paddingSizeSmall,
//                         vertical: ResponsiveHelper.isDesktop(
//                             context)
//                             ? Dimensions
//                             .paddingSizeExtraSmall
//                             : Dimensions
//                             .paddingSizeExtraSmall,
//                         // vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//     }
// }
