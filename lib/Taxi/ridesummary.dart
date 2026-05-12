import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/widgets/custom_app_bar.dart';
import 'Controller/DriverController.dart';
import 'Controller/bookingController.dart';
import 'TripDetails.dart';
import 'booking_history.dart';
import 'chatscreen.dart';
import 'model/captionmodel.dart';
import 'sharedservice.dart';

class RideConfirmedScreen extends StatefulWidget {
  final int Bookingid;
  final int driverid;
  final int userId;
  final String otp;

  const RideConfirmedScreen({
    super.key,
    required this.Bookingid,
    required this.driverid,
    required this.userId,
    required this.otp,
  });

  @override
  State<RideConfirmedScreen> createState() => _RideConfirmedScreenState();
}

class _RideConfirmedScreenState extends State<RideConfirmedScreen> with SingleTickerProviderStateMixin {
  final DriverController controller = Get.put(
    DriverController(apiClient: Get.find()),
  );
  final LocationController _locationController = Get.find<LocationController>();
  CaptainDetailsData? _captainDetails;
  String? rideStatus;
  String? fareAmount;
  StreamSubscription<DatabaseEvent>? _rideStatusSubscription;

  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    Get.put(DriverController(apiClient: Get.find()));
    _loadCaptainDetails();
    _listenToRideStatus(context);
  }

  Future<void> _loadCaptainDetails() async {
    print("🚀 Loading captain details in screen...");
    final details = await controller.fetchCaptainDetails(widget.driverid);
    await controller.fetchCaptainRating(widget.driverid);
    if (mounted) {
      setState(() {
        _captainDetails = details;
      });
    }
  }
  Future<void> _makePhoneCall() async {
    final Uri uri = Uri.parse("tel:${8072126469}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri uri = Uri.parse(
      "https://wa.me/+91${8072126469}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  void _listenToRideStatus(BuildContext context) {
    final ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConstants.firebaseDBURL,
    ).ref('bookings/${widget.Bookingid}');

    _rideStatusSubscription = ref.onValue.listen(
      (event) {
        if (!event.snapshot.exists) {
          print(
            "⚠️ Booking ID '${widget.Bookingid}' not found. Navigating to History...",
          );
          _navigateToHistory(context);
          return;
        }

        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          print("📡 Firebase Update: $data");
          if (mounted) {
            setState(() {
              rideStatus = data['ride_status']?.toString();
              fareAmount = data['fare_amount']?.toString();
            });

            if (rideStatus == 'completed') {
              print("✅ Ride completed — navigating to History screen...");
              _navigateToHistory(context);
            }
          }
        }
      },
      onError: (error) {
        print("❌ Firebase Error: $error");
      },
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _rideStatusSubscription?.cancel();
    super.dispose();
  }

  void _navigateToHistory(BuildContext context) async {
    await SharedService.clearOngoingBooking();
    Navigator.pop(context);
    Get.offAll(() => DashboardScreen(pageIndex: 6, fromSplash: false));
    // Get.to(() => HistoryScreen());
  }

  String _formatRideStatus(String status) {
    if (status == 'in_progress') return 'Pickedup';
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1);
  }
  Future<bool> _handleBackNavigation(BuildContext context) async {
    if (rideStatus == "completed") {
      _navigateToHistory(context);
      return true;
    } else {
      Get.offAll(() => DashboardScreen(
        pageIndex: 0,
        fromSplash: false,
      ));
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (rideStatus == "completed") {
          _navigateToHistory(context);
          return true;
        } else {
          Get.offAll(() => DashboardScreen(pageIndex: 0, fromSplash: false));
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar3(
          title:
              "Your ride ${widget.Bookingid} is ${_formatRideStatus(rideStatus??"")}.",
          backButton: true,
          onBackPressed: () async {
            await _handleBackNavigation(context);
          },
        ),

        body: Obx(() {
          if (controller.isLoading.value) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(height: 20, width: 150, color: Colors.white),
                        const Spacer(),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                        ),
                        const SizedBox(width: 8),
                        Container(height: 40, width: 40, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 14,
                              width: 100,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Container(height: 30, width: 80, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 45, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(height: 45, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 45,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          } else if (_captainDetails == null) {
            return const Center(child: Text("No details available"));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "Vehicle Number : ${_captainDetails!.vehicle.vehicleNumber}",
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/image/driver_icon.png',
                        ),
                        radius: 18,
                      ),
                      const SizedBox(width: 8),
                      Image.network(
                        '${AppConstants.baseUrl}${AppConstants.Vehicleimage}${_captainDetails!.vehicleTypeDetails.image}',
                        height: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Caption Name : ${_captainDetails!.captain.name}",
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (controller.captainRating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.amber.shade400, Colors.orange.shade400],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${controller.captainRating!.averageRating?.toStringAsFixed(1) ?? '0.0'}",
                                    style: robotoBold.copyWith(fontSize: 14, color: Colors.white),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(width: 1, height: 12, color: Colors.white.withOpacity(0.5)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${controller.captainRating!.totalReviews} reviews",
                                    style: robotoMedium.copyWith(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 5),
                          Text(
                            _captainDetails!.vehicleTypeDetails.name,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          // light transparent green
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          "OTP :${widget.otp}",
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final phone = _captainDetails?.captain.mobileNumber;
                            if (phone != null && phone.isNotEmpty) {
                              final Uri phoneUri = Uri.parse('tel:$phone');
                              launchUrl(phoneUri);
                            } else {
                              Get.snackbar(
                                'Error',
                                'Driver phone number not available',
                              );
                            }
                          },
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(
                              () => ChatScreentaxi(
                                userid: widget.userId.toString(),
                                bookingId: widget.Bookingid.toString(),
                                // Replace with real customer ID
                                driverId: widget.driverid.toString(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text("Chat"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Fare ₹${fareAmount ?? '--'}",
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("Please agree on the final price with the driver"),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.money, color: Colors.green),
                            SizedBox(width: 8),
                            Text("Cash"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (rideStatus != null) {
                        showTripDetailBottomSheet(
                          context,
                          widget.Bookingid,
                          rideStatus!,
                        );
                      }
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text("Trip Details"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),

          Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
          children:  [
          Icon(Icons.support_agent, color: Colors.red),
          SizedBox(width: 8),
          Text(
          "Admin Support",
          style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          // fontWeight: FontWeight.w600,
          ),
          ),
          ],
          ),
          const SizedBox(height: 10),
            Text(
              "You're riding with us.\n"
                  "For emergencies or any support during the trip, "
                  "reach out to our admin team instantly.",
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
          const SizedBox(height: 16),

          Row(
          children: [
          Expanded(
          child: ElevatedButton.icon(
          onPressed: _makePhoneCall,
          icon:  Icon(Icons.call,color: Theme.of(context).cardColor,),
          label: Text("phoneNumber",style: robotoMedium.copyWith(color: Theme.of(context).cardColor),),
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,

          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          ),
          ),
          ),
          ),
          const SizedBox(width: 12),
          Expanded(
          child: ElevatedButton.icon(
          onPressed: _openWhatsApp,
            icon: Image.asset(
              "assets/image/whatsapp.png",
              height: 20,
              width: 20,
               color: Theme.of(context).cardColor, // optional
            ),
          label:  Text("WhatsApp",style: robotoMedium.copyWith(color:  Theme.of(context).cardColor),),
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          ),
          ),
          ),
          ),
          ],
          ),
          ],
          ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_rippleController.value * (i + 1) * 0.3),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.red.withOpacity(0.3 * (1 - _rippleController.value)),
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if(_locationController.position.latitude != 0) {
                           controller.sendSosAlert(
                            bookingId: widget.Bookingid,
                            captainId: widget.driverid,
                            customerId: widget.userId,
                            lat: _locationController.position.latitude,
                            lng: _locationController.position.longitude,
                          );
                        } else {
                          await _locationController.getCurrentLocation(true);
                          controller.sendSosAlert(
                            bookingId: widget.Bookingid,
                            captainId: widget.driverid,
                            customerId: widget.userId,
                            lat: _locationController.position.latitude,
                            lng: _locationController.position.longitude,
                          );
                        }
                      },
                      icon: const Icon(Icons.emergency, color: Colors.white),
                      label: Text(
                        "SOS",
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}


