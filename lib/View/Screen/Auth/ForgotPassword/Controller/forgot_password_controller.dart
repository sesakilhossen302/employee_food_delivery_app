import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Core/AppRoute/app_route.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../SignIn/Controller/sign_in_controller.dart';

class ForgotPasswordController extends GetxController {
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmHidden = true.obs;

  final RxInt timerCount = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      emailController.text = Get.arguments;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmVisibility() {
    isConfirmHidden.value = !isConfirmHidden.value;
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

  Future<void> sendResetEmail() async {
    if (!emailFormKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    isLoading.value = true;

    try {
      final res = await ApiClient.postData(ApiConstant.forgotPassword, {
        'email': email,
      });

      if (res.statusCode == 200) {
        startCountdown();

        Fluttertoast.showToast(
          msg: 'A 6-digit verification code has been sent to $email',
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
        );

        Get.toNamed(AppRoute.resetPasswordOtpScreen);
      } else {
        Fluttertoast.showToast(
          msg: res.body?['message'] ?? 'Failed to send verification code',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to send verification code: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    isLoading.value = true;
    try {
      final res = await ApiClient.postData(ApiConstant.forgotPassword, {
        'email': emailController.text.trim(),
      });

      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'New verification code sent to ${emailController.text.trim()}',
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
        msg: 'Failed to resend OTP: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyResetOtp() async {
    final code = pinController.text.trim();
    if (code.length != 6) {
      Fluttertoast.showToast(
        msg: 'Please enter the complete 6-digit code',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await ApiClient.postData(ApiConstant.verifyOtp, {
        'email': emailController.text.trim(),
        'otp': code,
      });

      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'OTP verified successfully!',
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
        );

        Get.toNamed(AppRoute.createNewPasswordScreen);
      } else {
        Fluttertoast.showToast(
          msg: res.body?['message'] ?? 'Invalid verification code',
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

  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final res = await ApiClient.postData(ApiConstant.resetPassword, {
        'email': emailController.text.trim(),
        'otp': pinController.text.trim(),
        'newPassword': newPasswordController.text.trim(),
      });

      if (res.statusCode == 200) {
        Get.dialog(
          Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 40),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Password Reset!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your password has been reset successfully. You can now sign in with your new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (Get.isRegistered<SignInController>()) {
                        final signInCtrl = Get.find<SignInController>();
                        signInCtrl.passwordController.clear();
                        signInCtrl.isLoading.value = false;
                      }
                      bool found = false;
                      navigator?.popUntil((route) {
                        if (route.settings.name == AppRoute.signInScreen) {
                          found = true;
                          return true;
                        }
                        return false;
                      });
                      if (!found) {
                        Get.offAllNamed(AppRoute.signInScreen);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          barrierDismissible: false,
        );
      } else {
        Fluttertoast.showToast(
          msg: res.body?['message'] ?? 'Failed to reset password',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to reset password: $e',
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
    super.onClose();
  }
}
