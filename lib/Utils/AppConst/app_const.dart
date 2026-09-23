class AppConstants {
  static String bearerToken = "BearerToken";
  // static String userId = "UserId";
  static String onBoard = "Onboard";

  /// <====================== All Response Message Static==============================>

  static String successfull = "Request Successfull";
  static String error = "Oops, something went wrong";
  static String profileID = "profileID";
  static String userStatus = "userStatus";
  static String rememberMe = "rememberMe";
  static var chatId = "chatID";

  /// Google Maps API Key
  static const String googleMapsApiKey =
      "AIzaSyDJXC1_hT7bYHo1qQU56OOAQTjz4FPq0Ks";
}

enum Status { loading, error, completed, internetError }
