import 'package:flutter/material.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ParcelHowouSrerviceWorkWidget extends StatelessWidget {
  const ParcelHowouSrerviceWorkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(left: 13, right: 13, bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        height: 680,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "How Our Service Works",
              style: robotoBold.copyWith(
                color: Colors.black,
                fontSize: Dimensions.fontSizeExtraLarge,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            /**
             * ? want to replace the below code to image
             * ? i just add to hold the place
             */
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
                image:  DecorationImage(
                  image: AssetImage(
                    Images.parcelBanner,
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),

            /*
             * time line like style
             */

            FixedTimeline.tileBuilder(
              mainAxisSize: MainAxisSize.min,
              direction: Axis.vertical,
              builder: TimelineTileBuilder(
                indicatorBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2,
                        spreadRadius: 1,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(5.3),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                  ),
                ),
                indicatorPositionBuilder: (context, index) => 0,
                endConnectorBuilder: (context, index) => index == 2
                    ? null
                    : const SolidLineConnector(
                        color: Colors.black12,
                        thickness: 1.8,
                      ),
                itemExtent: 130,
                nodePositionBuilder: (context, index) => 0,
                itemCount: _howOurServiceWorkList.length,
                contentsBuilder: (context, index) =>
                    ParcelHowouSrerviceWorkCardWidget(
                  index: index,
                ),
              ),
              clipBehavior: Clip.none,
            ),

          ],
        ),
      ),
    );
  }
}

class ParcelHowouSrerviceWorkCardWidget extends StatelessWidget {
  final int index;
  const ParcelHowouSrerviceWorkCardWidget({
    super.key,
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              _howOurServiceWorkList[index].title,
              style: robotoBold.copyWith(
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 280),
            padding:
                const EdgeInsets.only(left: 15, right: 20, top: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _howOurServiceWorkList[index].content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                color: Colors.black38,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<_HowOurServiceWork> _howOurServiceWorkList = const [
  _HowOurServiceWork(
    title: "Got a Parcel? we've Got You!",
    content:
        "We'll pick it up from your door and deliver it the same day.Quick, easy, and reliable!",
  ),
  _HowOurServiceWork(
    title: "Send it Today, Get it There Today",
    content:
        "From doorstep pick-up to same-day delivery, we make it super simple for you.",
  ),
  _HowOurServiceWork(
    title: "Pick-up. Deliver. Done.",
    content:
        "We handle you parcels like pros-from your door to theirs, all in one day.",
  )
];

class _HowOurServiceWork {
  final String title;
  final String content;

  const _HowOurServiceWork({
    required this.title,
    required this.content,
  });
}
