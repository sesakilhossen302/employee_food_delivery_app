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

  static String fallbackImageFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('monster') || lower.contains('energy') || lower.contains('red bull')) {
      return 'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=400';
    }
    if (lower.contains('coca') || lower.contains('coke') || lower.contains('pepsi') || lower.contains('drink') || lower.contains('pop') || lower.contains('beverage')) {
      return 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=400';
    }
    if (lower.contains('doritos') || lower.contains('chip') || lower.contains('snack') || lower.contains('nacho') || lower.contains('lays')) {
      return 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400';
    }
    if (lower.contains('candy') || lower.contains('chocolate') || lower.contains('snickers') || lower.contains('bar')) {
      return 'https://images.unsplash.com/photo-1582293041079-7814c2f12063?w=400';
    }
    if (lower.contains('ice cream')) {
      return 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=400';
    }
    if (lower.contains('firewood') || lower.contains('wood')) {
      return 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400';
    }
    if (lower.contains('fluid') || lower.contains('washer') || lower.contains('auto')) {
      return 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=400';
    }
    if (lower.contains('ice')) {
      return 'https://images.unsplash.com/photo-1516054575922-f0b8eeadec1a?w=400';
    }
    return 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400';
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawImg = json['imageUrl']?.toString() ?? '';
    final itemName = json['name']?.toString() ?? '';
    final validImg = (rawImg.isNotEmpty && rawImg.startsWith('http'))
        ? rawImg
        : fallbackImageFor(itemName);

    return OrderItemModel(
      name: itemName,
      qty: (json['quantity'] as num?)?.toInt() ?? (json['qty'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: validImg,
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'received').toString().toLowerCase();
    OrderStatus mappedStatus;
    String mappedText;
    double progress;

    switch (rawStatus) {
      case 'confirmed':
        mappedStatus = OrderStatus.confirmed;
        mappedText = 'Confirmed';
        progress = 0.32;
        break;
      case 'preparing':
        mappedStatus = OrderStatus.preparing;
        mappedText = 'Preparing';
        progress = 0.50;
        break;
      case 'ready_for_driver':
        mappedStatus = OrderStatus.readyForDriver;
        mappedText = 'Ready for Driver';
        progress = 0.65;
        break;
      case 'out_for_delivery':
      case 'outfordelivery':
        mappedStatus = OrderStatus.outForDelivery;
        mappedText = 'Out for Delivery';
        progress = 0.82;
        break;
      case 'delivered':
        mappedStatus = OrderStatus.delivered;
        mappedText = 'Delivered';
        progress = 1.0;
        break;
      case 'received':
      default:
        mappedStatus = OrderStatus.orderReceived;
        mappedText = 'Order Received';
        progress = 0.16;
        break;
    }

    final isDeliv = (json['fulfillmentType'] ?? 'delivery').toString().toLowerCase() == 'delivery';
    final customer = json['customer'] as Map<String, dynamic>?;

    final rawItems = json['items'] as List?;
    final parsedItems = rawItems != null
        ? rawItems.map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>)).toList()
        : <OrderItemModel>[];

    return OrderModel(
      id: json['orderNumber'] ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      date: json['createdAt'] != null
          ? json['createdAt'].toString().substring(0, 10)
          : 'Today',
      status: mappedStatus,
      statusText: mappedText,
      isDelivery: isDeliv,
      estimatedTime: isDeliv ? 'Est. 25–35 min' : 'Est. 10–15 min',
      estimatedRange: '25–35 min',
      deliveryAddress: customer?['address'] ?? (isDeliv ? 'Delivery Address' : 'Store Pickup'),
      deliveryNote: customer?['instructions'] ?? 'Leave at door, ring bell',
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['taxes'] as num?)?.toDouble() ?? (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? (isDeliv ? 3.99 : 0.0),
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] == 'cash_at_store'
          ? 'Cash At Pickup'
          : 'Cash On Delivery',
      progressPercent: progress,
      hasActiveBorder: mappedStatus != OrderStatus.delivered,
    );
  }

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
