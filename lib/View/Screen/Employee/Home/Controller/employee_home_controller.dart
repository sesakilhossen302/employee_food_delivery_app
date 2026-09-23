import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../Model/employee_home_models.dart';

class EmployeeHomeController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final RxString selectedLocation = 'Current Location'.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString selectedCategory = 'Drinks'.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<DealModel> todaysDeals = <DealModel>[].obs;

  final RxMap<String, int> productQuantities = <String, int>{}.obs;
  final RxInt cartCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    if (index >= 0 && index < categories.length) {
      selectedCategory.value = categories[index].name;
    }
  }

  void selectCategoryByName(String categoryName) {
    selectedCategory.value = categoryName;
    final index = categories.indexWhere((c) => c.name.toLowerCase() == categoryName.toLowerCase());
    if (index != -1) {
      selectedCategoryIndex.value = index;
    }
  }

  int getQuantity(String productId) {
    return productQuantities[productId] ?? 0;
  }

  void increaseQuantity(ProductModel product) {
    final current = getQuantity(product.id);
    if (current >= product.maxPerOrder) {
      Fluttertoast.showToast(
        msg: 'Maximum ${product.maxPerOrder} items allowed for this product',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    productQuantities[product.id] = current + 1;
    _recalculateCart();
    Fluttertoast.showToast(
      msg: '${product.name} added to cart (${current + 1})',
      backgroundColor: AppColors.primaryAmber,
      textColor: Colors.white,
    );
  }

  void decreaseQuantity(ProductModel product) {
    final current = getQuantity(product.id);
    if (current <= 1) {
      productQuantities.remove(product.id);
      Fluttertoast.showToast(
        msg: '${product.name} removed from cart',
        backgroundColor: const Color(0xFF6B7280),
        textColor: Colors.white,
      );
    } else {
      productQuantities[product.id] = current - 1;
    }
    _recalculateCart();
  }

  void setQuantity(ProductModel product, int qty) {
    if (qty <= 0) {
      productQuantities.remove(product.id);
    } else {
      productQuantities[product.id] = qty.clamp(1, product.maxPerOrder);
    }
    _recalculateCart();
    Fluttertoast.showToast(
      msg: '${product.name} cart quantity updated to $qty',
      backgroundColor: AppColors.primaryAmber,
      textColor: Colors.white,
    );
  }

  void _recalculateCart() {
    int total = 0;
    productQuantities.forEach((_, qty) {
      total += qty;
    });
    cartCount.value = total;
  }

  List<ProductModel> get filteredProducts {
    return allProducts.where((p) {
      final matchesCategory = p.category.toLowerCase() == selectedCategory.value.toLowerCase();
      if (searchQuery.value.trim().isEmpty) {
        return matchesCategory;
      }
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Fetch data from API or load initial model instances
  
  List<MapEntry<ProductModel, int>> get cartItems {
    final List<MapEntry<ProductModel, int>> items = [];
    productQuantities.forEach((id, qty) {
      final product = allProducts.firstWhereOrNull((p) => p.id == id);
      if (product != null && qty > 0) {
        items.add(MapEntry(product, qty));
      }
    });
    return items;
  }

  double get subtotal {
    double sum = 0.0;
    productQuantities.forEach((id, qty) {
      final product = allProducts.firstWhereOrNull((p) => p.id == id);
      if (product != null) {
        sum += product.price * qty;
      }
    });
    return sum;
  }

  double get tax => subtotal * 0.08;
  double get deliveryFee => 3.99;
  double get totalWithDelivery => subtotal + tax + deliveryFee;
  double get totalWithPickup => subtotal + tax;

  void removeFromCart(String productId) {
    productQuantities.remove(productId);
    _recalculateCart();
    Fluttertoast.showToast(
      msg: 'Item removed from cart',
      backgroundColor: const Color(0xFF6B7280),
      textColor: Colors.white,
    );
  }

  void clearCart() {
    productQuantities.clear();
    _recalculateCart();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    try {
      // 1. Fetch live categories from backend API
      final catRes = await ApiClient.getData(ApiConstant.categories);
      if (catRes.statusCode == 200 && catRes.body != null && catRes.body['data'] is List) {
        final List list = catRes.body['data'];
        if (list.isNotEmpty) {
          categories.assignAll(list.map((c) => CategoryModel.fromJson(c)).toList());
        }
      }

      // Default categories fallback if empty or offline
      if (categories.isEmpty) {
        categories.assignAll([
          CategoryModel(id: '1', name: 'Drinks', iconEmoji: '🥤', bgColorValue: 0xFFEFF6FF),
          CategoryModel(id: '2', name: 'Pop', iconEmoji: '🫧', bgColorValue: 0xFFFAF5FF),
          CategoryModel(id: '3', name: 'Energy Drinks', iconEmoji: '⚡', bgColorValue: 0xFFFFFBEB),
          CategoryModel(id: '4', name: 'Water', iconEmoji: '💧', bgColorValue: 0xFFF0FDFA),
          CategoryModel(id: '5', name: 'Coffee', iconEmoji: '☕', bgColorValue: 0xFFFFF7ED),
          CategoryModel(id: '6', name: 'Snacks', iconEmoji: '🍿', bgColorValue: 0xFFFDF2F8),
        ]);
      }

      // 2. Fetch live products from backend MongoDB (includes Admin added products!)
      final prodRes = await ApiClient.getData(ApiConstant.products);
      if (prodRes.statusCode == 200 && prodRes.body != null && prodRes.body['data'] is List) {
        final List list = prodRes.body['data'];
        if (list.isNotEmpty) {
          allProducts.assignAll(list.map((p) => ProductModel.fromJson(p)).toList());
          featuredProducts.assignAll(allProducts.take(6).toList());
        }
      }

      // Default products fallback if backend empty
      if (allProducts.isEmpty) {
        allProducts.assignAll([
          ProductModel(
            id: 'p1',
            name: 'Gatorade Cool Blue',
            unit: '32 oz',
            price: 3.49,
            category: 'Drinks',
            description: 'Sports drink, 32 oz · 32 oz',
            imageUrl: 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=400',
            isSale: false,
            maxPerOrder: 12,
            inStock: true,
          ),
          ProductModel(
            id: 'p2',
            name: 'Red Bull Original',
            unit: '250ml',
            price: 4.29,
            category: 'Energy Drinks',
            description: 'Vitalizes body and mind, 250ml can',
            imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=400',
            isSale: false,
            maxPerOrder: 12,
            inStock: true,
          ),
          ProductModel(
            id: 'p3',
            name: 'Coca-Cola 6-Pack',
            unit: '6 × 355ml',
            price: 5.99,
            originalPrice: 7.99,
            category: 'Pop',
            description: 'Classic cola, 355ml cans (6 pack)',
            imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
            isSale: true,
            maxPerOrder: 10,
            inStock: true,
          ),
          ProductModel(
            id: 'p4',
            name: 'Monster Energy Green',
            unit: '473ml',
            price: 3.99,
            category: 'Energy Drinks',
            description: 'Tear into a can of Monster Energy, 473ml',
            imageUrl: 'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=400',
            isSale: false,
            maxPerOrder: 12,
            inStock: true,
          ),
          ProductModel(
            id: 'p5',
            name: 'Dasani Water 24-Pack',
            unit: '24 × 500ml',
            price: 7.99,
            originalPrice: 9.99,
            category: 'Water',
            description: 'Purified water bottles, mineral enhanced',
            imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=400',
            isSale: true,
            maxPerOrder: 8,
            inStock: true,
          ),
          ProductModel(
            id: 'p6',
            name: 'Starbucks Frappuccino',
            unit: '405ml',
            price: 4.49,
            category: 'Coffee',
            description: 'Chilled coffee drink vanilla flavor',
            imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=400',
            isSale: false,
            maxPerOrder: 12,
            inStock: true,
          ),
          ProductModel(
            id: 'p7',
            name: 'Doritos Nacho Cheese',
            unit: '9.25 oz',
            price: 3.99,
            category: 'Snacks',
            description: 'Crunchy tortilla chips with nacho cheese flavor',
            imageUrl: 'https://images.unsplash.com/photo-1568644396922-5c3bfae12521?w=400',
            isSale: false,
            maxPerOrder: 15,
            inStock: true,
          ),
        ]);
        featuredProducts.assignAll(allProducts.take(4).toList());
      }

      // Deals
      todaysDeals.assignAll([
        DealModel(
          id: 'd1',
          name: 'Coca-Cola 6-Pack',
          description: 'Classic cola, 355ml cans',
          price: 5.99,
          originalPrice: 7.99,
          discountTag: '25% OFF',
          imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
        ),
        DealModel(
          id: 'd2',
          name: 'Dasani Water 24-Pack',
          description: 'Purified water bottles',
          price: 7.99,
          originalPrice: 9.99,
          discountTag: '20% OFF',
          imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=400',
        ),
        DealModel(
          id: 'd3',
          name: 'Weekend Deal Bundle',
          description: 'Chips + Pop + Candy combo',
          price: 9.99,
          originalPrice: 12.99,
          discountTag: '23% OFF',
          imageUrl: 'https://images.unsplash.com/photo-1568644396922-5c3bfae12521?w=400',
        ),
      ]);
    } catch (e) {
      debugPrint('fetchHomeData error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
