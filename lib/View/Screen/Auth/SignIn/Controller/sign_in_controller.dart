import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../../Core/AppRoute/app_route.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../Utils/AppConst/app_const.dart';
import '../../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';

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
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final payload = {
        'email': email,
        'password': password,
      };

      final response = await ApiClient.postData(ApiConstant.signIn, payload);

      if (response.statusCode == 200 && response.body != null && response.body['success'] == true) {
        final token = response.body['token']?.toString() ?? '';
        final user = response.body['user'] ?? response.body['data']?['user'] ?? {};
        final role = (user['role'] ?? selectedRole.value).toString();

        if (token.isNotEmpty) {
          await SharePrefsHelper.setString(AppConstants.bearerToken, token);
          await SharePrefsHelper.setString(SharedPreferenceValue.token, token);
        }
        await SharePrefsHelper.setString(SharedPreferenceValue.email, email);
        await SharePrefsHelper.setString(SharedPreferenceValue.role, role);
        if (user['name'] != null) {
          await SharePrefsHelper.setString('saved_user_name', user['name'].toString());
        }
        if (user['phone'] != null) {
          await SharePrefsHelper.setString('saved_user_phone', user['phone'].toString());
        }

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
      } else {
        final errorMsg = response.body?['message'] ?? response.statusText ?? 'Invalid email or password';
        Fluttertoast.showToast(
          msg: errorMsg.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Sign in failed: $e',
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
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final role = selectedRole.value.toLowerCase() == 'driver' ? 'driver' : 'customer';

      final payload = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      };

      final response = await ApiClient.postData(ApiConstant.signUp, payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body?['token']?.toString() ?? '';
        if (token.isNotEmpty) {
          await SharePrefsHelper.setString(AppConstants.bearerToken, token);
          await SharePrefsHelper.setString(SharedPreferenceValue.token, token);
        }
        await SharePrefsHelper.setString(SharedPreferenceValue.role, selectedRole.value);
        await SharePrefsHelper.setString(SharedPreferenceValue.email, email);
        if (name.isNotEmpty) {
          await SharePrefsHelper.setString('saved_user_name', name);
        }
        if (phone.isNotEmpty) {
          await SharePrefsHelper.setString('saved_user_phone', phone);
        }

        // Send OTP to user email via backend Gmail SMTP service
        await ApiClient.postData(ApiConstant.sendOtp, {'email': email});

        Fluttertoast.showToast(
          msg: 'Account created! Verification code sent to $email.',
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
        );

        Get.toNamed(
          AppRoute.otpScreen,
          arguments: {
            'email': email,
            'role': selectedRole.value,
          },
        );
      } else {
        final errorMsg = response.body?['message'] ?? response.statusText ?? 'Registration failed';
        Fluttertoast.showToast(
          msg: errorMsg.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Sign up failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleForgotPassword() {
    Get.toNamed(AppRoute.forgotPasswordScreen, arguments: emailController.text.trim());
  }

}
