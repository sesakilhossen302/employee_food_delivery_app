import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/route_service.dart';
import '../../../../service/socket_service.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
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

  /// Live Driver Real Device Coordinates & Movement
  final RxDouble driverLat = 23.8103.obs;
  final RxDouble driverLng = 90.4125.obs;
  final RxDouble driverHeading = 0.0.obs;
  final RxList<LatLng> roadPolylinePoints = <LatLng>[].obs;

  RxDouble get currentLatitude => driverLat;
  RxDouble get currentLongitude => driverLng;

  Timer? _locationTimer;
  Timer? _ordersPollingTimer;
  StreamSubscription<Position>? _positionStreamSub;

  @override
  void onInit() {
    super.onInit();
    // 1. Acquire real device GPS immediately
    updateDriverGpsLocation();
    // 2. Fetch driver stats & orders
    fetchDriverData();
    // 3. Setup Sockets
    _initSocket();
    // 4. Polling timer to refresh available orders periodically every 5 seconds in background
    _ordersPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchDriverData(silent: true);
    });
  }

  /// Request Location Permission & Acquire Real GPS Position
  Future<void> updateDriverGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled on device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        driverLat.value = position.latitude;
        driverLng.value = position.longitude;
        driverHeading.value = position.heading;
        debugPrint('📍 Driver Real GPS acquired: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      debugPrint('Real GPS fetch error: $e');
    }
  }

  void _initSocket() {
    try {
      SocketService.socket.on('order_status_updated', (data) {
        debugPrint('DriverController socket order_status_updated: $data');
        fetchDriverData(silent: true);
      });
      SocketService.socket.on('new_order', (data) {
        debugPrint('DriverController socket new_order: $data');
        fetchDriverData(silent: true);
      });
      SocketService.socket.on('new_order_available', (data) {
        debugPrint('DriverController socket new_order_available: $data');
        fetchDriverData(silent: true);
      });
      SocketService.socket.on('order_created', (data) {
        debugPrint('DriverController socket order_created: $data');
        fetchDriverData(silent: true);
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

  Future<void> fetchDriverData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
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
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> acceptOrder(DriverOrderModel order) async {
    availableOrders.removeWhere((o) => o.id == order.id);
    order.status = DriverOrderStatus.pickingUp;
    activeOrder.value = order;
    currentNavIndex.value = 0; // Deliveries tab

    // Fetch fresh real GPS location from device
    await updateDriverGpsLocation();

    final savedName = await SharePrefsHelper.getString('saved_user_name');
    final savedPhone = await SharePrefsHelper.getString('saved_user_phone');
    final currentDriverName = savedName.isNotEmpty ? savedName : 'Delivery Driver';
    final currentDriverPhone = savedPhone.isNotEmpty ? savedPhone : '+880 1712-345678';

    Fluttertoast.showToast(
      msg: 'Accepted Order ${order.id}. Head to QuickStop Gas Station for pickup!',
      backgroundColor: AppColors.primaryAmber,
      textColor: Colors.white,
    );

    // Persist to backend with real assigned driver details
    if (order.backendId != null && order.backendId!.isNotEmpty) {
      await ApiClient.patchData(
        '${ApiConstant.orders}/${order.backendId}/status',
        jsonEncode({
          'status': 'ready_for_driver',
          'assignedDriver': {
            'name': currentDriverName,
            'phone': currentDriverPhone,
            'vehicle': 'Honda Civic (Plate: QST-991)',
            'rating': 4.9,
          },
        }),
      );
    }
    _startLocationBroadcasting();
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
      final savedName = await SharePrefsHelper.getString('saved_user_name');
      final savedPhone = await SharePrefsHelper.getString('saved_user_phone');
      final currentDriverName = savedName.isNotEmpty ? savedName : 'Delivery Driver';
      final currentDriverPhone = savedPhone.isNotEmpty ? savedPhone : '+880 1712-345678';

      await ApiClient.patchData(
        '${ApiConstant.orders}/$backendId/status',
        jsonEncode({
          'status': 'out_for_delivery',
          'assignedDriver': {
            'name': currentDriverName,
            'phone': currentDriverPhone,
            'vehicle': 'Honda Civic (Plate: QST-991)',
            'rating': 4.9,
          },
        }),
      );
    }
    _startLocationBroadcasting();
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
    _stopLocationBroadcasting();
    fetchDriverData();
  }

  void _startLocationBroadcasting() async {
    _stopLocationBroadcasting();

    // 1. Get initial GPS location
    await updateDriverGpsLocation();

    final origin = LatLng(driverLat.value, driverLng.value);
    final custLat = activeOrder.value?.customerLat ?? 23.8197;
    final custLng = activeOrder.value?.customerLng ?? 90.4277;
    final destination = LatLng(custLat, custLng);

    // Compute genuine road route from driver's REAL GPS position to customer
    final route = await RouteService.getRoadRoute(origin: origin, destination: destination);
    roadPolylinePoints.assignAll(route);

    // 2. Start continuous real-time device GPS stream
    try {
      _positionStreamSub?.cancel();
      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3, // Broadcast every 3 meters of movement
        ),
      ).listen((Position pos) {
        driverLat.value = pos.latitude;
        driverLng.value = pos.longitude;
        driverHeading.value = pos.heading;
        _broadcastRealTimeGps(pos.latitude, pos.longitude, pos.heading, pos.speed);
      });
    } catch (e) {
      debugPrint('Position stream note: $e');
    }

    // 3. Periodic timer to ensure backend and customer always have fresh location
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (activeOrder.value == null) {
        timer.cancel();
        return;
      }
      _broadcastRealTimeGps(driverLat.value, driverLng.value, driverHeading.value, 20.0);
    });
  }

  void _broadcastRealTimeGps(double lat, double lng, double heading, double speed) async {
    try {
      final savedName = await SharePrefsHelper.getString('saved_user_name');
      final savedPhone = await SharePrefsHelper.getString('saved_user_phone');
      final currentDriverName = savedName.isNotEmpty ? savedName : 'Delivery Driver';
      final currentDriverPhone = savedPhone.isNotEmpty ? savedPhone : '+880 1712-345678';

      final payload = {
        'driverId': 'driver_active',
        'driverName': currentDriverName,
        'driverPhone': currentDriverPhone,
        'orderId': activeOrder.value?.backendId ?? activeOrder.value?.id,
        'lat': lat,
        'lng': lng,
        'heading': heading,
        'speed': speed,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      SocketService.socket.emit('driver_location', payload);
      debugPrint('[Driver Real GPS Broadcast]: $payload');
    } catch (e) {
      debugPrint('Driver location emit error: $e');
    }
  }

  void _stopLocationBroadcasting() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  void onClose() {
    _ordersPollingTimer?.cancel();
    _ordersPollingTimer = null;
    _stopLocationBroadcasting();
    super.onClose();
  }
}
