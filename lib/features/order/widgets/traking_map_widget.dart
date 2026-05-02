import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/marker_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';

import 'dart:collection';
import 'dart:ui';

class TrackingMapWidget extends StatefulWidget {
  final OrderModel? track;
  const TrackingMapWidget({super.key, required this.track});

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  Future<void> _drawRoute(LatLng start, LatLng end) async {
    const String apiKey = "AIzaSyAOz7cVEGfVcfYBurOEIMuSiTLBq1OgcVk";

    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${start.latitude},${start.longitude}&"
        "destination=${end.latitude},${end.longitude}&"
        "mode=driving&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      if (json["status"] == "OK") {
        final String encodedPolyline = json["routes"][0]["overview_polyline"]["points"];
        List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            width: 5,
            color: Theme.of(context).primaryColor,
            points: decodedPoints
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList(),
          ),
        };

        if(mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Error drawing route: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double? lat;
    double? lng;
    try {
      if (widget.track?.deliveryAddress?.latitude != null && widget.track!.deliveryAddress!.latitude!.isNotEmpty && widget.track!.deliveryAddress!.latitude != 'null') {
        lat = double.parse(widget.track!.deliveryAddress!.latitude!);
      }
      if (widget.track?.deliveryAddress?.longitude != null && widget.track!.deliveryAddress!.longitude!.isNotEmpty && widget.track!.deliveryAddress!.longitude != 'null') {
        lng = double.parse(widget.track!.deliveryAddress!.longitude!);
      }
    } catch (e) {
      debugPrint("Error parsing coordinates: $e");
    }

    final width = MediaQuery.of(context).size.width;
    return Container(
      height: 350, width: ResponsiveHelper.isMobilePhone() ? width : 1170.0 - 100.0,
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: (lat != null && lng != null) ? Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child:
            GoogleMap(
              mapType: MapType.normal,
              trafficEnabled: true,
              initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 16),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 30),
              zoomControlsEnabled: false,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _isLoading = false;
                setMarker(
                  widget.track!.orderType == 'parcel' ? Store(latitude: widget.track!.receiverDetails!.latitude, longitude: widget.track!.receiverDetails!.longitude,
                      address: widget.track!.receiverDetails!.address, name: widget.track!.receiverDetails!.contactPersonName) : widget.track!.store, widget.track!.deliveryMan,
                  widget.track!.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? widget.track!.deliveryAddress : AddressModel(
                    latitude: Get.find<LocationController>().position.latitude.toString(),
                    longitude: Get.find<LocationController>().position.longitude.toString(),
                    address: Get.find<LocationController>().address,
                  ) : widget.track!.deliveryAddress, widget.track!.orderType == 'take_away', widget.track!.orderType == 'parcel', widget.track!.moduleType == 'food',
                );

                if (widget.track!.deliveryAddress != null && (widget.track!.store != null || widget.track!.receiverDetails != null)) {
                  try {
                    String? storeLat = widget.track!.orderType == 'parcel' ? widget.track!.receiverDetails!.latitude : widget.track!.store!.latitude;
                    String? storeLng = widget.track!.orderType == 'parcel' ? widget.track!.receiverDetails!.longitude : widget.track!.store!.longitude;

                    if(storeLat != null && storeLng != null && storeLat != 'null' && storeLng != 'null') {
                      final LatLng start = LatLng(lat!, lng!);
                      final LatLng end = LatLng(double.parse(storeLat), double.parse(storeLng));
                      _drawRoute(start, end);
                    }
                  } catch (e) {
                    debugPrint("Error in onMapCreated route: $e");
                  }
                }
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
            ),
          ),

          _isLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))) : const SizedBox(),
        ],
      ) : const SizedBox(),
    );
  }

  void setMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant) async {
    try {
      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70, imagePath: parcel ? Images.mapperson : isRestaurant ? Images.mapstore : Images.mapstore,
      );
      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70, imagePath: Images.mapdboy,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70, imagePath: takeAway ? Images.mapperson : Images.mapperson,
      );

      LatLngBounds? bounds;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
      if(!ResponsiveHelper.isWeb()) {
        zoomToFit(_controller, bounds, centerBounds, padding: 1.5);
      }

      _markers = HashSet<Marker>();
      if(addressModel != null) {
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'Sender' : 'Destination',
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        ));
      }

      if(store != null) {
        _markers.add(Marker(
          markerId: const MarkerId('store'),
          position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'Receiver' : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
            snippet: store.address,
          ),
          icon: restaurantImageData,
        ));
      }

      if(deliveryMan != null) {
        _markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
          infoWindow: InfoWindow(
            title: 'delivery_man'.tr,
            snippet: deliveryMan.location,
          ),
          icon: deliveryBoyImageData,
        ));
      }

    }catch(e) {
      debugPrint("Error setting markers: $e");
    }
    if(mounted) setState(() {});
  }


  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - 0.5;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }
}
