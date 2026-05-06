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
  final selectedTime = Rxn<TimeOfDay>();
  late GoogleMapController _mapController;
  final ValueNotifier<Set<Marker>> markers = ValueNotifier<Set<Marker>>({});
  late String googleMapsApiKey = controller.googleMapsApiKey ?? "";

  String _currentAddress = 'Fetching current address...';
  final Map<String, double> markerRotations = {};
  Timer? _pickupRotationTimer;
  Timer? _driverFetchTimer;
  final scheduletime = false.obs;
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

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
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
                                showBookingCancelledBottomSheet(
                                  ctx,
                                  null,
                                  "driver unavailable",
                                );
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

  void _showTimePickerSheet() {
    final initial = selectedTime.value ?? TimeOfDay.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        var temp = initial;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Schedule a ride', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),

              Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.now().copyWith(hour: temp.hour, minute: temp.minute),
                ),
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 150,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(
                    hours: initial.hour,
                    minutes: initial.minute,
                  ),
                  onTimerDurationChanged: (d) {
                    temp = TimeOfDay(hour: d.inHours, minute: d.inMinutes % 60);
                  },
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  scheduletime.value = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    selectedTime.value = temp;
                  });
                  print(
                    "✅ Scheduled Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().copyWith(hour: temp.hour, minute: temp.minute))}",
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.yellowAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateDistanceKm() {
    final dx = _pickupLatLng!.latitude - _dropoffLatLng!.latitude;
    final dy = _pickupLatLng!.longitude - _dropoffLatLng!.longitude;
    return sqrt(dx * dx + dy * dy) * 111;
  }

  String _calculateEstimatedFare(String base, String perKm, String perMin) {
    final baseFare = double.tryParse(base) ?? 0;
    final pricePerKm = double.tryParse(perKm) ?? 0;
    final distanceKm = _calculateDistanceKm();
    final fare = distanceKm * pricePerKm;
    final total = fare < baseFare ? baseFare : fare;
    return '₹${total.round()}';
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
    return ListTile(
      leading: Icon(Icons.location_on, color: iconColor),
      title: TextField(
        controller: controller,
        enabled: false,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
        onPressed: onTap,
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
  }) {
    bool isSelected = selectedRideIndex1 == idx;
    return GestureDetector(
      onTap: () {
        setState(() {
          _onVehicleSelected(idx);
          selectedRideIndex1 = idx;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  price,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                ),
                Text(
                  eta,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.grey,
                  ),
                ),
              ],
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

                        final fare = _calculateEstimatedFare(
                          selectedVehicle.baseFare,
                          selectedVehicle.pricePerKm,
                          selectedVehicle.pricePerMin,
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
                                      TimeOfDay selected =
                                          selectedTime.value ??
                                          TimeOfDay.fromDateTime(now);

                                      DateTime scheduledDateTime = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        selected.hour,
                                        selected.minute,
                                      );

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
                                        "fare_amount": fare.replaceAll('₹', ''),
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
                                          'Book ${_getRideTitle(selectedRideIndex1)} • ₹${fare.replaceAll('₹', '')}',
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

              final fare = _calculateEstimatedFare(
                selectedVehicle.baseFare,
                selectedVehicle.pricePerKm,
                selectedVehicle.pricePerMin,
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
                            TimeOfDay selected =
                                selectedTime.value ??
                                TimeOfDay.fromDateTime(now);

                            DateTime scheduledDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              selected.hour,
                              selected.minute,
                            );

                            Map<String, dynamic> bookingData = {
                              "pickup_location": _pickupAddress,
                              "dropoff_location": _dropoffAddress,
                              "pickup_lat": _pickupLatLng!.latitude,
                              "pickup_lng": _pickupLatLng!.longitude,
                              "dropoff_lat": _dropoffLatLng!.latitude,
                              "dropoff_lng": _dropoffLatLng!.longitude,
                              "distance_km": _calculateDistanceKm()
                                  .toStringAsFixed(2),
                              "fare_amount": fare.replaceAll('₹', ''),
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
                                'Book ${_getRideTitle(selectedRideIndex1)} • ₹${fare.replaceAll('₹', '')}',
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              _openLocationPicker("Dropoff");
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Search Destination",
                    style: robotoMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (recentLocations.isNotEmpty)
            Divider(height: 1, color: Colors.grey[300]),
          if (recentLocations.isNotEmpty) ...[
            ...recentLocations.take(4).map((loc) {
              return ListTile(
                dense: true,
                leading: Icon(Icons.history, color: Colors.grey),
                title: Text(
                  loc.address,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
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
                  // _processSelectedLocation(
                  //   status: "Dropoff",
                  //   latLng: LatLng(loc.latitude, loc.longitude),
                  //   address: loc.address,
                  // );
                },
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
                            TextSpan(
                              text: "Welcome aboard! ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
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
        ],
      ),
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
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

                // _buildLocationTile(
                //   iconColor: Colors.green,
                //   controller: pickupController,
                //   onIconTap: () async {
                //     await _openLocationPicker("Pickup");
                //   },
                //   onTextChanged: (value) {
                //     _pickupAddress = value;
                //   },
                // ),
                const Divider(),
                _buildLocationTile(
                  iconColor: Colors.red,
                  controller: destinationController,
                  onTap: () async {
                    await _openLocationPicker("Dropoff");
                  },
                ),

                // _buildLocationTile(
                //   iconColor: Colors.red,
                //   controller: destinationController,
                //   onIconTap: () async {
                //     await _openLocationPicker("Dropoff");
                //   },
                //   onTextChanged: (value) {
                //     _dropoffAddress = value;
                //   },
                // ),
              ],
            ),
            // Positioned(
            //   right: 10,
            //   bottom: 50,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(width: 1),
            //       borderRadius: BorderRadius.circular(10),
            //       color: Colors.white,
            //     ),
            //     child: TextButton(
            //       onPressed: () {
            //         _showTimePickerSheet();
            //         print(selectedTime.value);
            //         print("gddfg");
            //       },
            //       style: TextButton.styleFrom(foregroundColor: Colors.black),
            //       child: Obx(() => selectedTime.value == null
            //           ? const Icon(Icons.access_time)
            //           : Text(_formatTime(selectedTime.value!))),
            //     ),
            //   ),
            // ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 25.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Distance:",
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "${_calculateDistanceKm().toStringAsFixed(2)} KM",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
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

          return AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicleController.vehicleList.length,
              itemBuilder: (_, i) {
                final v = vehicleController.vehicleList[i];
                final isSel = selectedRideIndex.value == i;

                final price = _calculateEstimatedFare(
                  v.baseFare,
                  v.pricePerKm,
                  v.pricePerMin,
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
                        price,
                        etaText,
                        '${AppConstants.baseUrl}${AppConstants.Vehicleimage}${v.image}',
                        isSelected: isSel,
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
        }),

        const Divider(height: 1),

        const SizedBox(height: 50),
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

    if (showConfirmation) {
      showBookingCancelledBottomSheet(
        parentContext,
        null,
        "cancelled",
      ).then((_) {
        Get.find<SplashController>().showBottomNavBar();
        Get.offAll(() => const DashboardScreen(
              pageIndex: 1,
              fromSplash: false,
            ));
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
        int remainingSeconds = 300; // 5 minutes
        // startRetryTimer(bottomSheetContext, bookingId, retryCount);

        final dbRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: AppConstants.firebaseDBURL,
        ).ref('bookings/$bookingId');

        bookingListener = dbRef.onValue.listen((DatabaseEvent event) {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            print("❌ Booking does not exist or deleted");

            _handleRideCancellation(bottomSheetContext, safeContext, bookingListener, null, true);
            return;
          }

          final data = event.snapshot.value;

          if (data is! Map) {
            print("❌ Invalid booking data format");
            _handleRideCancellation(bottomSheetContext, safeContext, bookingListener, null, true);
            return;
          }

          final rideStatus = data['ride_status'];
          final driverIdsMap = data['driver_ids'];

          // 🔴 CASE 2: Cancelled
          if (rideStatus == 'cancelled') {
            print("❌ Ride cancelled");

            _handleRideCancellation(bottomSheetContext, safeContext, bookingListener, null, true);
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
              ) {
                if (remainingSeconds > 0) {
                  if (context.mounted) {
                    setState(() {
                      remainingSeconds--;
                    });
                  }
                } else {
                  timer.cancel();
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
                              print("✅ Cancellation confirmed by user — clearing search UI");
                              _handleRideCancellation(bottomSheetContext, safeContext, bookingListener, countdownTimer, false);
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

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 340,
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

                          const Spacer(),

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 100, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Price placeholder
            Container(width: 50, height: 14, color: Colors.white),
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
