import 'package:flutter/material.dart';

enum OrderStatus {
  orderReceived,
  confirmed,
  preparing,
  readyForDriver,
  outForDelivery,
  delivered,
}

class OrderItemModel {
  final String name;
  final int qty;
  final double price;
  final String imageUrl;

  OrderItemModel({
    required this.name,
    required this.qty,
    required this.price,
    required this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] ?? '',
      qty: json['qty'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

class OrderModel {
  final String id;
  final String date;
  final OrderStatus status;
  final String statusText;
  final bool isDelivery;
  final String estimatedTime;
  final String estimatedRange;
  final String deliveryAddress;
  final String deliveryNote;
  final List<OrderItemModel> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double tip;
  final String paymentMethod;
  final double progressPercent;
  final bool hasActiveBorder;

  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.statusText,
    required this.isDelivery,
    required this.estimatedTime,
    this.estimatedRange = '25–35 min',
    required this.deliveryAddress,
    this.deliveryNote = 'Leave at door, ring bell',
    required this.items,
    required this.subtotal,
    required this.tax,
    this.deliveryFee = 3.99,
    this.tip = 0.0,
    required this.paymentMethod,
    required this.progressPercent,
    this.hasActiveBorder = false,
  });

  double get total => subtotal + tax + (isDelivery ? deliveryFee : 0.0) + tip;

  Color get statusColor {
    switch (status) {
      case OrderStatus.outForDelivery:
        return const Color(0xFFF59E0B);
      case OrderStatus.preparing:
      case OrderStatus.confirmed:
      case OrderStatus.readyForDriver:
        return const Color(0xFFF59E0B);
      case OrderStatus.orderReceived:
        return const Color(0xFF6B7280);
      case OrderStatus.delivered:
        return const Color(0xFF10B981);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case OrderStatus.outForDelivery:
      case OrderStatus.preparing:
      case OrderStatus.confirmed:
      case OrderStatus.readyForDriver:
        return const Color(0xFFFFFBEB);
      case OrderStatus.orderReceived:
        return const Color(0xFFF3F4F6);
      case OrderStatus.delivered:
        return const Color(0xFFECFDF5);
    }
  }
}
