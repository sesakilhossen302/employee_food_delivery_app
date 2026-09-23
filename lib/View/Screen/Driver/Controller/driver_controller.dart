import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/socket_service.dart';
import '../Model/driver_order_model.dart';

class DriverController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final RxBool isOnline = true.obs;
  final RxBool isLoading = false.obs;

  final RxList<DriverOrderModel> availableOrders = <DriverOrderModel>[].obs;
  final Rx<DriverOrderModel?> activeOrder = Rx<DriverOrderModel?>(null);
  final RxList<DriverOrderModel> completedDeliveries = <DriverOrderModel>[].obs;

  final RxDouble todayEarnings = 0.0.obs;
  final RxDouble cashCollectedInHand = 0.0.obs;
  final RxInt completedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDriverData();
    _initSocket();
  }

  void _initSocket() {
    try {
      SocketService.socket.on('order_status_updated', (data) {
        debugPrint('DriverController socket order_status_updated: $data');
        fetchDriverData();
      });
      SocketService.socket.on('new_order', (data) {
        debugPrint('DriverController socket new_order: $data');
        fetchDriverData();
      });
    } catch (e) {
      debugPrint('DriverController socket warning: $e');
    }
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

  Future<void> fetchDriverData() async {
    isLoading.value = true;
    try {
      // 1. Fetch live driver stats from backend
      final statsRes = await ApiClient.getData(ApiConstant.driverStats);
      if (statsRes.statusCode == 200 && statsRes.body != null && statsRes.body['data'] != null) {
        final data = statsRes.body['data'];
        completedCount.value = (data['completedDeliveries'] ?? 0) as int;
        todayEarnings.value = (data['totalEarnings'] ?? data['totalTips'] ?? 0.0).toDouble();
        cashCollectedInHand.value = (data['totalCashCollected'] ?? 0.0).toDouble();
      }

      // 2. Fetch live active/available orders from backend
      final ordersRes = await ApiClient.getData(ApiConstant.driverActiveOrders);
      if (ordersRes.statusCode == 200 && ordersRes.body != null && ordersRes.body['data'] is List) {
        final List list = ordersRes.body['data'];
        final List<DriverOrderModel> allParsed = list.map((o) => DriverOrderModel.fromJson(o)).toList();

        final active = allParsed.firstWhereOrNull((o) =>
            o.status == DriverOrderStatus.pickingUp ||
            o.status == DriverOrderStatus.onTheWay ||
            o.status == DriverOrderStatus.arrived);
        activeOrder.value = active;

        final available = allParsed.where((o) =>
            o.status == DriverOrderStatus.readyForPickup &&
            (active == null || o.id != active.id)).toList();
        availableOrders.assignAll(available);

        final delivered = allParsed.where((o) => o.status == DriverOrderStatus.delivered).toList();
        completedDeliveries.assignAll(delivered);
      }
    } catch (e) {
      debugPrint('DriverController fetchDriverData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptOrder(DriverOrderModel order) async {
    availableOrders.removeWhere((o) => o.id == order.id);
    order.status = DriverOrderStatus.pickingUp;
    activeOrder.value = order;
    currentNavIndex.value = 0; // Deliveries tab

    Fluttertoast.showToast(
      msg: 'Accepted Order ${order.id}. Head to QuickStop Gas Station for pickup!',
      backgroundColor: AppColors.primaryAmber,
      textColor: Colors.white,
    );

    // Persist to backend
    if (order.backendId != null && order.backendId!.isNotEmpty) {
      await ApiClient.patchData(
        '${ApiConstant.orders}/${order.backendId}/status',
        jsonEncode({'status': 'ready_for_driver'}),
      );
    }
  }

  Future<void> confirmStorePickup() async {
    if (activeOrder.value == null) return;
    activeOrder.value!.status = DriverOrderStatus.onTheWay;
    activeOrder.refresh();

    Fluttertoast.showToast(
      msg: 'Pickup confirmed! Driving to ${activeOrder.value!.deliveryAddress}',
      backgroundColor: const Color(0xFF2563EB),
      textColor: Colors.white,
    );

    final backendId = activeOrder.value!.backendId;
    if (backendId != null && backendId.isNotEmpty) {
      await ApiClient.patchData(
        '${ApiConstant.orders}/$backendId/status',
        jsonEncode({'status': 'out_for_delivery'}),
      );
    }
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

  Future<void> completeDeliveryAndCollectCash() async {
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

    // Persist delivery completion to backend
    if (order.backendId != null && order.backendId!.isNotEmpty) {
      await ApiClient.patchData(
        '${ApiConstant.orders}/${order.backendId}/status',
        jsonEncode({'status': 'delivered', 'paymentStatus': 'paid'}),
      );
    }
    fetchDriverData();
  }
}
