import 'package:handy_allinone/features/search/controllers/search_controller.dart' as search;
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/search/widgets/filter_widget.dart';
import 'package:handy_allinone/features/search/widgets/item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/app_constants.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  final TabController? tabController;

  const SearchResultWidget({
    super.key,
    required this.searchText,
    this.tabController,
  });

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.pharmacy.toLowerCase();

    if (widget.tabController != null) {
      _tabController = widget.tabController;
    } else {
      _tabController = TabController(length: isPharmacy ? 3 : 2, initialIndex: 0, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.pharmacy.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<search.SearchController>(
          builder: (searchController) {
            bool isNull = true;
            int length = 0;
            if (searchController.isStore) {
              isNull = searchController.searchStoreList == null;
              if (!isNull) {
                length = searchController.searchStoreList!.length;
              }
            } else {
              isNull = searchController.searchItemList == null;
              if (!isNull) {
                length = searchController.searchItemList!.length;
              }
            }
            return isNull
                ? const SizedBox()
                : Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isPharmacy ? Text(
                                  'Showing results for "${widget.searchText}"',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black87),
                                ) : const SizedBox(),
                                isPharmacy ? Text(
                                  '$length results found',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
                                ) : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 8,
                                    ),
                                    child: IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          Text(
                                            length.toString(),
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeExtraSmall,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'results_found'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                                fontSize: Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            (ResponsiveHelper.isMobile(context) &&
                                    widget.searchText.isNotEmpty && !isPharmacy)
                                ? InkWell(
                                    onTap: () {
                                      List<double?> prices = [];
                                      if (!Get.find<search.SearchController>()
                                          .isStore) {
                                        for (var product
                                            in Get.find<
                                                  search.SearchController
                                                >()
                                                .allItemList!) {
                                          prices.add(product.price);
                                        }
                                        prices.sort();
                                      }
                                      double? maxValue = prices.isNotEmpty
                                          ? prices[prices.length - 1]
                                          : 1000;
                                      Get.dialog(
                                        FilterWidget(
                                          maxValue: maxValue,
                                          isStore:
                                              Get.find<
                                                    search.SearchController
                                                  >()
                                                  .isStore,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(
                                          alpha: 0.1,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.tune),
                                            SizedBox(width: 10),
                                            Text(
                                              'filter'.tr,
                                              style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  );
          },
        ),

        ResponsiveHelper.isDesktop(context)
            ? const SizedBox()
            : Center(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  color: isPharmacy ? Colors.white : Colors.grey.shade50,
                  padding: isPharmacy ? EdgeInsets.zero : const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    padding: isPharmacy ? EdgeInsets.zero : const EdgeInsets.all(6),
                    decoration: isPharmacy ? null : BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: isPharmacy ? true : false,
                      indicatorSize: isPharmacy ? TabBarIndicatorSize.label : TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: isPharmacy ? const UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.0, color: Color(0xFF24AE5F)),
                        insets: EdgeInsets.symmetric(horizontal: 16.0),
                      ) : BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      labelColor: isPharmacy ? const Color(0xFF24AE5F) : Colors.white,
                      unselectedLabelColor: isPharmacy ? Colors.grey : Colors.black,
                      labelStyle: robotoBold.copyWith(
                        fontSize: isPharmacy ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall,
                      ),
                      unselectedLabelStyle: robotoRegular.copyWith(
                        fontSize: isPharmacy ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall,
                      ),
                      tabs: isPharmacy ? [
                        const Tab(text: 'All'),
                        const Tab(text: 'Medicines'),
                        const Tab(text: 'Health Products'),
                      ] : [
                        Tab(text: 'item'.tr),
                        Tab(
                          text: (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
                              ? 'restaurants'.tr
                              : 'stores'.tr,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

        Expanded(
          child: NotificationListener(
            onNotification: (dynamic scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                Get.find<search.SearchController>().setStore(
                  _tabController!.index == 1,
                );
                Get.find<search.SearchController>().searchData(
                  widget.searchText,
                  false,
                );
              }
              return false;
            },
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: isPharmacy ? const [
                    ItemViewWidget(isItem: false),
                    ItemViewWidget(isItem: false),
                    ItemViewWidget(isItem: false),
                  ] : const [
                    ItemViewWidget(isItem: false),
                    ItemViewWidget(isItem: true),
                  ],
                ),
                if (isPharmacy)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Can\'t find your medicine?',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black87),
                          ),
                          const SizedBox(height: 5),
                          InkWell(
                            onTap: () {
                              // Prescription upload logic
                            },
                            child: Text(
                              'Upload Prescription',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF24AE5F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
