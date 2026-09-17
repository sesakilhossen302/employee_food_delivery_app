
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../Utils/AppColors/app_colors.dart' show AppColors;
import '../custom_text/custom_text.dart' show CustomText;


class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      this.height = 48,
      this.width = double.maxFinite,
      required this.onTap,
      this.title = "",
      this.isGradiant=true,
      this.marginVerticel = 0,
      this.marginHorizontal = 0,
      this.fillColor =Colors.red,
      this.textColor = Colors.white});

  final double height;
  final double width;
  final Color fillColor;
  final Color textColor;
  final bool isGradiant;

  final VoidCallback onTap;

  final String title;

  final double marginVerticel;

  final double marginHorizontal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: marginVerticel, horizontal:marginHorizontal),
        alignment: Alignment.center,
        height: height,
        width: width,
        decoration: BoxDecoration(
              gradient:isGradiant==true? const LinearGradient(
              colors: [AppColors.yellow500, AppColors.red500], // Start and end colors
              begin: Alignment.centerLeft, // Gradient starts at top-left
              end: Alignment.centerRight, // Gradient ends at bottom-right
            ):
             LinearGradient(
              colors: [AppColors.red500,AppColors.red500], // Start and end colors
              begin: Alignment.centerLeft, // Gradient starts at top-left
              end: Alignment.centerRight, // Gradient ends at bottom-right
            ),
            borderRadius: BorderRadius.circular(8.r),

            color: fillColor

        ),
        child: CustomText(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 18,
            textAlign: TextAlign.center,
            text: title),
      ),
    );
  }
}
