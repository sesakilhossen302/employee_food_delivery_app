import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/employee_orders_controller.dart';
import 'Detail/employee_order_detail_screen.dart';
import 'Model/employee_order_models.dart';

class EmployeeOrdersScreen extends StatelessWidget {
  const EmployeeOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Top Header: "My Orders" & "3 orders"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Orders',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${controller.orders.length} orders',
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

            /// 2. Orders List
            Expanded(
              child: Obx(
                () => ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  itemCount: controller.orders.length,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        Get.to(() => EmployeeOrderDetailScreen(order: order));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: order.hasActiveBorder ? AppColors.primaryAmber : const Color(0xFFF3F4F6),
            width: order.hasActiveBorder ? 1.5 : 1,
          ),
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
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top Row: ID, Date & Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            order.date,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: order.statusBgColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: order.statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              order.statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: order.statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  /// Thumbnails Row
                  Row(
                    children: order.items.take(3).map((item) {
                      return Container(
                        margin: EdgeInsets.only(right: 8.w),
                        width: 44.w,
                        height: 44.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(Icons.fastfood_outlined, size: 20, color: Color(0xFF9CA3AF)),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10.h),

                  /// Item Summary Line
                  Text(
                    order.items.map((i) => '${i.qty}× ${i.name}').join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// Delivery Info & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            order.isDelivery ? Icons.local_shipping_outlined : Icons.inventory_2_outlined,
                            size: 16.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            order.isDelivery ? 'Delivery' : 'Pickup',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.access_time_rounded,
                            size: 14.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            order.estimatedTime,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
              child: LinearProgressIndicator(
                value: order.progressPercent,
                minHeight: 4.h,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAmber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
