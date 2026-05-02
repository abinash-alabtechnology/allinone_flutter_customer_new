import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static Future<void> saveOngoingBooking(int bookingId, int driverId, int userId, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ongoing_booking_id', bookingId);
    await prefs.setInt('ongoing_driver_id', driverId);
    await prefs.setInt('ongoing_userId', userId);
    await prefs.setString('ongoing_otp', otp);
  }

  static Future<void> saveBookingIdToPrefs(int bookingId, int userId, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ongoing_booking_id', bookingId);
    await prefs.setInt('ongoing_userId', userId);
    await prefs.setString('ongoing_otp', otp);
  }

  static Future<Map<String, dynamic>?> getBookingIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingId = prefs.getInt('ongoing_booking_id');
    final userId = prefs.getInt('ongoing_userId');
    final otp = prefs.getString('ongoing_otp');

    if (bookingId != null && userId != null && otp != null) {
      return {
        'bookingId': bookingId,
        'userId': userId,
        'otp': otp,
      };
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getOngoingBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingId = prefs.getInt('ongoing_booking_id');
    final driverId = prefs.getInt('ongoing_driver_id');
    final userId = prefs.getInt('ongoing_userId');
    final otp = prefs.getString('ongoing_otp');

    if (bookingId != null && driverId != null && userId != null && otp != null) {
      return {
        'bookingId': bookingId,
        'driverId': driverId,
        'userId': userId,
        'otp': otp,
      };
    }
    return null;
  }

  static Future<void> clearOngoingBooking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ongoing_booking_id');
    await prefs.remove('ongoing_driver_id');
    await prefs.remove('ongoing_userId');
    await prefs.remove('ongoing_otp');
  }
}
