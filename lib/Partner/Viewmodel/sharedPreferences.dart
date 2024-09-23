import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> savePartnerData(String partnerId, String token, String partnerName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('partnerId', partnerId);
  await prefs.setString('token', token);
  await prefs.setString('partnerName', partnerName);
}

Future<Map<String, String?>> getSavedPartnerData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'partnerId': prefs.getString('partnerId'),
    'token': prefs.getString('token'),
    'partnerName': prefs.getString('partnerName'),
  };
}

Future<void> clearPartnerData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> saveUserData(String firstName, String lastName, String token, String id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('token', token);
    await prefs.setString('id', id);
    print('Data saved: firstName=$firstName, lastName=$lastName, token=$token, id=$id');
  } catch (e) {
    print('Error saving data: $e');
  }
}

Future<Map<String, String?>> getSavedUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final token = prefs.getString('token');
    final id = prefs.getString('id');

    // Debugging
    print('Data retrieved: firstName=$firstName, lastName=$lastName, token=$token, id=$id');

    return {
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'id': id,
    };
  } catch (e) {
    print('Error retrieving data: $e');
    return {};
  }
}

Future<void> saveDriverData(String firstName, String lastName, String token, String id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('token', token);
    await prefs.setString('id', id);
    print('Data saved: firstName=$firstName, lastName=$lastName, token=$token, id=$id');
  } catch (e) {
    print('Error saving data: $e');
  }
}

Future<Map<String, String?>> getSavedDriverData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final token = prefs.getString('token');
    final id = prefs.getString('id');

    // Debugging
    print('Data retrieved: firstName=$firstName, lastName=$lastName, token=$token, id=$id');

    return {
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'id': id,
    };
  } catch (e) {
    print('Error retrieving data: $e');
    return {};
  }
}


Future<void> saveBookingId(String id, String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_id', id);
    await prefs.setString('token', token);
    print('Data saved: id=$id, token: $token');
  } catch (e) {
    print('Error saving data: $e');
  }
}

Future<Map<String, String?>> getSavedBookingId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('_id');
    final token = prefs.getString('token');

    if (id == null || token == null) {
      print('No data found for bookingId or token');
    } else {
      print('Data retrieved: _id=$id, token=$token');
    }

    return {
      '_id': id,
      'token': token,
    };
  } catch (e) {
    print('Error retrieving data: $e');
    return {};
  }
}

Future<void> clearDriverData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print('SharedPreferences cleared.');
}



Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print('SharedPreferences cleared.');
}
