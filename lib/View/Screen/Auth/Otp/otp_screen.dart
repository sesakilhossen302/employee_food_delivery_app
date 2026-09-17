import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.put(OtpController());

    final defaultPinTheme = PinTheme(
      width: 48.w,
      height: 52.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'OTP Verification',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 28.h),

              /// Top Email Verification Badge Icon
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primaryColor,
                    size: 36,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Title
              Text(
                'Verification Code',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 8.h),

              /// Subtitle with Email
              Text(
                'Please enter the 6-digit verification code sent to',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 4.h),
              Obx(() => Text(
                    controller.userEmail.value.isNotEmpty
                        ? controller.userEmail.value
                        : 'your email address',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  )),

              /// Role Pill Badge
              SizedBox(height: 10.h),
              Obx(() => controller.userRole.value.isNotEmpty
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Role: ' + controller.userRole.value,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),

              SizedBox(height: 36.h),

              /// Pinput modern OTP field
              Pinput(
                length: 6,
                controller: controller.pinController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                autofocus: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.otpCode.value = value;
                },
                onCompleted: (pin) {
                  controller.verifyOtp();
                },
              ),
              SizedBox(height: 28.h),

              /// Countdown Timer / Resend Row
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      controller.canResend.value
                          ? GestureDetector(
                              onTap: controller.resendOtp,
                              child: Text(
                                'Resend Code',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            )
                          : Text(
                              'Resend in ' +
                                  controller.timerCount.value
                                      .toString()
                                      .padLeft(2, '0') +
                                  's',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                    ],
                  )),
              SizedBox(height: 32.h),

              /// Verify Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryColor.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 22.h,
                              width: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Verify and Proceed',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
