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
  final double? lat;
  final double? lng;
  bool isDefault;

  SavedAddressModel({
    required this.id,
    required this.title,
    required this.address,
    required this.note,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Home',
      address: json['address'] ?? '',
      note: json['instructions'] ?? json['note'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'instructions': note,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }
}

class ProfileController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;
  final RxString userRole = 'Customer'.obs;
  final RxString profileImagePath = ''.obs;

  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  /// Live Notifications from Backend API (Zero static data)
  final RxList<AppNotificationModel> notifications = <AppNotificationModel>[].obs;

  /// Live Saved Addresses from Backend API (Zero static data)
  final RxList<SavedAddressModel> addresses = <SavedAddressModel>[].obs;

  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
    loadNotifications();
    loadAddresses();
  }

  Future<void> loadNotifications() async {
    try {
      final response = await ApiClient.getData(ApiConstant.notifications);
      if (response.statusCode == 200 && response.body != null && response.body['data'] is List) {
        final List list = response.body['data'];
        notifications.assignAll(list.map((n) => AppNotificationModel.fromJson(n)).toList());
      }
    } catch (e) {
      debugPrint('Load notifications error: $e');
    }
  }

  Future<void> loadAddresses() async {
    try {
      // 1. Load from local cache first for instant response
      final cachedStr = await SharePrefsHelper.getString('cached_user_addresses');
      if (cachedStr.isNotEmpty) {
        final List decoded = jsonDecode(cachedStr);
        addresses.assignAll(decoded.map((a) => SavedAddressModel.fromJson(a)).toList());
      }
      
      // 2. Sync from backend
      final response = await ApiClient.getData(ApiConstant.address);
      if (response.statusCode == 200 && response.body != null && response.body['data'] is List) {
        final List list = response.body['data'];
        addresses.assignAll(list.map((a) => SavedAddressModel.fromJson(a)).toList());
        await SharePrefsHelper.setString('cached_user_addresses', jsonEncode(addresses.map((a) => a.toJson()).toList()));
      }
    } catch (e) {
      debugPrint('Load addresses note: $e');
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

  Future<void> addAddress({
    required String title,
    required String address,
    required String note,
    double? lat,
    double? lng,
  }) async {
    final newAddr = SavedAddressModel(
      id: 'ADDR-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      address: address,
      note: note,
      lat: lat,
      lng: lng,
      isDefault: addresses.isEmpty,
    );

    // If new address is set as default, mark others false
    if (newAddr.isDefault) {
      for (var a in addresses) {
        a.isDefault = false;
      }
    }

    addresses.add(newAddr);
    addresses.refresh();

    // Save to local cache
    await SharePrefsHelper.setString(
      'cached_user_addresses',
      jsonEncode(addresses.map((a) => a.toJson()).toList()),
    );

    final payload = {
      'title': title,
      'address': address,
      'instructions': note,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };

    try {
      final res = await ApiClient.postData(ApiConstant.address, payload);
      if (res.statusCode == 200 && res.body != null && res.body['data'] is List) {
        final List list = res.body['data'];
        addresses.assignAll(list.map((a) => SavedAddressModel.fromJson(a)).toList());
        await SharePrefsHelper.setString(
          'cached_user_addresses',
          jsonEncode(addresses.map((a) => a.toJson()).toList()),
        );
      }
      Fluttertoast.showToast(msg: 'Address saved successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Address saved!');
    }
  }

  void setDefaultAddress(String id) {
    for (var a in addresses) {
      a.isDefault = (a.id == id);
    }
    addresses.refresh();
    SharePrefsHelper.setString(
      'cached_user_addresses',
      jsonEncode(addresses.map((a) => a.toJson()).toList()),
    );
    Fluttertoast.showToast(msg: 'Default address updated');
  }

  void deleteAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    addresses.refresh();
    SharePrefsHelper.setString(
      'cached_user_addresses',
      jsonEncode(addresses.map((a) => a.toJson()).toList()),
    );
    Fluttertoast.showToast(msg: 'Address removed');
  }
}
