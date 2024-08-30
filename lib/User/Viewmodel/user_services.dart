import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_otp.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/user_home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UserService{
  static const String baseUrl = 'https://naqli.onrender.com/api/';

  Future<void> userRegister(context,{
    required String firstName,
    required String lastName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
    required String contactNumber,
    required String alternateNumber,
    required String address1,
    required String address2,
    required String city,
    required String accountType,
    required String govtId,
    required String idNumber,
  }) async {
    final url = Uri.parse('${baseUrl}register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'emailAddress': emailAddress,
        'password': password,
        'confirmPassword': confirmPassword,
        'contactNumber': contactNumber,
        'alternateNumber': alternateNumber,
        'address1': address1,
        'address2': address2,
        'city': city,
        'accountType': accountType,
        'govtId': govtId,
        'idNumber': idNumber,
      }),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserOTP(emailAddress: emailAddress,contactNumber: contactNumber)
        ),
      );
    } else {
      final message = responseBody['message'] ?? responseBody;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to register user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> verifyUserOTP(context,{
    required String otp,
  }) async {
    if (otp.length == 6) {
      final url = Uri.parse('${baseUrl}verify-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp': otp,
        }),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Success');
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserLogin()
            ),
          );
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SuccessScreen(Image: 'assets/otp_verified.svg',title: 'Verified',subTitle: 'Your number have been verified successfully',)
          ),
        );
      } else {
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to register user: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  Future<void> resendUserOTP(context,{
    required String emailAddress,
  }) async {
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
  }

  Future<void> userForgotPassword(
      BuildContext context, {
        required String emailAddress,
      }) async {
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
          builder: (context)=> UserResetPassword(emailAddress: emailAddress),
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
  }

  Future<void> userForgotPasswordReset(
      BuildContext context, {
        required String otp,
        required String newPassword,
        required String confirmNewPassword,
      }) async {
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
          builder: (context)=> UserLogin(),
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
  }

  Future<void> userForgotPasswordResendOTP(context,{
    required String emailAddress,
  }) async {
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
  }

  Future<void> userLogin(
      BuildContext context, {
        required String emailAddress,
        required String password,
      }) async {
    final url = Uri.parse('${baseUrl}login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'emailAddress': emailAddress,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    print('Full Response Body: $responseBody');

    if (response.statusCode == 200) {
      print('Login successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      final userData = responseBody['data']['user'];
      final tokenData = responseBody['data'];

      if (userData != null) {
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final token = tokenData['token'] ?? '';
        final id = userData['_id'] ?? '';

        print(userData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserType(firstName: firstName,lastName: lastName,),
          ),
        );
        await saveUserData(firstName,lastName, token, id);
      } else {
        print('User data is null');
      }
    } else {
      final message = responseBody['message'] ?? 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to login user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<List<Vehicle>> fetchUserVehicle() async {
    final response = await http.get(Uri.parse('${baseUrl}vehicles'));

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      print('Fetched vehicles: $responseBody'); // Debug statement
      // Convert List<dynamic> to List<Vehicle>
      return responseBody.map((data) => Vehicle.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }


}