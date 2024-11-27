import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_otp.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UserService{
  static const String baseUrl = 'https://prod.naqlee.com:443/api/';

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
    try{
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserOTP(emailAddress: emailAddress,contactNumber: contactNumber)
          ),
        );
      } else {
        if (responseBody['errors'] != null && responseBody['errors'] is List) {
          for (var error in responseBody['errors']) {
            if (error['msg'] != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error['msg'])),
              );
            }
          }
        } else {
          final message = responseBody['message'] ?? 'Registration failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
        print('Failed to register user: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> verifyUserOTP(context,{
    required String otp,
  }) async {
    try{
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
                builder: (context) => VerifiedScreen(Image: 'assets/otp_verified.svg',title: 'verified'.tr(),subTitle: 'number_verified_successfully'.tr(),)
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
    }on SocketException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please check your connection and try again.')),
        );
        print('Network error: No Internet connection');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred')),
        );
        print('Error: $e');
      }
  }

  Future<void> resendUserOTP(context,{
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
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> userForgotPassword(
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
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> userForgotPasswordReset(
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
            builder: (context)=> UserForgotPasswordSuccess(),
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
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> userForgotPasswordResendOTP(context,{
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
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> userLogin(
      BuildContext context, {
        required String emailAddress,
        required String password,
      }) async {
    try {
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
        final userData = responseBody['data']['user'];
        final tokenData = responseBody['data'];
        if (userData != null) {
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final token = tokenData['token'] ?? '';
          final id = userData['_id'] ?? '';
          final email = userData['emailAddress'] ?? '';
          final accountType = userData['accountType'] ?? '';
          print(userData);

          if(accountType == 'Single User')
            {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UserType(
                    firstName: firstName,
                    lastName: lastName,
                    token: token,
                    id: id,
                    email: email,
                    accountType: accountType,
                  ),
                ),
              );
              print('Login successful');
              final message = responseBody['message'] ?? 'Login Failed';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              await saveUserData(firstName, lastName, token, id, email, accountType);
            }
          else{
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => SuperUserHomePage(
                    firstName: firstName,
                    lastName: lastName,
                    token: token,
                    id: id,
                    email: email,
                    accountType: accountType,
                ),
              ),
            );
            print('Login successful');
            final message = responseBody['message'] ?? 'Login Failed';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            await saveUserData(firstName, lastName, token, id, email, accountType);
          }

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
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }


  Future<List<Vehicle>> fetchUserVehicle() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}vehicles'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        print('Fetched vehicles: $responseBody');
        return responseBody.map((data) => Vehicle.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Buses>> fetchUserBuses() async {
    try{
      final response = await http.get(Uri.parse('${baseUrl}buses'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        print('Fetched buses: $responseBody');

        return responseBody.map((data) => Buses.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load buses');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Special>> fetchUserSpecialUnits() async {
    try{
      final response = await http.get(Uri.parse('${baseUrl}special-units'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        print('Fetched Special: $responseBody');

        return responseBody.map((data) => Special.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load special-units');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Equipment>> fetchUserEquipment() async {
    try{
      final response = await http.get(Uri.parse('${baseUrl}equipments'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        print('Fetched Equipment: $responseBody');

        return responseBody.map((data) => Equipment.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load equipments');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> userVehicleCreateBooking(
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
    try{
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
        await saveBookingId(bookingId,token);
        return bookingId;
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to create booking: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> userBusCreateBooking(
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
    try{
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
        print('Bus Booking Created successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Created successful')),
        );
        await saveBookingId(bookingId,token);
        return bookingId;
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to create booking: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> userEquipmentCreateBooking(
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
    try{
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
        print('Equipment Booking Created successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Created successful')),
        );
        await saveBookingId(bookingId,token);
        return bookingId;
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to create booking: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> userSpecialCreateBooking(
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
    try{
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
        print('Special Booking Created successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Created successful')),
        );
        await saveBookingId(bookingId,token);
        return bookingId;
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to create booking: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }


  Future<List<Map<String, dynamic>>?> userVehicleVendor(
      BuildContext context, {
        required String bookingId,
        required String unitType,
        required String unitClassification,
        required String subClassification,
      }) async {
    try{
      final url = Uri.parse('${baseUrl}partner/filtered-vendors');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'unitType': unitType,
          'unitClassification': unitClassification,
          'subClassification': subClassification,
        }),
      );

      final responseBody = jsonDecode(response.body);

      print('Full Response Body: $responseBody');

      if (response.statusCode == 200) {
        List<dynamic> data = responseBody['data'];
        List<Map<String, dynamic>> vendors = [];

        for (var item in data) {
          vendors.add({
            'partnerName': item['partnerName'],
            'partnerId': item['partnerId'],
            'quotePrice': item['quotePrice'],
            'unitType': item['unitType'],
            'unitClassification': item['unitClassification'],
            'subClassification': item['subClassification'],
            'bookingId': item['bookingId'],
            'oldQuotePrice': item['oldQuotePrice'],
            'mobileNo': item['mobileNo'],
          });
        }
        print('Fetched Vendors: $vendors');
        return vendors;
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to fetch booking: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } on SocketException {
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }


  Future<dynamic> updatePayment(String token,int amount, String status, String partnerId,String bookingId, String totalAmount,String oldQuotePrice) async {
    final url = Uri.parse('${baseUrl}bookings/$bookingId/payment');
    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'status': status,
          'partnerId': partnerId,
          'totalAmount': totalAmount,
          'oldQuotePrice': oldQuotePrice,
        }),
      );

      if (response.statusCode == 200) {
        print('Payment update successful: ${response.body}');
        return jsonDecode(response.body);  // return the decoded response
      } else {
        print('Failed to update payment: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null; // Avoid returning null, handle error properly
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  void fetchSavedPaymentBookingHistory() async {
    final data = await getSavedUserData();

    final String? id = data['id'];
    final String? token = data['token'];

    if (id != null && token != null) {
      print('Fetching details with bookingId=$id and token=$token');
      await fetchPaymentBookingHistory(id, token);
    } else {
      print('No id or token found in shared preferences.');
    }
  }

  Future<List<dynamic>> fetchPaymentBookingHistory(String id, String token) async {
    try{
      final url = Uri.parse('${baseUrl}bookings/user/$id/completed');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

          if (responseBody.containsKey('data')) {
            final List<dynamic> bookingData = responseBody['data'];
            print('Fetched booking history: $bookingData');
            print('Full Response Body: $responseBody');
            return bookingData;
          } else {
            throw Exception('Unexpected response format');
          }
        } else {
          throw Exception('Failed to load booking history: ${response.body}');
        }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  void fetchSavedBookingDetails() async {
    final data = await getSavedBookingId();

    final String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId != null && token != null) {
      print('Fetching details with bookingId=$bookingId and token=$token');
      await fetchBookingDetails(bookingId, token);
    } else {
      print('No bookingId or token found in shared preferences.');
    }
  }

  Future<Map<String, dynamic>?> fetchBookingDetails(String id, String token) async {
    try {
      final url = Uri.parse('${baseUrl}getBookingsByBookingId/$id');
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
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Map<String, dynamic>>> getPartnerData(String partnerId, String token,String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}partner/$partnerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['data'] != null) {
          final partnerData = responseBody['data'];
          print('Decoded Partner Data: $partnerData');

          final partnerId = partnerData['_id'] ?? 'N/A';
          final partnerName = partnerData['partnerName'] ?? 'N/A';
          final type = partnerData['type'] ?? 'N/A';
          final operators = partnerData['operators'] ?? [];

          if (operators.isEmpty) {
            print('No operators available for this partner.');
            return [];
          }

          final partnerDetails = <Map<String, dynamic>>[];

          for (var operator in operators) {
            if (operator['operatorsDetail'] != null && operator['operatorsDetail'].isNotEmpty) {
              final operatorDetails = operator['operatorsDetail'][0] ?? {};
              final firstName = operatorDetails['firstName'] ?? 'N/A';
              final lastName = operatorDetails['lastName'] ?? 'N/A';
              final mode = operator['unitType'] ?? 'N/A';
              final fullName = '$firstName $lastName';
              final mobileNo = operatorDetails['mobileNo'] ?? 'N/A';
              final bookingRequests = partnerData['bookingRequest'] ?? [];
              if (bookingRequests.isNotEmpty) {
                for (var booking in bookingRequests) {
                  if (booking['bookingId'] == bookingId) {
                  final bookingId = booking['bookingId']?.toString() ?? 'Unknown Booking ID';
                  final paymentStatus = booking['paymentStatus']?.toString() ?? 'Unknown Payment Status';
                  final assignedOperator = booking['assignedOperator'] ?? {};
                  final assignOperatorName = assignedOperator['operatorName']?.toString() ?? 'N/A';
                  final assignOperatorMobileNo = assignedOperator['operatorMobileNo']?.toString() ?? 'N/A';

                    print('Operator for Booking ID $bookingId: $assignOperatorName, Mobile: $assignOperatorMobileNo');
                    partnerDetails.add({
                      'type': type,
                      'assignOperatorName': assignOperatorName,
                      'assignOperatorMobileNo': assignOperatorMobileNo,
                      'partnerId': partnerId,
                      'partnerName': partnerName,
                      'mobileNo': mobileNo,
                      'operatorName': fullName,
                      'lastName': lastName,
                      'mode': mode,
                      'bookingId': bookingId,
                      'paymentStatus': paymentStatus,
                    });
                  }
                }
              } else {
                partnerDetails.add({
                  'type': type,
                  'partnerId': partnerId,
                  'partnerName': partnerName,
                  'mobileNo': mobileNo,
                  'operatorName': fullName,
                  'lastName': lastName,
                  'mode': mode,
                  'bookingId': 'No bookingId',
                  'paymentStatus': 'No paymentStatus',
                });
              }
            } else {
              print('No operator details found for operator: ${operator}');
            }
          }
          return partnerDetails;
        } else {
          print('No data field found in the response.');
          return [];
        }
      } else {
        print('Failed to load partner data: ${response.statusCode} ${response.body}');
        return [];
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet connection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }


  Future<void> deleteBooking(context,String bookingId, String token) async {
    final String url = '${baseUrl}bookings/$bookingId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? responseBody;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Delete successful: $responseBody');
      } else {
        print('Failed to delete booking: ${response.statusCode} ${response.body}');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> userSubmitTicket(BuildContext context, {
    required String reportMessage,
    required String email,
    required File? pictureOfTheReport,
  }) async {
    try {
      final url = Uri.parse('${baseUrl}report/add-report');

      var request = http.MultipartRequest('POST', url);
      request.fields['email'] = email;
      request.fields['reportMessage'] = reportMessage;

      if (pictureOfTheReport != null) {
        var fileName = basename(pictureOfTheReport.path);
        var fileBytes = await pictureOfTheReport.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'pictureOfTheReport',
            fileBytes,
            filename: fileName,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        try {
          final message = jsonDecode(responseBody)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          print('Success: $message');
        } catch (e) {
          print('Error parsing JSON: $e');
          print('Received body: $responseBody');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} - $responseBody')),
        );
        print('Failed to submit ticket: ${response.statusCode}');
        print('Response body: $responseBody');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<String?> getPaymentPendingBooking(String userId, String token) async {
    try {
      final url = Uri.parse('${baseUrl}bookings/getBookingsWithPendingPayment/$userId');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        final message = responseBody['message'];
        commonWidgets.showToast(message);

        if (responseBody.containsKey('booking')) {
          final booking = responseBody['booking'];
          final String bookingId = booking['_id'];
          print('Fetched pending bookingId: $bookingId');
          return bookingId;
        } else {
          print('No booking found in the response');
          return null;
        }
      } else {
        print('Failed to load pending booking: ${response.body}');
        return null;
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet connection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Map<String, String>>> getNotifications(String userId) async {
    try {
      final url = Uri.parse('${baseUrl}admin/getNotificationById/$userId');
      print('Fetching notifications for userId: $userId');

      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        print('API Response: $responseBody');

        if (responseBody.containsKey('data') && responseBody['data'] != null) {
          final notifications = responseBody['data'] as List<dynamic>;
          print('Notifications Data: $notifications');
          return notifications.map((notification) {
            return {
              'messageTitle': notification['messageTitle']?.toString() ?? 'No Title',
              'messageBody': notification['messageBody']?.toString() ?? 'No Message',
            };
          }).toList();
        } else {
          print('No notifications found in response');
          return [];
        }
      } else {
        print('Failed to fetch notifications, Status Code: ${response.statusCode}');
        return [];
      }
    }  on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet connection and try again.');
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<UserDataModel> getUserData(String userId, String token) async{
    try{
      final response = await http.get(Uri.parse('${baseUrl}users/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if(response.statusCode == 200){
        print('ResponseData: ${response.body}');
        final responseBody = jsonDecode(response.body);
        return UserDataModel.fromJson(jsonDecode(response.body));
      }
      else{
        throw Exception('Failed to load user data for user ID $userId');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

}