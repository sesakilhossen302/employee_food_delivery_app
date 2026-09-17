import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Terms & Conditions',
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
            _buildSection(
              '1. QuickStop Gas Station Delivery Service',
              'QuickStop Convenience Store & Gas Station delivers snacks, beverages, groceries, and automotive essentials within authorized Springfield delivery radius zones (0–5 km, 5–10 km, and 10–20 km). By ordering, you agree to these operational terms.',
            ),
            _buildSection(
              '2. Cash on Delivery (COD) & Hand Cash Terms',
              'All deliveries operate strictly on a Cash on Delivery (Hand Cash) basis. Customers must pay the driver the exact cash amount shown on their order bill upon arrival. Drivers will issue a physical cash receipt and verify total bill collection.',
            ),
            _buildSection(
              '3. Driver Conduct & Cash Remittance Policy',
              'Drivers are independent authorized representatives of QuickStop Gas Station #12. Drivers are required to safeguard all cash collected during their shifts and remit the total collected balance to the station head cashier at the end of each shift.',
            ),
            _buildSection(
              '4. Delivery Time & Drop-off Instructions',
              'Delivery times are estimates calculated using real-time GPS routing. Customers may specify clear drop-off instructions (e.g., "Leave at front door", "Call when arrived"). If the customer is unreachable after 10 minutes, the order will be returned to the store.',
            ),
            _buildSection(
              '5. Cancellations & Returns',
              'Orders may be cancelled free of charge before the store marks the items "Ready for Driver". Once a driver is en route, order cancellations may incur a base delivery trip fee.',
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                'Last updated: September 2026 • QuickStop Springfield, IL',
                style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
