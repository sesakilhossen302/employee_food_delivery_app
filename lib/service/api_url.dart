class ApiConstant {
  static const port = "/api/v1";
  
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/Web, or your machine IP for physical phone
  static const baseUrl = "http://10.0.2.2:5000";
  static const socketUrl = "http://10.0.2.2:5000";

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

  ///<=================================== Driver Flow ====================>
  static const driverActiveOrders = "$port/driver/active-orders";
  static const driverStats = "$port/driver/stats";
}
