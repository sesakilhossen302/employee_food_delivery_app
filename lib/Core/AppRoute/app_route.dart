import '../../View/Screen/Profile/edit_profile_screen.dart';
import '../../View/Screen/Profile/notifications_screen.dart';
import '../../View/Screen/Profile/terms_and_conditions_screen.dart';
import '../../View/Screen/Profile/privacy_policy_screen.dart';
import '../../View/Screen/Profile/help_support_screen.dart';
import '../../View/Screen/Profile/my_addresses_screen.dart';
import '../../View/Screen/Auth/ForgotPassword/create_new_password_screen.dart';
import '../../View/Screen/Auth/ForgotPassword/forgot_password_screen.dart';
import '../../View/Screen/Auth/ForgotPassword/reset_password_otp_screen.dart';
import 'package:get/get.dart';
import '../../View/Screen/Auth/Otp/otp_screen.dart';
import '../../View/Screen/Auth/SignIn/sign_in_screen.dart';
import '../../View/Screen/Driver/ActiveDelivery/driver_active_delivery_screen.dart';
import '../../View/Screen/Driver/Nav/driver_nav_screen.dart';
import '../../View/Screen/Employee/Account/employee_account_screen.dart';
import '../../View/Screen/Employee/Cart/employee_cart_screen.dart';
import '../../View/Screen/Employee/Checkout/employee_checkout_screen.dart';
import '../../View/Screen/Employee/Detail/employee_product_detail_screen.dart';
import '../../View/Screen/Employee/Nav/employee_nav_screen.dart';
import '../../View/Screen/Employee/Orders/Detail/employee_order_detail_screen.dart';
import '../../View/Screen/Employee/Orders/employee_orders_screen.dart';

class AppRoute {
  ///==================== Authentication Routes ====================
  static const String splashScreen = '/splash_screen';
  static const String signInScreen = '/sign_in_screen';
  static const String otpScreen = '/otp_screen';
  static const String forgotPasswordScreen = '/forgot_password_screen';
  static const String resetPasswordOtpScreen = '/reset_password_otp_screen';
  static const String createNewPasswordScreen = '/create_new_password_screen';


  ///==================== Employee Routes ====================
  static const String employeeHomeScreen = '/employee_home_screen';
  static const String employeeNavScreen = '/employee_nav_screen';
  static const String employeeCartScreen = '/employee_cart_screen';
  static const String employeeCheckoutScreen = '/employee_checkout_screen';
  static const String employeeProductDetailScreen = '/employee_product_detail_screen';
  static const String employeeOrdersScreen = '/employee_orders_screen';
  static const String employeeOrderDetailScreen = '/employee_order_detail_screen';
  static const String employeeAccountScreen = '/employee_account_screen';

  ///==================== Driver Routes ====================
  static const String driverNavScreen = '/driver_nav_screen';
  static const String driverActiveDeliveryScreen = '/driver_active_delivery_screen';

  ///==================== Profile & Shared Routes ====================
  static const String editProfileScreen = '/edit_profile_screen';
  static const String notificationsScreen = '/notifications_screen';
  static const String termsAndConditionsScreen = '/terms_and_conditions_screen';
  static const String privacyPolicyScreen = '/privacy_policy_screen';
  static const String helpSupportScreen = '/help_support_screen';
  static const String myAddressesScreen = '/my_addresses_screen';


  static List<GetPage> routes = [
    /// Authentication
    GetPage(
      name: signInScreen,
      page: () => const SignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
        GetPage(
      name: forgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: resetPasswordOtpScreen,
      page: () => const ResetPasswordOtpScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: createNewPasswordScreen,
      page: () => const CreateNewPasswordScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: otpScreen,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),

    /// Employee App
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

    /// Driver App
    GetPage(
      name: driverNavScreen,
      page: () => const DriverNavScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
        /// Profile & Shared
    GetPage(
      name: editProfileScreen,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: notificationsScreen,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: termsAndConditionsScreen,
      page: () => const TermsAndConditionsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: privacyPolicyScreen,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: helpSupportScreen,
      page: () => const HelpSupportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: myAddressesScreen,
      page: () => const MyAddressesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: driverActiveDeliveryScreen,
      page: () => const DriverActiveDeliveryScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
