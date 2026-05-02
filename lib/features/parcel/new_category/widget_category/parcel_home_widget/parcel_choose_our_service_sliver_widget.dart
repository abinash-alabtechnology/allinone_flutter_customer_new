import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:handy_allinone/features/parcel/new_category/widget_category/parcel_home_widget/parcel_icon_holder_widget.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class ParcelChooseOurServiceSliverWidget extends StatelessWidget {
  const ParcelChooseOurServiceSliverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        padding: const EdgeInsets.only(bottom: 16, top: 16),
        child: Column(
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Row(
                spacing: 10,
                children: [
                  const ParcelIconHolderWidget(
                    icon: CupertinoIcons.star_circle_fill,
                    iconColor: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                  Text(
                    "Why choose our service",
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ListView.separated(
                itemCount: _whyChooseOurServiceList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (c, i) => ChooseWidgetCard(i: i),
              ),
            )
          ],
        ),
      ),
    );
  }
}

///
///  choose widget card
///

class ChooseWidgetCard extends StatelessWidget {
  final int i;
  const ChooseWidgetCard({super.key, required this.i});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: i == 0 ? 18 : 0,
        right: i == 3 ? 18 : 0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300),
          BoxShadow(color: Colors.grey.shade400),
          BoxShadow(color: Colors.grey.shade500),
          BoxShadow(color: Colors.grey.shade600),
          BoxShadow(color: Colors.grey.shade700),
          BoxShadow(color: Colors.grey.shade800),
          BoxShadow(color: Colors.grey.shade900),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ParcelIconHolderWidget(
            icon: _whyChooseOurServiceList[i].icondata,
            iconColor: Colors.black,
            backgroundColor: Colors.grey.shade200,
          ),
          Text(
            _whyChooseOurServiceList[i].title,
            style: robotoBold.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            _whyChooseOurServiceList[i].content,
            style: robotoBold.copyWith(
                color: Colors.black38,
                fontWeight: FontWeight.w300),
          )
        ],
      ),
    );
  }
}

List<_WhyChooseOurServiceModel> _whyChooseOurServiceList = [
  _WhyChooseOurServiceModel(
    icondata: Icons.timer_sharp,
    title: "Fast Delivery",
    content: "Some-day delivery for local packages",
  ),
  _WhyChooseOurServiceModel(
    icondata: Icons.location_on_outlined,
    title: "Live Tracking",
    content: "Monitor your package in real-time",
  ),
  _WhyChooseOurServiceModel(
    icondata: CupertinoIcons.shield_fill,
    title: "Safe Handling",
    content: "Your items protected and insured",
  ),
  _WhyChooseOurServiceModel(
    icondata: Icons.attach_money_sharp,
    title: "Best Prices",
    content: "Competitive and transparent rates",
  ),
];

class _WhyChooseOurServiceModel {
  final IconData icondata;
  final String title;
  final String content;

  _WhyChooseOurServiceModel({
    required this.icondata,
    required this.title,
    required this.content,
  });
}
