import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../Model/employee_home_models.dart';

class EmployeeHomeController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final RxString selectedLocation = 'Current Location'.obs;
  final RxInt selectedCategoryIndex = 0.obs;

  final RxBool isLoading = false.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<DealModel> todaysDeals = <DealModel>[].obs;

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
  }

  void addToCart(String itemName) {
    cartCount.value++;
    Fluttertoast.showToast(
      msg: '$itemName added to cart!',
      backgroundColor: AppColors.primaryColor,
      textColor: const Color(0xFFFFFFFF),
    );
  }

  /// Fetch data from API or load initial model instances
  Future<void> fetchHomeData() async {
    isLoading.value = true;
    try {
      // Prepared for API integration:
      // final response = await ApiClient.getData(ApiConstant.home);
      // parse response.body into models...

      categories.assignAll([
        CategoryModel(
          id: '1',
          name: 'Drinks',
          iconEmoji: '🥤',
          bgColorValue: 0xFFEFF6FF,
        ),
        CategoryModel(
          id: '2',
          name: 'Pop',
          iconEmoji: '🫧',
          bgColorValue: 0xFFFAF5FF,
        ),
        CategoryModel(
          id: '3',
          name: 'Energy Drinks',
          iconEmoji: '⚡',
          bgColorValue: 0xFFFFFBEB,
        ),
        CategoryModel(
          id: '4',
          name: 'Water',
          iconEmoji: '💧',
          bgColorValue: 0xFFF0FDFA,
        ),
        CategoryModel(
          id: '5',
          name: 'Coffee',
          iconEmoji: '☕',
          bgColorValue: 0xFFFFF7ED,
        ),
        CategoryModel(
          id: '6',
          name: 'Snacks',
          iconEmoji: '🍿',
          bgColorValue: 0xFFFDF2F8,
        ),
      ]);

      featuredProducts.assignAll([
        ProductModel(
          id: 'p1',
          name: 'Gatorade Cool Blue',
          unit: '32 oz',
          price: 3.49,
          imageUrl: 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=400',
          isSale: false,
        ),
        ProductModel(
          id: 'p2',
          name: 'Red Bull Original',
          unit: '250ml',
          price: 4.29,
          imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=400',
          isSale: false,
        ),
        ProductModel(
          id: 'p3',
          name: 'Coca-Cola 6-Pack',
          unit: '6 × 355ml',
          price: 5.99,
          originalPrice: 7.99,
          imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
          isSale: true,
        ),
        ProductModel(
          id: 'p4',
          name: 'Monster Energy Green',
          unit: '473ml',
          price: 3.99,
          imageUrl: 'https://images.unsplash.com/photo-1624517452488-04869289c4ca?w=400',
          isSale: false,
        ),
        ProductModel(
          id: 'p5',
          name: 'Weekend Deal Bundle',
          unit: 'Combo Pack',
          price: 9.99,
          originalPrice: 12.99,
          imageUrl: 'https://images.unsplash.com/photo-1568644396922-5c3bfae12521?w=400',
          isSale: true,
        ),
      ]);

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
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
