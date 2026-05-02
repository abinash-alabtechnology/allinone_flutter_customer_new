import 'package:handy_allinone/features/search/controllers/search_controller.dart' as search;
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/search/widgets/filter_widget.dart';
import 'package:handy_allinone/features/search/widgets/item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    if (widget.tabController != null) {
      _tabController = widget.tabController;
    } else {
      _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ),
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Container(
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

                            (ResponsiveHelper.isMobile(context) &&
                                    widget.searchText.isNotEmpty)
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
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
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

                      isScrollable: false,

                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,

                      indicator: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(28),
                      ),

                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,

                      labelStyle: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                      unselectedLabelStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                      ),

                      tabs: [
                        Tab(text: 'item'.tr),
                        Tab(
                          text:
                              Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
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
            child: TabBarView(
              controller: _tabController,
              children: const [
                ItemViewWidget(isItem: false),
                ItemViewWidget(isItem: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
