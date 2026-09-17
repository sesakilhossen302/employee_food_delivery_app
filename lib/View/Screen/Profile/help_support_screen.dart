import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utils/AppColors/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showTicketDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Submit Support Request', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: 'Issue subject',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your issue in detail...',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Fluttertoast.showToast(
                msg: 'Support ticket submitted! Our team will respond shortly.',
                backgroundColor: AppColors.primaryAmber,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Submit', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Help & Support',
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Quick Contact Cards
            Text(
              'Contact QuickStop Support',
              style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                    title: 'Call Store',
                    subtitle: '+1 (555) 234-5678',
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Dialing QuickStop Station dispatcher...');
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email_rounded,
                    iconColor: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    title: 'Email Us',
                    subtitle: 'support@quickstop.com',
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Opening email client...');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            /// Station Location Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_gas_station_rounded, color: Color(0xFFD97706), size: 24),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Station Store Location', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2.h),
                        Text(
                          'QuickStop Gas Station #12\n1250 Highway Blvd, Springfield, IL',
                          style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            /// FAQs Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
            SizedBox(height: 12.h),
            _buildFaqAccordion('How does Cash on Delivery work?', 'QuickStop utilizes a 100% Hand Cash model. When the driver arrives with your order, pay the exact order total in cash. The driver confirms payment on the spot.'),
            _buildFaqAccordion('What is the delivery radius for QuickStop?', 'We serve customers in 0–5 km, 5–10 km, and 10–20 km radius rings from our 1250 Highway Blvd store in Springfield.'),
            _buildFaqAccordion('How do Drivers remit cash collected?', 'At the end of each shift, drivers visit Station #12 cashier desk, show the Cash to Remit balance in the Driver App, and hand over the exact cash total.'),
            _buildFaqAccordion('Can I leave special drop-off instructions?', 'Yes! When placing your order, choose instructions like "Leave at front door", "Call when arrived", or "Side entrance".'),
            SizedBox(height: 24.h),

            /// Submit Ticket Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: () => _showTicketDialog(context),
                icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
                label: Text('Submit Support Request', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10.r)),
                child: Center(child: Icon(icon, color: iconColor, size: 20)),
              ),
              SizedBox(height: 10.h),
              Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqAccordion(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              child: Text(answer, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF4B5563), height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}
