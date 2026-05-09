import 'dart:convert';

Vehiclelist vehiclelistFromJson(String str) => Vehiclelist.fromJson(json.decode(str));

String vehiclelistToJson(Vehiclelist data) => json.encode(data.toJson());

class Vehiclelist {
  bool status;
  List<Datum> data;

  Vehiclelist({
    required this.status,
    required this.data,
  });

  factory Vehiclelist.fromJson(Map<String, dynamic> json) => Vehiclelist(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String name;
  String image;
  String baseFare;
  String pricePerKm;
  String pricePerMin;
  String vehicletype;
  int seats;
  bool isCommon;
  bool status;
  DateTime createdAt;
  DateTime updatedAt;
  int? discount;
  String? description;

  Datum({
    required this.id,
    required this.name,
    required this.image,
    required this.baseFare,
    required this.pricePerKm,
    required this.pricePerMin,
    required this.vehicletype,
    required this.seats,
    required this.isCommon,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.discount,
    this.description,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    baseFare: json["base_fare"],
    pricePerKm: json["price_per_km"],
    pricePerMin: json["price_per_min"],
    vehicletype: json["vehicle_type"],
    seats: json["seats"],
    isCommon: json["is_common"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    discount: json["discount"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "base_fare": baseFare,
    "price_per_km": pricePerKm,
    "price_per_min": pricePerMin,
    "vehicle_type": vehicletype,
    "seats": seats,
    "is_common": isCommon,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "discount": discount,
    "description": description,
  };
}
