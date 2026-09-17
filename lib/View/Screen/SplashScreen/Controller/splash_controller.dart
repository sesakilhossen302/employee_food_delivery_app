import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Utils/AppConst/app_const.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../service/api_check.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';

class SplashController extends GetxController{





  ///<======================== This one is for the signIn ======================>


  TextEditingController signUpEmailController = TextEditingController();
  TextEditingController signUpNameController = TextEditingController();
  TextEditingController signUpPhoneController = TextEditingController();
  TextEditingController signUpPassController = TextEditingController();
  TextEditingController signUpConfirmPassController = TextEditingController();



  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPassController = TextEditingController();



  bool rememberMe = false;


  bool signInLoading = false;


  Future<void> signIn() async {
    signInLoading = true;
    update();

    Map<String, String> body = {
      'email': signInEmailController.text,
      'password': signInPassController.text,
    };

    var response = await ApiClient.postData(ApiConstant.signIn, body);

    if (response.statusCode == 200) {

      await SharePrefsHelper.setString(
          SharedPreferenceValue.role, response.body["data"]["role"]);

      await SharePrefsHelper.setString(
          AppConstants.bearerToken, response.body["data"]["accessToken"]);

      await SharePrefsHelper.setString(SharedPreferenceValue.creatorId,response.body["data"]["id"]);

      String token = await SharePrefsHelper.getString(AppConstants.bearerToken);

      print("This is the token=--=-=-=-=-=-=---=-=-=-=-${token}");

      await SharePrefsHelper.setBool(AppConstants.rememberMe, rememberMe);


      update();

      if (response.body["data"]["role"] == "CREATOR"){

        //
        //  CreatorProfileController controller=Get.find<CreatorProfileController>();
        //
        //  controller.getCreatorProfile();
        // // await SharePrefsHelper.setString(SharedPreferenceValue.creatorId, controller.creatorProfile.value.data?.id??"");
        //update();
        // String id= await SharePrefsHelper.getString(SharedPreferenceValue.creatorId);
        //
        // debugPrint("This is the id=--=-=-=-=-=-=-=-=-=-=-=-=-=${id}");

        Get.offAllNamed("");
      } else {

        Get.offAllNamed("");

      }

      signInLoading = false;

      update();
    } else {
      ApiChecker.checkApi(response);
    }
    signInLoading = false;
    update();
  }



}