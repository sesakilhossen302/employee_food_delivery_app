import 'package:get/get.dart';
import '../../View/Screen/Auth/Otp/otp_screen.dart';
import '../../View/Screen/Auth/SignIn/sign_in_screen.dart';
import '../../View/Screen/Employee/Account/employee_account_screen.dart';
import '../../View/Screen/Employee/Cart/employee_cart_screen.dart';
import '../../View/Screen/Employee/Checkout/employee_checkout_screen.dart';
import '../../View/Screen/Employee/Detail/employee_product_detail_screen.dart';
import '../../View/Screen/Employee/Nav/employee_nav_screen.dart';
import '../../View/Screen/Employee/Orders/Detail/employee_order_detail_screen.dart';
import '../../View/Screen/Employee/Orders/employee_orders_screen.dart';

class AppRoute {
  ///==================== Initial Routes ====================
  static const String splashScreen = '/splash_screen';
  static const String signInScreen = '/sign_in_screen';
  static const String otpScreen = '/otp_screen';
  static const String employeeHomeScreen = '/employee_home_screen';
  static const String employeeNavScreen = '/employee_nav_screen';
  static const String employeeCartScreen = '/employee_cart_screen';
  static const String employeeCheckoutScreen = '/employee_checkout_screen';
  static const String employeeProductDetailScreen = '/employee_product_detail_screen';
  static const String employeeOrdersScreen = '/employee_orders_screen';
  static const String employeeOrderDetailScreen = '/employee_order_detail_screen';
  static const String employeeAccountScreen = '/employee_account_screen';

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
    GetPage(
      name: employeeCartScreen,
      page: () => const EmployeeCartScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: employeeCheckoutScreen,
      page: () => const EmployeeCheckoutScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: employeeProductDetailScreen,
      page: () => EmployeeProductDetailScreen(product: Get.arguments),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: employeeOrdersScreen,
      page: () => const EmployeeOrdersScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: employeeOrderDetailScreen,
      page: () => EmployeeOrderDetailScreen(order: Get.arguments),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: employeeAccountScreen,
      page: () => const EmployeeAccountScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
  ];
}
