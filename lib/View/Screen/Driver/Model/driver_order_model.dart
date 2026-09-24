import 'package:flutter/material.dart';

enum DriverOrderStatus {
  readyForPickup,
  pickingUp,
  onTheWay,
  arrived,
  delivered,
}

class DriverOrderModel {
  final String id;
  final String? backendId;
  final String customerName;
  final String customerPhone;
  final String pickupAddress;
  final String deliveryAddress;
  final String distance;
  final double deliveryFee;
  final double tip;
  final double totalCashToCollect;
  final String deliveryInstructions;
  final List<String> items;
  DriverOrderStatus status;
  final String timeEst;
  final String orderTime;
  final double? customerLat;
  final double? customerLng;

  DriverOrderModel({
    required this.id,
    this.backendId,
    required this.customerName,
    required this.customerPhone,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.deliveryFee,
    required this.tip,
    required this.totalCashToCollect,
    required this.deliveryInstructions,
    required this.items,
    this.status = DriverOrderStatus.readyForPickup,
    this.timeEst = '20–30 min',
    required this.orderTime,
    this.customerLat,
    this.customerLng,
  });

  factory DriverOrderModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    DriverOrderStatus parsedStatus = DriverOrderStatus.readyForPickup;
    if (statusStr == 'delivered') {
      parsedStatus = DriverOrderStatus.delivered;
    } else if (statusStr == 'out_for_delivery') {
      parsedStatus = DriverOrderStatus.onTheWay;
    } else if (statusStr == 'ready_for_driver' || statusStr == 'picking_up') {
      parsedStatus = DriverOrderStatus.pickingUp;
    }

    final customer = json['customer'] is Map ? json['customer'] : {};
    final pricing = json['pricing'] is Map ? json['pricing'] : {};

    final List<String> parsedItems = [];
    if (json['items'] is List) {
      for (var item in json['items']) {
        if (item is Map) {
          final qty = item['quantity'] ?? 1;
          final name = item['name'] ?? 'Item';
          parsedItems.add('$qty× $name');
        }
      }
    }

    String formattedTime = 'Recent';
    if (json['createdAt'] != null) {
      try {
        final dt = DateTime.parse(json['createdAt'].toString());
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final period = dt.hour >= 12 ? 'p.m.' : 'a.m.';
        final min = dt.minute.toString().padLeft(2, '0');
        formattedTime = '$hour:$min $period';
      } catch (_) {
        formattedTime = json['createdAt'].toString();
      }
    }

    final double fee = (pricing['deliveryFee'] ?? json['deliveryFee'] ?? 3.99).toDouble();
    final double tipVal = (pricing['tip'] ?? json['tip'] ?? 0.0).toDouble();
    final double totalVal = (json['total'] ?? pricing['total'] ?? 0.0).toDouble();

    double? cLat;
    double? cLng;
    if (customer['lat'] != null) {
      cLat = double.tryParse(customer['lat'].toString());
    } else if (json['customerLocation'] is Map && json['customerLocation']['lat'] != null) {
      cLat = double.tryParse(json['customerLocation']['lat'].toString());
    }
    if (customer['lng'] != null) {
      cLng = double.tryParse(customer['lng'].toString());
    } else if (json['customerLocation'] is Map && json['customerLocation']['lng'] != null) {
      cLng = double.tryParse(json['customerLocation']['lng'].toString());
    }

    return DriverOrderModel(
      id: json['orderNumber'] ?? (json['_id'] != null ? '#${json['_id'].toString().substring(json['_id'].toString().length - 6).toUpperCase()}' : '#ORD-LIVE'),
      backendId: json['_id']?.toString() ?? json['id']?.toString(),
      customerName: customer['name'] ?? json['customerName'] ?? 'Customer',
      customerPhone: customer['phone'] ?? json['customerPhone'] ?? '(555) 000-0000',
      pickupAddress: 'QuickStop Gas Station, 1250 Highway Blvd',
      deliveryAddress: customer['deliveryAddress'] ?? json['deliveryAddress'] ?? 'Springfield Area',
      distance: json['distance'] ?? '2.5 km',
      deliveryFee: fee,
      tip: tipVal,
      totalCashToCollect: totalVal,
      deliveryInstructions: customer['deliveryInstructions'] ?? json['deliveryInstructions'] ?? 'Collect cash upon delivery',
      items: parsedItems.isNotEmpty ? parsedItems : ['Order Package'],
      status: parsedStatus,
      timeEst: '15–25 min',
      orderTime: formattedTime,
      customerLat: cLat,
      customerLng: cLng,
    );
  }

  double get driverEarning => deliveryFee + tip;

  String get statusTitle {
    switch (status) {
      case DriverOrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case DriverOrderStatus.pickingUp:
        return 'Picking Up at Store';
      case DriverOrderStatus.onTheWay:
        return 'On the Way to Customer';
      case DriverOrderStatus.arrived:
        return 'Arrived at Destination';
      case DriverOrderStatus.delivered:
        return 'Delivered & Paid';
    }
  }

  Color get statusColor {
    switch (status) {
      case DriverOrderStatus.readyForPickup:
        return const Color(0xFFF59E0B);
      case DriverOrderStatus.pickingUp:
      case DriverOrderStatus.onTheWay:
        return const Color(0xFF2563EB);
      case DriverOrderStatus.arrived:
        return const Color(0xFF7C3AED);
      case DriverOrderStatus.delivered:
        return const Color(0xFF10B981);
    }
  }
}
