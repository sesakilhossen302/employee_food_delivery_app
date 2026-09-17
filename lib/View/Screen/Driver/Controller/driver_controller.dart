import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Model/driver_order_model.dart';

class DriverController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final RxBool isOnline = true.obs;

  final RxList<DriverOrderModel> availableOrders = <DriverOrderModel>[].obs;
  final Rx<DriverOrderModel?> activeOrder = Rx<DriverOrderModel?>(null);
  final RxList<DriverOrderModel> completedDeliveries = <DriverOrderModel>[].obs;

  final RxDouble todayEarnings = 48.50.obs;
  final RxDouble cashCollectedInHand = 142.30.obs;
  final RxInt completedCount = 6.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialDriverData();
  }

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
    Fluttertoast.showToast(
      msg: isOnline.value
          ? 'You are now Online. Ready for delivery requests!'
          : 'You are now Offline. No new delivery requests.',
      backgroundColor: isOnline.value ? const Color(0xFF10B981) : const Color(0xFF6B7280),
      textColor: Colors.white,
    );
  }

  void acceptOrder(DriverOrderModel order) {
    availableOrders.removeWhere((o) => o.id == order.id);
    order.status = DriverOrderStatus.pickingUp;
    activeOrder.value = order;
    currentNavIndex.value = 0; // Go to Deliveries tab where active delivery is shown

    Fluttertoast.showToast(
      msg: 'Accepted Order ${order.id}. Head to QuickStop Gas Station for pickup!',
      backgroundColor: AppColors.primaryAmber,
      textColor: Colors.white,
    );
  }

  void confirmStorePickup() {
    if (activeOrder.value == null) return;
    activeOrder.value!.status = DriverOrderStatus.onTheWay;
    activeOrder.refresh();

    Fluttertoast.showToast(
      msg: 'Pickup confirmed! Driving to ${activeOrder.value!.deliveryAddress}',
      backgroundColor: const Color(0xFF2563EB),
      textColor: Colors.white,
    );
  }

  void markArrived() {
    if (activeOrder.value == null) return;
    activeOrder.value!.status = DriverOrderStatus.arrived;
    activeOrder.refresh();

    Fluttertoast.showToast(
      msg: 'Arrived at customer location. Collect cash payment.',
      backgroundColor: const Color(0xFF7C3AED),
      textColor: Colors.white,
    );
  }

  void completeDeliveryAndCollectCash() {
    if (activeOrder.value == null) return;
    final order = activeOrder.value!;
    order.status = DriverOrderStatus.delivered;

    todayEarnings.value += order.driverEarning;
    cashCollectedInHand.value += order.totalCashToCollect;
    completedCount.value += 1;
    completedDeliveries.insert(0, order);

    activeOrder.value = null;

    Fluttertoast.showToast(
      msg: 'Delivery completed! \$${order.totalCashToCollect.toStringAsFixed(2)} cash collected.',
      backgroundColor: const Color(0xFF10B981),
      textColor: Colors.white,
    );
  }

  void _loadInitialDriverData() {
    availableOrders.assignAll([
      DriverOrderModel(
        id: '#ORD-1004',
        customerName: 'Sarah Jenkins',
        customerPhone: '(555) 234-5678',
        pickupAddress: 'QuickStop Gas Station, 1250 Highway Blvd',
        deliveryAddress: '456 Pine Ave, Springfield, S4P 1T2',
        distance: '2.4 km',
        deliveryFee: 3.99,
        tip: 2.50,
        totalCashToCollect: 24.85,
        deliveryInstructions: 'Leave at front door, call when you arrive',
        items: ['1× Coca-Cola 6-Pack', '1× Doritos Nacho Cheese', '1× Dasani Water'],
        orderTime: '09:15 p.m.',
      ),
      DriverOrderModel(
        id: '#ORD-1005',
        customerName: 'Marcus Miller',
        customerPhone: '(555) 876-5432',
        pickupAddress: 'QuickStop Gas Station, 1250 Highway Blvd',
        deliveryAddress: '789 Oak St, Apt 4B, Springfield, S4P 4K8',
        distance: '4.8 km',
        deliveryFee: 4.99,
        tip: 3.00,
        totalCashToCollect: 32.40,
        deliveryInstructions: 'Meet me in the lobby, buzz 402',
        items: ['2× Red Bull Original', '2× Party Ice Bag', '1× Weekend Deal Bundle'],
        orderTime: '09:22 p.m.',
      ),
    ]);

    // Active order already in progress matching the PDF specification (#ORD-1001)
    activeOrder.value = DriverOrderModel(
      id: '#ORD-1001',
      customerName: 'Customer',
      customerPhone: '(555) 123-4567',
      pickupAddress: 'QuickStop Gas Station, 1250 Highway Blvd',
      deliveryAddress: '123 Maple St, Springfield, S4P 3Y2',
      distance: '3.2 km',
      deliveryFee: 3.99,
      tip: 2.00,
      totalCashToCollect: 18.48,
      deliveryInstructions: 'Leave at front door, call when you arrive',
      items: ['2× Red Bull Original', '1× Lay\'s Classic'],
      status: DriverOrderStatus.onTheWay,
      orderTime: '08:32 p.m.',
    );
  }
}
