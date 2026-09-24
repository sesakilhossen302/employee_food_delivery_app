import 'location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/profile_controller.dart';
import '../../../../Core/AppRoute/app_route.dart';

class MyAddressesScreen extends StatelessWidget {
  const MyAddressesScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'My Addresses',
          style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.loadAddresses,
          color: AppColors.primaryAmber,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              if (controller.addresses.isEmpty) ...[
                SizedBox(height: 40.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_off_rounded, color: Color(0xFFD97706), size: 28),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'No Saved Addresses Yet',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Add your home, office, or frequently visited addresses for quick delivery checkout.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ] else ...[
                ...controller.addresses.map((addr) => Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: addr.isDefault ? AppColors.primaryAmber : const Color(0xFFF3F4F6),
                      width: addr.isDefault ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: addr.isDefault ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: addr.isDefault ? const Color(0xFFD97706) : const Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(addr.title, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                                if (addr.isDefault) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text('Default', style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFFD97706))),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(addr.address, style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF4B5563))),
                            if (addr.note.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text('Note: ${addr.note}', style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF9CA3AF), fontStyle: FontStyle.italic)),
                            ],
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                if (!addr.isDefault)
                                  GestureDetector(
                                    onTap: () => controller.setDefaultAddress(addr.id),
                                    child: Text('Set as default', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primaryAmber)),
                                  ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => controller.deleteAddress(addr.id),
                                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Get.to(() => const LocationPickerScreen());
                    controller.loadAddresses();
                  },
                  icon: const Icon(Icons.add_rounded, color: AppColors.primaryAmber),
                  label: Text('Add New Address', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primaryAmber)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryAmber, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
