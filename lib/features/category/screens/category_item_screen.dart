import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/cart_widget.dart';
import 'package:handy_allinone/common/widgets/item_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/veg_filter_widget.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/card_design/store_card_with_distance.dart';
import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../common/widgets/item_shimmer.dart';
import '../../../common/widgets/item_widget.dart';
import '../../../common/widgets/no_data_screen.dart';
import '../../../common/widgets/web_item_widget.dart';
import '../../../util/images.dart';
import '../../home/widgets/web/widgets/store_card_widget.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen({super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen> {
  final ScrollController scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catController = Get.find<CategoryController>();
      catController.setRestaurant(false); // Set store mode to false so we fetch items
      catController.getSubCategoryList(widget.categoryID); // Now respects isStore=false
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryItemList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      if(catController.isSearching ? catController.searchItemList != null : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if(catController.isSearching) {
            catController.toggleSearch();
          }else {
            return;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
            elevation: 2,
            title: catController.isSearching ? SizedBox(
              height: 45,
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide(color: Theme.of(context).disabledColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide(color: Theme.of(context).disabledColor),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => catController.toggleSearch(),
                    icon: Icon(
                      catController.isSearching ? Icons.close_sharp : Icons.search,
                      color:Theme.of(context).cardColor,
                    ),
                  ),
                ),
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color:Theme.of(context).cardColor,),
                onSubmitted: (String query) {
                  catController.searchData(
                    query, catController.subCategoryIndex == 0 ? widget.categoryID
                      : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                    catController.type,
                  );
                }
              ),
            ) : Text(widget.categoryName, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge, color:Theme.of(context).cardColor,
            )),
            centerTitle: false,
            leading: IconButton(
              icon:  Icon(Icons.arrow_back_ios,color:Theme.of(context).cardColor,),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else {
                  Get.back();
                }
              },
            ),
            actions: [

              !catController.isSearching ? IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? Icons.close_sharp : Icons.search,
                  color:Theme.of(context).cardColor,
                ),
              ) : const SizedBox(),

              IconButton(
                onPressed: () {
                  Get.find<CartController>().getCartDataOnline();
                  Get.toNamed(RouteHelper.getCartRoute());
                },
                icon: CartWidget(color:Theme.of(context).cardColor, size: 25),
              ),

              VegFilterWidget(type: catController.type, fromAppBar: true, onSelected: (String type) {
                if(catController.isSearching) {
                  catController.searchData(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString(), '1', type,
                  );
                }else {
                  catController.getCategoryItemList(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                  );
                }
              }),

              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
          )),
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: ResponsiveHelper.isDesktop(context) ?
          SingleChildScrollView(
            child: FooterView(
              child: Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(children: [

                  (catController.subCategoryList != null && !catController.isSearching) ? Center(child: Container(
                    height: 40, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: ListView.builder(
                      key: scaffoldKey,
                      scrollDirection: Axis.horizontal,
                      itemCount: catController.subCategoryList!.length,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                catController.subCategoryList![index].name!,
                                style: index == catController.subCategoryIndex
                                    ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                    : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  )) : const SizedBox(),

                  SingleChildScrollView(
                    controller: scrollController,
                    child: ItemsViewStore(
                      isStore: false, items: item, stores: null, noDataText: 'no_category_item_found'.tr, backButton: () {  },
                    ),
                  ),

                  catController.isLoading ? Center(child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                  )) : const SizedBox(),

                ]),
              )),
            ),
          ) : SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(children: [

              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Container(height: double.infinity,width: 90,
                        decoration: BoxDecoration(
                          color:Colors.grey.withValues(alpha: 0.1),
                          border:Border(
                            right: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child:
                        (catController.subCategoryList != null && !catController.isSearching) ? Container(
                          height: 40, width:double.infinity, color: Theme.of(context).cardColor,
                          child: ListView.builder(
                            key: scaffoldKey,
                            scrollDirection: Axis.vertical,
                            itemCount: catController.subCategoryList!.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.only(right: 2,left: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    border: Border.all(
                                      color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor: Colors.transparent,
                                    ),
                                    color: index == catController.subCategoryIndex ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Colors.transparent,
                                  ),
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const SizedBox(height: 10,),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: index == 0
                                          ? Container(
                                              height: 70,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: index == catController.subCategoryIndex
                                                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                                    : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.grid_view_rounded,
                                                size: 32,
                                                color: index == catController.subCategoryIndex
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey.shade600,
                                              ),
                                            )
                                          : CustomImage(
                                              image: catController.subCategoryList![index].imageFullUrl ?? "",
                                              height: 70,
                                              width: 80,
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Text(
                                      catController.subCategoryList![index].name!,
                                      textAlign: TextAlign.center,
                                      style: index == catController.subCategoryIndex
                                          ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                          : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          ),
                        ) : const SizedBox(),

                      ),
                    ),

                    Expanded(
                      child: Container(
                       height: double.infinity,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ItemsViewCategory(
                                isStore: false, items: item, stores: null, noDataText: 'no_category_item_found'.tr, backButton: () {  },
                                showbackbutton: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              catController.isLoading ? Center(child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : const SizedBox(),

            ]),
          ),
        ),
      );
    });
  }
}


class ItemsViewCategory extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final bool isFeatured;
  final bool? isFoodOrGrocery;
  final VoidCallback backButton;
  final bool? showbackbutton;
  final bool? showfavourite;

  const ItemsViewCategory({super.key, required this.stores, required this.items, required this.isStore, this.isScrollable = false,
    this.shimmerLength = 20, this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault), this.noDataText,
    this.isCampaign = false, this.inStorePage = false, this.isFeatured = false,
    this.isFoodOrGrocery = true, required this.backButton, this.showbackbutton = true,this.showfavourite=false});

  @override
  State<ItemsViewCategory> createState() => _ItemsViewCategoryState();
}

class _ItemsViewCategoryState extends State<ItemsViewCategory> {
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if(widget.isStore) {
      isNull = widget.stores == null;
      if(!isNull) {
        length = widget.stores!.length;
      }
    }else {
      isNull = widget.items == null;
      if(!isNull) {
        length = widget.items!.length;
      }
    }



    return Column(
      mainAxisAlignment: .center, crossAxisAlignment: .center,
        children: [
      !isNull ? length > 0 ?
      Align(
        alignment: Alignment.topCenter,
        child: GridView.builder(
          key: UniqueKey(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : widget.stores != null ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeSmall,
            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : widget.stores != null && widget.isStore ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
            mainAxisExtent: ResponsiveHelper.isDesktop(context) && widget.isStore ? 220
                : ResponsiveHelper.isMobile(context) ? widget.stores != null && widget.isStore ? 200 : 280
                : ResponsiveHelper.isDesktop(context) ? 300 : 280,
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isDesktop(context) && widget.stores != null  ? 4 : ResponsiveHelper.isDesktop(context) ? 4 : 2,
          ),
          physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
          shrinkWrap: widget.isScrollable ? false : true,
          itemCount: length,
          padding: widget.padding,
          itemBuilder: (context, index) {
            return widget.stores != null && widget.isStore ?  widget.isFoodOrGrocery! && widget.isStore ? StoreCardWidget(store: widget.stores![index])
                : StoreCardWithDistance(store: widget.stores![index]!, fromAllStore: true)
                : !ResponsiveHelper.isDesktop(context) ?
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: .start,
                crossAxisAlignment: .start,
                children: [
                  ItemWidgetStore(
                    isStore: widget.isStore, item: widget.isStore ? null : widget.items![index], isFeatured: widget.isFeatured,
                    store: widget.isStore ? widget.stores![index] : null, index: index, length: length, isCampaign: widget.isCampaign,
                    inStore: widget.inStorePage,
                  ),
                ],
              ),
            )
                : WebItemWidget(
              isStore: widget.isStore, item: widget.isStore ? null : widget.items![index], isFeatured: widget.isFeatured,
              store: widget.isStore ? widget.stores![index] : null, index: index, length: length, isCampaign: widget.isCampaign,
              inStore: widget.inStorePage,
            );
          },
        ),
      ) :
      NoDataScreen(
        text: widget.noDataText ?? (widget.isStore ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
            ? 'no_restaurant_available'.tr : 'no_store_available'.tr : 'no_item_available'.tr),
      ) :
      GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : widget.stores != null ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : widget.stores != null && widget.isStore ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) && widget.isStore ? 220
              : ResponsiveHelper.isMobile(context) ? widget.stores != null && widget.isStore ? 200 : 280
              : ResponsiveHelper.isDesktop(context) ? 300 : 280,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isDesktop(context) && widget.stores != null  ? 4 : ResponsiveHelper.isDesktop(context) ? 4 : 2,
        ),
        physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: widget.isScrollable ? false : true,
        itemCount: widget.shimmerLength,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return !widget.isStore ? ItemShimmer(isEnabled: isNull, isStore: widget.isStore, hasDivider: index != widget.shimmerLength-1, isGridView: true)
              : widget.isFoodOrGrocery! ? const StoreCardShimmer()
              : const NewOnShimmerView();
        },
      ),
    ]);
  }
}
