import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/location/domain/models/prediction_model.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

import '../util/images.dart';
import 'Controller/Recentlocationservice.dart';

class LocationPickerScreen extends StatefulWidget {
  final String? status;
  final LatLng? initialPosition;
  final LatLng? initialRoute;
  final LatLng? pickuplatLng;
  final String? pickupaddress;

  const LocationPickerScreen({
    super.key,
    this.status,
    this.initialPosition,
    this.initialRoute,
    this.pickuplatLng,
    this.pickupaddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen>
    with SingleTickerProviderStateMixin {
  LatLng? pickedLatLng;
  String selectedAddress = 'Tap to select a location';
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoadingAddress = false;
  TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _userAction = false;
  bool _isLocationSelected = false;
  bool _isProgrammaticMove = false;
  bool _canShowMarker = false;
  @override
  void initState() {
    super.initState();
    if (widget.status == "Pickup") {
      pickedLatLng = widget.initialRoute ?? widget.pickuplatLng;
      _userAction = true;
      _canShowMarker = true;
    } else {
      pickedLatLng = widget.initialRoute;
      _userAction = widget.initialRoute != null;
      _canShowMarker = widget.initialRoute != null;
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 50.0,
      end: 80.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (pickedLatLng != null) {
      _updateLatLngAndMarker(pickedLatLng!);
    }
  }

  void _updateLatLngAndMarker(LatLng position) async {
    setState(() {
      pickedLatLng = position;
    });
    _isProgrammaticMove = true;
    await _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    await _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            '${place.name}, ${place.subLocality}, ${place.locality}';
        setState(() {
          selectedAddress = address;
          _searchController.text = address;
        });
      }
    } catch (e) {
      print("❌ Failed to fetch address: $e");
    }
    setState(() {
      _isLoadingAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar3(
        title: widget.status == "Dropoff"
            ? "Set Destination"
            : "Set Pickup Point",
        backButton: true,
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  widget.initialRoute ??
                  widget.pickuplatLng ??
                  const LatLng(13.0827, 80.2707),
              zoom: 15,
            ),

            onMapCreated: _onMapCreated,
            onCameraMoveStarted: () {
              _userAction = true;
            },
            onCameraMove: (position) {
              if (_canShowMarker) {
                setState(() {
                  pickedLatLng = position.target;
                });
              }
            },
            onCameraIdle: () {
              if (_isProgrammaticMove) {
                _isProgrammaticMove = false;
              } else if (pickedLatLng != null && _userAction) {
                _getAddressFromLatLng(pickedLatLng!);
              }
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_canShowMarker)
            Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: _animation.value,
                          height: _animation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(0.3),
                            border: Border.all(width: 2, color: Colors.orange),
                          ),
                        );
                      },
                    ),
                    Image.asset(Images.mapcat, width: 50, height: 50),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: TypeAheadField<PredictionModel>(
              suggestionsCallback: (String pattern) async {
                if (_isLocationSelected) return <PredictionModel>[];
                return await Get.find<LocationController>().searchLocation(
                  context,
                  pattern,
                );
              },

              itemBuilder: (context, PredictionModel suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(suggestion.description ?? ''),
                );
              },

              onSelected: (PredictionModel suggestion) async {
                FocusScope.of(context).unfocus();
                setState(() {
                  _isLocationSelected = true;
                  _canShowMarker = true;
                });
                _userAction = true;
                final LatLng? coords = await Get.find<LocationController>()
                    .getPlaceDetails(suggestion.placeId ?? '');

                if (coords != null) {
                  _searchController.text = suggestion.description ?? '';
                  selectedAddress = suggestion.description ?? '';
                  pickedLatLng = coords;
                  _isProgrammaticMove = true;

                  await _mapController?.animateCamera(
                    CameraUpdate.newLatLng(coords),
                  );

                  setState(() {
                    _markers = {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: coords,
                      ),
                    };
                  });
                }
              },

              emptyBuilder: (context) {
                if (_isLocationSelected) return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No results found'),
                );
              },

              builder: (context, controller, focusNode) {
                _searchController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (val) {
                    if (_isLocationSelected) {
                      setState(() {
                        _isLocationSelected = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),

          // Positioned(
          //   top: 15,
          //   left: 15,
          //   right: 15,
          //   child: TypeAheadField<PredictionModel>(
          //     textFieldConfiguration: TextFieldConfiguration(
          //       controller: _searchController,
          //       decoration: InputDecoration(
          //         hintText: 'Search location',
          //         prefixIcon: const Icon(Icons.search),
          //         filled: true,
          //         fillColor: Colors.white,
          //         contentPadding:
          //         const EdgeInsets.symmetric(horizontal: 16),
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //           borderSide: BorderSide.none,
          //         ),
          //       ),
          //     ),
          //     suggestionsCallback: (pattern) async {
          //       return await Get.find<LocationController>()
          //           .searchLocation(context, pattern);
          //     },
          //     itemBuilder: (context, PredictionModel suggestion) {
          //       return ListTile(
          //         leading: const Icon(Icons.location_on_outlined),
          //         title: Text(suggestion.description ?? ''),
          //       );
          //     },
          //     onSuggestionSelected: (PredictionModel suggestion) async {
          //       final LatLng? coords = await Get.find<LocationController>()
          //           .getPlaceDetails(suggestion.placeId ?? '');
          //       if (coords != null) {
          //         _searchController.text = suggestion.description ?? '';
          //         pickedLatLng = coords;
          //         await _mapController
          //             ?.animateCamera(CameraUpdate.newLatLng(coords));
          //         setState(() {
          //           _markers = {
          //             Marker(
          //               markerId: const MarkerId('selected'),
          //               position: coords,
          //             ),
          //           };
          //         });
          //         await _getAddressFromLatLng(coords);
          //       }
          //     },
          //     noItemsFoundBuilder: (_) => const Padding(
          //       padding: EdgeInsets.all(8.0),
          //       child: Text('No results found'),
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed:
                    pickedLatLng == null ||
                        _isLoadingAddress ||
                        selectedAddress == 'Tap to select a location' ||
                        !Get.find<LocationController>().inZone
                    ? null
                    : () async {
                        if (widget.status == "Dropoff") {
                          await RecentLocationService.addLocation(
                            selectedAddress,
                            pickedLatLng!.latitude,
                            pickedLatLng!.longitude,
                          );
                          print("✅ Stored Dropoff Address: $selectedAddress");

                          Navigator.pop(context, {
                            'pickupAddress': widget.pickupaddress ?? '',
                            'pickupLatLng': widget.pickuplatLng!,
                            'dropoffAddress': selectedAddress,
                            'dropoffLatLng': pickedLatLng!,
                          });
                        } else {
                          await RecentLocationService.addLocation(
                            selectedAddress,
                            pickedLatLng!.latitude,
                            pickedLatLng!.longitude,
                          );
                          Navigator.pop(context, {
                            'pickupLatLng': pickedLatLng,
                            'pickupAddress': selectedAddress,
                          });
                        }
                      },
                child: _isLoadingAddress
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Get.find<LocationController>().inZone
                    ? Text(
                        'Confirm Location',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.radiusExtraLarge,
                        ),
                      )
                    : Text(
                        'service_not_available_in_this_area'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.radiusExtraLarge,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
