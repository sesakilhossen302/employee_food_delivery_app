import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Utils/AppColors/app_colors.dart';

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

      Fluttertoast.showToast(
        msg: 'Signed in successfully!',
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
      );
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
      await Future.delayed(const Duration(milliseconds: 1200));
      Fluttertoast.showToast(
        msg: 'Account created as ' + selectedRole.value + ' successfully!',
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
      );
      selectedTab.value = 0;
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
