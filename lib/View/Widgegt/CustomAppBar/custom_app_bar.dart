// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:naftali/Utils/AppIcons/app_icons.dart';
// import 'package:naftali/View/Widgegt/custom_text/custom_text.dart';
// import '../../../utils/AppColors/app_colors.dart';
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final double height;
//
//   CustomAppBar({
//     super.key,
//     required this.child,
//     required this.title,
//     this.action = false,
//     this.onAction,
//     this.height = 90.0,
//   });
//
//   /// Implement the preferredSize getter
//
//   @override
//   Size get preferredSize => Size.fromHeight(height);
//   Widget child;
//   String title;
//   bool action = false;
//   void Function()? onAction;
//   @override
//   Widget build(BuildContext context) {
//     return PreferredSize(
//       preferredSize: Size.fromHeight(height),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(28.0),
//           bottomRight: Radius.circular(28.0),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.white50, // Background color for the app bar
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.black200.withOpacity(0.8), // Shadow color
//                 spreadRadius: 0, // Spread of shadow
//                 blurRadius: 4, // Blur radius
//                 offset: const Offset(0, 2), // Offset in x and y direction
//               ),
//             ],
//           ),
//           child: AppBar(
//             actions: [
//               action == true
//                   ? IconButton(
//                       onPressed: onAction,
//                       icon: SvgPicture.asset(
//                         AppIcons.editBannerIcon,
//                         height: 32.h,
//                         width: 32.w,
//                       ))
//                   : SizedBox(),
//             ],
//             leading: AppBar(
//               backgroundColor: AppColors.white50,
//             ),
//             centerTitle: true,
//             title: CustomText(
//               text: title,
//               fontWeight: FontWeight.w500,
//               fontSize: 16,
//               color: AppColors.navy500,
//             ),
//             elevation: 0, // Remove default shadow if using custom BoxShadow
//             backgroundColor: AppColors
//                 .white50, // Set to transparent since Container has color
//             automaticallyImplyLeading: false,
//             toolbarHeight: 60,
//             flexibleSpace: Align(
//               alignment: AlignmentDirectional.bottomEnd,
//               child: Padding(
//                   padding:
//                       const EdgeInsets.only(top: 85.0, left: 16.0, right: 16.0),
//                   child: child),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
