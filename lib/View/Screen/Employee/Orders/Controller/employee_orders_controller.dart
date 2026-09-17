import 'package:get/get.dart';
import '../Model/employee_order_models.dart';

class EmployeeOrdersController extends GetxController {
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  void loadOrders() {
    orders.assignAll([
      /// Order 1: #ORD-1001 (Out for Delivery - matching Image 1, 2, 3)
      OrderModel(
        id: '#ORD-1001',
        date: 'Sep 10 · 08:32 p.m.',
        status: OrderStatus.outForDelivery,
        statusText: 'Out for Delivery',
        isDelivery: true,
        estimatedTime: 'Est. 09:05 p.m.',
        estimatedRange: '25–35 min',
        deliveryAddress: '123 Maple St, Springfield, S4P 3Y2',
        deliveryNote: 'Leave at door, ring bell',
        progressPercent: 0.78,
        hasActiveBorder: true,
        subtotal: 11.57,
        tax: 0.92,
        deliveryFee: 3.99,
        tip: 2.00,
        paymentMethod: 'Cash On Delivery',
        items: [
          OrderItemModel(
            name: 'Red Bull Original',
            qty: 2,
            price: 8.58,
            imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=400',
          ),
          OrderItemModel(
            name: "Lay's Classic",
            qty: 1,
            price: 2.99,
            imageUrl: 'https://images.unsplash.com/photo-1568644396922-5c3bfae12521?w=400',
          ),
        ],
      ),

      /// Order 2: #ORD-1002 (Preparing - matching Image 1)
      OrderModel(
        id: '#ORD-1002',
        date: 'Sep 10 · 08:55 p.m.',
        status: OrderStatus.preparing,
        statusText: 'Preparing',
        isDelivery: true,
        estimatedTime: 'Est. 09:30 p.m.',
        estimatedRange: '25–35 min',
        deliveryAddress: '123 Maple St, Springfield, S4P 3Y2',
        deliveryNote: 'Leave at door, ring bell',
        progressPercent: 0.45,
        hasActiveBorder: false,
        subtotal: 16.90,
        tax: 1.35,
        deliveryFee: 3.99,
        tip: 0.0,
        paymentMethod: 'Cash On Delivery',
        items: [
          OrderItemModel(
            name: 'Coca-Cola 6-Pack',
            qty: 1,
            price: 5.99,
            imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
          ),
          OrderItemModel(
            name: 'Party Ice Bag',
            qty: 2,
            price: 10.91,
            imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=400',
          ),
        ],
      ),

      /// Order 3: #ORD-1003 (Order Received / Pickup - matching Image 1, 4, 5)
      OrderModel(
        id: '#ORD-1003',
        date: 'Sep 10 · 09:10 p.m.',
        status: OrderStatus.orderReceived,
        statusText: 'Order Received',
        isDelivery: false,
        estimatedTime: 'Est. 09:25 p.m.',
        estimatedRange: '25–35 min',
        deliveryAddress: 'QuickStop Gas Station, 1250 Highway Blvd',
        deliveryNote: 'Store Pickup',
        progressPercent: 0.16,
        hasActiveBorder: false,
        subtotal: 9.99,
        tax: 0.80,
        deliveryFee: 0.0,
        tip: 0.0,
        paymentMethod: 'Cash At Pickup',
        items: [
          OrderItemModel(
            name: 'Weekend Deal Bundle',
            qty: 1,
            price: 9.99,
            imageUrl: 'https://images.unsplash.com/photo-1568644396922-5c3bfae12521?w=400',
          ),
        ],
      ),
    ]);
  }
}
