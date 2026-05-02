import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/item_view.dart';
import 'package:handy_allinone/common/widgets/paginated_list_view.dart';
import 'package:handy_allinone/common/widgets/veg_filter_widget.dart';
import 'package:handy_allinone/features/store/widgets/bottom_cart_widget.dart';

class StoreItemSearchScreen extends StatefulWidget {
  final String? storeID;
  const StoreItemSearchScreen({super.key, required this.storeID});

  @override
  State<StoreItemSearchScreen> createState() => _StoreItemSearchScreenState();
}

class _StoreItemSearchScreenState extends State<StoreItemSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<StoreController>().initSearchData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(Dimensions.webMaxWidth, 100),
            child: Container(
              height: 75 + context.mediaQueryPadding.top, width: Dimensions.webMaxWidth,
              padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                color: Theme.of(context).primaryColor,
              ),
              alignment: Alignment.center,
              child: SizedBox(width: Dimensions.webMaxWidth,
                  height: 75,
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
                  ),
                  Expanded(child:
                  SearchWithMicField(controller: _searchController, store: widget.storeID.toString(),),
                  // TextField(
                  //   controller: _searchController,
                  //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  //   textInputAction: TextInputAction.search,
                  //   cursorColor: Theme.of(context).primaryColor,
                  //   textAlignVertical: TextAlignVertical.center,
                  //   decoration: InputDecoration(
                  //     hintText: 'search_item_in_store'.tr,
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                  //     isDense: true,
                  //     contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  //       borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1),
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  //       borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1),
                  //     ),
                  //     suffixIcon: IconButton(
                  //       icon: Icon(Icons.search, color: Theme.of(context).hintColor, size: 25),
                  //       onPressed: () => Get.find<StoreController>().getStoreSearchItemList(
                  //         _searchController.text.trim(), widget.storeID, 1, Get.find<StoreController>().searchType,
                  //       ),
                  //     ),
                  //   ),
                  //   onSubmitted: (text) => Get.find<StoreController>().getStoreSearchItemList(
                  //     _searchController.text.trim(), widget.storeID, 1, Get.find<StoreController>().searchType,
                  //   ),
                  // )
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),


                  VegFilterWidget(
                    type: storeController.searchText.isNotEmpty ? storeController.searchType : null,
                    onSelected: (String type) {
                      storeController.getStoreSearchItemList(storeController.searchText, widget.storeID, 1, type);
                    },
                    fromAppBar: true,
                  )

                ]),
              )),
            ),
          ),

          body: SingleChildScrollView(
            controller: _scrollController,
            padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: PaginatedListView(
              scrollController: _scrollController,
              onPaginate: (int? offset) => storeController.getStoreSearchItemList(
                storeController.searchText, widget.storeID, offset!, storeController.searchType,
              ),
              totalSize: storeController.storeSearchItemModel?.totalSize,
              offset: storeController.storeSearchItemModel?.offset,
              itemView: ItemsViewStore(
                  isStore: false, stores: null,
                  items: storeController.storeSearchItemModel?.items,
                  inStorePage: true, backButton: () {  },showfavourite: false,showbackbutton: false,
              ),
            ))),
          ),

          // bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          //   return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? Column(
          //     mainAxisAlignment: .end,
          //     crossAxisAlignment: .end,
          //     children: [
          //       Align(
          //         alignment: Alignment.centerRight,
          //         child: Padding(
          //           padding: EdgeInsets.only(
          //               left: 18.w, right: 18.w,bottom: 4.w),
          //           child: Container(
          //               decoration: BoxDecoration(
          //                 color: Colors.transparent,
          //                 borderRadius:
          //                 BorderRadius.circular(
          //                     15),
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Colors.lightGreenAccent
          //                         .withValues(alpha: 0.3),
          //                     spreadRadius: 1,
          //                     blurRadius: 3,
          //                     offset: const Offset(0,
          //                         2), // changes position of shadow
          //                   ),
          //                 ],
          //               ),
          //               child: BottomCartWidget()),
          //         ),
          //       ),
          //     ],
          //   ) : const SizedBox();
          // })

        );
      }
    );
  }
}
