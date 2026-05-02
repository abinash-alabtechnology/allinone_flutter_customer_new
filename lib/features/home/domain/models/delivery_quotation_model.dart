class PaginatedDeliveryQuotationModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<DeliveryQuotationModel>? data;

  PaginatedDeliveryQuotationModel({this.totalSize, this.limit, this.offset, this.data});

  PaginatedDeliveryQuotationModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'] != null ? int.parse(json['limit'].toString()) : null;
    offset = json['offset'] != null ? int.parse(json['offset'].toString()) : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(DeliveryQuotationModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryQuotationModel {
  String? id;
  int? userId;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<String>? imageFullUrl;

  DeliveryQuotationModel(
      {this.id,
      this.userId,
      this.image,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.imageFullUrl});

  DeliveryQuotationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['images_full_url'] != null) {
      imageFullUrl = List<String>.from(json['images_full_url']);
    } else if (json['image_full_url'] != null) {
      if (json['image_full_url'] is List) {
        imageFullUrl = List<String>.from(json['image_full_url']);
      } else if (json['image_full_url'] is String) {
        imageFullUrl = [json['image_full_url']];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}
