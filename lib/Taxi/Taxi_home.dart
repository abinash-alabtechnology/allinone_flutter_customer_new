import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:shimmer/shimmer.dart';
import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:geocoding/geocoding.dart';
import 'package:handy_allinone/util/styles.dart';
import '../features/splash/controllers/splash_controller.dart';
import 'Controller/DriverController.dart';
import 'Controller/Recentlocationservice.dart';
import 'Controller/vehiclelistController.dart';
import 'Locationpicker.dart';
import 'TripDetails.dart';
import 'ridesummary.dart';
import 'sharedservice.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';

class Taxihome extends StatefulWidget {
  final bool showBottomSheet;
  final int? bookingId;
  final int? userId;
  final String? otp;

  const Taxihome({
    Key? key,
    this.showBottomSheet = false,
    this.bookingId,
    this.userId,
    this.otp,
  }) : super(key: key);

  @override
  State<Taxihome> createState() => _TaxihomeState();
}

class _TaxihomeState extends State<Taxihome> with WidgetsBindingObserver {
  final VehicleListController vehicleController = Get.put(
    VehicleListController(apiClient: Get.find()),
  );
  final DriverController controller = Get.put(
    DriverController(apiClient: Get.find()),
  );
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  LatLng? _currentPosition;
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  int retryCount = 0;
  Timer? bookingTimer;
  String? _pickupAddress;
  String? _dropoffAddress;
  late GoogleMapController _mapController;
  final ValueNotifier<Set<Marker>> markers = ValueNotifier<Set<Marker>>({});
  late String googleMapsApiKey = controller.googleMapsApiKey ?? "";

  String _currentAddress = 'Fetching current address...';
  final Map<String, double> markerRotations = {};
  Timer? _pickupRotationTimer;
  Timer? _driverFetchTimer;
  final RxBool showDraggableSheet = true.obs;
  final showVehiclelist = true.obs;
  int selectedRideIndex1 = 0;
  final selectedRideIndex = (-1).obs;
  List<RecentLocation> recentLocations = [];
  Set<Polyline> _polylines = {};
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadRecentLocations();
    controller..loadGoogleMapKey();
    Get.find<BannerController>().getTaxiBannerList(true);
    WidgetsBinding.instance.addObserver(this);
    _startDriverStream();
    if (widget.showBottomSheet && widget.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showContactingDriversBottomSheet(
          context,
          widget.bookingId!,
          widget.userId!,
          widget.otp!,
        );
      });
    }
    initCall();
    if (_pickupAddress != null) {
      pickupController.text = _pickupAddress!;
    }
    if (_dropoffAddress != null) {
      destinationController.text = _dropoffAddress!;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pickupRotationTimer?.cancel();
    _driverFetchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentLocations() async {
    final locations = await RecentLocationService.getRecentLocations();
    setState(() {
      recentLocations = locations;
    });
    for (var loc in recentLocations) {
      print("📍 ${loc.address} (${loc.latitude}, ${loc.longitude})");
    }
  }

  Future<void> _getCurrentLocation() async {
    _startAllMarkersAnimation();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);
    _pickupLatLng = _currentPosition;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      _pickupAddress = '${place.name}, ${place.subLocality}, ${place.locality}';
    }

    setState(() {
      _currentAddress = _pickupAddress!;
      pickupController.text = _pickupAddress!;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    debugPrint(" Updating Markers...");
    _startAllMarkersAnimation();
    final updatedMarkers = <Marker>{
      if (_pickupLatLng != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      if (_dropoffLatLng != null)
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoffLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
    };
    markers.notifyListeners();
    markers.value = updatedMarkers;
  }

  void _startDriverStream() {
    _driverFetchTimer?.cancel();

    _driverFetchTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      // debugPrint("Fetching realtime driver data...");
      await controller.fetchRealtimeDrivers();
    });
  }

  void _startAllMarkersAnimation([String? vehicleType]) async {
    _pickupRotationTimer?.cancel();
    markerRotations.clear();

    final Map<String, BitmapDescriptor> vehicleIcons = {
      'bike': await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/image/bikemap.png',
      ),
      'auto': await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/image/automap.png',
      ),
      'car': await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/image/cabmap.png',
      ),
    };

    Map<String, LatLng> lastPositions = {};

    _pickupRotationTimer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) async {
      final filteredDrivers = controller.driverList.where((driver) {
        if (_pickupLatLng == null) return false;

        final distanceInMeters = Geolocator.distanceBetween(
          _pickupLatLng!.latitude,
          _pickupLatLng!.longitude,
          driver.lat,
          driver.long,
        );

        final matchesVehicle =
            vehicleType == null ||
            driver.type.toLowerCase() == vehicleType.toLowerCase();

        return distanceInMeters <= 3000 && matchesVehicle;
      }).toList();
      // print("Filtered ${filteredDrivers.length} drivers within 5km radius.");
      final animatedMarkers = <Marker>{};

      for (int i = 0; i < filteredDrivers.length; i++) {
        final driver = filteredDrivers[i];
        final LatLng currentPosition = LatLng(driver.lat, driver.long);
        final String markerId = 'driver_${driver.type}_$i';

        final LatLng lastPosition = lastPositions[markerId] ?? currentPosition;
        lastPositions[markerId] = currentPosition;

        double speedFactor = driver.speed;
        double newLat =
            lastPosition.latitude +
            (currentPosition.latitude - lastPosition.latitude) * speedFactor;
        double newLng =
            lastPosition.longitude +
            (currentPosition.longitude - lastPosition.longitude) * speedFactor;

        final icon =
            vehicleIcons[driver.type.toLowerCase()] ??
            BitmapDescriptor.defaultMarker;

        animatedMarkers.add(
          Marker(
            markerId: MarkerId(markerId),
            position: LatLng(newLat, newLng),
            rotation: driver.heading,
            icon: icon,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }

      final baseMarkers = <Marker>{
        if (_pickupLatLng != null)
          Marker(
            markerId: const MarkerId('pickup'),
            position: _pickupLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        if (_dropoffLatLng != null)
          Marker(
            markerId: const MarkerId('dropoff'),
            position: _dropoffLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
      };

      markers.value = {...baseMarkers, ...animatedMarkers};
      markers.notifyListeners();
    });
  }

  void showCancelConfirmationbookingSheet(
    BuildContext context,
    int bookingId,
    String reason,
    int? retryStep,
    int userId,
  ) {
    final VehicleListController vehicleController = Get.put(
      VehicleListController(apiClient: Get.find()),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async {
            Get.offAll(() => DashboardScreen(pageIndex: 0, fromSplash: false));
            return false;
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Are you sure you want to cancel the ride?",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Cancel Ride button
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
                              print("dfsggfvs $success");
                              if (success) {
                                bookingTimer?.cancel();
                                // showBookingCancelledBottomSheet handles the feedback globally via background listener
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

                // Retry if available
                if (retryStep! < 2)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        int nextRadius = retryStep == 0 ? 6 : 9;

                        Map<String, dynamic> retryBooking = {
                          "booking_id": bookingId,
                          "radius": nextRadius,
                        };

                        bool success = await vehicleController.retrybooking(
                          retryBooking,
                        );

                        if (success && ctx.mounted) {
                          print("ghgfhf");
                          retryCount++; // increase retry count
                          startRetryTimer(ctx, bookingId, userId);
                          Navigator.pop(ctx); // restart timer
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Don't Cancel gfhh",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void startRetryTimer(BuildContext context, int bookingId, int userId) {
    bookingTimer?.cancel(); // Cancel previous timer

    String reason =
        "No drivers accepted your ride within ${2 * (retryCount + 1)} minutes.";

    bookingTimer = Timer(const Duration(minutes: 2), () async {
      if (!context.mounted) return;

      debugPrint("🔔 Retry timer fired — showing cancel confirmation");

      // Give it time to close cleanly
      // await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        showCancelConfirmationbookingSheet(
          context,
          bookingId,
          reason,
          retryCount,
          userId,
        );
      }
    });
  }

  Future<void> _drawPolyline() async {
    if (_pickupLatLng == null || _dropoffLatLng == null) return;

    final polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);
    List<LatLng> polylineCoordinates = [];

    final PolylineResult result = await polylinePoints
        .getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(
              _pickupLatLng!.latitude,
              _pickupLatLng!.longitude,
            ),
            destination: PointLatLng(
              _dropoffLatLng!.latitude,
              _dropoffLatLng!.longitude,
            ),
            mode: TravelMode.driving,
          ),
        );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: Theme.of(context).primaryColor,
            width: 5,
          ),
        );
      });
    } else {
      print("❌ No polyline points found: ${result.errorMessage}");
    }
  }

  double _calculateDistanceKm() {
    final dx = _pickupLatLng!.latitude - _dropoffLatLng!.latitude;
    final dy = _pickupLatLng!.longitude - _dropoffLatLng!.longitude;
    return sqrt(dx * dx + dy * dy) * 111;
  }

  double _calculateEstimatedFare(String base, String perKm, String perMin) {
    final baseFare = double.tryParse(base) ?? 0;
    final pricePerKm = double.tryParse(perKm) ?? 0;
    final distanceKm = _calculateDistanceKm();
    final fare = distanceKm * pricePerKm;
    final total = fare < baseFare ? baseFare : fare;
    return total;
  }

  double _calculateDiscountedFare(double fare, int? discount) {
    if (discount == null || discount <= 0) return fare;
    return fare * (1 - (discount / 100));
  }

  Future<void> _processSelectedLocation({
    required String status,
    required LatLng latLng,
    required String address,
  }) async {
    setState(() async {
      if (status == "Pickup") {
        _pickupLatLng = latLng;
        _pickupAddress = address;
        pickupController.text = _pickupAddress!;
        print("✅ Pickup set from recent: $_pickupAddress ($_pickupLatLng)");
        await _drawPolyline();
      }

      if (status == "Dropoff") {
        _dropoffLatLng = latLng;
        _dropoffAddress = address;
        destinationController.text = _dropoffAddress!;
        _startAllMarkersAnimation('bike');
        Get.find<SplashController>().hideBottomNav();
        print("✅ Dropoff set from recent: $_dropoffAddress ($_dropoffLatLng)");
        await _drawPolyline();
      }

      _updateMarkers();

      if (_pickupLatLng != null && _dropoffLatLng != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            _pickupLatLng!.latitude < _dropoffLatLng!.latitude
                ? _pickupLatLng!.latitude
                : _dropoffLatLng!.latitude,
            _pickupLatLng!.longitude < _dropoffLatLng!.longitude
                ? _pickupLatLng!.longitude
                : _dropoffLatLng!.longitude,
          ),
          northeast: LatLng(
            _pickupLatLng!.latitude > _dropoffLatLng!.latitude
                ? _pickupLatLng!.latitude
                : _dropoffLatLng!.latitude,
            _pickupLatLng!.longitude > _dropoffLatLng!.longitude
                ? _pickupLatLng!.longitude
                : _dropoffLatLng!.longitude,
          ),
        );
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      } else if (status == "Pickup" && _pickupLatLng != null) {
        _mapController.animateCamera(CameraUpdate.newLatLng(_pickupLatLng!));
      } else if (status == "Dropoff" && _dropoffLatLng != null) {
        Get.find<SplashController>().hideBottomNav();
        _mapController.animateCamera(CameraUpdate.newLatLng(_dropoffLatLng!));
      }

      if (_pickupLatLng != null && _dropoffLatLng != null) {
        vehicleController.fetchVehicleList(
          pickupLat: _pickupLatLng!.latitude,
          pickupLng: _pickupLatLng!.longitude,
          dropLat: _dropoffLatLng!.latitude,
          dropLng: _dropoffLatLng!.longitude,
        );
      }
    });
  }

  Future<void> _openLocationPicker(String status) async {
    if (_pickupLatLng == null || _pickupAddress == null) {
      if (_currentPosition != null && _currentAddress.isNotEmpty) {
        _pickupLatLng = _currentPosition!;
        _pickupAddress = _currentAddress;
      } else {
        return;
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          status: status,
          pickuplatLng: _pickupLatLng!,
          pickupaddress: _pickupAddress!,
        ),
      ),
    );

    if (result != null) {
      if (status == "Pickup" &&
          result['pickupLatLng'] != null &&
          result['pickupAddress'] != null) {
        setState(() {
          _pickupLatLng = result['pickupLatLng'];
          _pickupAddress = result['pickupAddress'];
          pickupController.text = _pickupAddress!;
        });
        print("✅ Updated Pickup Address: $_pickupAddress");
        print("✅ Updated Pickup LatLng: $_pickupLatLng");
        await _drawPolyline();
      }

      if (status == "Dropoff" &&
          result['dropoffLatLng'] != null &&
          result['dropoffAddress'] != null) {
        setState(() {
          Get.find<SplashController>().hideBottomNav();
          _dropoffLatLng = result['dropoffLatLng'];
          _dropoffAddress = result['dropoffAddress'];
          destinationController.text = _dropoffAddress!;
        });
        _startAllMarkersAnimation('bike');
        await _drawPolyline();
      }

      setState(() {
        _updateMarkers();
      });

      if (_pickupLatLng != null && _dropoffLatLng != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            _pickupLatLng!.latitude < _dropoffLatLng!.latitude
                ? _pickupLatLng!.latitude
                : _dropoffLatLng!.latitude,
            _pickupLatLng!.longitude < _dropoffLatLng!.longitude
                ? _pickupLatLng!.longitude
                : _dropoffLatLng!.longitude,
          ),
          northeast: LatLng(
            _pickupLatLng!.latitude > _dropoffLatLng!.latitude
                ? _pickupLatLng!.latitude
                : _dropoffLatLng!.latitude,
            _pickupLatLng!.longitude > _dropoffLatLng!.longitude
                ? _pickupLatLng!.longitude
                : _dropoffLatLng!.longitude,
          ),
        );
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      } else if (status == "Pickup" && _pickupLatLng != null) {
        _mapController.animateCamera(CameraUpdate.newLatLng(_pickupLatLng!));
      } else if (status == "Dropoff" && _dropoffLatLng != null) {
        Get.find<SplashController>().hideBottomNav();
        _mapController.animateCamera(CameraUpdate.newLatLng(_dropoffLatLng!));
      }

      if (_pickupLatLng != null && _dropoffLatLng != null) {
        vehicleController.fetchVehicleList(
          pickupLat: _pickupLatLng!.latitude,
          pickupLng: _pickupLatLng!.longitude,
          dropLat: _dropoffLatLng!.latitude,
          dropLng: _dropoffLatLng!.longitude,
        );
      }
    }
  }

  String _getRideTitle(int index) {
    if (index >= 0 && index < vehicleController.vehicleList.length) {
      return vehicleController.vehicleList[index].name;
    }
    return 'a Ride';
  }

  Widget _buildLocationTile({
    required Color iconColor,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.text.isEmpty ? "Select Location" : controller.text,
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: controller.text.isEmpty ? Colors.grey : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _onVehicleSelected(int index) {
    setState(() {
      selectedRideIndex1 = index;

      final selectedVehicle = vehicleController.vehicleList[selectedRideIndex1];
      final vehicleName = selectedVehicle.vehicletype.toLowerCase();

      if (vehicleName.contains('bike')) {
        _startAllMarkersAnimation('bike');
      } else if (vehicleName.contains('auto')) {
        _startAllMarkersAnimation('auto');
      } else if (vehicleName.contains('car')) {
        _startAllMarkersAnimation('car');
      } else {
        _pickupRotationTimer?.cancel();
      }
    });
  }

  Widget _buildRideTile(
    int idx,
    String title,
    String subtitle,
    String price,
    String eta,
    String imageUrl, {
    required bool isSelected,
    required VoidCallback onTap,
    String? originalPrice,
    int? discountPercent,
    String? description,
  }) {
    bool isSelected = selectedRideIndex1 == idx;
    bool hasDiscount = originalPrice != null && originalPrice != price;

    return GestureDetector(
      onTap: () {
        setState(() {
          _onVehicleSelected(idx);
          selectedRideIndex1 = idx;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.12),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // Vehicle Image with background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car,
                      size: 32,
                      color: Colors.grey,
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Seats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: robotoBold.copyWith(
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: robotoRegular.copyWith(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (eta.isNotEmpty) ...[
                            Icon(
                              Icons.access_time_filled,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              eta,
                              style: robotoMedium.copyWith(
                                fontSize: 13,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.grey.shade700
                                : Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Price Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: robotoBold.copyWith(
                        fontSize: 19,
                        color: hasDiscount
                            ? const Color(0xFF2E7D32)
                            : Colors.black, // Dark green for discount
                      ),
                    ),
                    if (hasDiscount)
                      IntrinsicWidth(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              originalPrice!,
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Container(height: 1, color: Colors.grey.shade500),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Discount Badge
            if (hasDiscount && discountPercent != null && discountPercent > 0)
              Positioned(
                top: -24,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "SAVE $discountPercent%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void initCall() {
    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    Get.find<ProfileController>().initData();
  }

  void _updateUserFields(ProfileController profileController) {
    if (profileController.userInfoModel != null &&
        _phoneController.text.isEmpty) {
      _firstNameController.text = profileController.userInfoModel?.fName ?? '';
      _lastNameController.text = profileController.userInfoModel?.lName ?? '';
      _phoneController.text = profileController.userInfoModel?.phone ?? '';
      _emailController.text = profileController.userInfoModel?.email ?? '';
    }
  }

  Widget buildSearchBar(String address) {
    return SafeArea(
      child: InkWell(
        onTap: () {
          _openLocationPicker("Pickup");
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: robotoMedium.copyWith(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.edit_location, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  LatLng _getOffsetPosition(LatLng position, double offsetInMeters) {
    double offsetInDegrees = offsetInMeters / 111000;
    return LatLng(position.latitude - offsetInDegrees, position.longitude);
  }

  void _moveCameraToOffset(LatLng target, double offsetInMeters) {
    double offsetInDegrees = offsetInMeters / 111000;
    LatLng offsetPosition = LatLng(
      target.latitude - offsetInDegrees,
      target.longitude,
    );
    _mapController.animateCamera(CameraUpdate.newLatLng(offsetPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ProfileController>(
        builder: (profileController) {
          _updateUserFields(profileController);
          return Stack(
            children: [
              _currentPosition == null
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    )
                  : ValueListenableBuilder<Set<Marker>>(
                      valueListenable: markers,
                      builder: (context, markerSet, _) {
                        return GoogleMap(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.4,
                          ),
                          initialCameraPosition: CameraPosition(
                            target: _getOffsetPosition(
                              _currentPosition!,
                              150,
                            ), // shift 150m down
                            zoom: 16,
                          ),
                          myLocationEnabled: true,
                          polylines: _polylines,
                          zoomControlsEnabled: false,
                          markers: markerSet,
                          onMapCreated: (controller) {
                            _mapController = controller;

                            Future.delayed(Duration(milliseconds: 3), () {
                              _moveCameraToOffset(_currentPosition!, 150);
                            });
                          },
                        );
                      },
                    ),
              _dropoffLatLng == null
                  ? Positioned(
                      top: 0,
                      left: 16,
                      right: 16,
                      child: buildSearchBar(
                        _pickupAddress ?? "Search pickup location",
                      ),
                    )
                  : Positioned(
                      top: 50,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          Get.find<SplashController>().showBottomNavBar();
                          Get.offAll(
                            () => DashboardScreen(
                              pageIndex: 0,
                              fromSplash: false,
                            ),
                          );
                        },
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            CupertinoIcons.back,
                            color: Theme.of(context).cardColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
              _dropoffLatLng == null
                  ? const SizedBox.shrink()
                  : Positioned(
                      bottom: -10,
                      left: 16,
                      right: 16,
                      child: Obx(() {
                        final isLoading = vehicleController.isLoading.value;
                        if (vehicleController.vehicleList.isEmpty ||
                            selectedRideIndex1 >=
                                vehicleController.vehicleList.length) {
                          return const SizedBox.shrink();
                        }
                        final selectedVehicle =
                            vehicleController.vehicleList[selectedRideIndex1];

                        final originalFare = _calculateEstimatedFare(
                          selectedVehicle.baseFare,
                          selectedVehicle.pricePerKm,
                          selectedVehicle.pricePerMin,
                        );
                        final discountedFare = _calculateDiscountedFare(
                          originalFare,
                          selectedVehicle.discount,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 100,
                            left: 16,
                            right: 16,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: (isLoading || _currentPosition == null)
                                  ? null
                                  : () async {
                                      final name =
                                          "${_firstNameController.text} ${_lastNameController.text}";
                                      final phone = _phoneController.text;

                                      DateTime now = DateTime.now();
                                      DateTime scheduledDateTime =
                                          DateTime.now();

                                      Map<String, dynamic> bookingData = {
                                        "pickup_location": _pickupAddress,
                                        "dropoff_location": _dropoffAddress,
                                        "pickup_lat": _pickupLatLng!.latitude,
                                        "pickup_lng": _pickupLatLng!.longitude,
                                        "dropoff_lat": _dropoffLatLng!.latitude,
                                        "dropoff_lng":
                                            _dropoffLatLng!.longitude,
                                        "distance_km": _calculateDistanceKm()
                                            .toStringAsFixed(2),
                                        "fare_amount": discountedFare
                                            .round()
                                            .toString(),
                                        "vehicle_price_type_id":
                                            selectedVehicle.id,
                                        "passenger_name": name,
                                        "passenger_phone": phone,
                                        "payment_method": "cash",
                                        "scheduled_at": DateFormat(
                                          'yyyy-MM-dd HH:mm:ss',
                                        ).format(scheduledDateTime),
                                      };

                                      showBookingConfirmationDialog(
                                        context,
                                        bookingData,
                                      );
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.local_taxi,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Book ${_getRideTitle(selectedRideIndex1)} • ₹${discountedFare.round()}',
                                          style: robotoBlack.copyWith(
                                            color: Theme.of(context).cardColor,
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showDraggableSheet.value ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: _dropoffLatLng == null
                          ? MediaQuery.of(context).size.height * 0.4
                          : MediaQuery.of(context).size.height * 0.6,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _dropoffLatLng == null
                              ? _buildSearchDestination()
                              : _buildBookingDetails(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _dropoffLatLng == null
          ? const SizedBox.shrink()
          : Obx(() {
              final isLoading = vehicleController.isLoading.value;
              if (vehicleController.vehicleList.isEmpty ||
                  selectedRideIndex1 >= vehicleController.vehicleList.length) {
                return const SizedBox.shrink();
              }
              final selectedVehicle =
                  vehicleController.vehicleList[selectedRideIndex1];

              final originalFare = _calculateEstimatedFare(
                selectedVehicle.baseFare,
                selectedVehicle.pricePerKm,
                selectedVehicle.pricePerMin,
              );
              final discountedFare = _calculateDiscountedFare(
                originalFare,
                selectedVehicle.discount,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: (isLoading || _currentPosition == null)
                        ? null
                        : () async {
                            final name =
                                "${_firstNameController.text} ${_lastNameController.text}";
                            final phone = _phoneController.text;

                            DateTime now = DateTime.now();
                            DateTime scheduledDateTime = DateTime.now();

                            Map<String, dynamic> bookingData = {
                              "pickup_location": _pickupAddress,
                              "dropoff_location": _dropoffAddress,
                              "pickup_lat": _pickupLatLng!.latitude,
                              "pickup_lng": _pickupLatLng!.longitude,
                              "dropoff_lat": _dropoffLatLng!.latitude,
                              "dropoff_lng": _dropoffLatLng!.longitude,
                              "distance_km": _calculateDistanceKm()
                                  .toStringAsFixed(2),
                              "fare_amount": discountedFare.round().toString(),
                              "vehicle_price_type_id": selectedVehicle.id,
                              "passenger_name": name,
                              "passenger_phone": phone,
                              "payment_method": "cash",
                              "scheduled_at": DateFormat(
                                'yyyy-MM-dd HH:mm:ss',
                              ).format(scheduledDateTime),
                            };

                            showBookingConfirmationDialog(context, bookingData);
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_taxi, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Book ${_getRideTitle(selectedRideIndex1)} • ₹${discountedFare.round()}',
                                style: robotoBlack.copyWith(
                                  color: Theme.of(context).cardColor,
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget module(
    String name,
    String description,
    String image,
    BuildContext context,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.45,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(name, style: robotoBold.copyWith()),
                    Text(
                      description,
                      style: robotoRegular.copyWith(fontSize: 9),
                    ),
                  ],
                ),
                Image.asset(image),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchDestination() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle for Draggable Sheet
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Search Bar
        InkWell(
          onTap: () => _openLocationPicker("Dropoff"),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  "Where to?",
                  style: robotoBold.copyWith(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Icon(
                  Icons.map,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (recentLocations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Recent Places",
              style: robotoBold.copyWith(fontSize: 14, color: Colors.black54),
            ),
          ),
          ...recentLocations.take(3).map((loc) {
            return InkWell(
              onTap: () {
                if (_currentPosition != null) {
                  _processSelectedLocation(
                    status: "Dropoff",
                    latLng: LatLng(loc.latitude, loc.longitude),
                    address: loc.address,
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    "Please Wait...",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade300,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ] else ...[
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Lottie.asset(
                  'assets/animation/new_user_explore_animation.json',
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: "Welcome aboard! ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const TextSpan(
                            text:
                                "Wishing you a smooth and joyful journey ahead 🚖✨",
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 10),
        const SizedBox(height: 16),
        GetBuilder<BannerController>(
          builder: (bannerController) {
            if (bannerController.taxiBannerImageList == null) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            return (bannerController.taxiBannerImageList!.isNotEmpty)
                ? Column(
                    children: [
                      CarouselSlider.builder(
                        itemCount: bannerController.taxiBannerImageList!.length,
                        options: CarouselOptions(
                          aspectRatio: 2.5,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          viewportFraction: 0.85,
                          onPageChanged: (index, reason) {
                            bannerController.setCurrentIndex(index, true);
                          },
                        ),
                        itemBuilder: (context, index, realIndex) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              child: CustomImage(
                                image: bannerController
                                    .taxiBannerImageList![index]!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: bannerController.taxiBannerImageList!.map((
                          url,
                        ) {
                          int index = bannerController.taxiBannerImageList!
                              .indexOf(url);
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 2.0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bannerController.currentIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Location Inputs Group
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildLocationTile(
                    iconColor: Colors.green,
                    controller: pickupController,
                    onTap: () async {
                      await _openLocationPicker("Pickup");
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildLocationTile(
                    iconColor: Colors.red,
                    controller: destinationController,
                    onTap: () async {
                      await _openLocationPicker("Dropoff");
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Total Journey Distance",
                          style: robotoRegular.copyWith(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${_calculateDistanceKm().toStringAsFixed(1)} km",
                          style: robotoBold.copyWith(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Connecting line - Refined Dashed Line
              Positioned(
                left: 31,
                top: 40,
                bottom: 84, // Adjust to stop at the second pin
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    12,
                    (index) => Container(
                      width: 1,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Select Vehicle",
            style: robotoBold.copyWith(fontSize: 18, color: Colors.black87),
          ),
        ),

        Obx(() {
          if (vehicleController.isLoading.value) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, __) => buildRideSkeletonTile(),
            );
          }

          if (vehicleController.hasError.value) {
            return Center(child: Text(vehicleController.errorMessage.value));
          }

          final vehicleListWidget = AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicleController.vehicleList.length,
              itemBuilder: (_, i) {
                final v = vehicleController.vehicleList[i];
                final isSel = selectedRideIndex.value == i;

                final originalFare = _calculateEstimatedFare(
                  v.baseFare,
                  v.pricePerKm,
                  v.pricePerMin,
                );
                final discountedFare = _calculateDiscountedFare(
                  originalFare,
                  v.discount,
                );

                final matchingDrivers = controller.driverList
                    .where(
                      (d) =>
                          d.vehicletype.toLowerCase() == v.name.toLowerCase(),
                    )
                    .toList();

                double? minEta;

                if (_pickupLatLng != null && matchingDrivers.isNotEmpty) {
                  for (var driver in matchingDrivers) {
                    final distanceMeters = Geolocator.distanceBetween(
                      _pickupLatLng!.latitude,
                      _pickupLatLng!.longitude,
                      driver.lat,
                      driver.long,
                    );

                    final distanceKm = distanceMeters / 1000;
                    final speedKmph = (driver.speed * 3.6).clamp(5, 60);
                    final eta = (distanceKm / speedKmph) * 60;

                    if (eta.isFinite && (minEta == null || eta < minEta)) {
                      minEta = eta;
                    }
                  }
                }

                final etaText = minEta != null ? '${minEta.round()} min' : '';

                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 800),
                  child: SlideAnimation(
                    verticalOffset: 30,
                    curve: Curves.easeOutQuad,
                    child: FadeInAnimation(
                      child: _buildRideTile(
                        i,
                        v.name,
                        '${v.seats}',
                        '₹${discountedFare.round()}',
                        etaText,
                        '${AppConstants.baseUrl}${AppConstants.Vehicleimage}${v.image}',
                        isSelected: isSel,
                        originalPrice: '₹${originalFare.round()}',
                        discountPercent: v.discount,
                        description: v.description,
                        onTap: () {
                          selectedRideIndex.value = i;
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          return vehicleListWidget;
        }),

        const SizedBox(height: 16),

        GetBuilder<BannerController>(
          builder: (bannerController) {
            if (bannerController.taxiBannerImageList == null) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            return (bannerController.taxiBannerImageList!.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CarouselSlider.builder(
                      itemCount: bannerController.taxiBannerImageList!.length,
                      options: CarouselOptions(
                        aspectRatio: 2.5,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 0.85,
                        onPageChanged: (index, reason) {
                          bannerController.setCurrentIndex(index, true);
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            child: CustomImage(
                              image:
                                  bannerController.taxiBannerImageList![index]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox();
          },
        ),

        const Divider(height: 1),

        const SizedBox(height: 120),
      ],
    );
  }

  //
  // Widget _buildBookingDetails(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Stack(
  //         children: [
  //           Column(
  //             children: [
  //               _buildLocationTile(
  //                 iconColor: Colors.green,
  //                 controller: pickupController,
  //                 onTap: () async {
  //                   await _openLocationPicker("Pickup");
  //                 },
  //               ),
  //
  //
  //               const Divider(),
  //               _buildLocationTile(
  //                 iconColor: Colors.red,
  //                 controller: destinationController,
  //                 onTap: () async {
  //                   await _openLocationPicker("Dropoff");
  //                 },
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(left: 20.0,right: 25.0),
  //         child: Row(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //
  //           Text("Total Distance:",style: robotoBold.copyWith(
  //             fontSize: Dimensions.fontSizeExtraLarge,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.black87,
  //           ),),
  //           Text("${_calculateDistanceKm().toStringAsFixed(2)} KM",style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.black87,
  //           ),),
  //         ],),
  //       ),
  //       Obx(() {
  //
  //         if (vehicleController.isLoading.value) {
  //           return ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: 3, // number of shimmer tiles
  //             itemBuilder: (_, __) => buildRideSkeletonTile(),
  //           );
  //         }
  //
  //         if (vehicleController.hasError.value) {
  //           return Center(child: Text(vehicleController.errorMessage.value));
  //         }
  //
  //         return  ListView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: vehicleController.vehicleList.length,
  //           itemBuilder: (_, i) {
  //             final v = vehicleController.vehicleList[i];
  //             final isSel = selectedRideIndex.value == i;
  //
  //             final price = _calculateEstimatedFare(
  //               v.baseFare,
  //               v.pricePerKm,
  //               v.pricePerMin,
  //             );
  //
  //             final matchingDrivers = controller.driverList.where((driver) =>
  //             driver.vehicletype.toLowerCase() == v.name.toLowerCase()).toList();
  //
  //             double? minEta;
  //
  //             if (_pickupLatLng != null && matchingDrivers.isNotEmpty) {
  //               for (var driver in matchingDrivers) {
  //                 final distanceMeters = Geolocator.distanceBetween(
  //                   _pickupLatLng!.latitude,
  //                   _pickupLatLng!.longitude,
  //                   driver.lat,
  //                   driver.long,
  //                 );
  //                 final distanceKm = distanceMeters / 1000;
  //
  //                 final speedKmph = (driver.speed * 3.6).clamp(5, 60); // prevent zero/very low speeds
  //                 final eta = (distanceKm / speedKmph) * 60;
  //
  //                 if (eta.isFinite && (minEta == null || eta < minEta)) {
  //                   minEta = eta;
  //                 }
  //               }
  //             }
  //
  //             String etaText;
  //             if (minEta != null && minEta.isFinite) {
  //               etaText = '${minEta.round()} min';
  //             } else {
  //               etaText = '';
  //             }
  //
  //             return _buildRideTile(
  //               i,
  //               v.name,
  //               '${v.seats}',
  //               price,
  //               etaText,
  //               '${AppConstants.baseUrl}${AppConstants.Vehicleimage}${v.image}',
  //               isSelected: isSel,
  //               onTap: () {
  //                 selectedRideIndex.value = i;
  //               },
  //             );
  //           },
  //         );
  //
  //       }),
  //       const Divider(height: 1),
  //       SizedBox(height:100,),
  //       SizedBox(height: 100,),
  //
  //     ],
  //   );
  // }
  void _handleRideCancellation(
    BuildContext bottomSheetContext,
    BuildContext parentContext,
    StreamSubscription bookingListener, [
    Timer? countdownTimer,
    bool showConfirmation = true,
    String reason = "user request",
  ]) {
    bookingTimer?.cancel();
    bookingListener.cancel();
    countdownTimer?.cancel();

    // Clear all modal sheets and dialogs to prevent overlapping
    while (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
    while (Get.isDialogOpen ?? false) {
      Get.back();
    }

    bool isHomepage =
        Get.currentRoute.contains('DashboardScreen') || Get.currentRoute == '/';
    if (showConfirmation && !isHomepage) {
      showBookingCancelledBottomSheet(Get.context!, null, reason).then((_) {
        Get.find<SplashController>().showBottomNavBar();
        Get.offAll(
          () => const DashboardScreen(pageIndex: 0, fromSplash: false),
        );
      });
    }
  }

  void showContactingDriversBottomSheet(
    BuildContext context,
    int? bookingId,
    int? userId,
    String? otp,
  ) {
    print("🟡 showContactingDriversBottomSheet called");

    if (bookingId == null || userId == null || otp == null) {
      print("❌ Missing bookingId, userId, or otp.");
      Get.offAll(() => const DashboardScreen(pageIndex: 0, fromSplash: false));
      return;
    }

    final safeContext = context;
    late StreamSubscription<DatabaseEvent> bookingListener;

    showModalBottomSheet(
      context: safeContext,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        Timer? countdownTimer;
        int remainingSeconds = 600; // 5 minutes
        // startRetryTimer(bottomSheetContext, bookingId, retryCount);

        final dbRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: AppConstants.firebaseDBURL,
        ).ref('bookings/$bookingId');

        bookingListener = dbRef.onValue.listen((DatabaseEvent event) {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            print("❌ Booking does not exist or deleted");

            _handleRideCancellation(
              bottomSheetContext,
              safeContext,
              bookingListener,
              null,
              true,
            );
            return;
          }

          final data = event.snapshot.value;

          if (data is! Map) {
            print("❌ Invalid booking data format");
            _handleRideCancellation(
              bottomSheetContext,
              safeContext,
              bookingListener,
              null,
              true,
            );
            return;
          }

          final rideStatus = data['ride_status'];
          final driverIdsMap = data['driver_ids'];

          // 🔴 CASE 2: Cancelled
          if (rideStatus == 'cancelled') {
            print("❌ Ride cancelled");

            _handleRideCancellation(
              bottomSheetContext,
              safeContext,
              bookingListener,
              null,
              true,
            );
            return;
          }

          // 🟢 CASE 3: Accepted
          if (rideStatus == 'accepted' &&
              driverIdsMap is Map &&
              driverIdsMap.isNotEmpty) {
            final rawDriverKey = driverIdsMap.keys.first;
            final driverId = int.tryParse(
              rawDriverKey.replaceAll(RegExp(r'[^0-9]'), ''),
            );

            if (driverId != null) {
              SharedService.saveOngoingBooking(
                bookingId,
                driverId,
                userId,
                otp,
              );

              bookingTimer?.cancel();
              bookingListener.cancel();
              countdownTimer?.cancel();

              Future.delayed(const Duration(milliseconds: 300), () {
                if (Navigator.canPop(bottomSheetContext)) {
                  Navigator.pop(bottomSheetContext);
                }

                Get.to(
                  () => RideConfirmedScreen(
                    Bookingid: bookingId ?? 0,
                    driverid: driverId ?? 0,
                    userId: userId ?? 0,
                    otp: otp ?? "1234",
                  ),
                );
              });
            }
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            if (countdownTimer == null) {
              countdownTimer = Timer.periodic(const Duration(seconds: 1), (
                timer,
              ) async {
                if (remainingSeconds > 0) {
                  if (context.mounted) {
                    setState(() {
                      remainingSeconds--;
                    });
                  }
                } else {
                  timer.cancel();
                  // Cancel the ride via API if no driver found within time
                  Map<String, dynamic> bookingcancelData = {
                    "booking_id": bookingId,
                    "cancel_reason": "No Driver Found",
                    "type": "user",
                  };
                  await vehicleController.cancelBookingAndVerify(
                    bookingcancelData,
                    bookingId,
                  );

                  _handleRideCancellation(
                    bottomSheetContext,
                    safeContext,
                    bookingListener,
                    timer,
                    true,
                    "No Driver Found",
                  );
                }
              });
            }

            String minutes = (remainingSeconds ~/ 60).toString().padLeft(
              2,
              '0',
            );
            String seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
            double progress = remainingSeconds / 300.0;

            return WillPopScope(
              onWillPop: () async {
                Get.offAll(
                  () => DashboardScreen(pageIndex: 0, fromSplash: false),
                );
                return false; // or true, based on whether you want to allow popping
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Hang tight, finding drivers close by...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Highly Appealing Timer UI
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Estimated wait time",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$minutes:$seconds",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(context).primaryColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.linear,
                                    height: 12,
                                    width: constraints.maxWidth * progress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.5),
                                          Theme.of(context).primaryColor,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Lottie.asset(
                      'assets/animation/searching_drivers.json',
                      height: 160,
                    ),

                    const SizedBox(height: 20),
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
                        onPressed: () async {
                          // Open the cancel reason sheet
                          // Note: We don't cancel the listener here anymore to allow
                          // background status updates to handle the UI transition.
                          bool success = await showCancelReasonBottomSheet(
                            bottomSheetContext,
                            bookingId,
                          );

                          if (success) {
                            print(
                              "✅ Cancellation confirmed by user — clearing search UI",
                            );
                            bookingTimer?.cancel();
                            bookingListener.cancel();
                            countdownTimer?.cancel();
                          }
                        },
                        child: Text(
                          'Cancel Ride',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showBookingConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> bookingData,
  ) {
    GoogleMapController? _mapController;
    Set<Polyline> _polylines = {};
    bool routeDrawn = false;

    LatLng pickup = LatLng(
      bookingData["pickup_lat"],
      bookingData["pickup_lng"],
    );
    LatLng dropoff = LatLng(
      bookingData["dropoff_lat"],
      bookingData["dropoff_lng"],
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Booking Confirmation",
      barrierColor: Colors.black.withOpacity(0.35), // dim background
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 👈 BLUR
          child: Center(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  Future<void> drawRoutePolyline() async {
                    if (routeDrawn) return;

                    PolylinePoints polylinePoints = PolylinePoints(
                      apiKey: googleMapsApiKey,
                    );

                    PolylineResult result = await polylinePoints
                        .getRouteBetweenCoordinates(
                          request: PolylineRequest(
                            origin: PointLatLng(
                              pickup.latitude,
                              pickup.longitude,
                            ),
                            destination: PointLatLng(
                              dropoff.latitude,
                              dropoff.longitude,
                            ),
                            mode: TravelMode.driving,
                          ),
                        );

                    if (result.points.isNotEmpty) {
                      final routePoints = result.points
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
                    }
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    drawRoutePolyline();
                  });

                  return SizedBox(
                    height:
                        MediaQuery.of(context).size.height * 0.75, // 👈 BIGGER
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Confirm Your Booking",
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: pickup,
                                  zoom: 14,
                                ),
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
                                onMapCreated: (controller) =>
                                    _mapController = controller,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bookingData["pickup_location"],
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.flag, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bookingData["dropoff_location"],
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Distance: ${bookingData["distance_km"]} km",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Fare: ₹${bookingData["fare_amount"]}",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: vehicleController.isLoading.value
                                      ? null
                                      : () async {
                                          vehicleController.isLoading.value =
                                              true;

                                          final success =
                                              await vehicleController
                                                  .bookingdata(bookingData);

                                          final bookingId =
                                              vehicleController.lastBookingId;
                                          final userId =
                                              vehicleController.userId!;
                                          final otp = vehicleController.otp!;

                                          SharedService.saveBookingIdToPrefs(
                                            bookingId ?? 0,
                                            userId,
                                            otp,
                                          );

                                          vehicleController.isLoading.value =
                                              false;

                                          if (success && bookingId != null) {
                                            Navigator.pop(context);
                                            showDraggableSheet.value = false;
                                            showContactingDriversBottomSheet(
                                              context,
                                              bookingId,
                                              userId,
                                              otp,
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: vehicleController.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          "Confirm",
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraLarge,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // void showBookingConfirmationDialog(BuildContext context, Map<String, dynamic> bookingData) {
  //   GoogleMapController? _mapController;
  //   Set<Polyline> _polylines = {};
  //   bool routeDrawn = false;
  //
  //   LatLng pickup = LatLng(bookingData["pickup_lat"], bookingData["pickup_lng"]);
  //   LatLng dropoff = LatLng(bookingData["dropoff_lat"], bookingData["dropoff_lng"]);
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         child: StatefulBuilder(
  //           builder: (context, setState) {
  //             Future<void> drawRoutePolyline() async {
  //               PolylinePoints polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);
  //
  //               PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //                 request: PolylineRequest(
  //                   origin: PointLatLng(pickup.latitude, pickup.longitude),
  //                   destination: PointLatLng(dropoff.latitude, dropoff.longitude),
  //                   mode: TravelMode.driving,
  //                 ),
  //               );
  //
  //               if (result.points.isNotEmpty) {
  //                 List<LatLng> routePoints = result.points
  //                     .map((e) => LatLng(e.latitude, e.longitude))
  //                     .toList();
  //
  //                 setState(() {
  //                   _polylines = {
  //                     Polyline(
  //                       polylineId: const PolylineId("route"),
  //                       color: Theme.of(context).primaryColor,
  //                       width: 5,
  //                       points: routePoints,
  //                     ),
  //                   };
  //                   routeDrawn = true;
  //                 });
  //
  //                 _mapController?.animateCamera(
  //                   CameraUpdate.newLatLngBounds(
  //                     LatLngBounds(
  //                       southwest: LatLng(
  //                         pickup.latitude < dropoff.latitude ? pickup.latitude : dropoff.latitude,
  //                         pickup.longitude < dropoff.longitude ? pickup.longitude : dropoff.longitude,
  //                       ),
  //                       northeast: LatLng(
  //                         pickup.latitude > dropoff.latitude ? pickup.latitude : dropoff.latitude,
  //                         pickup.longitude > dropoff.longitude ? pickup.longitude : dropoff.longitude,
  //                       ),
  //                     ),
  //                     80,
  //                   ),
  //                 );
  //               } else {
  //                 debugPrint('❌ Polyline fetch failed: ${result.errorMessage}');
  //               }
  //             }
  //
  //             Future.delayed(Duration.zero, () {
  //               if (!routeDrawn) drawRoutePolyline();
  //             });
  //
  //             return
  //              Container(
  //               width: MediaQuery.of(context).size.width * 0.95,
  //               padding: const EdgeInsets.all(16),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                    Text(
  //                     "Confirm Your Booking",
  //                     style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
  //                   ),
  //                   const SizedBox(height: 12),
  //
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: SizedBox(
  //                       height: 200,
  //                       child: GoogleMap(
  //                         initialCameraPosition: CameraPosition(target: pickup, zoom: 14),
  //                         markers: {
  //                           Marker(
  //                             markerId: const MarkerId('pickup'),
  //                             position: pickup,
  //                             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //                           ),
  //                           Marker(
  //                             markerId: const MarkerId('dropoff'),
  //                             position: dropoff,
  //                             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //                           ),
  //                         },
  //                         polylines: _polylines,
  //                         onMapCreated: (controller) => _mapController = controller,
  //                         myLocationButtonEnabled: false,
  //                         zoomControlsEnabled: false,
  //                       ),
  //                     ),
  //                   ),
  //
  //                   const SizedBox(height: 12),
  //
  //                   Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const Icon(Icons.location_on, color: Colors.green),
  //                       const SizedBox(width: 8),
  //                       Expanded(
  //                         child: Text(
  //                           bookingData["pickup_location"],
  //                           style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const Icon(Icons.flag, color: Colors.red),
  //                       const SizedBox(width: 8),
  //                       Expanded(
  //                         child: Text(
  //                           bookingData["dropoff_location"],
  //                           style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //
  //                   const SizedBox(height: 16),
  //                   /// Distance and Fare - make them visually strong
  //                   Container(
  //                     width: double.infinity,
  //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //                     decoration: BoxDecoration(
  //                       color: Theme.of(context).primaryColor.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Text(
  //                           "Distance: ${bookingData["distance_km"]} km",
  //                           style: const TextStyle(fontWeight: FontWeight.w600),
  //                         ),
  //                         const Spacer(),
  //                         Text(
  //                           "Fare: ₹${bookingData["fare_amount"]}",
  //                           style: const TextStyle(fontWeight: FontWeight.w600),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //
  //                   const SizedBox(height: 16),
  //
  //                   /// Action Buttons
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: () => Navigator.pop(context),
  //                           style: ElevatedButton.styleFrom(
  //                             foregroundColor: Theme.of(context).cardColor,
  //                             backgroundColor: Colors.black,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           child:  Text("Cancel",style: robotoMedium,),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: vehicleController.isLoading.value
  //                               ? null
  //                               : () async {
  //                             vehicleController.isLoading.value = true;
  //
  //                             final success = await vehicleController.bookingdata(bookingData);
  //                             final bookingId = vehicleController.lastBookingId;
  //                             final userId = vehicleController.userId!;
  //                             final otp = vehicleController.otp!;
  //
  //                             SharedService.saveBookingIdToPrefs(
  //                                 bookingId ?? 0, userId, otp);
  //
  //                             vehicleController.isLoading.value = false;
  //
  //                             if (success && bookingId != null) {
  //                               Navigator.pop(context);
  //                               showDraggableSheet.value = false;
  //                               showContactingDriversBottomSheet(
  //                                   context, bookingId, userId, otp);
  //                             }
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             foregroundColor: Theme.of(context).cardColor,
  //                             backgroundColor: Theme.of(context).primaryColor,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           child: vehicleController.isLoading.value
  //                               ?  SizedBox(
  //                             width: 20,
  //                             height: 20,
  //                             child: CircularProgressIndicator(
  //                               strokeWidth: 2,
  //                               color: Theme.of(context).primaryColor,
  //                             ),
  //                           )
  //                               :  Text("Confirm",style: robotoMedium,),
  //                         ),
  //                       ),
  //                     ],
  //                   )
  //
  //                 ],
  //               ),
  //             );
  //
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget buildRideSkeletonTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 100, color: Colors.white),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(height: 12, width: 40, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(height: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 18, width: 60, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 12, width: 40, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget submodule(
    String name,
    String description,
    String image,
    BuildContext context,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(name, style: robotoBold.copyWith()),
                    Text(
                      description,
                      style: robotoRegular.copyWith(fontSize: 9),
                    ),
                  ],
                ),
                Image.asset(image),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLocationRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

void showRideCancelledPopup() {
  if (Get.isDialogOpen ?? false) return;

  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Text("Ride Cancelled"),
        content: const Text("Your ride has been cancelled by the admin."),
        actions: [
          TextButton(
            onPressed: () {
              Get.find<SplashController>().showBottomNavBar();
              Get.offAll(
                () => const DashboardScreen(pageIndex: 0, fromSplash: false),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}
