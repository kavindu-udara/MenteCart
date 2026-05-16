import 'package:flutter/foundation.dart';

@immutable
class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final int duration;
  final CategoryModel categoryId;
  final String imageUrl;
  final int capacityPerSlot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SlotModel> slots;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.categoryId,
    required this.imageUrl,
    required this.capacityPerSlot,
    required this.createdAt,
    required this.updatedAt,
    required this.slots,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? 0,
      categoryId: CategoryModel.fromJson(
        json['categoryId'] as Map<String, dynamic>? ?? {},
      ),
      imageUrl: json['imageUrl'] as String? ?? '',
      capacityPerSlot: json['capacityPerSlot'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
        slots: (json['slots'] as List?)
            ?.map((s) => SlotModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
            [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'categoryId': categoryId.toJson(),
      'imageUrl': imageUrl,
      'capacityPerSlot': capacityPerSlot,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

@immutable
class SlotModel {
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int remainingCapacity;

  const SlotModel({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.remainingCapacity,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      remainingCapacity: json['remainingCapacity'] as int? ?? 0,
    );
  }
}

@immutable
class CategoryModel {
  final String id;
  final String name;
  final String description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
    };
  }
}

@immutable
class ServicesResponse {
  final List<ServiceModel> services;
  final int total;
  final bool hasMore;
  final String message;

  const ServicesResponse({
    required this.services,
    required this.total,
    required this.hasMore,
    required this.message,
  });

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    final servicesList = (json['services'] as List?)?.map(
          (service) => ServiceModel.fromJson(service as Map<String, dynamic>),
        ).toList() ??
        [];

    return ServicesResponse(
      services: servicesList,
      total: json['total'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

@immutable
class ServiceDetailsResponse {
  final ServiceModel service;
  final String message;

  const ServiceDetailsResponse({
    required this.service,
    required this.message,
  });

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsResponse(
      service: ServiceModel.fromJson(
        json['service'] as Map<String, dynamic>? ?? {},
      ),
      message: json['message'] as String? ?? '',
    );
  }
}
