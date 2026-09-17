import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../Profile/Controller/profile_controller.dart';

class EmployeeAccountScreen extends StatelessWidget {
  const EmployeeAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Top Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Text(
                'Account',
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),

            /// 2. Account Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Column(
                  children: [
                    /// User Profile Card (Clickable to Edit)
                    Obx(() => _buildProfileCard(controller)),
                    SizedBox(height: 16.h),

                    /// Menu Options Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
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
                        children: [
                          /// 1. Edit Profile
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF10B981),
                            iconBgColor: const Color(0xFFECFDF5),
                            title: 'Edit Profile',
                            subtitle: 'Name, phone, and profile photo',
                            onTap: () => Get.toNamed(AppRoute.editProfileScreen),
                          ),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 2. My Addresses
                          _buildMenuItem(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFFD97706),
                            iconBgColor: const Color(0xFFFEF3C7),
                            title: 'My Addresses',
                            subtitle: 'Manage Springfield delivery addresses',
                            onTap: () => Get.toNamed(AppRoute.myAddressesScreen),
                          ),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 3. Notifications
                          Obx(() => _buildMenuItem(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFF2563EB),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Notifications',
                            subtitle: 'Order updates and store alerts',
                            badgeCount: controller.unreadNotificationsCount,
                            onTap: () => Get.toNamed(AppRoute.notificationsScreen),
                          )),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 4. Help & Support
                          _buildMenuItem(
                            icon: Icons.support_agent_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            iconBgColor: const Color(0xFFF3E8FF),
                            title: 'Help & Support',
                            subtitle: 'Store contact & FAQ assistance',
                            onTap: () => Get.toNamed(AppRoute.helpSupportScreen),
                          ),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 5. Terms & Conditions
                          _buildMenuItem(
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFF4B5563),
                            iconBgColor: const Color(0xFFF3F4F6),
                            title: 'Terms & Conditions',
                            subtitle: 'Gas station delivery & cash policies',
                            onTap: () => Get.toNamed(AppRoute.termsAndConditionsScreen),
                          ),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 6. Privacy Policy
                          _buildMenuItem(
                            icon: Icons.shield_outlined,
                            iconColor: const Color(0xFF0D9488),
                            iconBgColor: const Color(0xFFCCFBF1),
                            title: 'Privacy Policy',
                            subtitle: 'GPS location & data security',
                            onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    /// Sign Out Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _buildMenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFEF4444),
                        iconBgColor: const Color(0xFFFEE2E2),
                        title: 'Sign Out',
                        subtitle: 'Log out of your account',
                        titleColor: const Color(0xFFEF4444),
                        showArrow: false,
                        onTap: () => _showSignOutConfirmation(context),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    /// Version Footer
                    Center(
                      child: Text(
                        'QuickStop v1.0 • Gas Station Delivery',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
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

  Widget _buildProfileCard(ProfileController controller) {
    final path = controller.profileImagePath.value;
    final hasLocalImage = path.isNotEmpty && File(path).existsSync();
    final initialLetter = controller.userName.value.isNotEmpty
        ? controller.userName.value[0].toUpperCase()
        : 'C';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoute.editProfileScreen),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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
                            initialLetter,
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD97706),
                            ),
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
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.userEmail.value,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
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

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    int? badgeCount,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20.sp),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
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
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (showArrow)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: const Color(0xFFD1D5DB),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Sign Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Get.back();
                Get.offAllNamed(AppRoute.signInScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}
