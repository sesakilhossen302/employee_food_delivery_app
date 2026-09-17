import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeAccountScreen extends StatelessWidget {
  const EmployeeAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Employee Account',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('C', style: GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.bold, color: const Color(0xFFD97706))),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Employee Profile', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 6.h),
            Text('Manage account details & settings', style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}
