import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Widgegt/navBar/nav_bar.dart';
import '../Account/employee_account_screen.dart';
import '../Cart/employee_cart_screen.dart';
import '../Home/Controller/employee_home_controller.dart';
import '../Home/employee_home_screen.dart';
import '../Orders/employee_orders_screen.dart';
import 'Controller/employee_nav_controller.dart';
import 'Tabs/employee_browse_screen.dart';

class EmployeeNavScreen extends StatelessWidget {
  const EmployeeNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(EmployeeNavController());
    final homeController = Get.put(EmployeeHomeController());

    final List<Widget> pages = [
      const EmployeeHomeScreen(),
      const EmployeeBrowseScreen(),
      const EmployeeCartScreen(),
      const EmployeeOrdersScreen(),
      const EmployeeAccountScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: navController.currentNavIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavBar(
          currentIndex: navController.currentNavIndex.value,
          cartCount: homeController.cartCount.value,
          onTap: (index) {
            navController.changeNavIndex(index);
          },
        ),
      ),
    );
  }
}
