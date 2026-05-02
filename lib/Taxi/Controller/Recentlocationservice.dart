// import 'package:shared_preferences/shared_preferences.dart';
//
// class RecentLocationService {
//   static const String _key = "recent_locations";
//
//   static Future<void> addLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> locations = prefs.getStringList(_key) ?? [];
//
//     locations.remove(location); // avoid duplicate
//     locations.insert(0, location); // latest first
//
//     if (locations.length > 5) {
//       locations = locations.sublist(0, 5); // limit to 5
//     }
//
//     await prefs.setStringList(_key, locations);
//   }
//
//   static Future<List<String>> getRecentLocations() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getStringList(_key) ?? [];
//   }
// }
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentLocation {
  final String address;
  final double latitude;
  final double longitude;

  RecentLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
  };

  factory RecentLocation.fromJson(Map<String, dynamic> json) {
    return RecentLocation(
      address: json["address"] ?? "",
      latitude: (json["latitude"] ?? 0.0).toDouble(),
      longitude: (json["longitude"] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() => "📍 $address ($latitude, $longitude)";
}

class RecentLocationService {
  static const String _key = "recent_locations";

  /// Add a new location
  static Future<void> addLocation(
      String address, double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedList = prefs.getStringList(_key) ?? [];

    // Convert existing entries (safe parse)
    List<RecentLocation> locations = storedList.map((e) {
      try {
        return RecentLocation.fromJson(json.decode(e));
      } catch (_) {
        // Fallback for old plain string data
        return RecentLocation(address: e, latitude: 0.0, longitude: 0.0);
      }
    }).toList();

    // Remove duplicate (same address)
    locations.removeWhere((loc) => loc.address == address);

    // Add latest on top
    locations.insert(
      0,
      RecentLocation(address: address, latitude: latitude, longitude: longitude),
    );

    // Limit to 5 recent
    if (locations.length > 5) {
      locations = locations.sublist(0, 5);
    }

    // Encode and save
    List<String> jsonList =
    locations.map((loc) => json.encode(loc.toJson())).toList();
    await prefs.setStringList(_key, jsonList);

    print("✅ Saved Locations: $jsonList");
  }

  /// Get all recent locations
  static Future<List<RecentLocation>> getRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedList = prefs.getStringList(_key) ?? [];

    List<RecentLocation> locations = storedList.map((e) {
      try {
        return RecentLocation.fromJson(json.decode(e));
      } catch (_) {
        // fallback for old plain address strings
        return RecentLocation(address: e, latitude: 0.0, longitude: 0.0);
      }
    }).toList();

    print("📌 Loaded Recent Locations: $locations");
    return locations;
  }

  /// Clear all
  static Future<void> clearLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    print("🗑️ Cleared recent locations");
  }
}
