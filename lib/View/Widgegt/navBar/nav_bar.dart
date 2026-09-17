// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
//
// import '../../../Utils/AppColors/app_colors.dart' show AppColors;
// import '../../../Utils/AppIcons/app_icons.dart';
//
//


//final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


// class NavBar extends StatefulWidget {
//   final int currentIndex;
//    //bool drware=false;
//   const NavBar({required this.currentIndex, super.key});
//
//   @override
//   State<NavBar> createState() => _NavBarState();
// }
//
// class _NavBarState extends State<NavBar>{
//
//   bool drwareValue=false;
//
//   var bottomNavIndex = 0;
//   // List<String> selectedText = [
//   //   AppString.home.tr,
//   //   AppString.myCourses.tr,
//   //   AppString.profile.tr,
//   //   AppString.menu.tr,
//   //
//   //
//   List<String> unselectedIcon = [
//     AppIcons.vlepo,
//     AppIcons.search,
//     AppIcons.eventIcon,
//     AppIcons.profile,
//   ];
//
//   List<String> selectedIcon = [
//     AppIcons.vlepoActive,
//     AppIcons.searchActive,
//     AppIcons.eventActive,
//     AppIcons.profileActive,
//
//   ];
//
//   @override
//   void initState() {
//     bottomNavIndex = widget.currentIndex;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(topLeft:Radius.circular(24.r,),topRight: Radius.circular(24.r)),
//         color: Colors.white,
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.grey,
//             offset: Offset(0.0, 1.0), //(x,y)
//             blurRadius: 4,
//           ),
//         ],
//       ),
//       height: 80.h,
//       width: MediaQuery.of(context).size.width,
//       padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 8.h),
//       alignment: Alignment.center,
//       // color: AppColors.greenNormalGreen4,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(
//           unselectedIcon.length,
//           (index) => InkWell(
//             onTap: () => onTap(index),
//             child: Padding(
//               padding: const EdgeInsetsDirectional.all(2),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   //color: index == bottomNavIndex ? AppColors.black500 : null,
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ///==================== Icon ===================
//
//                     index == bottomNavIndex
//                         ? SvgPicture.asset(
//                             selectedIcon[index],
//                             height: 24.w,
//                       // colorFilter: ColorFilter.mode(AppColors.golden700,BlendMode.srcIn),
//                           )
//                         : SvgPicture.asset(
//                             unselectedIcon[index],
//                             height: 24.w,
//                           ),
//
//                     ///==================== Text ===================
//                     SizedBox(height: 8.h,),
//
//                     index==bottomNavIndex?Container(
//                     height:4.h,
//                     width: 48.w,
//                     decoration: BoxDecoration(
//                     gradient: const LinearGradient(colors:[AppColors.yellow500,AppColors.red500]),
//                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r),topRight: Radius.circular(20.r)),
//                     ),
//                     ):
//
//                     Container(
//                       height:4.h,
//                       width: 48.w,
//                       decoration:BoxDecoration(
//                       borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r),topRight: Radius.circular(20.r)),
//                       ),
//                     ),
//
//                     // CustomText(
//                     //   left: index == bottomNavIndex ? 4 : 0,
//                     //   top: 4.h,
//                     //   color:index==bottomNavIndex?AppColors.red500:Colors.transparent,
//                     //   fontSize: 10.h,
//                     //   fontWeight: FontWeight.w400,
//                     //   text: selectedText[index],
//                     // ),
//
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void onTap(int index)async{
//     // HomeController homeController = Get.find<HomeController>();
//     // homeController.scrollController.dispose();
//     if (index == 0) {
//       if (!(widget.currentIndex == 0)) {
//        Get.offAll(() => UserHomeScreen());
//       }
//     }
//     else if (index == 1) {
//       if (!(widget.currentIndex == 1)){
//           Get.offAll(() => UserSearchScreen());
//       }
//      }
//       else if (index == 2){
//       if (!(widget.currentIndex == 2)){
//         Get.offAll(() => UserEventScreen());
//         //Get.toNamed(AppRoute.studentEventScreen);
//       }
//     }
//
//     else if (index == 3) {
//       if (!(widget.currentIndex == 3)) {
//         Get.to(() =>  UserProfileScreen(),arguments: true);
//       }
//     }
//   }
// }
