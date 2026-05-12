import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/util/app_constants.dart';
import '../model/bookinghistorymodel.dart';
import '../model/captionmodel.dart';
import 'package:handy_allinone/features/review/domain/models/captain_rating_model.dart';

class DriverController extends GetxController {
  final ApiClient apiClient;
  RxList<Driver> driverList = <Driver>[].obs;

  DriverController({required this.apiClient});
  var isLoading = false.obs;
  String? googleMapsApiKey;
  CaptainDetailsData? captainDetails;
  CaptainRatingModel? captainRating;
  Future<void> fetchRealtimeDrivers() async {
    try {
      final dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: AppConstants.firebaseDBURL,
      ).ref();

      final DataSnapshot snapshot = await dbRef.child('drivers').get();

      if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
        // print("Driver Data Response: ${snapshot.value}");
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        final List<Driver> loadedDrivers = [];

        data.forEach((key, value) {
          if (value is Map) {
            final driverMap = Map<String, dynamic>.from(value);
            final driver = Driver.fromMap(driverMap);
            loadedDrivers.add(driver);
          }
        });

        driverList.value = loadedDrivers;
      } else {
        if (snapshot.value != null && snapshot.value is! Map) {
          print(
            "⚠️ Unexpected data format for drivers: ${snapshot.value.runtimeType}",
          );
        }
        driverList.clear();
      }
    } catch (e) {
      print("❌ Error while fetching drivers: $e");
    }
  }

  Future<Driver?> fetchDriver(int driverId) async {
    try {
      final dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: AppConstants.firebaseDBURL,
      ).ref();

      final snapshot = await dbRef.child('drivers/$driverId').get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        return Driver.fromMap(data);
      }
    } catch (e) {
      print("❌ Error fetching driver: $e");
    }
    return null;
  }

  Future<void> fetchBookings(int bookingId) async {
    print("Fetching booking with ID: $bookingId");

    try {
      final dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: AppConstants.firebaseDBURL,
      ).ref();

      final DataSnapshot snapshot = await dbRef
          .child('bookings/$bookingId')
          .get();

      print("Snapshot fetched.");

      if (snapshot.exists && snapshot.value != null) {
        final Map<String, dynamic> booking = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        print("📦 Booking ID: $bookingId");
        print("   🚗 Vehicle Type: ${booking['type']}");
        print(
          "   📍 Pickup: ${booking['pickup_location']} (${booking['pickup_lat']}, ${booking['pickup_lng']})",
        );
        print(
          "   📍 Dropoff: ${booking['dropoff_location']} (${booking['dropoff_lat']}, ${booking['dropoff_lng']})",
        );
        print(
          "   👤 Passenger: ${booking['passenger_name']} - ${booking['passenger_phone']}",
        );
        print("   💰 Fare: ${booking['fare_amount']}");
        print("   📅 Scheduled At: ${booking['scheduled_at']}");
      } else {
        print("⚠️ No booking found with ID: $bookingId");
      }
    } catch (e) {
      print("❌ Error while fetching booking: $e");
    }
  }

  Future<void> loadGoogleMapKey() async {
    try {
      final response = await apiClient.getData(AppConstants.polylinemap);
      if (response.statusCode == 200 && response.body != null) {
        googleMapsApiKey = response.body['google_map_key'];
        print("✅ Google Map Key loaded: $googleMapsApiKey");

        // Proceed only if key is valid
        if (googleMapsApiKey != null && googleMapsApiKey!.isNotEmpty) {
          // Optionally call a method to initialize maps or services
          onMapKeyLoaded();
        }
      } else {
        print(
          "❌ Failed to fetch Google Map Key. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Exception while loading map key: $e");
    }
  }

  void onMapKeyLoaded() {
    // Use the key here if needed
    print("🗺️ Ready to use Map Key: $googleMapsApiKey");

    // For example, fetch routes or initialize maps
  }

  // If you need a getter
  String? get mapKey => googleMapsApiKey;

  Future<CaptainDetailsData?> fetchCaptainDetails(int captainId) async {
    print("🔄 Fetching captain details for ID: $captainId");
    isLoading.value = true;

    try {
      final response = await apiClient.getData(
        "${AppConstants.captiondetails}?captain_id=$captainId",
      );

      if (response.statusCode == 200 && response.body['status'] == true) {
        captainDetails = CaptainDetailsData.fromJson(response.body['data']);

        print("✅ Captain Name: ${captainDetails!.captain.name}");
        print("✅ RC Verified: ${captainDetails!.captain.rcVerified}");
        print("✅ License Expiry: ${captainDetails!.captain.dlExpiry}");
        print("✅ Vehicle Number: ${captainDetails!.vehicle.vehicleNumber}");
        print("✅ Vehicle Type: ${captainDetails!.vehicleTypeDetails.name}");
      } else {
        print("❌ Failed: ${response.body['message']}");
        captainDetails = null;
      }
    } catch (e) {
      print("❗ Exception: $e");
      captainDetails = null;
    } finally {
      isLoading.value = false;
      print("✅ Loading finished for captain ID: $captainId");
    }

    return captainDetails;
  }

  Future<CaptainRatingModel?> fetchCaptainRating(int captainId) async {
    print("🔄 Fetching captain rating for ID: $captainId");
    try {
      final response = await apiClient.getData("${AppConstants.captainReviewRatingUri}$captainId");
      if (response.statusCode == 200) {
        captainRating = CaptainRatingModel.fromJson(response.body);
        print("✅ Captain Rating: ${captainRating!.averageRating} (${captainRating!.totalReviews} reviews)");
        update();
      }
    } catch (e) {
      print("❗ Exception while fetching rating: $e");
    }
    return captainRating;
  }

  Future<void> sendSosAlert({
    required int bookingId,
    required int captainId,
    required int customerId,
    required double lat,
    required double lng,
  }) async {
    isLoading.value = true;
    try {
      final response = await apiClient.postData(AppConstants.sosAlert, {
        "booking_id": bookingId,
        "captain_id": captainId,
        "customer_id": customerId,
        "triggered_by": "customer",
        "lat": lat,
        "long": lng,
      });

      if (response.statusCode == 200) {
        showCustomSnackBar("SOS alert sent successfully!", isError: false);
      } else {
        showCustomSnackBar("Failed to send SOS alert: ${response.statusText}", isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Error sending SOS alert: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}

