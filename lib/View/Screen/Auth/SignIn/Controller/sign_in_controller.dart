import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Core/AppRoute/app_route.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../helper/shared_prefe/shared_prefe.dart';

class SignInController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 0 = Sign In, 1 = Sign Up
  final RxInt selectedTab = 0.obs;

  /// Role selection for Sign Up: 'Employee' or 'Driver'
  final RxString selectedRole = 'Employee'.obs;

  /// Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Sign Up specific controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// Visibility states
  final RxBool isPasswordHidden = true.obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  void toggleTab(int index) {
    selectedTab.value = index;
    formKey.currentState?.reset();
  }

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> handleSignIn() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final email = emailController.text.trim();
      final role = selectedRole.value;
      await SharePrefsHelper.setString(SharedPreferenceValue.email, email);
      await SharePrefsHelper.setString(SharedPreferenceValue.role, role);

      Fluttertoast.showToast(
        msg: 'Signed in successfully as $role!',
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
      );

      if (role.toLowerCase() == 'driver') {
        Get.offAllNamed(AppRoute.driverNavScreen);
      } else {
        Get.offAllNamed(AppRoute.employeeNavScreen);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Sign in failed: ' + e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final email = emailController.text.trim();
      final role = selectedRole.value;

      /// Save role & email to SharedPreferences
      await SharePrefsHelper.setString(SharedPreferenceValue.role, role);
      await SharePrefsHelper.setString(SharedPreferenceValue.email, email);

      Fluttertoast.showToast(
        msg: 'Account created as ' + role + '! Please verify OTP.',
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
      );

      /// Navigate to OTP screen with email and role arguments
      Get.toNamed(
        AppRoute.otpScreen,
        arguments: {
          'email': email,
          'role': role,
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Sign up failed: ' + e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleForgotPassword() {
    final email = emailController.text.trim();
    Fluttertoast.showToast(
      msg: email.isNotEmpty
          ? ('Reset password link sent to ' + email)
          : 'Reset password link sent to your email',
      backgroundColor: AppColors.primaryColor,
      textColor: Colors.white,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
