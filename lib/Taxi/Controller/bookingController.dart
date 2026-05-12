import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/util/app_constants.dart';
import '../model/bookinghistorymodel.dart';
import '../model/vehicle_listmodel.dart';


  class BookingController extends GetxController {
  final ApiClient apiClient;

  BookingController({required this.apiClient});

  final RxList<RideData> bookingList = <RideData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;

  int offset = 0;
  final int limit = 10;
  bool hasMore = true;
  final RxList<Datum> vehicleList = <Datum>[].obs;

  Future<void> fetchVehicleList() async {
    final Response response = await apiClient.getData(AppConstants.Vehiclelist);
    if (response.statusCode == 200) {
      final vehicles = Vehiclelist.fromJson(response.body);
      vehicleList.value = vehicles.data;
    } else {
      Get.snackbar("Error", "Failed to load vehicle list");
    }
  }
  Future<void> fetchBookingHistory({bool isInitial = false}) async {
    if (isInitial) {
      offset = 0;
      hasMore = true;
      bookingList.clear();
    }

    // ✅ If no more data, avoid calling API
    if (!hasMore || isLoading.value || isMoreLoading.value) return;

    isLoading.value = isInitial;
    isMoreLoading.value = !isInitial;

    try {
      final response = await apiClient.getData(
        '${AppConstants.bookinghistory}?offset=$offset&limit=$limit',
      );

      print("📦 Response Body: ${response.body}");
      print("✅ Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final history = HistoryModel.fromJson(response.body);
        final List<RideData> newRides = history.data;

        // ✅ Avoid duplicates based on unique `id` or property
        final filteredRides = newRides.where((newRide) {
          return !bookingList.any((existingRide) => existingRide.id == newRide.id);
        }).toList();

        // ✅ Add only new non-duplicate rides
        bookingList.addAll(filteredRides);

        // ✅ Increment offset only for newly fetched data
        if (filteredRides.isNotEmpty) {
          offset += limit;
        }

        // ✅ If fetched fewer than limit, assume no more
        if (newRides.length < limit) {
          hasMore = false;
        }
      } else {
        Get.snackbar("Error", "Failed to fetch booking history");
      }
    } catch (e) {
      print("🚨 Exception: $e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<bool> submitCaptainReview(int captainId, int bookingId, double rating, String comment) async {
    isLoading.value = true;
    update();
    try {
      final response = await apiClient.postData(AppConstants.submitCaptainReviewUri, {
        'captain_id': captainId,
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      });

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Review submitted successfully");
        return true;
      } else if (response.statusCode == 403) {
        Get.snackbar("Error", response.body['message'] ?? "Forbidden");
        return false;
      } else {
        Get.snackbar("Error", response.body['message'] ?? "Failed to submit review");
        return false;
      }
    } catch (e) {
      print("🚨 Exception: $e");
      Get.snackbar("Exception", e.toString());
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
