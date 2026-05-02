import 'package:handy_allinone/features/item/domain/models/item_model.dart';

class OrderDetailsModel {
  int? id;
  int? itemId;
  int? orderId;
  double? price;
  Item? itemDetails;
  List<Variation>? variation;
  List<FoodVariation>? foodVariation;
  List<AddOn>? addOns;
  double? discountOnItem;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;
  String? imageFullUrl;
  int? isGuest;
  bool? delivarBooking;
  String? publicTrackingId;
  String? otherChargesLabel;
  String? otherChargesAmount;
  String? taxStatus;
  double? discountPercentage;

  OrderDetailsModel({
    this.id,
    this.itemId,
    this.orderId,
    this.price,
    this.itemDetails,
    this.variation,
    this.foodVariation,
    this.addOns,
    this.discountOnItem,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
    this.imageFullUrl,
    this.isGuest,
    this.delivarBooking,
    this.publicTrackingId,
    this.otherChargesLabel,
    this.otherChargesAmount,
    this.taxStatus,
    this.discountPercentage,
  });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['item_id'];
    orderId = json['order_id'];
    price = json['price'].toDouble();
    itemDetails = json['item_details'] != null ? Item.fromJson(json['item_details']) : null;
    variation = [];
    foodVariation = [];
    if (json['variation'] != null && json['variation'].isNotEmpty) {
      if (json['variation'][0]['values'] != null) {
        json['variation'].forEach((v) {
          foodVariation!.add(FoodVariation.fromJson(v));
        });
      } else {
        json['variation'].forEach((v) {
          variation!.add(Variation.fromJson(v));
        });
      }
    }
    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOn.fromJson(v));
      });
    }
    discountOnItem = json['discount_on_item']?.toDouble();
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = json['tax_amount']?.toDouble();
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = json['total_add_on_price']?.toDouble();
    imageFullUrl = json['image_full_url'];
    isGuest = json['is_guest'];
    delivarBooking = (json['delivar_booking']?.toString().toLowerCase().trim() == '1' || json['delivar_booking']?.toString().toLowerCase().trim() == 'true' || json['delivar_booking']?.toString().toLowerCase().trim() == '1.0' || json['delivar_booking'] == 1 || json['delivar_booking'] == true)
        || (json['deliver_booking']?.toString().toLowerCase().trim() == '1' || json['deliver_booking']?.toString().toLowerCase().trim() == 'true' || json['deliver_booking']?.toString().toLowerCase().trim() == '1.0' || json['deliver_booking'] == 1 || json['deliver_booking'] == true)
        || (json['delivar_booking_status']?.toString().toLowerCase().trim() == '1' || json['delivar_booking_status']?.toString().toLowerCase().trim() == 'true' || json['delivar_booking_status']?.toString().toLowerCase().trim() == '1.0' || json['delivar_booking_status'] == 1 || json['delivar_booking_status'] == true);
    publicTrackingId = json['public_tracking_id']?.toString() ?? json['public_track_id']?.toString();
    otherChargesLabel = json['other_charges_label']?.toString();
    otherChargesAmount = json['other_charges_amount']?.toString();
    taxStatus = json['tax_status'];
    discountPercentage = json['discount_percentage']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_id'] = itemId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (itemDetails != null) {
      data['item_details'] = itemDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    } else if (foodVariation != null) {
      data['variation'] = foodVariation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_on_item'] = discountOnItem;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    data['image_full_url'] = imageFullUrl;
    data['is_guest'] = isGuest;
    data['delivar_booking'] = delivarBooking;
    data['public_tracking_id'] = publicTrackingId;
    data['other_charges_label'] = otherChargesLabel;
    data['other_charges_amount'] = otherChargesAmount;
    data['tax_status'] = taxStatus;
    data['discount_percentage'] = discountPercentage;
    return data;
  }
}

class AddOn {
  String? name;
  double? price;
  int? quantity;

  AddOn({
    this.name,
    this.price,
    this.quantity,
  });

  AddOn.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'].toDouble();
    quantity = int.parse(json['quantity'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}
