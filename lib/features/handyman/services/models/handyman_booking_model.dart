class HandymanBookingItem {
  final String title;
  final String variantName;
  final int quantity;
  final double unitPrice;

  HandymanBookingItem({
    required this.title,
    required this.variantName,
    required this.quantity,
    required this.unitPrice,
  });
}

class HandymanBookingModel {
  final String id;
  final String serviceName;
  final DateTime bookingDate;
  final DateTime serviceDate;
  final double price;
  final String status; // 'Pending', 'Accepted', 'Ongoing', 'Completed', 'Cancelled'
  final List<String> tasks;
  final String timeSlot;
  final String address;
  final String paymentMethod;
  final String paymentStatus;
  final List<HandymanBookingItem> items;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double campaignDiscount;
  final double vat;
  final double fee;
  final String? startOtp;
  final String? endOtp;

  HandymanBookingModel({
    required this.id,
    required this.serviceName,
    required this.bookingDate,
    required this.serviceDate,
    required this.price,
    required this.status,
    required this.tasks,
    required this.timeSlot,
    this.address = 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
    this.paymentMethod = 'Cash after service',
    this.paymentStatus = 'Unpaid',
    this.items = const [],
    this.subTotal = 0.0,
    this.discount = 0.0,
    this.couponDiscount = 0.0,
    this.campaignDiscount = 0.0,
    this.vat = 0.0,
    this.fee = 0.0,
    this.startOtp,
    this.endOtp,
  });
}

