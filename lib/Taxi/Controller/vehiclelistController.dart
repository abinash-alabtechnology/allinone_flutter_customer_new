// import 'package:get/get.dart';
// import 'package:handy_allinone/api/api_client.dart';
// import 'package:handy_allinone/features/Taxi/model/vehicle_listmodel.dart';
// import 'package:flutter/foundation.dart';
// import 'package:handy_allinone/util/app_constants.dart';
//
// class VehicleListController extends GetxController {
//   final ApiClient apiClient;
//
//   VehicleListController({required this.apiClient});
//
//
//   var vehicleList = <Datum>[].obs;
//   var isLoading = false.obs;
//   var hasError = false.obs;
//   var errorMessage = ''.obs;
//
//
//   Future<void> fetchVehicleList() async {
//     isLoading.value = true;
//     hasError.value = false;
//     errorMessage.value = '';
//
//     try {
//       Response response = await apiClient.getData(AppConstants.Vehiclelist);
//       if (response.statusCode == 200 && response.body != null) {
//         final Vehiclelist vehicles = Vehiclelist.fromJson(response.body);
//         vehicleList.value = vehicles.data;
//       } else {
//         hasError.value = true;
//         errorMessage.value = response.statusText ?? 'Unknown error';
//         if (kDebugMode) {
//           print("❌ Failed to load vehicles: ${response.statusText}");
//         }
//       }
//     } catch (e) {
//       hasError.value = true;
//       errorMessage.value = e.toString();
//       if (kDebugMode) {
//         print("❌ Exception: $e");
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:handy_allinone/util/app_constants.dart';

import '../model/vehicle_listmodel.dart';

class VehicleListController extends GetxController {
  final ApiClient apiClient;

  VehicleListController({required this.apiClient});

  var vehicleList = <Datum>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  int? lastBookingId;
  int? userId;
  String? otp;
  var vehicleFareMap = <int, double>{}.obs;

  Future<void> fetchVehicleList({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      Response response = await apiClient.getData(AppConstants.Vehiclelist);
      if (response.statusCode == 200 && response.body != null) {
        final Vehiclelist vehicles = Vehiclelist.fromJson(response.body);
        vehicleList.value = vehicles.data;

      } else {
        hasError.value = true;
        errorMessage.value = response.statusText ?? 'Unknown error';
        if (kDebugMode) {
          print("❌ Failed to load vehicles: ${response.statusText}");
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      if (kDebugMode) {
        print("❌ Exception: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }



  Future<bool> bookingdata(Map<String, dynamic> bookingData) async {
    isLoading.value = true;
    try {
      final String? zoneIdHeader = apiClient.zoneId;

      if (zoneIdHeader != null) {
        bookingData['zone_id'] = jsonDecode(zoneIdHeader)[0];
      } else {
        print("⚠️ zone_id not found in headers");
      }

      Response response = await apiClient.postData(AppConstants.taxibooking, bookingData);
      if (response.statusCode == 200 && response.body != null) {
        final responseData = response.body;


        lastBookingId = responseData['id'] ?? responseData['data']?['id'];
        userId = responseData['user_id'] ?? responseData['data']?['user_id'];
        otp = responseData['user_id'] ?? responseData['data']?['otp'];
        print("✅ Booking Successful, ID: $lastBookingId");

        return true;
      } else {
        print("❌ Booking Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception occurred while booking: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> retrybooking(Map<String, dynamic> retrybooking) async {
    isLoading.value = true;
    try {
      Response response = await apiClient.postData(AppConstants.retrybooking, retrybooking);
      print("gddfgdfg ${response.statusCode}");
      print(response.body);
      if (response.statusCode == 200 && response.body != null) {
        final responseData = response.body;
        print("✅ Booking retring Successful $responseData");
        return true;
      } else {
        print("❌ Booking retry Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception occurred while booking: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> cancelbooking(Map<String, dynamic> bookingcancelData) async {
    isLoading.value = true;
    try {
      Response response = await apiClient.postData(AppConstants.bookingcancel, bookingcancelData);
print("gddfgdfg ${response.statusCode}");
print(response.body);
      if (response.statusCode == 200 && response.body != null) {
        final responseData = response.body;
        print("✅ Booking cancelled Successful $responseData");
        return true;
      } else {
        print("❌ Booking Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception occurred while booking: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelBookingAndVerify(

      Map<String, dynamic> bookingCancelData, int? bookingId) async {
    isLoading.value = true;
    try {
      bool apiSuccess = await cancelbooking(bookingCancelData);
      if (!apiSuccess) return false;

      final dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
         AppConstants.firebaseDBURL,
      ).ref();


      await dbRef.child('bookings/$bookingId').remove();
      print("✅ Booking with ID $bookingId deleted from Firebase");


      // Step 3: Confirm the update (optional but good practice)
      final DataSnapshot snapshot =
      await dbRef.child('bookings/$bookingId').get();

      if (!snapshot.exists) {
        print("✅ Firebase ride_status updated to cancelled");
        return true;
      } else {
        print("❌ Failed to confirm ride_status update in Firebase");
        return false;
      }
    } catch (e) {
      print("❌ Exception in cancelBookingAndUpdateStatus: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }


}
