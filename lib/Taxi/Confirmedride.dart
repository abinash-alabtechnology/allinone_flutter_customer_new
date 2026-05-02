// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:handy_allinone/features/Taxi/TripDetails.dart';
// import 'package:handy_allinone/features/Taxi/booking_history.dart';
// import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
//
// import '../../util/app_constants.dart';
// import '../chat/screens/chat_screen.dart';
// import 'Controller/DriverController.dart';
// import 'chatscreen.dart';
// import 'model/captionmodel.dart';
//
// class RideConfirmedScreen extends StatefulWidget {
//   final int Bookingid;
//   final int driverid;
//   const RideConfirmedScreen({super.key, required this.Bookingid, required this.driverid});
//
//   @override
//   State<RideConfirmedScreen> createState() => _RideConfirmedScreenState();
// }
//
// class _RideConfirmedScreenState extends State<RideConfirmedScreen> {
//   final DriverController controller = Get.put(
//       DriverController(apiClient: Get.find()));
//   CaptainDetailsData? _captainDetails;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     controller.fetchCaptainDetails(widget.driverid);
//   }
//
//   void _navigateToHistory(BuildContext context) {
//     Navigator.pop(context);
//     Future<void> resetDropoffFlag() async {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('hasDropoff', false);
//     }
//     Get.offAll(() => DashboardScreen(pageIndex: 4, fromSplash: false)); // this is the screen you want when pressing back
//
//                     Get.to(() => HistoryScreen());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _navigateToHistory(context);
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           automaticallyImplyLeading: false, // Removes the back arrow
//           title: const Text("Your ride is confirmed."),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           actions: [
//             TextButton(
//               onPressed: () {
//               },
//               child: const Text("Emergency", style: TextStyle(color: Colors.red)),
//             )
//           ],
//         ),
//         body:_isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _captainDetails == null
//             ? const Center(child: Text("No details available"))
//             : Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                      Text(
//             _captainDetails!.vehicle.vehicleNumber,
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const Spacer(),
//                     CircleAvatar(
//                       backgroundImage: AssetImage('assets/image/driver_icon.png'), // Replace with actual image path
//                       radius: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Image.network
//                       ('${AppConstants.baseUrl}${AppConstants.Vehicleimage}${_captainDetails!.vehicleTypeDetails.image}', height: 40),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                  Align(
//                   alignment: Alignment.centerLeft,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(_captainDetails!.vehicleTypeDetails.name, style: TextStyle(fontSize: 14)),
//                       const SizedBox(height: 5),
//                       Text("${_captainDetails!.captain.name} ", style: TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 InkWell(
//                   onTap: (){ ChatScreentaxi(
//                     bookingId: 'bookingId_123',
//                     customerId: 'user_001',
//                     driverId: 'driver_001',
//                   );},
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Message your driver...",
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed: () {},
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Total Fare ₹75",
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 4),
//                       const Text("Please agree on the final price with the driver"),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: const [
//                           Icon(Icons.money, color: Colors.green),
//                           SizedBox(width: 8),
//                           Text("Cash"),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     showTripDetailBottomSheet(context , widget.Bookingid);
//                   },
//                   icon: const Icon(Icons.info_outline),
//                   label: const Text("Trip Details"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade50,
//                     foregroundColor: Colors.blue.shade800,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//    //   ),
//     );
//   }
// }
