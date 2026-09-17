import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/profile_controller.dart';

class MyAddressesScreen extends StatelessWidget {
  const MyAddressesScreen({super.key});

  void _showAddAddressDialog(BuildContext context, ProfileController controller) {
    final titleCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Add New Address', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: 'Label (e.g. Home, Work, Gym)',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: addressCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Street address & Springfield zone',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                hintText: 'Dropoff instructions (optional)',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty && addressCtrl.text.trim().isNotEmpty) {
                controller.addAddress(
                  title: titleCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  note: noteCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Save Address', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

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
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
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
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => _showAddAddressDialog(context, controller),
                icon: const Icon(Icons.add_rounded, color: AppColors.primaryAmber),
                label: Text('Add New Address', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primaryAmber)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryAmber, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
