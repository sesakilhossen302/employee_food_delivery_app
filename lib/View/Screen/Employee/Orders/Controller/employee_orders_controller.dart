import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../service/socket_service.dart';
import '../Model/employee_order_models.dart';

class EmployeeOrdersController extends GetxController {
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    _initSocket();
  }

  void _initSocket() {
    try {
      SocketService.socket.on('order_status_updated', (data) {
        debugPrint('Socket order_status_updated in Flutter: $data');
        loadOrders();
      });
      SocketService.socket.on('new_order', (data) {
        debugPrint('Socket new_order in Flutter: $data');
        loadOrders();
      });
    } catch (e) {
      debugPrint('Socket init warning: $e');
    }
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.getData(ApiConstant.orders);
      if (response.statusCode == 200 && response.body != null && response.body['data'] is List) {
        final List list = response.body['data'];
        orders.assignAll(list.map((o) => OrderModel.fromJson(o)).toList());
      }
    } catch (e) {
      debugPrint('Orders load error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
