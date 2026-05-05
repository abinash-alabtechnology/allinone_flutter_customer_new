import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/search/controllers/search_controller.dart' as search;
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:handy_allinone/features/search/widgets/filter_widget.dart';
import 'package:handy_allinone/features/search/widgets/search_field_widget.dart';
import 'package:handy_allinone/features/search/widgets/search_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/features/store/widgets/bottom_cart_widget.dart';

import '../../../voice_search.dart';

class SearchScreen extends StatefulWidget {
  final String? queryText;
  const SearchScreen({super.key, required this.queryText});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  final TextEditingController _searchController = TextEditingController();
  late bool _isLoggedIn;

  List<String> _itemsAndStors = <String>[];
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);
    Get.find<search.SearchController>().getPopularCategories();
    if(_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedItems();
    }
    Get.find<search.SearchController>().getHistoryList();
    if(widget.queryText != null && widget.queryText!.isNotEmpty) {
      _actionSearch(true, widget.queryText, true);
    }
  }

  Future<void> _searchSuggestions(String query) async {
    _itemsAndStors = [];
    if (query == '') {
      _showSuggestion = false;
      _itemsAndStors = [];
    } else {
      _showSuggestion = true;
      _itemsAndStors = await Get.find<search.SearchController>().getSearchSuggestions(query);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.pharmacy.toLowerCase();

    debugPrint("SearchScreen Build: isPharmacy=$isPharmacy, query=${widget.queryText}");
    return Scaffold(
        backgroundColor: isPharmacy ? Colors.white : Theme.of(context).colorScheme.surface,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
        body: Stack(
          children: [
            SafeArea(
                top: false,
                bottom: true,
                left: false,
                right: false,
                child: Padding(
                  padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero :  EdgeInsets.zero,
                  child: GetBuilder<search.SearchController>(builder: (searchController) {
                    if(!GetPlatform.isWeb) {
                      _searchController.text = searchController.searchText ?? '';
                    }
                    return Column(children: [
                      ResponsiveHelper.isDesktop(context) ? Container(
                        width : double.infinity,
                        color: Theme.of(context).primaryColor,
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              Text('search_items_and_stores'.tr, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<search.SearchController>(builder: (searchController) {
                                return SearchFieldWidget(
                                  controller: _searchController,
                                  radius: 50,
                                  hint: (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
                                      ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                                  suffixIcon: (searchController.searchHomeText ?? '').isNotEmpty ? Icons.cancel : CupertinoIcons.search,
                                  iconColor: Theme.of(context).disabledColor,
                                  filledColor: Theme.of(context).colorScheme.surface,
                                  onChanged: (text) {
                                    _searchSuggestions(text);
                                    searchController.setSearchText(text);
                                  },
                                  iconPressed: () {
                                    if((searchController.searchHomeText ?? '').isNotEmpty) {
                                      _searchController.text = '';
                                      _showSuggestion = false;
                                      searchController.setSearchMode(true);
                                      searchController.clearSearchHomeText();
                                    }else {
                                      searchData();
                                    }
                                  },
                                  onSubmit: (text) => searchData(),
                                );
                              })),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              !searchController.isSearchMode ?
                              Center(
                                  child: SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 220,
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: TabBar(
                                              controller: _tabController,
                                              isScrollable: true,
                                              indicatorSize: TabBarIndicatorSize.tab,
                                              dividerColor: Colors.transparent,

                                              indicator: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),

                                              labelColor: Colors.white,
                                              unselectedLabelColor: Colors.white70,

                                              labelStyle: robotoBold.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                              ),
                                              unselectedLabelStyle: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                              ),

                                              labelPadding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions.radiusDefault,
                                              ),

                                              tabs: [
                                                Tab(text: 'item'.tr),
                                                Tab(
                                                  text: (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
                                                      ? 'restaurants'.tr
                                                      : 'stores'.tr,
                                                ),
                                              ],
                                            ),
                                          ),


                                          InkWell(
                                              onTap: () {
                                                _actionSearch(false, _searchController.text.trim(), false);
                                              },
                                              child: Image.asset(Images.filter, height: 28, width: 28))
                                        ],
                                      )
                                  ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      ) : const SizedBox(),

                      (widget.queryText != null && widget.queryText!.isNotEmpty) ? const SizedBox() : Center(child: ResponsiveHelper.isDesktop(context) ? const SizedBox() :
                      Container(
                          width: Dimensions.webMaxWidth,
                          decoration: BoxDecoration(
                              color: Get.find<ThemeController>().darkTheme ? Colors.black12 : isPharmacy ? Colors.white : Theme.of(context).primaryColor,
                              boxShadow: Get.find<ThemeController>().darkTheme ? null : [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 5))]
                          ),
                          padding: EdgeInsets.only(bottom: 10, top: isPharmacy ? MediaQuery.of(context).padding.top : 40),
                          child: Container(
                            margin:const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: isPharmacy ? Colors.grey.shade200 : Theme.of(context).disabledColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [

                              IconButton(
                                onPressed: (){
                                  if(searchController.isSearchMode) {
                                    Get.back();
                                  } else {
                                    _showSuggestion = false;
                                    searchController.setSearchMode(true);
                                    searchController.setStore(false);
                                  }
                                },
                                icon: Icon(Icons.arrow_back_ios_new, color: isPharmacy ? Colors.black : Theme.of(context).cardColor),
                              ),

                              Expanded(child: SearchFieldWidget(
                                controller: _searchController,
                                radius: 12,
                                prefixIcon: isPharmacy ? Icons.search : null,
                                suffixIcon: isPharmacy ? Icons.mic : null,
                                filledColor: isPharmacy ? const Color(0xFFF1F5F9) : null,
                                isFocused: false,
                                hint: (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
                                    ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                                iconPressed: () {
                                  _showSuggestion = false;
                                  searchController.setSearchMode(true);
                                  searchController.setStore(false);
                                  if(GetPlatform.isWeb) {
                                    _searchController.text = '';
                                  }
                                },
                                onChanged: (text) {
                                  searchController.setSearchText(text);
                                  _searchSuggestions(text);
                                },
                                onSubmit: (text) => _actionSearch(true, _searchController.text.trim(), false),
                              )),
                              if (!isPharmacy) IconButton(
                                icon: Icon(CupertinoIcons.search,color: Theme.of(context).disabledColor,),
                                onPressed: (){
                                  _actionSearch(true, _searchController.text.trim(), false);
                                },
                              ),
                              if (!isPharmacy) const SizedBox(width: Dimensions.paddingSizeSmall),
                              if (!isPharmacy) const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(height: 30,child:VerticalDivider(color: Colors.grey,width: 2,)),
                              ),
                              if (!isPharmacy) const SizedBox(width: Dimensions.paddingSizeSmall),
                              if (!isPharmacy) VoiceSearchIcon(
                                controller: _searchController,
                                onSearch: (text) {
                                  _actionSearch(true, text, false);
                                },
                              ),

                            ]),
                          ))),

                      Expanded(child: searchController.isSearchMode ? _showSuggestion ? showSuggestions(
                        context, searchController, _itemsAndStors,
                      ) : SingleChildScrollView(
                        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: FooterView(
                          child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            searchController.historyList.isNotEmpty ? Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                Text(ResponsiveHelper.isDesktop(context) ? 'recent_searches'.tr : 'your_last_search'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                InkWell(
                                  onTap: () => searchController.clearSearchHistory(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 4),
                                    child: Text('clear_all'.tr, style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault, color: Colors.red,
                                    )),
                                  ),
                                ),
                              ]),
                            ) : const SizedBox(),

                            SizedBox(
                              height: ResponsiveHelper.isDesktop(context) ? 36 : null,
                              child: ListView.builder(
                                itemCount: searchController.historyList.length > 10 ? 10 : searchController.historyList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: ResponsiveHelper.isDesktop(context) ? Axis.horizontal : Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ResponsiveHelper.isDesktop(context) ?
                                  Container(
                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                    padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                                      border: Border.all(color: Theme.of(context).primaryColor),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        _searchController.text = searchController.historyList[index];
                                        // searchController.setSearchText(searchController.historyList[index]);
                                        searchController.searchData(searchController.historyList[index], false);
                                      },
                                      child: Row(
                                        children: [
                                          Text(searchController.historyList[index], style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),

                                          InkWell(
                                            onTap: () => searchController.removeHistory(index),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                              child: Icon(Icons.close, color: Theme.of(context).primaryColor, size: 16),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ) : InkWell(
                                    onTap: () => searchController.searchData(searchController.historyList[index], false),
                                    child: Row(children: [

                                      Icon(CupertinoIcons.search, size: 18, color: Theme.of(context).disabledColor),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                          child: Text(
                                            searchController.historyList[index],
                                            style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => searchController.removeHistory(index),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                          child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 20),
                                        ),
                                      )
                                    ]),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            (_isLoggedIn && searchController.suggestedItemList != null) ? Text(
                              'suggestions'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                            ) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            (_isLoggedIn && searchController.suggestedItemList != null) ? searchController.suggestedItemList!.isNotEmpty ?  GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3, childAspectRatio:  ResponsiveHelper.isMobile(context) ? (1/ 0.4) : (1.8/ 0.3),
                                mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: searchController.suggestedItemList!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 10)]
                                  ),
                                  child: CustomInkWell(
                                    onTap: () {
                                      Get.find<ItemController>().navigateToItemPage(searchController.suggestedItemList![index], context);
                                    },
                                    radius: Dimensions.radiusDefault,
                                    child: Row(children: [
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        child: CustomImage(
                                          image: '${searchController.suggestedItemList![index].imageFullUrl}',
                                          width: 45, height: 45, fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      Expanded(child: Text(
                                        searchController.suggestedItemList![index].name ?? '',
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                      )),
                                    ]),
                                  ),
                                );
                              },
                            ) : Padding(padding: const EdgeInsets.only(top: 10), child: Text('no_suggestions_available'.tr)) : const SizedBox(),

                            SizedBox(height: (_isLoggedIn && searchController.suggestedItemList != null) ? Dimensions.paddingSizeLarge : 0),

                            (searchController.popularCategoryList != null && searchController.popularCategoryList!.isNotEmpty) ? Text(
                              'popular_categories'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                            ) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            searchController.popularCategoryList != null ? searchController.popularCategoryList!.isNotEmpty ? Wrap(
                              children: searchController.popularCategoryList!.map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                                  child: CustomInkWell(
                                    onTap: () {
                                      _searchController.text = category?.name??'';
                                      searchController.searchData(category?.name??'', false);
                                    },
                                    radius: 50,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: Theme.of(context).disabledColor, width: 0.1),
                                      ),
                                      child: Text(
                                        category?.name??'',
                                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ) : Padding(padding: const EdgeInsets.only(top: 10), child: Center(child: Text('no_category_available'.tr))) : const SizedBox(),

                          ])),
                        ),
                      ) : SearchResultWidget(searchText: _searchController.text.trim(), tabController: ResponsiveHelper.isDesktop(context) ? _tabController : null)),
                    ]);
                  }),
                )),
            Positioned(
              bottom: 10,right: 10,
              child: GetBuilder<CartController>(builder: (cartController) {
                return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? IntrinsicWidth(child: const BottomCartWidget()) : const SizedBox();
              }),
            ),
          ],
        ),
    );
  }

  void searchData() {
    if (_searchController.text.trim().isEmpty) {
      showCustomSnackBar((Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
          ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr);
    } else {
      _actionSearch(true, _searchController.text, true);
    }
  }

  void _actionSearch(bool isSubmit, String? queryText, bool fromHome) {
    if(Get.find<search.SearchController>().isSearchMode || isSubmit) {
      if(queryText!.isNotEmpty) {
        Get.find<search.SearchController>().searchData(queryText, fromHome);
      } else {
        showCustomSnackBar((Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
            ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr);
      }
    } else {
      List<double?> prices = [];
      if(!Get.find<search.SearchController>().isStore) {
        for (var product in Get.find<search.SearchController>().allItemList!) {
          prices.add(product.price);
        }
        prices.sort();
      }
      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
      Get.dialog(FilterWidget(maxValue: maxValue, isStore: Get.find<search.SearchController>().isStore));
    }
  }


  Widget showSuggestions(BuildContext context, search.SearchController searchController, List<String> foodsAndRestaurants) {
    return SingleChildScrollView(
      child: FooterView(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: foodsAndRestaurants.isNotEmpty ? ListView.builder(
            itemCount: foodsAndRestaurants.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(foodsAndRestaurants[index]),
                leading: Icon(CupertinoIcons.search, color: Theme.of(context).disabledColor),
                trailing: Icon(Icons.north_west, color: Theme.of(context).disabledColor),
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  _searchController.text = foodsAndRestaurants[index];
                  _actionSearch(true, _searchController.text.trim(), false);
                },
              );
            },
          ) : Padding(
            padding: EdgeInsets.only(top: context.height * 0.2),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CustomAssetImageWidget(Images.emptyBox, height: 100, width: 100),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('no_suggestions_found'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      ),
    );
  }
}
