import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Checkout/employee_checkout_screen.dart';
import '../Home/Controller/employee_home_controller.dart';
import '../Nav/Controller/employee_nav_controller.dart';

class EmployeeCartScreen extends StatelessWidget {
  const EmployeeCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Top Header: "Your Cart" & "X items"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Cart',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${controller.cartCount.value} ${controller.cartCount.value == 1 ? "item" : "items"}',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 2. Cart Content or Empty State
            Expanded(
              child: Obx(() {
                final items = controller.cartItems;

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Add items from Home or Browse to get started',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: () {
                            if (Get.isRegistered<EmployeeNavController>()) {
                              Get.find<EmployeeNavController>().changeNavIndex(0);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAmber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          ),
                          child: Text(
                            'Start Shopping',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    children: [
                      /// List of Cart Items
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final product = items[index].key;
                          final qty = items[index].value;

                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                /// Thumbnail Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: SizedBox(
                                    width: 62.w,
                                    height: 62.w,
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: const Color(0xFFF3F4F6),
                                          child: const Icon(
                                            Icons.fastfood_outlined,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                /// Product Title & Price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryAmber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Stepper Box: [-] qty [+]
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => controller.decreaseQuantity(product),
                                        icon: const Icon(Icons.remove, size: 14, color: Color(0xFF4B5563)),
                                        splashRadius: 16,
                                        constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
                                        padding: EdgeInsets.zero,
                                      ),
                                      SizedBox(
                                        width: 22.w,
                                        child: Text(
                                          '$qty',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => controller.increaseQuantity(product),
                                        icon: const Icon(Icons.add, size: 14, color: Color(0xFF4B5563)),
                                        splashRadius: 16,
                                        constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),

                                /// Red Delete (x) Button
                                GestureDetector(
                                  onTap: () => controller.removeFromCart(product.id),
                                  child: Container(
                                    width: 28.w,
                                    height: 28.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),

                      /// Order Summary Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Summary',
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            _buildSummaryRow('Subtotal', '\$${controller.subtotal.toStringAsFixed(2)}'),
                            SizedBox(height: 10.h),
                            _buildSummaryRow('Tax (8%)', '\$${controller.tax.toStringAsFixed(2)}'),
                            SizedBox(height: 10.h),
                            _buildSummaryRow('Delivery fee', '\$${controller.deliveryFee.toStringAsFixed(2)}'),
                            Divider(height: 22.h, color: const Color(0xFFF3F4F6)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  '\$${controller.totalWithDelivery.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryAmber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      /// Proceed to Checkout Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const EmployeeCheckoutScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAmber,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Proceed to Checkout · \$${controller.totalWithDelivery.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: const Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
