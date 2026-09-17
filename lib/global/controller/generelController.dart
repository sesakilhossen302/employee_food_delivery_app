import 'dart:io';
import 'package:flutter/material.dart';
import 'package:employee_food_delivery_app/View/Widgegt/custom_loader/custom_loader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';



class GeneralController extends GetxController {
  ///========================== Show Popup Loader ========================
  showPopUpLoader() {
    return showDialog(
        barrierColor: Colors.transparent,
        context: Get.context!,
        builder: (_) {
          return const SizedBox(
            height: 70,
            child:AlertDialog(
              elevation:0,
              backgroundColor: Colors.transparent,
              content: CustomLoader(),
            ),
          );
        });
  }

  ///========================== Pick Image ========================
  Rx<File> imageFile = File("").obs;
  RxString imagePath = "".obs;
  selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? getImages =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 15);
    refresh();
    if (getImages != null) {
      imageFile.value = File(getImages.path);
      imagePath.value = getImages.path;
    }
  }

  // RxString chatId="".obs;
  //
  // createChatId() async {
  //    String id=await SharePrefsHelper.getString(AppConstants.bearerToken);
  //
  //   //if(chatId==null && chatId.isEmpty==true){
  //
  //   // }
  //   if(id!=null || id.isNotEmpty==true) {
  //     var response = await ApiClient.postData(
  //         ApiConstant.creatChat,{}
  //     );
  //     if (response.statusCode == 200) {
  //       await SharePrefsHelper.setString(
  //           AppConstants.chatId, response.body["data"]["_id"]);
  //       print(
  //           " this is my chatId============      =============================${response
  //               .body["data"]["_id"]}");
  //       chatId.value = response.body["data"]["_id"];
  //       refresh();
  //     } else {
  //       ApiChecker.checkApi(response);
  //     }
  //   }
  // }

  @override
  void onInit() {
    //createChatId();
    // print("This is my chat ID: =-=-==--=-=-===-=-=-=-==-   ${chatId.value}");
    super.onInit();
  }
}
