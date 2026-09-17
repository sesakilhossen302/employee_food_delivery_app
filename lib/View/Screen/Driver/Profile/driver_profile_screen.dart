import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Core/AppRoute/app_route.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

              /// Driver Badge Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      child: Center(
                        child: Text(
                          'D',
                          style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFFD97706)),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official QuickStop Driver',
                          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'driver@quickstopdelivery.com',
                          style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              /// Details Container
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
                    _buildRow('Delivery Radius', '0–20 km (per store settings)'),
                    Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                    _buildRow('Vehicle Assigned', 'Honda Civic (Plate: QST-991)'),
                    Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
                    _buildRow('Payment Handling', 'Cash on Delivery & Hand Payment'),
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
                  'QuickStop Driver App v1.0 · Gas Station Delivery',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                ),
              ),
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
