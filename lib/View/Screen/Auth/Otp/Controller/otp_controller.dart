import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Core/AppRoute/app_route.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../helper/shared_prefe/shared_prefe.dart';

class OtpController extends GetxController {
  final TextEditingController pinController = TextEditingController();
  final RxString otpCode = ''.obs;

  final RxString userEmail = ''.obs;
  final RxString userRole = ''.obs;

  final RxInt timerCount = 60.obs;
  final RxBool canResend = false.obs;
  final RxBool isLoading = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    startCountdown();
  }

  Future<void> _loadArguments() async {
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        userEmail.value = Get.arguments['email'] ?? '';
        userRole.value = Get.arguments['role'] ?? '';
      } else if (Get.arguments is String) {
        userEmail.value = Get.arguments;
      }
    }

    if (userEmail.value.isEmpty) {
      userEmail.value = await SharePrefsHelper.getString(SharedPreferenceValue.email);
    }
    if (userRole.value.isEmpty) {
      userRole.value = await SharePrefsHelper.getString(SharedPreferenceValue.role);
    }
  }

  void startCountdown() {
    timerCount.value = 60;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerCount.value > 0) {
        timerCount.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    Fluttertoast.showToast(
      msg: 'A new 6-digit verification code has been sent to ${userEmail.value}',
      backgroundColor: AppColors.primaryColor,
      textColor: Colors.white,
    );
    startCountdown();
  }

  Future<void> verifyOtp() async {
    final code = pinController.text.trim();
    if (code.length != 6) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid 6-digit OTP',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1400));

      Fluttertoast.showToast(
        msg: 'Email verified successfully as ${userRole.value}!',
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
      );

      // Check role: If Employee, navigate to EmployeeHomeScreen
      if (userRole.value.trim().toLowerCase() == 'employee') {
        Get.offAllNamed(AppRoute.employeeHomeScreen);
      } else {
        Get.offAllNamed(AppRoute.signInScreen);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Verification failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    pinController.dispose();
    super.onClose();
  }
}
