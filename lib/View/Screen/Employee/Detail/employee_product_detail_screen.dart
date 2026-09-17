import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Home/Controller/employee_home_controller.dart';
import '../Home/Model/employee_home_models.dart';

class EmployeeProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const EmployeeProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();
    // Local quantity for stepper, initialized from controller or defaults to 1
    final RxInt selectedQuantity = (homeController.getQuantity(product.id) > 0
            ? homeController.getQuantity(product.id)
            : 1)
        .obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          /// Scrollable Product Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Product Image
                SizedBox(
                  width: double.infinity,
                  height: 340.h,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF3F4F6),
                        child: Center(
                          child: Icon(
                            Icons.fastfood_outlined,
                            size: 64.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// Details Container
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Category Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🥤', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4.w),
                            Text(
                              product.category,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF2563EB),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      /// Product Title
                      Text(
                        product.name,
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),

                      /// Subtitle
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : '${product.category}, ${product.unit} · ${product.unit}',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      /// Price
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                      SizedBox(height: 14.h),

                      /// In Stock Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'In Stock',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF059669),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      /// Quantity Selector Row
                      Row(
                        children: [
                          Text(
                            'Quantity',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(width: 16.w),

                          /// Stepper Box
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (selectedQuantity.value > 1) {
                                      selectedQuantity.value--;
                                    }
                                  },
                                  icon: const Icon(Icons.remove, size: 16, color: Color(0xFF6B7280)),
                                  splashRadius: 18,
                                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                                  padding: EdgeInsets.zero,
                                ),
                                Obx(
                                  () => SizedBox(
                                    width: 28.w,
                                    child: Text(
                                      '${selectedQuantity.value}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (selectedQuantity.value < product.maxPerOrder) {
                                      selectedQuantity.value++;
                                    }
                                  },
                                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF6B7280)),
                                  splashRadius: 18,
                                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),

                          Text(
                            'Max ${product.maxPerOrder}',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      /// Product Info Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Info',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            _buildInfoRow('Size / Qty', product.unit),
                            Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                            _buildInfoRow('Max per order', '${product.maxPerOrder}'),
                            Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                            _buildInfoRow('Category', product.category),
                          ],
                        ),
                      ),
                      SizedBox(height: 100.h), // Space for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Floating Back Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 26,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Sticky Bottom "Add to Cart" Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        homeController.setQuantity(product, selectedQuantity.value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add to Cart',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${selectedQuantity.value} × \$${product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
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
