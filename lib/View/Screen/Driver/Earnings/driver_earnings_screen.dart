import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Controller/driver_controller.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shift Earnings & Cash',
                style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
              ),
              SizedBox(height: 14.h),

              /// Big Earnings Card
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF111827)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Driver Earnings",
                        style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '\$${controller.todayEarnings.value.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      SizedBox(height: 16.h),
                      Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Completed Trips', style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
                              SizedBox(height: 2.h),
                              Text('${controller.completedCount.value} Deliveries', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Cash to Remit to Store', style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFFFEF3C7))),
                              SizedBox(height: 2.h),
                              Text('\$${controller.cashCollectedInHand.value.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.primaryAmber)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Cash Remittance Notice (Matching Dakota.pdf Cash on Delivery policy)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_outlined, color: Color(0xFFD97706), size: 24),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remit Cash at End of Shift',
                            style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF92400E)),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Please hand over collected cash to the QuickStop store cashier when your shift concludes.',
                            style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Recent Completed Deliveries',
                style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 12.h),

              /// Recent Deliveries List
              Obx(() {
                final list = controller.completedDeliveries;
                if (list.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                    child: Center(
                      child: Text('Completed deliveries will appear here', style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF))),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.id, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                              SizedBox(height: 2.h),
                              Text('${item.distance} · ${item.orderTime}', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+\$${item.driverEarning.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF10B981))),
                              SizedBox(height: 2.h),
                              Text('Collected \$${item.totalCashToCollect.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
