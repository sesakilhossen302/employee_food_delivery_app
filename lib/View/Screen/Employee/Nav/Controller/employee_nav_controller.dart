import 'package:get/get.dart';

class EmployeeNavController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final RxInt cartCount = 0.obs;

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void incrementCart() {
    cartCount.value++;
  }
}
