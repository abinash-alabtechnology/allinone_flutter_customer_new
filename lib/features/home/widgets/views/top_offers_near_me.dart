import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/title_widget.dart';
import 'package:handy_allinone/features/home/widgets/web/web_new_on_view_widget.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';

import '../../../../common/widgets/card_design/store_card_with_distance.dart';
class TopOffersNearMe extends StatelessWidget {
  const TopOffersNearMe({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.topOfferStoreList;

      return storeList != null ? storeList.isNotEmpty ? Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        // color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        color: Colors.grey[900],
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: "IN THE SPOTLIGHT",
              // title: 'top_offers_near_me'.tr,
              color: Theme.of(context).cardColor,
              Titlecolor:Theme.of(context).cardColor,
              image: Images.fireIcon,
              onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('topOffer')),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: 282,
            child: ListView.builder(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              itemCount: storeList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                  // child: StoreCard(store: storeList[index], isTopOffers: true),
                  child: StoreCardWithDistance3(store: storeList[index], fromTopOffers: true),
                );
              },
            ),
          ),
        ]),
      ) : const SizedBox.shrink() : const WebNewOnShimmerView();
    });
  }
}