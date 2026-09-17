import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/profile_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1F2937)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            onSelected: (val) {
              if (val == 'read_all') {
                controller.markAllNotificationsAsRead();
              } else if (val == 'clear_all') {
                controller.clearNotifications();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all_rounded, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8.w),
                    Text('Mark all as read', style: GoogleFonts.inter(fontSize: 13.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 8.w),
                    Text('Clear all', style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.notifications_off_outlined, color: Color(0xFF2563EB), size: 36),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Notifications Yet',
                  style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                ),
                SizedBox(height: 6.h),
                Text(
                  'You will receive real-time order and delivery updates here',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          itemCount: controller.notifications.length,
          separatorBuilder: (ctx, i) => SizedBox(height: 10.h),
          itemBuilder: (ctx, index) {
            final item = controller.notifications[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleNotificationRead(item.id),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: item.isRead ? Colors.white : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: item.isRead ? const Color(0xFFF3F4F6) : const Color(0xFFFDE68A),
                      width: item.isRead ? 1 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: item.iconBgColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Icon(item.icon, color: item.iconColor, size: 22),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryAmber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.message,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xFF4B5563),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              item.time,
                              style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
