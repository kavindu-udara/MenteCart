class BookingItemModel {
  final String serviceId;
  final DateTime selectedDate;
  final String timeSlotStart;
  final String timeSlotEnd;
  final double priceAtBooking;

  const BookingItemModel({
    required this.serviceId,
    required this.selectedDate,
    required this.timeSlotStart,
    required this.timeSlotEnd,
    required this.priceAtBooking,
  });

  factory BookingItemModel.fromJson(Map<String, dynamic> json) {
    return BookingItemModel(
      serviceId: json['serviceId']?.toString() ?? '',
      selectedDate: DateTime.tryParse(json['selectedDate']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      timeSlotStart: json['timeSlotStart']?.toString() ?? '',
      timeSlotEnd: json['timeSlotEnd']?.toString() ?? '',
      priceAtBooking: (json['priceAtBooking'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BookingModel {
  final String id;
  final String userId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final List<BookingItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? const [];

    return BookingModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      items: itemsJson
          .whereType<Map>()
          .map((item) => BookingItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
