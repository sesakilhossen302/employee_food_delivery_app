import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../Profile/Controller/profile_controller.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

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
                'Driver Profile',
                style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
              ),
              SizedBox(height: 16.h),

              /// Driver Badge Card (Clickable to Edit)
              Obx(() => _buildDriverBadgeCard(controller)),
              SizedBox(height: 16.h),

              /// Vehicle & Station Assigned Container
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  children: [
                    _buildRow('Assigned Station', 'QuickStop #12, 1250 Highway Blvd'),
                    Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                    _buildRow('Delivery Radius', '0–20 km (Springfield zone)'),
                    Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                    _buildRow('Vehicle Assigned', 'Honda Civic (Plate: QST-991)'),
                    Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                    _buildRow('Payment Mode', 'Cash on Delivery / Hand Cash'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              /// Driver Menu Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  children: [
                    _buildDriverMenuItem(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      iconBgColor: const Color(0xFFECFDF5),
                      title: 'Edit Driver Details',
                      subtitle: 'Update phone, name, and driver picture',
                      onTap: () => Get.toNamed(AppRoute.editProfileScreen),
                    ),
                    Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                    Obx(() => _buildDriverMenuItem(
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      title: 'Shift & Order Notifications',
                      subtitle: 'Delivery updates and dispatch alerts',
                      badgeCount: controller.unreadNotificationsCount,
                      onTap: () => Get.toNamed(AppRoute.notificationsScreen),
                    )),
                    Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                    _buildDriverMenuItem(
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBgColor: const Color(0xFFF3E8FF),
                      title: 'Driver Support & Dispatcher',
                      subtitle: 'Call dispatcher desk or station team',
                      onTap: () => Get.toNamed(AppRoute.helpSupportScreen),
                    ),
                    Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                    _buildDriverMenuItem(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF4B5563),
                      iconBgColor: const Color(0xFFF3F4F6),
                      title: 'Driver Terms & Cash Policies',
                      subtitle: 'Hand cash collection & remittance rules',
                      onTap: () => Get.toNamed(AppRoute.termsAndConditionsScreen),
                    ),
                    Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                    _buildDriverMenuItem(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF0D9488),
                      iconBgColor: const Color(0xFFCCFBF1),
                      title: 'Privacy Policy',
                      subtitle: 'GPS navigation and location terms',
                      onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              /// Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Get.offAllNamed(AppRoute.signInScreen);
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: Text('Sign Out', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Center(
                child: Text(
                  'QuickStop Driver App v1.0 • Gas Station Delivery',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverBadgeCard(ProfileController controller) {
    final path = controller.profileImagePath.value;
    final hasLocalImage = path.isNotEmpty && File(path).existsSync();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoute.editProfileScreen),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: hasLocalImage
                      ? Image.file(File(path), width: 54.w, height: 54.w, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            controller.userName.value.isNotEmpty ? controller.userName.value[0].toUpperCase() : 'D',
                            style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFFD97706)),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userName.value,
                      style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      controller.userEmail.value,
                      style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12.r)),
                child: Center(child: Icon(icon, color: iconColor, size: 20.sp)),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                    SizedBox(height: 2.h),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}
