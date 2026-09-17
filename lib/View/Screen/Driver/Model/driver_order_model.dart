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

  DriverOrderModel({
    required this.id,
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
  });

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
