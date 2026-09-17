import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';

class EmployeeAccountScreen extends StatefulWidget {
  const EmployeeAccountScreen({super.key});

  @override
  State<EmployeeAccountScreen> createState() => _EmployeeAccountScreenState();
}

class _EmployeeAccountScreenState extends State<EmployeeAccountScreen> {
  String userEmail = 'ce.sakilhossen302@gmail.com';
  String userName = 'Customer';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final savedEmail = await SharePrefsHelper.getString(SharedPreferenceValue.email);
    if (savedEmail.isNotEmpty) {
      setState(() {
        userEmail = savedEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Top Header: "Account"
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
                    /// User Profile Card
                    _buildProfileCard(initialLetter),
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
                          /// 1. My Addresses
                          _buildMenuItem(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFFD97706),
                            iconBgColor: const Color(0xFFFEF3C7),
                            title: 'My Addresses',
                            subtitle: 'Manage delivery addresses',
                            onTap: () {
                              _showComingSoon('Addresses');
                            },
                          ),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 2. Notifications
                          _buildMenuItem(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFF2563EB),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Notifications',
                            subtitle: 'Order updates and alerts',
                            onTap: () {
                              _showComingSoon('Notifications');
                            },
                          ),
                          Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 64.w),

                          /// 3. Help & Support
                          _buildMenuItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            iconBgColor: const Color(0xFFF3E8FF),
                            title: 'Help & Support',
                            subtitle: 'FAQ and contact us',
                            onTap: () {
                              _showComingSoon('Help & Support');
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    /// Sign Out Card
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
                        onTap: () {
                          _showSignOutConfirmation();
                        },
                      ),
                    ),
                    SizedBox(height: 32.h),

                    /// Version Footer
                    Center(
                      child: Text(
                        'QuickStop v1.0 · Gas Station Delivery',
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

  /// --------------------------------------------------------------------------
  /// PROFILE CARD
  /// --------------------------------------------------------------------------
  Widget _buildProfileCard(String initial) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          /// Avatar Circle ('C')
          Container(
            width: 54.w,
            height: 54.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),

          /// Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  userEmail,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// MENU ITEM
  /// --------------------------------------------------------------------------
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature management coming soon!'),
        backgroundColor: AppColors.primaryAmber,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Sign Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
