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
      isDismissible: true,
      enableDrag: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Trip Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Locations Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.location_on, size: 16, color: Colors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pickupLocation,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.location_on, size: 16, color: Colors.red),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dropoffLocation,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Connecting line
                    Positioned(
                      left: 12,
                      top: 24,
                      bottom: 24,
                      child: Container(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fare Amount',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹$totalFare',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/image/money.png', width: 20, height: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Cash',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
    context: Get.context!,
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
    context: Get.context!,
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
    context: Get.context!,
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  "Reason for cancellation",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please tell us why you want to cancel your ride",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
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
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () async {
                                bool confirmed = await showCancelConfirmationSheet(
                                  context,
                                  bookingId,
                                  reason,
                                );
                                if (context.mounted && confirmed) {
                                  Navigator.pop(context, true);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // "Don't Cancel" button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Keep my ride", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    context: Get.context!,
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Lottie.asset(
                'assets/animation/searching_drivers.json',
                height: 140,
              ),
              const SizedBox(height: 16),
              const Text(
                "Cancel this ride?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to cancel? This action cannot be undone.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("No, Back", style: TextStyle(color: Colors.black87, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
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
                                  bool success = await vehicleController.cancelBookingAndVerify(
                                    bookingcancelData,
                                    bookingId,
                                  );
                                  if (success) {
                                    // Feedback and navigation are handled globally by _handleRideCancellation in Taxi_home.dart
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text("Yes, Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                      }),
                    ),
                  ),
                ],
              ),
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
    context: Get.context!,
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
    context: Get.context!,
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
                    () => DashboardScreen(pageIndex: 0, fromSplash: false),
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
