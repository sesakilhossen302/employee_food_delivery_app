import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:employee_food_delivery_app/View/Widgegt/DeviceUtils/device_utils.dart';
import 'package:get/get.dart';

import 'Core/AppRoute/app_route.dart';
import 'Core/Dependency/dependency.dart';
import 'service/socket_service.dart';

void main() {


  WidgetsFlutterBinding.ensureInitialized();
  DeviceUtils.lockDevicePortrait();
  DependencyInjection di = DependencyInjection();
  SocketApi.init();
  di.dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
    child:GetMaterialApp(
    debugShowCheckedModeBanner:false,
    // locale: const Locale("en","US"),
    // translations: Language(),
    defaultTransition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
    initialRoute:AppRoute.splashScreen,
    navigatorKey: Get.key,
    getPages:AppRoute.routes,
    )
    );
  }
}

