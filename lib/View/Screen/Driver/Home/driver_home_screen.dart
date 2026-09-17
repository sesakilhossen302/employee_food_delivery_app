import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../ActiveDelivery/driver_active_delivery_screen.dart';
import '../Controller/driver_controller.dart';
import '../Model/driver_order_model.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// 1. Driver Top Header: Driver Badge & Online Toggle
            _buildDriverHeader(controller),

            /// 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Quick Shift Stats Row
                    _buildShiftStatsRow(controller),
                    SizedBox(height: 18.h),

                    /// Active Delivery Card (if any)
                    Obx(() {
                      if (controller.activeOrder.value != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Delivery in Progress',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            _buildActiveOrderCard(controller.activeOrder.value!, controller),
                            SizedBox(height: 20.h),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    /// Available Orders Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Orders (Ready at Store)',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Obx(
                          () => Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${controller.availableOrders.length} Ready',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    /// Available Orders List
                    Obx(() {
                      if (!controller.isOnline.value) {
                        return _buildOfflineMessage();
                      }

                      if (controller.availableOrders.isEmpty) {
                        return _buildEmptyOrdersCard();
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.availableOrders.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final order = controller.availableOrders[index];
                          return _buildAvailableOrderCard(order, controller);
                        },
                      );
                    }),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverHeader(DriverController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'D',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QuickStop Driver',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Assigned: Station #12',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// Online / Offline Toggle Button
          Obx(
            () => GestureDetector(
              onTap: () => controller.toggleOnlineStatus(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: controller.isOnline.value
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: controller.isOnline.value
                        ? const Color(0xFF10B981)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: controller.isOnline.value
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      controller.isOnline.value ? 'Online' : 'Offline',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: controller.isOnline.value
                            ? const Color(0xFF059669)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftStatsRow(DriverController controller) {
    return Obx(
      () => Row(
        children: [
          /// Deliveries Done
          Expanded(
            child: _buildStatItem(
              title: 'Deliveries',
              value: '${controller.completedCount.value}',
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
            ),
          ),
          SizedBox(width: 10.w),

          /// Shift Earnings
          Expanded(
            child: _buildStatItem(
              title: 'Earnings',
              value: '\$${controller.todayEarnings.value.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF10B981),
              bgColor: const Color(0xFFECFDF5),
            ),
          ),
          SizedBox(width: 10.w),

          /// Cash to Remit
          Expanded(
            child: _buildStatItem(
              title: 'Cash in Hand',
              value: '\$${controller.cashCollectedInHand.value.toStringAsFixed(2)}',
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFFD97706),
              bgColor: const Color(0xFFFEF3C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: iconColor, size: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(DriverOrderModel order, DriverController controller) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const DriverActiveDeliveryScreen());
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.primaryAmber, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAmber.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    order.statusTitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.primaryAmber, size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  order.distance,
                  style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collect: \$${order.totalCashToCollect.toStringAsFixed(2)} Cash',
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                ),
                Text(
                  'Earning: \$${order.driverEarning.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 42.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const DriverActiveDeliveryScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text(
                  'Open Delivery Actions & Route',
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableOrderCard(DriverOrderModel order, DriverController controller) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Fee + Tip: \$${order.driverEarning.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF059669)),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  order.pickupAddress,
                  style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryAmber),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${order.deliveryAddress} (${order.distance})',
                  style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            order.items.join(', '),
            style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collect: \$${order.totalCashToCollect.toStringAsFixed(2)} (Cash)',
                style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
              ElevatedButton(
                onPressed: () => controller.acceptOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  elevation: 0,
                ),
                child: Text(
                  'Accept Delivery',
                  style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 48.sp, color: const Color(0xFF9CA3AF)),
            SizedBox(height: 12.h),
            Text(
              'You are currently offline',
              style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              'Switch to Online mode at the top to receive orders.',
              style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.done_all_rounded, size: 48.sp, color: const Color(0xFF10B981)),
            SizedBox(height: 12.h),
            Text(
              'No pending orders at the store',
              style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              'New orders will pop up automatically as customers place them.',
              style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}
