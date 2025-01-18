import 'dart:convert';

import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> savePartnerData(String partnerId, String token, String partnerName, String email) async {
  try{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partnerId', partnerId);
    await prefs.setString('token', token);
    await prefs.setString('partnerName', partnerName);
    await prefs.setString('email', email);

  }
  catch (e) {
    CommonWidgets().showToast('An error occurred,Please try again.');
  }
}

Future<Map<String, String?>> getSavedPartnerData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'partnerId': prefs.getString('partnerId'),
    'token': prefs.getString('token'),
    'partnerName': prefs.getString('partnerName'),
    'email': prefs.getString('email'),
  };
}

Future<void> clearPartnerData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> saveUserData(String firstName, String lastName, String token, String id,String email, String accountType) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('token', token);
    await prefs.setString('id', id);
    await prefs.setString('email', email);
    await prefs.setString('accountType', accountType);
  } catch (e) {
    CommonWidgets().showToast('An error occurred,Please try again.');
  }
}

Future<Map<String, String?>> getSavedUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final token = prefs.getString('token');
    final id = prefs.getString('id');
    final email = prefs.getString('email');
    final accountType = prefs.getString('accountType');
    return {
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'id': id,
      'email': email,
      'accountType': accountType,
    };
  } catch (e) {
    return {};
  }
}

Future<void> saveDriverData(String firstName, String lastName, String token, String id,String partnerId,String mode) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('token', token);
    await prefs.setString('id', id);
    await prefs.setString('partnerId', partnerId);
    await prefs.setString('mode', mode);
  } catch (e) {
    CommonWidgets().showToast('An error occurred,Please try again.');
  }
}

Future<Map<String, String?>> getSavedDriverData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final token = prefs.getString('token');
    final id = prefs.getString('id');
    final partnerId = prefs.getString('partnerId');
    final mode = prefs.getString('mode');
    return {
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'id': id,
      'partnerId': partnerId,
      'mode': mode,
    };
  } catch (e) {
    return {};
  }
}


Future<void> saveBookingId(String id, String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_id', id);
    await prefs.setString('token', token);
  } catch (e) {
    CommonWidgets().showToast('An error occurred,Please try again.');
  }
}

Future<Map<String, String?>> getSavedBookingId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('_id');
    final token = prefs.getString('token');

    if (id == null || token == null) {

    } else {

    }

    return {
      '_id': id,
      'token': token,
    };
  } catch (e) {
    return {};
  }
}

Future<void> clearDriverData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}



Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
