import 'package:get/get.dart';
import '../../global/controller/generelController.dart' show GeneralController;

class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GeneralController(), fenix: true);
  }
}
