import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../Utils/AppIcons/app_icons.dart' show AppIcons;
import '../custom_text/custom_text.dart' show CustomText;

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.title = 'Back'});
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Row(
        children: [
          SvgPicture.asset(AppIcons.customBackArrow),
          CustomText(text: title, fontWeight: FontWeight.w500, fontSize: 16, left: 8.w),
        ],
      ),
    );
  }
}
