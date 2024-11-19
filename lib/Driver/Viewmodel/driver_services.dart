import 'dart:convert';
import 'dart:io';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_forgotPassword.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DriverService{
  static const String baseUrl = 'https://naqli.onrender.com/api/partner/';

  Future<void> driverLogin(
      BuildContext context, {
        required String email,
        required String password,
      }) async {
    try {
      final url = Uri.parse('${baseUrl}operator-login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      print('Full Response Body: $responseBody');

      if (response.statusCode == 200) {
        print('Login successful');
        final message = responseBody['message'] ?? 'Login Failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        final driverData = responseBody['data']['operator'];
        final tokenData = responseBody['data'];

        if (driverData != null) {
          final firstName = driverData['firstName'] ?? '';
          final lastName = driverData['lastName'] ?? '';
          final mode = driverData['mode'] ?? '';
          final token = tokenData['token'] ?? '';
          final operatorId = driverData['_id'] ?? '';
          final partnerId = tokenData['associatedPartnerId'] ?? '';
          print(driverData);
          await driverMode(context, partnerId: partnerId, operatorId: operatorId, mode: mode);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverHomePage(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: operatorId,partnerId: partnerId,mode: mode,)));
          await saveDriverData(firstName, lastName, token, operatorId,partnerId,mode);
        } else {
          print('Driver data is null');
        }
      } else {
        final message = responseBody['message'] ?? 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to login driver: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please try again...')),
      );
      print('Error: $e');
    }
  }

  Future<void> driverForgotPassword(
      BuildContext context, {
        required String emailAddress,
      }) async {
    try{
      final url = Uri.parse('${baseUrl}forgot-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailAddress': emailAddress,
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Success');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> DriverResetPassword(emailAddress: emailAddress),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An unexpected error occurred. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to send OTP: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      print('Error: $e');
    }
  }

  Future<void> driverForgotPasswordReset(
      BuildContext context, {
        required String otp,
        required String newPassword,
        required String confirmNewPassword,
      }) async {
    try{
      final url = Uri.parse('${baseUrl}verify-otp-update-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp': otp,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Success');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> DriverForgotPasswordSuccess(),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An unexpected error occurred. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to Reset Pwd: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      print('Error: $e');
    }
  }

  Future<void> driverForgotPasswordResendOTP(context,{
    required String emailAddress,
  }) async {
    try{
      final url = Uri.parse('${baseUrl}resend-otp');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailAddress': emailAddress,
        }),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Success');
        Fluttertoast.showToast(
          msg: 'OTP Send Successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to register user: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      print('Error: $e');
    }
  }

  Future<void> driverMode(
      BuildContext context, {
        required String partnerId,
        required String operatorId,
        required String mode,
      }) async {
    try {
      final url = Uri.parse('${baseUrl}updateOperatorMode');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'partnerId': partnerId,
          'operatorId': operatorId,
          'mode': mode,
        }),
      );

      final responseBody = jsonDecode(response.body);

      print('Full Response Body: $responseBody');

      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to update: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please try again...')),
      );
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>?> driverRequest(
      BuildContext context, {
        required String operatorId,
      }) async {
    try {
      final url = Uri.parse('${baseUrl}getBookingRequest');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'operatorId': operatorId,
        }),
      );

      final responseBody = jsonDecode(response.body);
      print('Full Response Body: $responseBody');

      if (response.statusCode == 200) {
        // final message = responseBody['message'] ?? 'Request successful';
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(message)),
        // );
        return responseBody; // Return the response body on success
      } else {
        final message = responseBody['message'] ?? 'No Booking request found';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to update: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null; // Return null for errors
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
      return null; // Return null on network error
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please try again...')),
      );
      print('Error: $e');
      return null; // Return null for other errors
    }
  }

  Future<Map<String, dynamic>?> fetchBookingDetails(String id, String token) async {
    try {
      final url = Uri.parse('https://naqli.onrender.com/api/getBookingsByBookingId/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('Fetching from URL: ${url.toString()}');

      final response = await http.get(url, headers: headers);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseBody.containsKey('data')) {
          final Map<String, dynamic> bookingData = responseBody['data'];
          print('Booking Data: $bookingData');
          return bookingData;
        } else {
          throw Exception('Unexpected response format: $responseBody');
        }
      }
      else if (response.statusCode == 404 && response.body.contains('Booking not found')) {
        print('Booking not found');
        return null;
      }
      else if (response.statusCode == 503) {
        print('Service unavailable. Please try again later.');
        throw Exception('Service is temporarily unavailable. Please try again later.');
      } else {
        throw Exception('Failed to load booking details. Status code: ${response.statusCode}, Response body: ${response.body}');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet connection and try again.');
    } on FormatException {
      print('An error occurred: Invalid JSON format or empty response body.');
      throw Exception('Invalid response format or empty response body.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String?> getUserName(String userId, String token) async {
    try{
      final response = await http.get(
        Uri.parse('https://naqli.onrender.com/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Check if 'data' exists and contains 'firstName' and 'lastName'
        if (responseBody != null) {
          final firstName = responseBody['firstName'] ?? '';
          final lastName = responseBody['lastName'] ?? '';

          if (firstName.isNotEmpty && lastName.isNotEmpty) {
            print('token: $token');
            print('User name: $firstName $lastName');
            return '$firstName $lastName';
          } else {
            print("First name or last name is not available.");
            return null;
          }
        } else {
          print("Response body does not contain user data.");
          return null;
        }
      } else if (response.statusCode == 401) {
        print("Authorization failed for user ID $userId: ${response.body}");
        throw Exception('Authorization failed');
      } else {
        print('Failed to load user data: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load user data for user ID $userId');
      }
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }


  Future<void> driverCompleteOrder(
      BuildContext context, {
        required String bookingId,
        required bool status,
        required String token,
      }) async {
    try {
      final url = Uri.parse('https://naqli.onrender.com/api/bookings/update-booking-status');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "bookingId": bookingId,
          "status": status,
        }),
      );
        print(status);
      final responseBody = jsonDecode(response.body);

      print('Full Response Body: $responseBody');

      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to update: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please try again...')),
      );
      print('Error: $e');
    }
  }

}