import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> saveUserData(String partnerId, String token, String partnerName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('partnerId', partnerId);
  await prefs.setString('token', token);
  await prefs.setString('partnerName', partnerName);
}

Future<Map<String, String?>> getSavedUserData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'partnerId': prefs.getString('partnerId'),
    'token': prefs.getString('token'),
    'partnerName': prefs.getString('partnerName'),
  };
}


// Retrieve and use token and user data on app startup
Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final userDataString = prefs.getString('user_data');

  if (token != null && userDataString != null) {
    final userData = jsonDecode(userDataString);
    // Use the token and userData as needed
    print('Token: $token');
    print('User Data: $userData');
  } else {
    // Handle missing data (e.g., navigate to login)
    print('No token or user data found');
  }
}

Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
