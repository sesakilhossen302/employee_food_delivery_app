import 'package:get/get.dart';
import '../../View/Screen/Auth/Otp/otp_screen.dart';
import '../../View/Screen/Auth/SignIn/sign_in_screen.dart';
import '../../View/Screen/Employee/Nav/employee_nav_screen.dart';

class AppRoute {
  ///==================== Initial Routes ====================
  static const String splashScreen = '/splash_screen';
  static const String signInScreen = '/sign_in_screen';
  static const String otpScreen = '/otp_screen';
  static const String employeeHomeScreen = '/employee_home_screen';
  static const String employeeNavScreen = '/employee_nav_screen';

  static List<GetPage> routes = [
    ///==================== Authentication Routes ====================
    GetPage(
      name: signInScreen,
      page: () => const SignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: otpScreen,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),

    ///==================== Employee Routes ====================
    GetPage(
      name: employeeHomeScreen,
      page: () => const EmployeeNavScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: employeeNavScreen,
      page: () => const EmployeeNavScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
