import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_otp.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_naqli/user_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            builder: (context) => UserType(firstName: firstName,lastName: lastName,token: token,),
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
      return responseBody.map((data) => Vehicle.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<List<Buses>> fetchUserBuses() async {
    final response = await http.get(Uri.parse('${baseUrl}buses'));

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      print('Fetched buses: $responseBody');

      return responseBody.map((data) => Buses.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load buses');
    }
  }

  Future<List<Special>> fetchUserSpecialUnits() async {
    final response = await http.get(Uri.parse('${baseUrl}special-units'));

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      print('Fetched Special: $responseBody');

      return responseBody.map((data) => Special.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load special-units');
    }
  }

  Future<List<Equipment>> fetchUserEquipment() async {
    final response = await http.get(Uri.parse('${baseUrl}equipments'));

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      print('Fetched Equipment: $responseBody');

      return responseBody.map((data) => Equipment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load equipments');
    }
  }

  Future<void> userVehicleCreateBooking(
      BuildContext context, {
        required String name,
        required String unitType,
        required String typeName,
        required String scale,
        required String typeImage,
        required String typeOfLoad,
        required String date,
        required String additionalLabour,
        required String time,
        required String productValue,
        required String pickup,
        required List dropPoints,
        required String token,
      }) async {
    final url = Uri.parse('${baseUrl}bookings');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'unitType': unitType,
        'type':{
          'typeName': typeName,
          'scale': scale,
          'typeImage': typeImage,
          'typeOfLoad': typeOfLoad,
        },
        'date': date,
        'additionalLabour': additionalLabour,
        'time': time,
        'productValue': productValue,
        'pickup': pickup,
        'dropPoints': dropPoints,
      }),
    );

    final responseBody = jsonDecode(response.body);

    print('Full Response Body: $responseBody');

    if (response.statusCode == 201) {
      String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
      print(' Vehicle Booking Created successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Created successful')),
      );
      CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChooseVendor(
                bookingId: bookingId??'',
                size: scale,
                unitType: unitType,
                load: typeOfLoad,
                unit: name,
                pickup: pickup,
                dropPoints: dropPoints,
                token: token
              )
          ),
        );
      });
    } else {
      final message = responseBody['message'] ?? 'Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to create booking: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> userBusCreateBooking(
      BuildContext context, {
        required String name,
        required String unitType,
        required String image,
        required String date,
        required String additionalLabour,
        required String time,
        required String productValue,
        required String pickup,
        required List dropPoints,
        required String token,
      }) async {
    final url = Uri.parse('${baseUrl}bookings');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'unitType': unitType,
        'image': image,
        'date': date,
        'additionalLabour': additionalLabour,
        'time': time,
        'productValue': productValue,
        'pickup': pickup,
        'dropPoints': dropPoints,
      }),
    );

    final responseBody = jsonDecode(response.body);

    print('Full Response Body: $responseBody');

    if (response.statusCode == 201) {
      String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
      CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
      print('Bus Booking Created successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Created successful')),
      );
    } else {
      final message = responseBody['message'] ?? 'Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to create booking: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> userEquipmentCreateBooking(
      BuildContext context, {
        required String name,
        required String unitType,
        required String typeName,
        required String typeImage,
        required String date,
        required String additionalLabour,
        required String fromTime,
        required String toTime,
        required String cityName,
        required String address,
        required String zipCode,
        required String token,
      }) async {
    final url = Uri.parse('${baseUrl}bookings');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'unitType': unitType,
        'type':{
          'typeName': typeName,
          'typeImage': typeImage,
        },
        'date': date,
        'additionalLabour': additionalLabour,
        'fromTime': fromTime,
        'toTime': toTime,
        'cityName': cityName,
        'address': address,
        'zipCode': zipCode,
      }),
    );

    final responseBody = jsonDecode(response.body);

    print('Full Response Body: $responseBody');

    if (response.statusCode == 201) {
      String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
      CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
      print('Equipment Booking Created successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Created successful')),
      );
    } else {
      final message = responseBody['message'] ?? 'Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to create booking: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> userSpecialCreateBooking(
      BuildContext context, {
        required String name,
        required String unitType,
        required String image,
        required String date,
        required String additionalLabour,
        required String fromTime,
        required String toTime,
        required String cityName,
        required String address,
        required String zipCode,
        required String token,
      }) async {
    final url = Uri.parse('${baseUrl}bookings');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'unitType': unitType,
        'image': image,
        'date': date,
        'additionalLabour': additionalLabour,
        'fromTime': fromTime,
        'toTime': toTime,
        'cityName': cityName,
        'address': address,
        'zipCode': zipCode,
      }),
    );

    final responseBody = jsonDecode(response.body);

    print('Full Response Body: $responseBody');

    if (response.statusCode == 201) {
      String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
      CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
      print('Special Booking Created successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Created successful')),
      );
    } else {
      final message = responseBody['message'] ?? 'Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to create booking: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }


}