import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              '1. Information We Collect',
              'We collect personal details provided during account creation, including your name, email, contact telephone number, and designated delivery addresses. For Drivers, we also collect vehicle model and registration details.',
            ),
            _buildCard(
              '2. GPS & Location Data',
              'Real-time GPS location is accessed during active deliveries solely to calculate optimal driving routes, estimated time of arrival (ETA), and to enable customer delivery tracking. We do not track your location when the app is inactive.',
            ),
            _buildCard(
              '3. Cash Transaction Data',
              'Records of items ordered, total cash due, and driver cash collection logs are maintained securely to ensure accountability between the customer, delivery driver, and QuickStop convenience store.',
            ),
            _buildCard(
              '4. Data Protection & Sharing',
              'We do not sell, rent, or lease your personal information to third-party advertisers. Your phone number is shared only with the assigned driver for order drop-off communication.',
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                'Questions regarding privacy? Contact privacy@quickstopdelivery.com',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF4B5563), height: 1.5),
          ),
        ],
      ),
    );
  }
}
