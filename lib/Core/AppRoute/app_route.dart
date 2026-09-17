import 'package:get/get.dart';
import '../../View/Screen/Auth/SignIn/sign_in_screen.dart';

class AppRoute {
  ///==================== Initial Routes ====================
  static const String splashScreen = '/splash_screen';
  static const String signInScreen = '/sign_in_screen';

  static List<GetPage> routes = [
    ///==================== Authentication Routes ====================
    GetPage(
      name: signInScreen,
      page: () => const SignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
  ];
}
