import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static const port = "/api/v1";
  
  // Reads from .env (API_BASE_URL) or defaults to local machine IP for physical device connection
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.trim().isNotEmpty) return envUrl.trim();
    return "http://10.10.26.202:5000";
  }

  static String get socketUrl {
    final envSocket = dotenv.env['API_SOCKET_URL'] ?? dotenv.env['API_BASE_URL'];
    if (envSocket != null && envSocket.trim().isNotEmpty) return envSocket.trim();
    return "http://10.10.26.202:5000";
  }

  ///<=================================== Auth & Gmail OTP ====================>
  static const signIn = "$port/auth/login";
  static const signUp = "$port/auth/register";
  static const sendOtp = "$port/auth/send-otp";
  static const verifyOtp = "$port/auth/verify-otp";
  static const forgotPassword = "$port/auth/forgot-password";
  static const resetPassword = "$port/auth/reset-password";
  static const guestCheckout = "$port/auth/guest-checkout";
  static const profile = "$port/auth/me";
  static const updateProfile = "$port/auth/profile";
  static const address = "$port/auth/address";
  static const notifications = "$port/notifications";

  ///<=================================== Store Catalog & Home ====================>
  static const storeHome = "$port/store/home";
  static const storeSettings = "$port/store/settings";
  static const categories = "$port/categories";
  static const products = "$port/products";

  ///<=================================== Delivery & Pricing ====================>
  static const checkDeliveryArea = "$port/delivery/check-area";
  static const calculatePricing = "$port/delivery/calculate-pricing";

  ///<=================================== Orders ====================>
  static const createOrder = "$port/orders";
  static const orders = "$port/orders";
  static String orderTracking(String id) => "$port/orders/$id/tracking";

  ///<=================================== Driver Flow ====================>
  static const driverActiveOrders = "$port/driver/active-orders";
  static const driverStats = "$port/driver/stats";
}
