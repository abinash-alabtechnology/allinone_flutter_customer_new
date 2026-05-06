import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/Taxi/sharedservice.dart';
import 'package:handy_allinone/Taxi/waitingdriver.dart';
import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/images.dart';
import 'Confirmedride.dart';
import 'Controller/DriverController.dart';
import 'Controller/vehiclelistController.dart';
import 'model/bookinghistorymodel.dart';
import 'model/captionmodel.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:lottie/lottie.dart';

void showTripDetailBottomSheet(
  BuildContext context,
  int bookingId,
  String rideStatus,
) async {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConstants.firebaseDBURL,
  ).ref('bookings/$bookingId');

  final snapshot = await databaseRef
      .get(); // ✅ One-time fetch, no onValue.listen
  final data = snapshot.value;

  if (data != null && data is Map) {
    final pickupLocation = data['pickup_location'] ?? 'Unknown pickup location';
    final dropoffLocation =
        data['dropoff_location'] ?? 'Unknown dropoff location';
    final totalFare = data['fare_amount']?.toString() ?? '0';

    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Pickup & Drop
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pickupLocation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 10, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dropoffLocation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total ₹$totalFare',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Paying by Cash',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/image/money.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } else {
    print("❌ No booking data found for ID $bookingId");
  }
}

void showwaitingdriverBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isDismissible: false,
    enableDrag: false,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: const FindingDriverContent(),
    ),
  );
}

void showRideScheduledsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isDismissible: false,
    enableDrag: false,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: const FindingDriverContent(),
    ),
  );
}

Future<bool> showCancelReasonBottomSheet(
  BuildContext context,
  int bookingId,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);

      return WillPopScope(
        onWillPop: () async => false,
        child: Padding(
          padding: mediaQuery.viewInsets,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animation/searching_drivers.json',
                  height: 120,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Why would you like to cancel?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                ...[
                  "Driver denied drop location",
                  "Driver demanded extra cash",
                  "Driver unresponsive on chat/call",
                  "Driver insisted on taking directly/offline",
                  "No Driver Found",
                  "Driver not moving",
                  "Other Reason",
                ].map((reason) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 100));

                        bool confirmed = await showCancelConfirmationSheet(
                          context,
                          bookingId,
                          reason,
                        );

                        if (context.mounted) {
                          Navigator.pop(
                            context,
                            confirmed,
                          ); // ✅ Always returns true or false
                        }
                      },
                      child: Text(reason, textAlign: TextAlign.center),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 10),

                // "Don't Cancel" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false); // ✅ Always returns false
                    },
                    child: const Text("Don't Cancel"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showCancelConfirmationSheet(
  BuildContext context,
  int? bookingId,
  String reason,
) async {
  final VehicleListController vehicleController = Get.put(
    VehicleListController(apiClient: Get.find()),
  );

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Lottie.asset(
                  'assets/animation/searching_drivers.json',
                  height: 120,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to cancel the ride?",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isLoading = vehicleController.isLoading.value;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            Map<String, dynamic> bookingcancelData = {
                              "booking_id": bookingId,
                              "cancel_reason": reason,
                              "type": "user",
                            };
                            bool success = await vehicleController
                                .cancelBookingAndVerify(
                                  bookingcancelData,
                                  bookingId,
                                );
                            if (success) {
                              await showBookingCancelledBottomSheet(
                                context,
                                null,
                                "cancelled",
                              );
                              await SharedService.clearOngoingBooking();
                              Get.find<SplashController>().showBottomNavBar();
                              Get.offAll(() => const DashboardScreen(
                                    pageIndex: 0,
                                    fromSplash: false,
                                  ));
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.red,
                            ),
                          )
                        : Text(
                            "Cancel Ride",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Don't Cancel",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showBookingCancelledBottomSheet(
  BuildContext context,
  String? crnNumber,
  String reason,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      "Booking Cancelled",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(Images.cancelGif, height: 60),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                crnNumber == null
                    ? "Your booking has\nbeen cancelled, Due to $reason"
                    : "Your booking with $crnNumber has\nbeen cancelled successfully, Due to $reason",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

void showRideScheduledBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row with Title and Grey Box
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Ride Scheduled',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your ride has been scheduled. Driver details will be shared 10 min before your pickup time.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
                  color: Color(0xFFBDBDBD), // grey[400]
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Got it button
            InkWell(
              onTap: () {
                print("ghthdgdthbt");
                try {
                  Get.offAll(
                    () => DashboardScreen(pageIndex: 1, fromSplash: false),
                  );
                } catch (e, stack) {
                  print('Navigation error: $e');
                  print('Stack: $stack');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
