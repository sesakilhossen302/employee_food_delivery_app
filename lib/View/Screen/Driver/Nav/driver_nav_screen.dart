import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Controller/driver_controller.dart';
import '../Earnings/driver_earnings_screen.dart';
import '../Home/driver_home_screen.dart';
import '../Map/driver_map_screen.dart';
import '../Profile/driver_profile_screen.dart';

class DriverNavScreen extends StatelessWidget {
  const DriverNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverController());

    final List<Widget> pages = [
      const DriverHomeScreen(),
      const DriverMapScreen(),
      const DriverEarningsScreen(),
      const DriverProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentNavIndex.value,
          children: pages,
        ),
        bottomNavigationBar: _buildDriverBottomNav(controller),
      ),
    );
  }

  Widget _buildDriverBottomNav(DriverController controller) {
    final items = [
      {'icon': Icons.local_shipping_outlined, 'activeIcon': Icons.local_shipping_rounded, 'label': 'Deliveries'},
      {'icon': Icons.map_outlined, 'activeIcon': Icons.map_rounded, 'label': 'Map Route'},
      {'icon': Icons.account_balance_wallet_outlined, 'activeIcon': Icons.account_balance_wallet_rounded, 'label': 'Earnings'},
      {'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
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
        child: SizedBox(
          height: 62.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = controller.currentNavIndex.value == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.changeNavIndex(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 3.h,
                        width: 36.w,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryAmber : Colors.transparent,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(3.r)),
                        ),
                      ),
                      Icon(
                        isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                        size: 24.sp,
                        color: isSelected ? AppColors.primaryAmber : const Color(0xFF9CA3AF),
                      ),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryAmber : const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
