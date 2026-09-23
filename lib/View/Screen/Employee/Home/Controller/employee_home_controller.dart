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
      // 1. Fetch live categories from backend API (MongoDB)
      final catRes = await ApiClient.getData(ApiConstant.categories);
      if (catRes.statusCode == 200 && catRes.body != null && catRes.body['data'] is List) {
        final List list = catRes.body['data'];
        categories.assignAll(list.map((c) => CategoryModel.fromJson(c)).toList());
        if (categories.isNotEmpty && selectedCategory.value.isEmpty) {
          selectedCategory.value = categories[0].name;
          selectedCategoryIndex.value = 0;
        }
      }

      // 2. Fetch live products from backend API (MongoDB)
      final prodRes = await ApiClient.getData(ApiConstant.products);
      if (prodRes.statusCode == 200 && prodRes.body != null && prodRes.body['data'] is List) {
        final List list = prodRes.body['data'];
        allProducts.assignAll(list.map((p) => ProductModel.fromJson(p)).toList());
        featuredProducts.assignAll(allProducts.where((p) => p.inStock).take(6).toList());

        // Derive Today's Deals dynamically from products fetched from database
        final saleProducts = allProducts.where((p) => p.isSale || (p.originalPrice != null && p.originalPrice! > p.price)).toList();
        if (saleProducts.isNotEmpty) {
          todaysDeals.assignAll(saleProducts.map((p) {
            final discount = p.originalPrice != null && p.originalPrice! > p.price
                ? '${(((p.originalPrice! - p.price) / p.originalPrice!) * 100).round()}% OFF'
                : 'SPECIAL DEAL';
            return DealModel(
              id: p.id,
              name: p.name,
              description: p.description,
              price: p.price,
              originalPrice: p.originalPrice ?? p.price,
              discountTag: discount,
              imageUrl: p.imageUrl,
            );
          }).toList());
        } else if (allProducts.isNotEmpty) {
          todaysDeals.assignAll(allProducts.take(3).map((p) => DealModel(
            id: p.id,
            name: p.name,
            description: p.description,
            price: p.price,
            originalPrice: p.originalPrice ?? p.price,
            discountTag: 'HOT ITEM',
            imageUrl: p.imageUrl,
          )).toList());
        }
      }
    } catch (e) {
      debugPrint('fetchHomeData error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
