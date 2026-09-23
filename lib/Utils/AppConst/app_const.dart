import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Google Maps API Key loaded securely from .env (Not public / not hardcoded)
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ??
      const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
}

enum Status { loading, error, completed, internetError }
