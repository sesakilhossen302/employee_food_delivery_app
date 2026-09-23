import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Core/AppRoute/app_route.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../Utils/AppConst/app_const.dart';
import '../../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';

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

    isLoading.value = true;
    try {
      final res = await ApiClient.postData(ApiConstant.sendOtp, {
        'email': userEmail.value,
      });

      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'A new 6-digit verification code has been sent to ${userEmail.value}',
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
        );
        startCountdown();
      } else {
        Fluttertoast.showToast(
          msg: res.body?['message'] ?? 'Failed to resend code',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to send OTP: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
      final res = await ApiClient.postData(ApiConstant.verifyOtp, {
        'email': userEmail.value,
        'otp': code,
      });

      if (res.statusCode == 200 && res.body != null && res.body['success'] == true) {
        final token = res.body['token']?.toString() ?? '';
        if (token.isNotEmpty) {
          await SharePrefsHelper.setString(AppConstants.bearerToken, token);
          await SharePrefsHelper.setString(SharedPreferenceValue.token, token);
        }

        Fluttertoast.showToast(
          msg: 'Email verified successfully as ${userRole.value}!',
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
        );

        final role = userRole.value.trim().toLowerCase();
        if (role == 'driver') {
          Get.offAllNamed(AppRoute.driverNavScreen);
        } else {
          Get.offAllNamed(AppRoute.employeeNavScreen);
        }
      } else {
        Fluttertoast.showToast(
          msg: res.body?['message'] ?? 'Invalid or expired OTP',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
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
