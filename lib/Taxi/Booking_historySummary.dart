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
class RideSummaryScreen extends StatefulWidget {
  final String date;
  final String time;
  final String type;
  final String image;
  final String from;
  final String fareamount;
  final String to;
  final int captionid;
  final int bookingid;
  final double fromlat;
  final String drivenkm;
  final double fromlong;
  final double tolat;
  final double tolong;
  final bool isReviewed;

  RideSummaryScreen({
    required this.date,
    required this.time,
    required this.type,
    required this.image,
    required this.fareamount,
    required this.from,
    required this.to,
    required this.captionid,
    required this.bookingid,
    required this.fromlat,
    required this.fromlong,
    required this.drivenkm,
    required this.tolat,
    required this.tolong,
    required this.isReviewed,
  });

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  final BookingController controller = Get.find<BookingController>();
  final DriverController mapcontroller = Get.put(
    DriverController(apiClient: Get.find()),
  );
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  late LatLng pickup;
  late LatLng dropoff;
  late LatLng center;
  String googleMapsApiKey = "";
  bool routeDrawn = false;
  CaptainDetailsData? _captainDetails;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isReviewSubmitted = false;

  @override
  void initState() {
    super.initState();
    Get.put(DriverController(apiClient: Get.find()));
    if (widget.captionid != 0) {
      _loadCaptainDetails();
    }
    pickup = LatLng(widget.fromlat, widget.fromlong);
    dropoff = LatLng(widget.tolat, widget.tolong);
    center = LatLng(widget.fromlat, widget.fromlong);

    loadMapKeyAndDrawRoute();
  }

  Future<void> _loadCaptainDetails() async {
    print("🚀 Loading captain details in screen...");
    final details = await mapcontroller.fetchCaptainDetails(widget.captionid);
    if (mounted) {
      setState(() {
        _captainDetails = details;
      });
    }
  }

  Future<void> loadMapKeyAndDrawRoute() async {
    await mapcontroller.loadGoogleMapKey();
    googleMapsApiKey = mapcontroller.googleMapsApiKey ?? "";

    if (googleMapsApiKey.isNotEmpty) {
      await drawRoutePolyline();
    } else {
      debugPrint("❌ Google Maps API Key is empty");
    }
  }

  Future<void> drawRoutePolyline() async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(pickup.latitude, pickup.longitude),
        destination: PointLatLng(dropoff.latitude, dropoff.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = result.points
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Theme.of(context).primaryColor,
            width: 5,
            points: routePoints,
          ),
        };
        routeDrawn = true;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              pickup.latitude < dropoff.latitude
                  ? pickup.latitude
                  : dropoff.latitude,
              pickup.longitude < dropoff.longitude
                  ? pickup.longitude
                  : dropoff.longitude,
            ),
            northeast: LatLng(
              pickup.latitude > dropoff.latitude
                  ? pickup.latitude
                  : dropoff.latitude,
              pickup.longitude > dropoff.longitude
                  ? pickup.longitude
                  : dropoff.longitude,
            ),
          ),
          80,
        ),
      );
    } else {
      debugPrint('❌ Polyline fetch failed: ${result.errorMessage}');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: CustomAppBar3(title: 'Booking History Details'.tr, backButton: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120), // 👈 safe for floating nav
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 900),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 40,
                curve: Curves.easeOutQuad,
                child: FadeInAnimation(child: widget),
              ),
              children: [

                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition:
                    CameraPosition(target: pickup, zoom: 14),
                    markers: {
                      Marker(
                        markerId: const MarkerId('pickup'),
                        position: pickup,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                      ),
                      Marker(
                        markerId: const MarkerId('dropoff'),
                        position: dropoff,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                    polylines: _polylines,
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Location Details",
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        locationRow(
                          "Pickup Point:",
                          widget.from,
                          widget.fromlat,
                          widget.fromlong,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        locationRow(
                          "Drop-off Point:",
                          widget.to,
                          widget.tolat,
                          widget.tolong,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                if (widget.captionid != 0 && _captainDetails != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Captain Details",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                      ),
                    ),
                  ),

                if (widget.captionid != 0 && _captainDetails != null)
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_captainDetails!.vehicleTypeDetails.name} Ride",
                                    style: robotoBold.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${widget.date}${widget.time}",
                                    style: robotoRegular.copyWith(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_captainDetails!.vehicle.vehicleNumber}',
                                    style: robotoRegular.copyWith(
                                      fontSize: 14,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                widget.image.startsWith('http')
                                    ? Image.network(widget.image, height: 50)
                                    : Image.asset(widget.image, height: 50),
                                const SizedBox(height: 6),
                                Text(
                                  _captainDetails!.captain.name ?? '',
                                  style: robotoBold.copyWith(fontSize: 14),
                                ),
                                Text(
                                  _captainDetails!.vehicleTypeDetails.name ?? '',
                                  style: robotoRegular.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Booking Details",
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: widget.type == 'accepted'
                                    ? Colors.cyan
                                    : widget.type == 'completed'
                                    ? Colors.green
                                    : widget.type == 'cancelled'
                                    ? Colors.red
                                    : widget.type == 'pickedup'
                                    ? Colors.purple
                                    : widget.type == 'pending'
                                    ? Colors.blueGrey
                                    : widget.type == 'dropped'
                                    ? Colors.indigoAccent
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                widget.type.capitalizeFirst ?? "",
                                style: robotoRegular.copyWith(
                                  fontSize: 15,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildFareRow('Booking Id', "${widget.bookingid}"),
                        _buildFareRow('Driven KM', "${widget.drivenkm} KM"),
                        _buildFareRow(
                          'Booking Fare',
                          "₹${widget.fareamount}",
                          isBold: true,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),

                if (widget.type == 'completed' && !_isReviewSubmitted && widget.captionid != 0 && !widget.isReviewed)
                  _buildReviewSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Rate your Captain",
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating ? Colors.amber : Colors.grey,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () async {
                        if (_rating == 0) {
                          Get.snackbar("Required", "Please provide a rating");
                          return;
                        }
                        if (_commentController.text.isEmpty) {
                          Get.snackbar("Required", "Please provide a comment");
                          return;
                        }

                        bool success = await controller.submitCaptainReview(
                          widget.captionid,
                          widget.bookingid,
                          _rating.toDouble(),
                          _commentController.text,
                        );

                        if (success) {
                          setState(() {
                            _isReviewSubmitted = true;
                          });
                          controller.fetchBookingHistory(isInitial: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Submit Review",
                        style: robotoBold.copyWith(color: Colors.white),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(
      String label,
      String amount, {
        bool isBold = false,
        Color? color,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          "${amount}",
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget locationRow(
      String title,
      String address,
      double lat,
      double lng,
      Color iconColor,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: robotoBold.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(address, style: robotoMedium.copyWith(
              ),),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.directions, color: Colors.blue),
          onPressed: () async {
            final url = Uri.parse(
              "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
            );
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              Get.snackbar("Error", "Could not open Google Maps");
            }
          },
        ),
      ],
    );
  }
}