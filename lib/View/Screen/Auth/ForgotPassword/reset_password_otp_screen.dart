import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/forgot_password_controller.dart';

class ResetPasswordOtpScreen extends StatelessWidget {
  const ResetPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.find<ForgotPasswordController>();

    final defaultPinTheme = PinTheme(
      width: 48.w,
      height: 52.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primaryColor, width: 1.8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),

              /// Key/SMS Icon with Circular Background
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              /// Header Texts
              Text(
                'Enter Verification Code',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'We have sent a 6-digit verification code to:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                controller.emailController.text.trim().isNotEmpty
                    ? controller.emailController.text.trim()
                    : 'your registered email',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 36.h),

              /// 6-digit Pinput Code
              Pinput(
                length: 6,
                controller: controller.pinController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                showCursor: true,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              ),
              SizedBox(height: 28.h),

              /// Resend Code Countdown
              Obx(() {
                if (controller.canResend.value) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Did not receive the code? ',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                      ),
                      GestureDetector(
                        onTap: controller.resendOtp,
                        child: Text(
                          'Resend Code',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  final mins = (controller.timerCount.value ~/ 60).toString().padLeft(2, '0');
                  final secs = (controller.timerCount.value % 60).toString().padLeft(2, '0');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Resend code in ',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                      ),
                      Text(
                        '$mins:$secs',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  );
                }
              }),
              SizedBox(height: 32.h),

              /// Verify Code Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.verifyResetOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                        )
                      : Text(
                          'Verify Code',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
