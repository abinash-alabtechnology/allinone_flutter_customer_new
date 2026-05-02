import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../../home/screens/modules/grocery_home_screen.dart';
import '../widget_category/parcel_home_widget/parcel_banner_sliver_widget.dart';
import '../widget_category/parcel_home_widget/parcel_carousel_banner_sliver_widget.dart';
import '../widget_category/parcel_home_widget/parcel_choose_our_service_sliver_widget.dart';
import '../widget_category/parcel_home_widget/parcel_gride_sliver_widget.dart';
import '../widget_category/parcel_home_widget/parcel_howourservicework_widget.dart';
import '../widget_category/parcel_home_widget/parcel_new_app_bar_widget.dart';

class ParcelNewCategoryScreen extends StatefulWidget {
  final String? wheatherType;

  const ParcelNewCategoryScreen({super.key, this.wheatherType});

  @override
  State<ParcelNewCategoryScreen> createState() =>
      _ParcelNewCategoryScreenState();
}

class _ParcelNewCategoryScreenState extends State<ParcelNewCategoryScreen> {
  late ScrollController _scrollController;
  late final ValueNotifier<String?> weatherType;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    weatherType = ValueNotifier<String?>(widget.wheatherType);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final Color parcelCoreColor = const Color(0xFF2C2C2C);


  Future<void> onRefresh() async {
    await Future.wait([
      Get.find<ParcelController>().getParcelCategoryList(),
      Get.find<BannerController>().getParcelOtherBannerList(true),
      Get.find<ParcelController>().getWhyChooseDetails(),
      Get.find<ParcelController>().getVideoContentDetails(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /**
       *  app bar 
       */
      appBar: const ParcelNewAppBarWidget(),
      /**
       *  body : refresh indicator -> custom scroll view
       */
      body: RefreshIndicator(
        color: parcelCoreColor,
        onRefresh: onRefresh,
        /**
         *  custom scroll view
         */
        child: CustomScrollView(
          controller: _scrollController,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            /**
             * dummy banner widget noting do only scroll down wards
             * options
             */
            ParcelBannerSliverWidget(controller: _scrollController,weatherType: weatherType,),

            /**
             *  dummy banner carosuel widget lift to right
             *  noting to navigation to next screen
             */

            const ParcelCarouselBannerSliverWidget(),

            /**
             *  label holder widget
             **/

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 30,
                      width: 8,
                      decoration: BoxDecoration(
                        color: parcelCoreColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Choose Package Type",
                            style: robotoBold.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Select the type of parcel you want to send",
                            style: robotoBold.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Colors.black26,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            /**
             *  Gride view builder to show categories
             */
            const ParcelGrideSliverWidget(),

            /**
             *  purpose of the why choose our
             *  service
             */
            const ParcelChooseOurServiceSliverWidget(),

            /**
             * How our service work
             * widget
             */

            const ParcelHowouSrerviceWorkWidget(),
            SliverToBoxAdapter(
          child:Container(height: 100,)),

          ],
        ),
      ),
    );
  }
}
