import 'package:flutter/foundation.dart';

@immutable
class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      items: (json['items'] as List?)
          ?.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

@immutable
class CartItemModel {
  final String id;
  final String serviceId;
  final DateTime selectedDate;
  final String timeSlotStart;
  final String timeSlotEnd;
  final int quantity;
  final double priceAtAdd;
  final DateTime addedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartItemModel({
    required this.id,
    required this.serviceId,
    required this.selectedDate,
    required this.timeSlotStart,
    required this.timeSlotEnd,
    required this.quantity,
    required this.priceAtAdd,
    required this.addedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'] as String)
          : DateTime.now(),
      timeSlotStart: json['timeSlotStart'] as String? ?? '',
      timeSlotEnd: json['timeSlotEnd'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      priceAtAdd: (json['priceAtAdd'] as num?)?.toDouble() ?? 0.0,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  CartItemModel copyWith({
    String? id,
    String? serviceId,
    DateTime? selectedDate,
    String? timeSlotStart,
    String? timeSlotEnd,
    int? quantity,
    double? priceAtAdd,
    DateTime? addedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      selectedDate: selectedDate ?? this.selectedDate,
      timeSlotStart: timeSlotStart ?? this.timeSlotStart,
      timeSlotEnd: timeSlotEnd ?? this.timeSlotEnd,
      quantity: quantity ?? this.quantity,
      priceAtAdd: priceAtAdd ?? this.priceAtAdd,
      addedAt: addedAt ?? this.addedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
