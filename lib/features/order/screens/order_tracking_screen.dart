import 'dart:async';
import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/location/widgets/permission_dialog_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/notification/domain/models/notification_body_model.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/chat/domain/models/conversation_model.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/marker_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/features/order/widgets/track_details_view_widget.dart';
import 'package:handy_allinone/features/order/widgets/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
    ));
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
    _timerTrackOrder();
  }

  void _timerTrackOrder(){
    if(Get.find<OrderController>().trackModel?.orderStatus != 'delivered' && Get.find<OrderController>().trackModel?.orderStatus != 'failed' && Get.find<OrderController>().trackModel?.orderStatus != 'canceled') {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if(Get.currentRoute.contains(RouteHelper.orderDetails) || Get.currentRoute.contains(RouteHelper.orderTracking)){
          Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);

          updateMarker(
            Get.find<OrderController>().trackModel?.store, Get.find<OrderController>().trackModel!.deliveryMan,
            Get.find<OrderController>().trackModel?.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? Get.find<OrderController>().trackModel?.deliveryAddress : AddressModel(
              latitude: Get.find<LocationController>().position.latitude.toString(),
              longitude: Get.find<LocationController>().position.longitude.toString(),
              address: Get.find<LocationController>().address,
            ) : Get.find<OrderController>().trackModel?.deliveryAddress,
            Get.find<OrderController>().trackModel?.orderType == 'take_away', Get.find<OrderController>().trackModel?.orderType == 'parcel', Get.find<OrderController>().trackModel?.moduleType == 'food',
          );

        } else {
          _timer?.cancel();
        }
      });
    }else{
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerTrackOrder();
    }else if(state == AppLifecycleState.paused){
      _timer?.cancel();
      _controller?.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }
  Set<Polyline> _polylines = {};


  Future<void> _drawRoute(LatLng start, LatLng end) async {
    const String apiKey = "AIzaSyAOz7cVEGfVcfYBurOEIMuSiTLBq1OgcVk";

    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${start.latitude},${start.longitude}&"
        "destination=${end.latitude},${end.longitude}&"
        "mode=driving&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);

    if (json["status"] == "OK") {
      final String encodedPolyline = json["routes"][0]["overview_polyline"]["points"];

      PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);
      List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

      _polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          width: 5,
          color: Colors.blue,
          points: decodedPoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
        ),
      };

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';
    bool isParcel = Get.find<SplashController>().module?.moduleType == 'parcel';

    return Scaffold(
      appBar: (isPharmacy || isParcel) ? null : CustomAppBar3(title: 'order_tracking'.tr),
      backgroundColor: (isPharmacy || isParcel) ? Colors.white : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;

          if(track!.orderType != 'parcel') {
            if (track.store!.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store!.storeSubscription != null && track.store!.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        if (track == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Parcel module: 50% map + 50% order details ──
        if (isParcel || track.orderType == 'parcel') {
          return _buildParcelTrackingView(track, orderController);
        }

        return isPharmacy 
          ? _buildPharmacyTrackingView(track, orderController)
          : SingleChildScrollView(
              physics: isHovered || !ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: Center(child: SizedBox(width: Dimensions.webMaxWidth, height: ResponsiveHelper.isDesktop(context) ? 700 : MediaQuery.of(context).size.height * 0.85, child: Stack(children: [

                  MouseRegion(
                    onEnter: (event) => onEntered(true),
                    onExit: (event) => onEntered(false),
                    child:
                    GoogleMap(
                      mapType: MapType.normal,
                      trafficEnabled: true,
                      initialCameraPosition: CameraPosition(target: LatLng(
                        double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                      ), zoom: 30,tilt: 65),
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 30),
                      zoomControlsEnabled: false,
                      markers: _markers,
                      polylines: _polylines,
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        _isLoading = false;
                        setMarker(
                          track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                              address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                          track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                            latitude: Get.find<LocationController>().position.latitude.toString(),
                            longitude: Get.find<LocationController>().position.longitude.toString(),
                            address: Get.find<LocationController>().address,
                          ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                        );
                        final LatLng pickup = LatLng(
                          double.parse(track.deliveryAddress!.latitude!),
                          double.parse(track.deliveryAddress!.longitude!),
                        );

                        final LatLng drop = LatLng(
                          double.parse(track.store!.latitude!),
                          double.parse(track.store!.longitude!),
                        );
                        _drawRoute(pickup, drop);
                      },
                      style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                    ),
                  ),



                  _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

                  Positioned(
                    top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                    child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
                  ),

                  Positioned(
                    right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 220,
                    child: InkWell(
                      onTap: () => _checkPermission(() async {
                        AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                        setMarker(
                          track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                              address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                          track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                            latitude: Get.find<LocationController>().position.latitude.toString(),
                            longitude: Get.find<LocationController>().position.longitude.toString(),
                            address: Get.find<LocationController>().address,
                          ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                          currentAddress: address, fromCurrentLocation: true,
                        );
                      }),
                      child: Container(
                        padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                        child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                    child: TrackDetailsViewWidget(status: track.orderStatus, track: track, showChatPermission: showChatPermission, callback: () async{
                      _timer?.cancel();
                      await Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                        user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, imageFullUrl: track.deliveryMan!.imageFullUrl),
                      ));
                      _timerTrackOrder();
                    }),
                  ),

                ])))));
      }),
    );
  }

  Widget _buildPharmacyTrackingView(OrderModel track, OrderController orderController) {
    int state = -1;
    String statusText = "";
    String statusDesc = "";
    Color statusColor = const Color(0xFF16A34A);

    if (track.orderStatus == 'pending') {
      state = 0;
      statusText = "Order Placed";
      statusDesc = "Your order has been placed successfully";
    } else if (track.orderStatus == 'confirmed') {
      state = 1;
      statusText = "Order Confirmed";
      statusDesc = "The store has confirmed your order";
    } else if (track.orderStatus == 'processing' || track.orderStatus == 'handover') {
      state = 2;
      statusText = "Packed & Ready";
      statusDesc = "Your order is packed and ready for delivery";
    } else if (track.orderStatus == 'picked_up') {
      state = 3;
      statusText = "Out for Delivery";
      statusDesc = "Rider is on the way to deliver your order";
    } else if (track.orderStatus == 'delivered') {
      state = 4;
      statusText = "Delivered";
      statusDesc = "Your order has been delivered";
    }

    return Column(
      children: [
        // Custom Header
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 15, left: 10, right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Order Tracking', style: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF1A1A1A))),
                    const SizedBox(height: 2),
                    Text('Order ID: ${track.id}', style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Section
                Text(statusText, style: robotoBold.copyWith(fontSize: 22, color: statusColor)),
                const SizedBox(height: 8),
                Text(statusDesc, style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600)),
                if (state == 3) ...[
                  const SizedBox(height: 4),
                  Text('Arriving in 12 mins', style: robotoBold.copyWith(fontSize: 14, color: statusColor)),
                ],

                const SizedBox(height: 30),

                // Stepper
                _buildPharmacyStepper(state),

                const SizedBox(height: 40),

                // Delivery Partner Card
                if (track.deliveryMan != null) ...[
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CustomImage(
                            image: track.deliveryMan!.imageFullUrl ?? '',
                            height: 60, width: 60, fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Delivery Partner', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('${track.deliveryMan!.fName} ${track.deliveryMan!.lName}', style: robotoBold.copyWith(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text('${track.deliveryMan!.avgRating}', style: robotoMedium.copyWith(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => launchUrlString('tel:${track.deliveryMan!.phone}', mode: LaunchMode.externalApplication),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), shape: BoxShape.circle),
                            child: const Icon(Icons.call, color: Color(0xFF16A34A), size: 20),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            _timer?.cancel();
                            await Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBodyModel(deliverymanId: track.deliveryMan!.id, orderId: track.id),
                              user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, imageFullUrl: track.deliveryMan!.imageFullUrl),
                            ));
                            _timerTrackOrder();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), shape: BoxShape.circle),
                            child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF16A34A), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // Map Card
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        GoogleMap(
                          mapType: MapType.normal,
                          trafficEnabled: true,
                          initialCameraPosition: CameraPosition(target: LatLng(
                            double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                          ), zoom: 15),
                          zoomControlsEnabled: false,
                          markers: _markers,
                          polylines: _polylines,
                          onMapCreated: (GoogleMapController controller) {
                            _controller = controller;
                            _isLoading = false;
                            setMarker(
                              track.store, track.deliveryMan,
                              track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                            );
                          },
                          style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                        ),
                        Positioned(
                          right: 15, bottom: 15,
                          child: InkWell(
                            onTap: () => _checkPermission(() async {
                              AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                              setMarker(
                                track.store, track.deliveryMan,
                                track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                                currentAddress: address, fromCurrentLocation: true,
                              );
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                              child: Icon(Icons.my_location_outlined, color: const Color(0xFF16A34A), size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Help Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF16A34A), size: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Need Help?', style: robotoBold.copyWith(fontSize: 16)),
                            Text('Call us 24/7', style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication),
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                          child: const Icon(Icons.call_outlined, color: Color(0xFF16A34A), size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPharmacyStepper(int state) {
    List<String> labels = ["Placed", "Confirmed", "Packed", "Out for Delivery", "Delivered"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (index) {
        bool isActive = index <= state;
        bool isLast = index == labels.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isActive ? const Color(0xFF16A34A) : Colors.grey.shade200))),
                  Container(
                    height: 24, width: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFF16A34A) : Colors.white,
                      border: Border.all(color: isActive ? const Color(0xFF16A34A) : Colors.grey.shade300, width: 2),
                    ),
                    child: isActive ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                  Expanded(child: Container(height: 2, color: isLast ? Colors.transparent : (index < state ? const Color(0xFF16A34A) : Colors.grey.shade200))),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: 10,
                  color: isActive ? const Color(0xFF16A34A) : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void setMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    try {

      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: (isRestaurant || parcel) ? 70 : isRestaurant ? 70 : 70,
        imagePath: parcel ? Images.mapperson : isRestaurant ? Images.mapstore : Images.mapstore,
      );

      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70,height: 70, imagePath: Images.mapdboy,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70,height: 70, imagePath: takeAway ? Images.mapperson : Images.mapperson,
      );

      /// Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      if(fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 7 : 15)));
      }

      if(!fromCurrentLocation) {
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
        if(!ResponsiveHelper.isWeb()) {
          zoomToFit(_controller, bounds, centerBounds, padding: GetPlatform.isWeb ? 15 : 3);
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'Destination'.tr,
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'receiver'.tr : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        // rotation: rotation,
        icon: deliveryBoyImageData,
      )) : const SizedBox();

    }catch(_) {}
    setState(() {});
  }

  void updateMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    try {

      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: (isRestaurant || parcel) ? 70 : isRestaurant ? 70 : 70,
        imagePath: parcel ? Images.mapstore : isRestaurant ? Images.mapstore : Images.mapstore,
      );

      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70, imagePath: Images.mapdboy,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 70, imagePath: takeAway ? Images.mapperson : Images.mapperson,
      );

      LatLngBounds? bounds;
      debugPrint(bounds.toString());
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 180;
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'Destination'.tr,
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'receiver'.tr : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        // rotation: rotation,
        icon: deliveryBoyImageData,
      )) : const SizedBox();

    }catch(_) {}
    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
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

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    }else {
      onTap();
    }
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
// PARCEL MODULE ── 50 % Live Map  +  50 % Order Details
// ═══════════════════════════════════════════════════════════════════════════════
extension _ParcelTracking on OrderTrackingScreenState {

  Widget _buildParcelTrackingView(OrderModel track, OrderController orderController) {
    const primaryOrange = Color(0xFFF97316);
    const bgColor       = Color(0xFFF8F9FB);

    int stepState = 0;
    if (track.orderStatus == 'confirmed')                                          stepState = 1;
    else if (track.orderStatus == 'processing' || track.orderStatus == 'handover') stepState = 2;
    else if (track.orderStatus == 'picked_up')                                     stepState = 3;
    else if (track.orderStatus == 'delivered')                                     stepState = 4;
    else if (track.orderStatus == 'failed' || track.orderStatus == 'canceled')     stepState = -1;

    final double screenH = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // ── Custom Header ───────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 12, left: 8, right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Order Tracking', style: robotoBold.copyWith(fontSize: 17, color: const Color(0xFF1A1A1A))),
                    Text('Parcel  #${track.id}', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: stepState == 4  ? const Color(0xFFDCFCE7)
                       : stepState == -1 ? const Color(0xFFFEE2E2)
                       :                   const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stepState == 4  ? 'Delivered'
                  : stepState == -1 ? 'Cancelled'
                  : stepState == 3  ? 'On The Way'
                  : stepState == 2  ? 'Preparing'
                  : stepState == 1  ? 'Confirmed'
                  : 'Placed',
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: stepState == 4  ? const Color(0xFF16A34A)
                         : stepState == -1 ? const Color(0xFFDC2626)
                         : primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Top 50 %: Live Map ──────────────────────────────────────────────
        SizedBox(
          height: screenH * 0.44,
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                trafficEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    double.tryParse(track.deliveryAddress?.latitude  ?? '0') ?? 0,
                    double.tryParse(track.deliveryAddress?.longitude ?? '0') ?? 0,
                  ),
                  zoom: 15,
                ),
                zoomControlsEnabled: false,
                markers:   _markers,
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  _isLoading  = false;
                  setMarker(
                    Store(
                      latitude:  track.receiverDetails?.latitude,
                      longitude: track.receiverDetails?.longitude,
                      address:   track.receiverDetails?.address,
                      name:      track.receiverDetails?.contactPersonName,
                    ),
                    track.deliveryMan,
                    track.deliveryAddress,
                    false, true, false,
                  );
                },
                style: Get.isDarkMode
                    ? Get.find<ThemeController>().darkMap
                    : Get.find<ThemeController>().lightMap,
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              // Location button
              Positioned(
                right: 14, bottom: 14,
                child: InkWell(
                  onTap: () => _checkPermission(() async {
                    AddressModel address = await Get.find<LocationController>()
                        .getCurrentLocation(false, mapController: _controller);
                    setMarker(
                      Store(
                        latitude:  track.receiverDetails?.latitude,
                        longitude: track.receiverDetails?.longitude,
                        address:   track.receiverDetails?.address,
                        name:      track.receiverDetails?.contactPersonName,
                      ),
                      track.deliveryMan, track.deliveryAddress,
                      false, true, false,
                      currentAddress: address, fromCurrentLocation: true,
                    );
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.my_location_rounded, color: primaryOrange, size: 22),
                  ),
                ),
              ),
              // Stepper overlay
              Positioned(
                top: 10, left: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: _buildParcelStepper(stepState, primaryOrange),
                ),
              ),
            ],
          ),
        ),

        // ── Bottom 50 %: Order Details ──────────────────────────────────────
        Expanded(
          child: Container(
            color: bgColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery partner
                  if (track.deliveryMan != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomImage(image: track.deliveryMan!.imageFullUrl ?? '', height: 52, width: 52, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery Partner', style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey)),
                              Text('${track.deliveryMan!.fName ?? ''} ${track.deliveryMan!.lName ?? ''}',
                                style: robotoBold.copyWith(fontSize: 15, color: const Color(0xFF1A1A1A))),
                            ],
                          )),
                          _parcelIconBtn(icon: Icons.call_rounded, color: primaryOrange, bg: const Color(0xFFFFF7ED),
                            onTap: () => launchUrlString('tel:${track.deliveryMan!.phone}', mode: LaunchMode.externalApplication)),
                          if (showChatPermission) ...[
                            const SizedBox(width: 8),
                            _parcelIconBtn(icon: Icons.chat_bubble_rounded, color: primaryOrange, bg: const Color(0xFFFFF7ED),
                              onTap: () async {
                                _timer?.cancel();
                                await Get.toNamed(RouteHelper.getChatRoute(
                                  notificationBody: NotificationBodyModel(deliverymanId: track.deliveryMan!.id, orderId: track.id),
                                  user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, imageFullUrl: track.deliveryMan!.imageFullUrl),
                                ));
                                _timerTrackOrder();
                              }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                      child: Row(children: [
                        const Icon(Icons.delivery_dining_rounded, color: Colors.grey, size: 28),
                        const SizedBox(width: 12),
                        Text('Delivery man not assigned yet', style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey.shade600)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Sender → Receiver card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                          child: const Icon(Icons.radio_button_checked_rounded, color: primaryOrange, size: 16)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Sender', style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(track.deliveryAddress?.contactPersonName ?? 'N/A', style: robotoBold.copyWith(fontSize: 14, color: const Color(0xFF1A1A1A))),
                          Text(track.deliveryAddress?.address ?? '', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                        if (track.deliveryAddress?.contactPersonNumber != null)
                          _parcelIconBtn(icon: Icons.call_outlined, color: primaryOrange, bg: const Color(0xFFFFF7ED), size: 18,
                            onTap: () => launchUrlString('tel:${track.deliveryAddress!.contactPersonNumber}', mode: LaunchMode.externalApplication)),
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(left: 19, top: 4, bottom: 4),
                        child: Column(children: List.generate(3, (_) => Container(height: 6, width: 2, margin: const EdgeInsets.symmetric(vertical: 2), color: Colors.grey.shade300))),
                      ),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on_rounded, color: Color(0xFF3B82F6), size: 16)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Receiver', style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(track.receiverDetails?.contactPersonName ?? 'N/A', style: robotoBold.copyWith(fontSize: 14, color: const Color(0xFF1A1A1A))),
                          Text(track.receiverDetails?.address ?? '', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                        if (track.receiverDetails?.contactPersonNumber != null)
                          _parcelIconBtn(icon: Icons.call_outlined, color: const Color(0xFF3B82F6), bg: const Color(0xFFEFF6FF), size: 18,
                            onTap: () => launchUrlString('tel:${track.receiverDetails!.contactPersonNumber}', mode: LaunchMode.externalApplication)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Order info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(children: [
                      _parcelInfoRow('Order ID', '#${track.id}', primaryOrange),
                      if (track.parcelCategory != null) ...[
                        const Divider(height: 20, thickness: 0.5),
                        _parcelInfoRow('Parcel Type', track.parcelCategory!.name ?? 'General', Colors.blueGrey),
                      ],
                      const Divider(height: 20, thickness: 0.5),
                      _parcelInfoRow('Payment', (track.paymentMethod ?? 'N/A').replaceAll('_', ' '), Colors.blueGrey),
                      const Divider(height: 20, thickness: 0.5),
                      _parcelInfoRow('Delivery Charge', '\$${(track.deliveryCharge ?? 0).toStringAsFixed(2)}', primaryOrange),
                      if (track.orderNote != null && track.orderNote!.isNotEmpty) ...[
                        const Divider(height: 20, thickness: 0.5),
                        _parcelInfoRow('Note', track.orderNote!, Colors.blueGrey),
                      ],
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _parcelIconBtn({required IconData icon, required Color color, required Color bg, double size = 20, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  Widget _parcelInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,  style: robotoBold.copyWith(fontSize: 13, color: valueColor)),
      ],
    );
  }

  Widget _buildParcelStepper(int state, Color activeColor) {
    const labels = ['Placed', 'Confirmed', 'Preparing', 'On the way', 'Delivered'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (index) {
        final isActive = state >= 0 && index <= state;
        final isLast   = index == labels.length - 1;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isActive ? activeColor : Colors.grey.shade200))),
                Container(
                  height: 22, width: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? activeColor : Colors.white,
                    border: Border.all(color: isActive ? activeColor : Colors.grey.shade300, width: 2),
                  ),
                  child: isActive ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                ),
                Expanded(child: Container(height: 2, color: isLast ? Colors.transparent : (index < state ? activeColor : Colors.grey.shade200))),
              ]),
              const SizedBox(height: 5),
              Text(labels[index], textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: 9, color: isActive ? activeColor : Colors.grey.shade400)),
            ],
          ),
        );
      }),
    );
  }
}

