
class CaptainDetailsData {
  final Captain captain;
  final Vehicle vehicle;
  final VehicleTypeDetails vehicleTypeDetails;

  CaptainDetailsData({
    required this.captain,
    required this.vehicle,
    required this.vehicleTypeDetails,
  });

  factory CaptainDetailsData.fromJson(Map<String, dynamic> json) {
    return CaptainDetailsData(
      captain: Captain.fromJson(json['captain']),
      vehicle: Vehicle.fromJson(json['vehicle']),
      vehicleTypeDetails: VehicleTypeDetails.fromJson(json['vehicle_type_details']),
    );
  }
}
class Captain {
  final int id;
  final String status;
  final String token;
  final String fcmToken;
  final String name;
  final String mobileNumber;
  final String gender;
  final String dob;
  final String rcNumber;
  final String rcFrontPhoto;
  final String rcBackPhoto;
  final int rcVerified;
  final String licenseNumber;
  final String licenseFrontPhoto;
  final String licenseBackPhoto;
  final String dlExpiry;
  final int licenseVerified;
  final String panNumber;
  final String panFrontPhoto;
  final int panVerified;
  final String aadhaarNumber;
  final String aadhaarFrontPhoto;
  final String aadhaarBackPhoto;
  final int aadhaarVerified;
  final String profileImage;
  final String createdAt;
  final String updatedAt;
  final int zoneId;

  Captain({
    required this.id,
    required this.status,
    required this.token,
    required this.fcmToken,
    required this.name,
    required this.mobileNumber,
    required this.gender,
    required this.dob,
    required this.rcNumber,
    required this.rcFrontPhoto,
    required this.rcBackPhoto,
    required this.rcVerified,
    required this.licenseNumber,
    required this.licenseFrontPhoto,
    required this.licenseBackPhoto,
    required this.dlExpiry,
    required this.licenseVerified,
    required this.panNumber,
    required this.panFrontPhoto,
    required this.panVerified,
    required this.aadhaarNumber,
    required this.aadhaarFrontPhoto,
    required this.aadhaarBackPhoto,
    required this.aadhaarVerified,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    required this.zoneId,
  });

  factory Captain.fromJson(Map<String, dynamic> json) {
    return Captain(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      token: json['token'] ?? '',
      fcmToken: json['fcm_token'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      rcNumber: json['rc_number'] ?? '',
      rcFrontPhoto: json['rc_front_photo'] ?? '',
      rcBackPhoto: json['rc_back_photo'] ?? '',
      rcVerified: json['rc_verified'] ?? 0,
      licenseNumber: json['license_number'] ?? '',
      licenseFrontPhoto: json['license_front_photo'] ?? '',
      licenseBackPhoto: json['license_back_photo'] ?? '',
      dlExpiry: json['dl_expiry'] ?? '',
      licenseVerified: json['license_verified'] ?? 0,
      panNumber: json['pan_number'] ?? '',
      panFrontPhoto: json['pan_front_photo'] ?? '',
      panVerified: json['pan_verified'] ?? 0,
      aadhaarNumber: json['aadhaar_number'] ?? '',
      aadhaarFrontPhoto: json['aadhaar_front_photo'] ?? '',
      aadhaarBackPhoto: json['aadhaar_back_photo'] ?? '',
      aadhaarVerified: json['aadhaar_verified'] ?? 0,
      profileImage: json['profile_image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      zoneId: json['zone_id'] ?? 0,
    );
  }
}
class Vehicle {
  final String vehicleNumber;
  final String color;

  Vehicle({
    required this.vehicleNumber,
    required this.color,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleNumber: json['vehicle_number'] ?? '',
      color: json['color'] ?? '',
    );
  }
}
class VehicleTypeDetails {
  final String name;
  final String image;
  final String baseFare;
  final String pricePerKm;
  final String pricePerMin;
  final int seats;
  final String vehicleType;
  final int? zoneId;
  final int commission;

  VehicleTypeDetails({
    required this.name,
    required this.image,
    required this.baseFare,
    required this.pricePerKm,
    required this.pricePerMin,
    required this.seats,
    required this.vehicleType,
    required this.zoneId,
    required this.commission,
  });

  factory VehicleTypeDetails.fromJson(Map<String, dynamic> json) {
    return VehicleTypeDetails(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      baseFare: json['base_fare'] ?? '',
      pricePerKm: json['price_per_km'] ?? '',
      pricePerMin: json['price_per_min'] ?? '',
      seats: json['seats'] ?? 0,
      vehicleType: json['vehicle_type'] ?? '',
      zoneId: json['zone_id'],
      commission: json['commission'] ?? 0,
    );
  }
}
