import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/common/widgets/card_design/store_card_with_distance.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/web_item_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/features/home/widgets/web/widgets/store_card_widget.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/string_extension.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/common/widgets/no_data_screen.dart';
import 'package:handy_allinone/common/widgets/item_shimmer.dart';
import 'package:handy_allinone/common/widgets/item_widget.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';

import '../../util/images.dart';

class ItemsView extends StatefulWidget {
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

  const ItemsView({
    super.key,
    required this.stores,
    required this.items,
    required this.isStore,
    this.isScrollable = false,
    this.shimmerLength = 20,
    this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
    this.noDataText,
    this.isCampaign = false,
    this.inStorePage = false,
    this.isFeatured = false,
    this.isFoodOrGrocery = true,
  });

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if (widget.isStore) {
      isNull = widget.stores == null;
      if (!isNull) {
        length = widget.stores!.length;
      }
    } else {
      isNull = widget.items == null;
      if (!isNull) {
        length = widget.items!.length;
      }
    }

    return Column(
      children: [
        !isNull
            ? length > 0
                  ? GridView.builder(
                      key: UniqueKey(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.paddingSizeExtremeLarge
                            : widget.stores != null
                            ? Dimensions.paddingSizeLarge
                            : Dimensions.paddingSizeLarge,
                        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.paddingSizeExtremeLarge
                            : widget.stores != null && widget.isStore
                            ? Dimensions.paddingSizeLarge
                            : Dimensions.paddingSizeSmall,
                        mainAxisExtent:
                            ResponsiveHelper.isDesktop(context) &&
                                widget.isStore
                            ? 240
                            : ResponsiveHelper.isMobile(context)
                            ? widget.stores != null && widget.isStore
                                  ? 250
                                  : 122
                            : ResponsiveHelper.isDesktop(context)
                            ? 300
                            : 122,
                        crossAxisCount: ResponsiveHelper.isMobile(context)
                            ? 1
                            : ResponsiveHelper.isDesktop(context) &&
                                  widget.stores != null
                            ? 3
                            : ResponsiveHelper.isDesktop(context)
                            ? 4
                            : 3,
                      ),
                      physics: widget.isScrollable
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: widget.isScrollable ? false : true,
                      itemCount: length,
                      padding: widget.padding,
                      itemBuilder: (context, index) {
                        return widget.stores != null && widget.isStore
                            ? widget.isFoodOrGrocery! && widget.isStore
                                  ? Hero(
                                      tag: "store_${widget.stores![index]!.id}",
                                      child: StoreCardWidget(
                                        store: widget.stores![index],
                                      ),
                                    )
                                  : StoreCardWithDistance(
                                      store: widget.stores![index]!,
                                      fromAllStore: true,
                                    )
                            : !ResponsiveHelper.isDesktop(context)
                            ? ItemWidget(
                                isStore: widget.isStore,
                                item: widget.isStore
                                    ? null
                                    : widget.items![index],
                                isFeatured: widget.isFeatured,
                                store: widget.isStore
                                    ? widget.stores![index]
                                    : null,
                                index: index,
                                length: length,
                                isCampaign: widget.isCampaign,
                                inStore: widget.inStorePage,
                              )
                            : WebItemWidget(
                                isStore: widget.isStore,
                                item: widget.isStore
                                    ? null
                                    : widget.items![index],
                                isFeatured: widget.isFeatured,
                                store: widget.isStore
                                    ? widget.stores![index]
                                    : null,
                                index: index,
                                length: length,
                                isCampaign: widget.isCampaign,
                                inStore: widget.inStorePage,
                              );
                      },
                    )
                  : NoDataScreen(
                      text:
                          widget.noDataText ??
                          (widget.isStore
                              ? Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .showRestaurantText!
                                    ? 'no_restaurant_available'.tr
                                    : 'no_store_available'.tr
                              : 'no_item_available'.tr),
                    )
            : GridView.builder(
                key: UniqueKey(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeExtremeLarge
                      : widget.stores != null
                      ? Dimensions.paddingSizeLarge
                      : Dimensions.paddingSizeLarge,
                  mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeLarge
                      : widget.stores != null
                      ? Dimensions.paddingSizeLarge
                      : Dimensions.paddingSizeSmall,
                  mainAxisExtent:
                      ResponsiveHelper.isDesktop(context) && widget.isStore
                      ? 220
                      : ResponsiveHelper.isMobile(context)
                      ? widget.isStore
                            ? 200
                            : 110
                      : 110,
                  crossAxisCount: ResponsiveHelper.isMobile(context)
                      ? 1
                      : ResponsiveHelper.isDesktop(context)
                      ? 3
                      : 3,
                ),
                physics: widget.isScrollable
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                shrinkWrap: widget.isScrollable ? false : true,
                itemCount: widget.shimmerLength,
                padding: widget.padding,
                itemBuilder: (context, index) {
                  return widget.isStore
                      ? widget.isFoodOrGrocery!
                            ? const StoreCardShimmer()
                            : const NewOnShimmerView()
                      : ItemShimmer(
                          isEnabled: isNull,
                          isStore: widget.isStore,
                          hasDivider: index != widget.shimmerLength - 1,
                        );
                },
              ),
      ],
    );
  }
}

class NewOnShimmerView extends StatelessWidget {
  const NewOnShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            // width: fromAllStore ?  MediaQuery.of(context).size.width : 260,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                        ),

                        Positioned(
                          top: 15,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).cardColor.withValues(alpha: 0.8),
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 95),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 5,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.blue,
                                    size: 15,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 10,
                                      width: 100,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 10,
                                width: 70,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                ),
                              ),

                              Container(
                                height: 20,
                                width: 65,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 60,
            left: 15,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 65,
                  width: 65,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemsViewStore extends StatefulWidget {
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
  final String categoryname;
  /// Called each time a category header is built, providing its GlobalKey
  /// so the parent can scroll to it with pixel-perfect accuracy.
  final void Function(String categoryName, GlobalKey key)? onCategoryHeaderKey;

  const ItemsViewStore({
    super.key,
    required this.stores,
    required this.items,
    required this.isStore,
    this.isScrollable = false,
    this.shimmerLength = 20,
    this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
    this.noDataText,
    this.isCampaign = false,
    this.inStorePage = false,
    this.isFeatured = false,
    this.isFoodOrGrocery = true,
    required this.backButton,
    this.showbackbutton = true,
    this.showfavourite = false,
    this.categoryname = "",
    this.isGridView = true,
    this.groupByCategory = false,
    this.vegFilter = false,
    this.nonVegFilter = false,
    this.discountFilter = false,
    this.onCategoryHeaderKey,
  });

  final bool isGridView;
  final bool groupByCategory;
  final bool vegFilter;
  final bool nonVegFilter;
  final bool discountFilter;

  @override
  State<ItemsViewStore> createState() => _ItemsViewStoreState();
}

class _ItemsViewStoreState extends State<ItemsViewStore> {
  /// Persisted keys for each category header — survive rebuilds.
  final Map<String, GlobalKey> _categoryHeaderKeys = {};
  /// Tracks which category sections are collapsed.
  final Set<String> _collapsedCategories = {};

  GlobalKey _getHeaderKey(String categoryName) =>
      _categoryHeaderKeys.putIfAbsent(categoryName, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if (widget.isStore) {
      isNull = widget.stores == null;
      if (!isNull) {
        length = widget.stores!.length;
      }
    } else {
      isNull = widget.items == null;
      if (!isNull) {
        length = widget.items!.length;
      }
    }

    final List<dynamic> groupedItems = widget.groupByCategory ? _getGroupedItems() : [];

    return Column(
      children: [
        !isNull
            ? length > 0
                  ? Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.showbackbutton == true && !widget.inStorePage)
                                ? Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 50,width: Get.width-16,
                                              child: Row(
                                                children: [
                                                  CustomAssetImageWidget(
                                                    Images.sparkle,
                                                    color: Colors.amber,
                                                    height: 24,
                                                    width: 24,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      widget.categoryname == "all" || widget.categoryname == "All" || widget.categoryname == ""
                                                          ? "Discover Our Menu"
                                                          : "Menu from ${widget.categoryname.toCapitalized()}",
                                                      style: robotoBold.copyWith(
                                                        fontSize: 20,
                                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                                        letterSpacing: -0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4.0),
                                              child: Text(
                                                'Swipe through categories and discover what\'s waiting for you',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 13,
                                                  color: Theme.of(context).disabledColor.withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : widget.showfavourite == true
                                ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical: 20.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFD40000),
                                          Color(0xFF980000),
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Save what you love\nShop when you're ready",
                                              style: robotoBold.copyWith(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "Whether it's groceries, medicines,\nmeals, or gadgets - we've got your back.",
                                              style: robotoBold.copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        CustomAssetImageWidget(
                                          Images.favouritenew,
                                          height: 80,
                                          width: 80,
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            widget.groupByCategory
                              ? _buildSwiggyGroupedList(context, groupedItems)
                              : widget.isGridView ? GridView.builder(
                              key: UniqueKey(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.paddingSizeExtremeLarge
                                        : widget.stores != null
                                        ? Dimensions.paddingSizeSmall
                                        : Dimensions.paddingSizeSmall,
                                    mainAxisSpacing:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.paddingSizeExtremeLarge
                                        : widget.stores != null &&
                                              widget.isStore
                                        ? Dimensions.paddingSizeLarge
                                        : Dimensions.paddingSizeSmall,
                                    mainAxisExtent:
                                        ResponsiveHelper.isDesktop(context) &&
                                            widget.isStore
                                        ? 220
                                        : ResponsiveHelper.isMobile(context)
                                        ? widget.stores != null &&
                                                  widget.isStore
                                              ? 200
                                              : 255
                                        : ResponsiveHelper.isDesktop(context)
                                        ? 300
                                        : 255,
                                    crossAxisCount:
                                        ResponsiveHelper.isMobile(context)
                                        ? 3
                                        : ResponsiveHelper.isDesktop(context) &&
                                              widget.stores != null
                                        ? 5
                                        : ResponsiveHelper.isDesktop(context)
                                        ? 5
                                        : 3,
                                  ),

                              physics: widget.isScrollable
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              shrinkWrap: widget.isScrollable ? false : true,
                              itemCount: length,
                              padding: widget.padding,
                              itemBuilder: (context, index) {
                                return widget.stores != null && widget.isStore
                                    ? widget.isFoodOrGrocery! && widget.isStore
                                          ? StoreCardWidget(
                                              store: widget.stores![index],
                                            )
                                          : StoreCardWithDistance(
                                              store: widget.stores![index]!,
                                              fromAllStore: true,
                                            )
                                    : !ResponsiveHelper.isDesktop(context)
                                    ? ItemWidgetStore(
                                        isStore: widget.isStore,
                                        item: widget.isStore
                                            ? null
                                            : widget.items![index],
                                        isFeatured: widget.isFeatured,
                                        store: widget.isStore
                                            ? widget.stores![index]
                                            : null,
                                        index: index,
                                        length: length,
                                        isCampaign: widget.isCampaign,
                                        inStore: widget.inStorePage,
                                      )
                                    : WebItemWidget(
                                        isStore: widget.isStore,
                                        item: widget.isStore
                                            ? null
                                            : widget.items![index],
                                        isFeatured: widget.isFeatured,
                                        store: widget.isStore
                                            ? widget.stores![index]
                                            : null,
                                        index: index,
                                        length: length,
                                        isCampaign: widget.isCampaign,
                                        inStore: widget.inStorePage,
                                      );
                              },
                            ) : GridView.builder(
                              key: UniqueKey(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: Dimensions.paddingSizeSmall,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 150,
                                crossAxisCount: 1,
                              ),
                              physics: widget.isScrollable
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              shrinkWrap: widget.isScrollable ? false : true,
                              itemCount: length,
                              padding: widget.padding,
                              itemBuilder: (context, index) {
                                return widget.stores != null && widget.isStore
                                    ? widget.isFoodOrGrocery! && widget.isStore
                                          ? StoreCardWidget(
                                              store: widget.stores![index],
                                            )
                                          : StoreCardWithDistance(
                                              store: widget.stores![index]!,
                                              fromAllStore: true,
                                              )
                                    : ItemWidget(
                                        isStore: widget.isStore,
                                        item: widget.isStore
                                            ? null
                                            : widget.items![index],
                                        isFeatured: widget.isFeatured,
                                        store: widget.isStore
                                            ? widget.stores![index]
                                            : null,
                                        index: index,
                                        length: length,
                                        isCampaign: widget.isCampaign,
                                        inStore: widget.inStorePage,
                                      );
                              },
                            ),


                          ],
                        ),
                        widget.showbackbutton == true
                            ? const SizedBox()
                            : const SizedBox(),
                      ],
                    )
                  : NoDataScreen(
                      text:
                          widget.noDataText ??
                          (widget.isStore
                              ? Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .showRestaurantText!
                                    ? 'no_restaurant_available'.tr
                                    : 'no_store_available'.tr
                              : 'no_item_available'.tr),
                    )
            : widget.isGridView ? GridView.builder(
                key: UniqueKey(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeExtremeLarge
                      : widget.stores != null
                      ? Dimensions.paddingSizeLarge
                      : Dimensions.paddingSizeSmall,
                  mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeExtremeLarge
                      : widget.stores != null && widget.isStore
                      ? Dimensions.paddingSizeLarge
                      : Dimensions.paddingSizeSmall,
                  mainAxisExtent:
                      ResponsiveHelper.isDesktop(context) && widget.isStore
                      ? 220
                      : ResponsiveHelper.isMobile(context)
                      ? widget.stores != null && widget.isStore
                            ? 200
                            : 255
                      : ResponsiveHelper.isDesktop(context)
                      ? 300
                      : 255,
                  crossAxisCount: ResponsiveHelper.isMobile(context)
                      ? 3
                      : ResponsiveHelper.isDesktop(context) &&
                            widget.stores != null
                      ? 5
                      : ResponsiveHelper.isDesktop(context)
                      ? 5
                      : 3,
                ),
                physics: widget.isScrollable
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                shrinkWrap: widget.isScrollable ? false : true,
                itemCount: widget.shimmerLength,
                padding: widget.padding,
                itemBuilder: (context, index) {
                  return widget.isStore
                      ? widget.isFoodOrGrocery!
                            ? const StoreCardShimmer()
                            : const NewOnShimmerView()
                      : ItemShimmer(
                          isEnabled: isNull,
                          isStore: widget.isStore,
                          hasDivider: index != widget.shimmerLength - 1,
                          isGridView: true,
                        );
                },
              ) : GridView.builder(
                key: UniqueKey(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisExtent: 130,
                  crossAxisCount: 1,
                ),
                physics: widget.isScrollable
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                shrinkWrap: widget.isScrollable ? false : true,
                itemCount: widget.shimmerLength,
                padding: widget.padding,
                itemBuilder: (context, index) {
                  return widget.isStore
                      ? widget.isFoodOrGrocery!
                            ? const StoreCardShimmer()
                            : const NewOnShimmerView()
                      : ItemShimmer(
                          isEnabled: isNull,
                          isStore: widget.isStore,
                          hasDivider: index != widget.shimmerLength - 1,
                        );
                },
              ),
      ],
    );
  }

  Widget _buildGroupedItem(int index, int length) {
    final displayItems = _getGroupedItems();
    final item = displayItems[index];

    if (item is String) {
      // It's a category header
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Container(
              height: 14,
              width: 3.5,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              item,
              style: robotoBold.copyWith(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.85),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    } else {
      // It's an actual item
      return ItemWidget(
        isStore: widget.isStore,
        item: item as Item,
        isFeatured: widget.isFeatured,
        store: null,
        index: index,
        length: length,
        isCampaign: widget.isCampaign,
        inStore: widget.inStorePage,
      );
    }
  }

  List<dynamic> _getGroupedItems() {
    if (widget.items == null) return [];
    
    Map<String, List<Item>> groups = {};
    for (var item in widget.items!) {
      if (item != null) {
        String catName = 'Uncategorized';
        if (item.categoryIds != null && item.categoryIds!.isNotEmpty) {
          catName = item.categoryIds![0].name ?? 'Uncategorized';
        }
        if (!groups.containsKey(catName)) {
          groups[catName] = [];
        }
        groups[catName]!.add(item);
      }
    }

    List<dynamic> flattened = [];
    groups.forEach((category, items) {
      flattened.add("$category (${items.length} ${items.length > 1 ? 'Items' : 'Item'})");
      flattened.addAll(items);
    });
    
    return flattened;
  }

  // ── Swiggy-style grouped list ──────────────────────────────────────────────
  Widget _buildSwiggyGroupedList(BuildContext context, List<dynamic> groupedItems) {
    // Re-build a structured map: category -> items (preserve order)
    final Map<String, List<Item>> groups = {};
    for (final entry in groupedItems) {
      if (entry is String) {
        final cleanName = entry.contains(' (')
            ? entry.substring(0, entry.lastIndexOf(' ('))
            : entry;
        groups.putIfAbsent(cleanName, () => []);
      } else if (entry is Item) {
        final catName = (entry.categoryIds != null && entry.categoryIds!.isNotEmpty)
            ? (entry.categoryIds![0].name ?? 'Uncategorized')
            : 'Uncategorized';
        groups.putIfAbsent(catName, () => []).add(entry);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.entries.map((groupEntry) {
        final catName = groupEntry.key;
        final bool anyFilter = widget.vegFilter || widget.nonVegFilter || widget.discountFilter;
        final List<Item> items = anyFilter
            ? groupEntry.value.where((item) {
                if (widget.vegFilter && (item.veg ?? 0) != 1) return false;
                if (widget.nonVegFilter && (item.veg ?? 0) != 0) return false;
                if (widget.discountFilter && (item.discount == null || item.discount! <= 0)) return false;
                return true;
              }).toList()
            : groupEntry.value;

        // Hide whole category if no items match filters
        if (items.isEmpty) return const SizedBox.shrink();

        final isCollapsed = _collapsedCategories.contains(catName);
        final headerKey = _getHeaderKey(catName);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onCategoryHeaderKey?.call(catName, headerKey);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category header ───────────────────────────────────────────
            InkWell(
              onTap: () {
                setState(() {
                  if (isCollapsed) {
                    _collapsedCategories.remove(catName);
                  } else {
                    _collapsedCategories.add(catName);
                  }
                });
              },
              child: Container(
                key: headerKey,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$catName (${items.length})',
                        style: robotoBold.copyWith(
                          fontSize: 17,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isCollapsed ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 24,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Items (collapsible) ───────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isCollapsed
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Column(
                children: items.asMap().entries.map((e) {
                  return _buildSwiggyItem(context, e.value, e.key == items.length - 1);
                }).toList(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Swiggy-style item card: text LEFT, image RIGHT with ADD button overlay.
  Widget _buildSwiggyItem(BuildContext context, Item item, bool isLast) {
    final bool isVeg = (item.veg ?? 0) == 1;
    final double price = item.price ?? 0;
    final double? discount = item.discount != null && item.discount! > 0 ? item.discount : null;
    final String? discountType = item.discountType;
    final String finalPrice = PriceConverter.convertPrice(price, discount: discount, discountType: discountType);

    return CustomInkWell(
      onTap: () {
        Get.find<ItemController>().navigateToItemPage(item, context, inStore: true);
      },
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LEFT: text info ─────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg / non-veg indicator
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isVeg ? const Color(0xFF00A550) : const Color(0xFFE43B3B),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isVeg ? const Color(0xFF00A550) : const Color(0xFFE43B3B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Item name
                    Text(
                      item.name ?? '',
                      style: robotoBold.copyWith(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price row
                    Row(
                      children: [
                        Text(
                          finalPrice,
                          style: robotoBold.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        if (discount != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            PriceConverter.convertPrice(price),
                            style: robotoRegular.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    if (item.description != null && item.description!.isNotEmpty)
                      Text(
                        item.description!,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).disabledColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── RIGHT: image + ADD button ────────────────────────────
              SizedBox(
                width: 110,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImage(
                            image: item.imageFullUrl ?? '',
                            height: 110,
                            width: 110,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Discount ribbon
                        if (discount != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                discountType == 'percent'
                                    ? '${discount.toStringAsFixed(0)}% OFF'
                                    : '${PriceConverter.convertPrice(discount)} OFF',
                                style: robotoBold.copyWith(
                                  fontSize: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // ADD / quantity controls via CartCountViewStore
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: CartCountViewStore(item: item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Divider (not after last item)
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
      ),
    );
  }
}
