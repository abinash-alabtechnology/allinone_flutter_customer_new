import 'dart:convert';

HistoryModel historyModelFromJson(String str) => HistoryModel.fromJson(json.decode(str));
String historyModelToJson(HistoryModel data) => json.encode(data.toJson());

class HistoryModel {
  final int total;
  final int limit;
  final int offset;
  final List<RideData> data;

  HistoryModel({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    total: json["total"] ?? 0,
    limit: json["limit"] ?? 0,
    offset: json["offset"] ?? 0,
    data: json["data"] == null
        ? []
        : List<RideData>.from(json["data"].map((x) => RideData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "limit": limit,
    "offset": offset,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class RideData {
  final int id;
  final int userId;
  final int? captainId;
  final int vehiclePriceTypeId;
  final String pickupLocation;
  final String dropoffLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String distanceKm;
  final String fareAmount;
  final String passengerName;
  final String passengerPhone;
  final String paymentMethod;
  final String paymentStatus;
  final String rideStatus;
  final dynamic cancelledBy;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int zoneId;

  RideData({
    required this.id,
    required this.userId,
    this.captainId,
    required this.vehiclePriceTypeId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.distanceKm,
    required this.fareAmount,
    required this.passengerName,
    required this.passengerPhone,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.rideStatus,
    this.cancelledBy,
    required this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    required this.zoneId,
  });

  factory RideData.fromJson(Map<String, dynamic> json) => RideData(
    id: json["id"],
    userId: json["user_id"],
    captainId: json["captain_id"],
    vehiclePriceTypeId: json["vehicle_price_type_id"],
    pickupLocation: json["pickup_location"] ?? "",
    dropoffLocation: json["dropoff_location"] ?? "",
    pickupLat: (json["pickup_lat"] ?? 0).toDouble(),
    pickupLng: (json["pickup_lng"] ?? 0).toDouble(),
    dropoffLat: (json["dropoff_lat"] ?? 0).toDouble(),
    dropoffLng: (json["dropoff_lng"] ?? 0).toDouble(),
    distanceKm: json["distance_km"] ?? "",
    fareAmount: json["fare_amount"] ?? "",
    passengerName: json["passenger_name"] ?? "",
    passengerPhone: json["passenger_phone"] ?? "",
    paymentMethod: json["payment_method"] ?? "",
    paymentStatus: json["payment_status"] ?? "",
    rideStatus: json["ride_status"] ?? "",
    cancelledBy: json["cancelled_by"],
    scheduledAt: DateTime.parse(json["scheduled_at"]),
    startedAt: json["started_at"] != null ? DateTime.tryParse(json["started_at"]) : null,
    completedAt: json["completed_at"] != null ? DateTime.tryParse(json["completed_at"]) : null,
    cancelledAt: json["cancelled_at"] != null ? DateTime.tryParse(json["cancelled_at"]) : null,
    cancelReason: json["cancel_reason"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    zoneId: json["zone_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "captain_id": captainId,
    "vehicle_price_type_id": vehiclePriceTypeId,
    "pickup_location": pickupLocation,
    "dropoff_location": dropoffLocation,
    "pickup_lat": pickupLat,
    "pickup_lng": pickupLng,
    "dropoff_lat": dropoffLat,
    "dropoff_lng": dropoffLng,
    "distance_km": distanceKm,
    "fare_amount": fareAmount,
    "passenger_name": passengerName,
    "passenger_phone": passengerPhone,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "ride_status": rideStatus,
    "cancelled_by": cancelledBy,
    "scheduled_at": scheduledAt.toIso8601String(),
    "started_at": startedAt?.toIso8601String(),
    "completed_at": completedAt?.toIso8601String(),
    "cancelled_at": cancelledAt?.toIso8601String(),
    "cancel_reason": cancelReason,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "zone_id": zoneId,
  };
}
class Driver {
  final double heading;
  final String type;
  final String vehicletype;
  final double lat;
  final double long;
  final double speed;

  Driver({
    required this.heading,
    required this.type,
    required this.vehicletype,
    required this.lat,
    required this.long,
    required this.speed,
  });

  /// Helper to safely parse dynamic types to double
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0; // default fallback
  }

  /// Factory constructor to build Driver from a Map
  factory Driver.fromMap(Map<dynamic, dynamic> map) {
    return Driver(
      heading: _parseDouble(map['heading']),
      type: map['type'] ?? '',
      vehicletype: map['vehicle_type'] ?? '',
      lat: _parseDouble(map['lat']),
      long: _parseDouble(map['long']),
      speed: _parseDouble(map['speed']),
    );
  }

  /// Convert Driver to Map
  Map<String, dynamic> toMap() {
    return {
      'heading': heading,
      'type': type,
      'vehicle_type': vehicletype,
      'lat': lat,
      'long': long,
      'speed': speed,
    };
  }

  /// String representation for debugging
  @override
  String toString() {
    return 'Driver(type: $type, vehicle: $vehicletype, heading: $heading, lat: $lat, long: $long, speed: $speed)';
  }
}

