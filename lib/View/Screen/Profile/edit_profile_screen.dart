import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: controller.userName.value);
    phoneController = TextEditingController(text: controller.userPhone.value);
    addressController = TextEditingController(text: controller.userAddress.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Profile Photo',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text('Take Photo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Use camera to capture photo', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                ),
                title: Text('Choose from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Select an image from your device', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Profile Avatar with Edit Badge
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final path = controller.profileImagePath.value;
                      final hasLocalImage = path.isNotEmpty && File(path).existsSync();

                      return Container(
                        width: 104.w,
                        height: 104.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFEF3C7),
                          border: Border.all(color: Colors.white, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasLocalImage
                              ? Image.file(
                                  File(path),
                                  width: 104.w,
                                  height: 104.w,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    controller.userName.value.isNotEmpty
                                        ? controller.userName.value[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.inter(
                                      fontSize: 38.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAmber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Tap camera icon to change photo',
                style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
              ),
              SizedBox(height: 28.h),

              /// Fields Container
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Full Name Field
                    _buildFieldLabel('Full Name'),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: nameController,
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      decoration: _buildInputDecoration(
                        hint: 'Enter your name',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    SizedBox(height: 18.h),

                    /// Email Address (Disabled / Read-only)
                    _buildFieldLabel('Email Address (Registered)'),
                    SizedBox(height: 6.h),
                    Obx(() => TextFormField(
                      initialValue: controller.userEmail.value,
                      readOnly: true,
                      style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                      decoration: _buildInputDecoration(
                        hint: 'Email address',
                        prefixIcon: Icons.email_outlined,
                        suffixIcon: Icons.lock_outline_rounded,
                        isReadOnly: true,
                      ),
                    )),
                    SizedBox(height: 18.h),

                    /// Phone Number Field
                    _buildFieldLabel('Phone Number'),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      decoration: _buildInputDecoration(
                        hint: 'Enter phone number',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
                    ),
                    SizedBox(height: 18.h),

                    /// Delivery Address / Primary Location
                    _buildFieldLabel('Default Address / Station Base'),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      decoration: _buildInputDecoration(
                        hint: 'Enter primary address',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your address' : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              /// Save Changes Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            controller.updateProfile(
                              name: nameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool isReadOnly = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFFD1D5DB), size: 18) : null,
      filled: true,
      fillColor: isReadOnly ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primaryAmber, width: 1.5),
      ),
    );
  }
}
