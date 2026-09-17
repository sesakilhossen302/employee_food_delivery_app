import 'package:get/get.dart';
import '../Utils/AppConst/app_const.dart' show AppConstants;
import '../helper/shared_prefe/shared_prefe.dart' show SharePrefsHelper;


class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) async {
    if (response.statusCode == 401) {
      await SharePrefsHelper.remove(AppConstants.bearerToken);
      //Get.offAllNamed(AppRoute.signInScreen);
    } else {
      //showCustomSnackBar(response.statusText!, getXSnackBar: getXSnackBar);
    }
  }
}
