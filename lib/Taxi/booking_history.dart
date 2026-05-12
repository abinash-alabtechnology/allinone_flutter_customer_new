import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../helper/responsive_helper.dart';
import 'Booking_historySummary.dart';
import 'Controller/bookingController.dart';
import 'package:shimmer/shimmer.dart';



class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final BookingController controller = Get.put(BookingController(apiClient: Get.find()));
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.fetchVehicleList();
    // controller.fetchUsers();
    controller.fetchBookingHistory(isInitial: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        controller.fetchBookingHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  String convertDate(String datefo) {
    List<String> dates = datefo.split(" ");
    DateTime date = DateTime.parse("${dates[0]}T${dates[1]}");
    String formattedDate = DateFormat('MMM, dd').format(date.toLocal());
    return formattedDate;
  }

  String convertTime(String datefo) {
    List<String> dates = datefo.split(" ");
    DateTime date = DateTime.parse("${dates[0]}T${dates[1]}");
    final formatted = DateFormat('hh:mm a').format(date.toLocal());
    return formatted;
  }
  // String formatTime(DateTime dateTime) {
  //   final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
  //   final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return "${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period";
  // }
  //
  // String formatDate(DateTime dateTime) {
  //   const monthNames = [
  //     '', 'Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'Jun.',
  //     'Jul.', 'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.'
  //   ];
  //   return "${monthNames[dateTime.month]} ${dateTime.day.toString().padLeft(2, '0')}";
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey.shade100,
      appBar: CustomAppBar3(title: 'Booking History'.tr, backButton: false),
      body: Obx(() {
        if (controller.isLoading.value && controller.bookingList.isEmpty) {
             return ListView.separated(
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => buildBookingHistoryShimmer(),
          );
        }
        if (controller.bookingList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animation/empty_cart.json',
                  width: MediaQuery.of(context).size.height * 0.15,
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                const SizedBox(height: 20),
                Text(
                  "No bookings found",
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        return AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: controller.bookingList.length +
                (controller.isMoreLoading.value ? 1 : 0),
            separatorBuilder: (_, __) =>
            const Divider(height: 0, color: Colors.transparent),
            itemBuilder: (context, index) {
              if (index == controller.bookingList.length) {
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final ride = controller.bookingList[index];

              String imageUrl;
              String displayStatus =
              ride.rideStatus.toLowerCase() == 'in_progress'
                  ? 'pickedup'
                  : ride.rideStatus;

              try {
                final vehicle = controller.vehicleList
                    .firstWhere((v) => v.id == ride.vehiclePriceTypeId);
                imageUrl =
                "${AppConstants.baseUrl}${AppConstants.Vehicleimage}${vehicle.image}";
              } catch (e) {
                imageUrl = 'assets/image/booksedan.png';
              }

              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 1050),
                columnCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                child: SlideAnimation(
                  verticalOffset: 40,
                  curve: Curves.easeOutQuad,
                  child: FadeInAnimation(
                    child: SizedBox(
                      height: 110,
                      child: InkWell(
                        onTap: () {
                          Get.to(() => RideSummaryScreen(
                            bookingid: ride.id,
                            drivenkm: ride.distanceKm,
                            date: convertDate(ride.createdAt.toString()),
                            time: convertTime(ride.createdAt.toString()),
                            type: displayStatus,
                            fareamount: ride.fareAmount,
                            image: imageUrl,
                            from: ride.pickupLocation,
                            fromlat: ride.pickupLat,
                            fromlong: ride.pickupLng,
                            to: ride.dropoffLocation,
                            tolat: ride.dropoffLat,
                            tolong: ride.dropoffLng,
                            captionid: ride.captainId ?? 0,
                            isReviewed: ride.isReviewed,
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildBookingHistoryTile(
                            time: convertTime(ride.createdAt.toString()),
                            date:  convertDate(ride.createdAt.toString()),
                            pickup: ride.pickupLocation,
                            drop: ride.dropoffLocation,
                            drivenkm: ride.distanceKm,
                            fareamount: ride.fareAmount,
                            bookingId: ride.id,
                            status: displayStatus,
                            imageUrl: imageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      })
      ,

    );
  }
  Widget buildBookingHistoryTile({
    required String time,
    required String date,
    required int bookingId,
    required String pickup,
    required String drop,
    required String drivenkm,
    required String fareamount,
    required String status,
    required String imageUrl,
  }) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                height: 65,
                width: 1,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: colorofStatus(status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Booking ID : $bookingId ',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      pickup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                    ),
                    ),

                    Text(
                      drop,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                      ),                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 3,
          top: 3,
          child: Container(
            width: 90,
            padding: EdgeInsets.only(top: 4, bottom: 4),
            decoration: BoxDecoration(
                color: colorofStatus(status),
                borderRadius:  BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8))),
            child: Center(
              child: Text(
                firstLetterCaps(status),
                style: robotoBold.copyWith(
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Color colorofStatus(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.cyan;
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.blueGrey ;
      case "dropped":
        return Colors.indigoAccent;
        case "pickedup":
        return Colors.purple;
      case "in_progress":
        return Colors.blueGrey;
        case "cancelled":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String firstLetterCaps(String start) {
    if (start == 'in_progress') {
      return "Progress";
    }
    return start.substring(0, 1).toUpperCase() +
        start.substring(1).toLowerCase();
  }
}
Widget buildBookingHistoryShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Time & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 50, height: 14),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 70, height: 12),
                ],
              ),

              const SizedBox(width: 16),

              /// Divider
              Container(
                height: 65,
                width: 1,
                color: Colors.grey.shade300,
              ),

              const SizedBox(width: 16),

              /// Booking details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _shimmerBox(height: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _shimmerBox(width: double.infinity, height: 12),
                    const SizedBox(height: 6),
                    _shimmerBox(width: double.infinity, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// Status badge shimmer
        Positioned(
          right: 3,
          top: 3,
          child: Container(
            width: 90,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _shimmerBox({double? width, double? height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}


