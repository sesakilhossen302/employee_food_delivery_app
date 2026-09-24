import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../Detail/employee_product_detail_screen.dart';
import '../../Home/Controller/employee_home_controller.dart';
import '../../Home/Model/employee_home_models.dart';
import '../Controller/employee_nav_controller.dart';

class EmployeeBrowseScreen extends StatelessWidget {
  const EmployeeBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();
    final navController = Get.find<EmployeeNavController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Top Bar: Back button, Search input, Filter button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  /// Back Button -> Navigates back to Home Tab
                  GestureDetector(
                    onTap: () => navController.changeNavIndex(0),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 24,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),

                  /// Search Field
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                homeController.searchQuery.value = val;
                              },
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),

                  /// Filter Button
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 2. Category Chips Horizontal Row with "All" Option & Active Highlights
            SizedBox(
              height: 44.h,
              child: Obx(() {
                final currentCat = homeController.selectedCategory.value.trim().toLowerCase();
                final isAllSelected = currentCat == 'all' || currentCat.isEmpty;

                return ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    // "All" option first
                    _buildCategoryChip(
                      label: 'All',
                      emoji: '✨',
                      isSelected: isAllSelected,
                      onTap: () {
                        homeController.selectCategoryByName('All');
                      },
                    ),
                    SizedBox(width: 8.w),

                    // Dynamic backend categories
                    ...homeController.categories.map((category) {
                      final isSelected = currentCat == category.name.trim().toLowerCase();
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _buildCategoryChip(
                          label: category.name,
                          emoji: category.iconEmoji,
                          isSelected: isSelected,
                          onTap: () {
                            homeController.selectCategoryByName(category.name);
                          },
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
            SizedBox(height: 12.h),

            /// 3. Product Count Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() {
                final list = homeController.filteredProducts;
                final catName = homeController.selectedCategory.value;
                final displayCat = catName.toLowerCase() == 'all' ? 'All Categories' : catName;
                return Text(
                  '${list.length} product${list.length == 1 ? '' : 's'} in $displayCat',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                );
              }),
            ),
            SizedBox(height: 12.h),

            /// 4. Products Grid
            Expanded(
              child: Obx(() {
                final list = homeController.filteredProducts;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 56.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No products found in this category',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final product = list[index];
                    return _buildBrowseProductCard(product, homeController);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseProductCard(ProductModel product, EmployeeHomeController controller) {
    return GestureDetector(
      onTap: () {
        Get.to(() => EmployeeProductDetailScreen(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: SizedBox(
                width: double.infinity,
                height: 118.h,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: Center(
                        child: Icon(
                          Icons.fastfood_outlined,
                          size: 40.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// Card Details
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.unit,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// Quantity Stepper or "Add to Cart" Button
                  Obx(() {
                    final qty = controller.getQuantity(product.id);

                    if (qty > 0) {
                      /// Stepper widget matching Image 1 & Image 3: [-]  qty  [+]
                      return Container(
                        height: 36.h,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Minus button
                            GestureDetector(
                              onTap: () => controller.decreaseQuantity(product),
                              child: Container(
                                width: 28.w,
                                height: 28.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.remove, size: 14, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ),

                            /// Current count
                            Text(
                              '$qty',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),

                            /// Plus button
                            GestureDetector(
                              onTap: () => controller.increaseQuantity(product),
                              child: Container(
                                width: 28.w,
                                height: 28.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAmber,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    /// Initial "Add to Cart" Button
                    return SizedBox(
                      width: double.infinity,
                      height: 36.h,
                      child: ElevatedButton(
                        onPressed: () => controller.increaseQuantity(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Add to Cart',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAmber : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryAmber : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAmber.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
