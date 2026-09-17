import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Controller/driver_controller.dart';
import '../Model/driver_order_model.dart';

class DriverActiveDeliveryScreen extends StatelessWidget {
  const DriverActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Obx(() {
          final order = controller.activeOrder.value;
          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 64.sp, color: const Color(0xFF10B981)),
                  SizedBox(height: 14.h),
                  Text('No active delivery right now', style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAmber),
                    child: const Text('Back to Deliveries', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              /// Top App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(Icons.chevron_left_rounded, size: 24),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery ${order.id}',
                          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          order.statusTitle,
                          style: GoogleFonts.inter(fontSize: 12.sp, color: order.statusColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    children: [
                      /// Customer & Contact Card
                      _buildCustomerContactCard(order),
                      SizedBox(height: 14.h),

                      /// Delivery Instructions Banner (Matching Dakota.pdf)
                      _buildInstructionsCard(order),
                      SizedBox(height: 14.h),

                      /// Order Items Checklist
                      _buildItemsChecklist(order),
                      SizedBox(height: 14.h),

                      /// Cash on Delivery Collection Box
                      _buildCashCollectionCard(order),
                      SizedBox(height: 24.h),

                      /// Step Actions based on Status
                      _buildActionButtons(order, controller),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCustomerContactCard(DriverOrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      order.customerPhone,
                      style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: 'Calling ${order.customerName} (${order.customerPhone})...',
                    backgroundColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                  );
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                  child: const Icon(Icons.phone_outlined, color: Color(0xFF10B981), size: 20),
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primaryAmber, size: 20),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(DriverOrderModel order) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Instructions:',
                  style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF92400E)),
                ),
                SizedBox(height: 2.h),
                Text(
                  order.deliveryInstructions,
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsChecklist(DriverOrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items to Deliver',
            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          ...order.items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  const Icon(Icons.check_box_rounded, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8.w),
                  Text(item, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCashCollectionCard(DriverOrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.primaryAmber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '💵 Cash to Collect on Delivery',
                style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFFD97706)),
              ),
              Text(
                '\$${order.totalCashToCollect.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.primaryAmber),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Hand cash payment only (per store policy). Collect from customer before handing over package.',
            style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DriverOrderModel order, DriverController controller) {
    if (order.status == DriverOrderStatus.pickingUp) {
      return SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () => controller.confirmStorePickup(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAmber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
          child: Text('Confirm Store Pickup & Start Driving', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      );
    }

    if (order.status == DriverOrderStatus.onTheWay) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: OutlinedButton(
                onPressed: () {
                  controller.changeNavIndex(1); // Go to map tab
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryAmber),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Live Map Route', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primaryAmber)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => controller.markArrived(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Mark Arrived', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      );
    }

    /// Arrived state -> Collect cash & complete
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {
          controller.completeDeliveryAndCollectCash();
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(
          'Confirm Cash Received (\$${order.totalCashToCollect.toStringAsFixed(2)}) & Complete',
          style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
