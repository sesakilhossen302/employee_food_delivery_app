import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String category; // 'order', 'delivery', 'promo', 'system'
  bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final cat = (json['category'] ?? 'order').toString().toLowerCase();
    IconData icon = Icons.notifications_active_rounded;
    Color iconColor = const Color(0xFF2563EB);
    Color iconBgColor = const Color(0xFFEFF6FF);

    if (cat == 'delivery') {
      icon = Icons.delivery_dining_rounded;
      iconColor = const Color(0xFF10B981);
      iconBgColor = const Color(0xFFECFDF5);
    } else if (cat == 'order') {
      icon = Icons.storefront_rounded;
      iconColor = const Color(0xFFD97706);
      iconBgColor = const Color(0xFFFEF3C7);
    } else if (cat == 'promo') {
      icon = Icons.local_offer_rounded;
      iconColor = const Color(0xFF8B5CF6);
      iconBgColor = const Color(0xFFF3E8FF);
    }

    return AppNotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      time: json['createdAt'] != null
          ? json['createdAt'].toString().substring(0, 10)
          : 'Just now',
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      category: cat,
      isRead: json['isRead'] ?? false,
    );
  }
}

class SavedAddressModel {
  final String id;
  final String title; // 'Home', 'Work', 'Other'
  final String address;
  final String note;
  bool isDefault;

  SavedAddressModel({
    required this.id,
    required this.title,
    required this.address,
    required this.note,
    this.isDefault = false,
  });
}

class ProfileController extends GetxController {
  final RxString userName = 'Alex Johnson'.obs;
  final RxString userEmail = 'alex.johnson@quickstop.com'.obs;
  final RxString userPhone = '+1 (555) 432-8910'.obs;
  final RxString userAddress = '742 Evergreen Terr, Springfield'.obs;
  final RxString userRole = 'Customer'.obs;
  final RxString profileImagePath = ''.obs;

  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  /// Notifications List
  final RxList<AppNotificationModel> notifications = <AppNotificationModel>[
    AppNotificationModel(
      id: 'N-101',
      title: 'Order Ready for Pickup',
      message: 'Order #ORD-8921 is packed and waiting at QuickStop Gas Station.',
      time: '10 mins ago',
      icon: Icons.storefront_rounded,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFEF3C7),
      category: 'order',
      isRead: false,
    ),
    AppNotificationModel(
      id: 'N-102',
      title: 'Driver En Route',
      message: 'Driver Mike is heading to your address with your cold drinks & snacks.',
      time: '25 mins ago',
      icon: Icons.delivery_dining_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFECFDF5),
      category: 'delivery',
      isRead: false,
    ),
    AppNotificationModel(
      id: 'N-103',
      title: 'Hand Cash Remittance Reminder',
      message: 'Please remit .90 collected cash to Station #12 cashier at shift end.',
      time: '2 hours ago',
      icon: Icons.payments_rounded,
      iconColor: const Color(0xFF2563EB),
      iconBgColor: const Color(0xFFEFF6FF),
      category: 'system',
      isRead: true,
    ),
    AppNotificationModel(
      id: 'N-104',
      title: 'Fuel & Snacks Promo: 15% OFF',
      message: 'Get 15% off all bakery and bottled coffee with your next fuel stop.',
      time: '1 day ago',
      icon: Icons.local_offer_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF3E8FF),
      category: 'promo',
      isRead: true,
    ),
  ].obs;

  /// Saved Addresses List
  final RxList<SavedAddressModel> addresses = <SavedAddressModel>[
    SavedAddressModel(
      id: 'ADDR-1',
      title: 'Home',
      address: '742 Evergreen Terr, Springfield',
      note: 'Leave at front porch next to doorbell',
      isDefault: true,
    ),
    SavedAddressModel(
      id: 'ADDR-2',
      title: 'Work / Office',
      address: 'Suite 4B, 1200 Industrial Pkwy, Springfield',
      note: 'Call when arriving at reception gate',
      isDefault: false,
    ),
  ].obs;

  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final response = await ApiClient.getData(ApiConstant.notifications);
      if (response.statusCode == 200 && response.body != null && response.body['data'] is List) {
        final List list = response.body['data'];
        if (list.isNotEmpty) {
          notifications.assignAll(list.map((n) => AppNotificationModel.fromJson(n)).toList());
        }
      }
    } catch (e) {
      debugPrint('Load notifications error: $e');
    }
  }

  Future<void> loadProfileData() async {
    final savedEmail = await SharePrefsHelper.getString(SharedPreferenceValue.email);
    if (savedEmail.isNotEmpty) {
      userEmail.value = savedEmail;
    }

    final savedRole = await SharePrefsHelper.getString(SharedPreferenceValue.role);
    if (savedRole.isNotEmpty) {
      userRole.value = savedRole;
    }

    final savedName = await SharePrefsHelper.getString('saved_user_name');
    if (savedName.isNotEmpty) {
      userName.value = savedName;
    } else if (userRole.value.toLowerCase() == 'driver') {
      userName.value = 'Driver Marcus';
    }

    final savedPhone = await SharePrefsHelper.getString('saved_user_phone');
    if (savedPhone.isNotEmpty) {
      userPhone.value = savedPhone;
    }

    final savedAddress = await SharePrefsHelper.getString('saved_user_address');
    if (savedAddress.isNotEmpty) {
      userAddress.value = savedAddress;
    }

    final savedImage = await SharePrefsHelper.getString('saved_user_image');
    if (savedImage.isNotEmpty) {
      profileImagePath.value = savedImage;
    }

    // Attempt to sync from backend if authenticated
    try {
      final res = await ApiClient.getData(ApiConstant.profile);
      if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
        final data = res.body['data'];
        if (data['name'] != null && data['name'].toString().isNotEmpty) {
          userName.value = data['name'];
        }
        if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
          userPhone.value = data['phone'];
        }
        if (data['address'] != null && data['address'].toString().isNotEmpty) {
          userAddress.value = data['address'];
        }
      }
    } catch (e) {
      debugPrint('Profile sync error: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (file != null) {
        profileImagePath.value = file.path;
        await SharePrefsHelper.setString('saved_user_image', file.path);
        Fluttertoast.showToast(
          msg: 'Profile picture updated!',
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to pick image: ',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    isLoading.value = true;
    try {
      userName.value = name.trim();
      userPhone.value = phone.trim();
      userAddress.value = address.trim();

      await SharePrefsHelper.setString('saved_user_name', userName.value);
      await SharePrefsHelper.setString('saved_user_phone', userPhone.value);
      await SharePrefsHelper.setString('saved_user_address', userAddress.value);

      // Hit Backend API to persist to MongoDB database
      final payload = {
        'name': userName.value,
        'phone': userPhone.value,
        'address': userAddress.value,
      };

      await ApiClient.patchData(
        ApiConstant.updateProfile,
        jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Fluttertoast.showToast(
        msg: 'Profile updated successfully!',
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
      );

      Get.back();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update profile: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    ApiClient.patchData("${ApiConstant.notifications}/read-all", {});
    Fluttertoast.showToast(msg: 'All notifications marked as read');
  }

  void clearNotifications() {
    notifications.clear();
    Fluttertoast.showToast(msg: 'Notifications cleared');
  }

  void toggleNotificationRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = !notifications[index].isRead;
      notifications.refresh();
    }
  }

  void addAddress({
    required String title,
    required String address,
    required String note,
  }) {
    addresses.add(
      SavedAddressModel(
        id: 'ADDR-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        address: address,
        note: note,
        isDefault: addresses.isEmpty,
      ),
    );
    Fluttertoast.showToast(msg: 'Address added successfully!');
  }

  void setDefaultAddress(String id) {
    for (var a in addresses) {
      a.isDefault = (a.id == id);
    }
    addresses.refresh();
    Fluttertoast.showToast(msg: 'Default address updated');
  }

  void deleteAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    Fluttertoast.showToast(msg: 'Address removed');
  }
}
