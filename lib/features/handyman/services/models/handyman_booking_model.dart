class HandymanBookingModel {
  final String id;
  final String serviceName;
  final DateTime bookingDate;
  final DateTime serviceDate;
  final double price;
  final String status; // 'Pending', 'Accepted', 'Ongoing', 'Completed', 'Cancelled'
  final List<String> tasks;
  final String timeSlot;

  HandymanBookingModel({
    required this.id,
    required this.serviceName,
    required this.bookingDate,
    required this.serviceDate,
    required this.price,
    required this.status,
    required this.tasks,
    required this.timeSlot,
  });
}
