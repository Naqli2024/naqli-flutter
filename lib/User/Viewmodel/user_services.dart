import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
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
        }
      }
    }on SocketException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please check your connection and try again.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred,Please try again.')),
        );
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
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> UserResetPassword(emailAddress: emailAddress),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An error occurred,Please try again.. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> UserForgotPasswordSuccess(),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An error occurred,Please try again.. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
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
        commonWidgets.showToast('OTP Send Successfully');
      } else {
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
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
      if (response.statusCode == 200) {
        final userData = responseBody['data']['user'];
        final userProfile = responseBody['data']['user']['userProfile'];
        final tokenData = responseBody['data'];
        if (userData != null) {
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final token = tokenData['token'] ?? '';
          final id = userData['_id'] ?? '';
          final email = userData['emailAddress'] ?? '';
          final accountType = userData['accountType'] ?? '';
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
            final message = responseBody['message'] ?? 'Login Failed';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            await saveUserData(firstName, lastName, token, id, email, accountType);
          }

        } else {
          final message = responseBody['message'] ?? 'Please try again';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        final message = responseBody['message'] ?? 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
    }
  }

  Future<List<Vehicle>> fetchUserVehicle() async {
    try {
      final String response = await rootBundle.loadString('assets/vehicles/vehicles.json');
      final Map<String, dynamic> jsonData = jsonDecode(response);

      final List<dynamic> vehiclesList = jsonData['vehicles'] ?? [];

      return vehiclesList.map((data) => Vehicle.fromJson(data)).toList();
    } catch (e) {
      commonWidgets.showToast('An error occurred, please try again.');
      return [];
    }
  }

/*  Future<List<Vehicle>> fetchUserVehicle() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}vehicles'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody.map((data) => Vehicle.fromJson(data)).toList();
      } else {
        return [];
      }
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return [];
    }
  }*/

  Future<List<Buses>> fetchUserBuses() async {
    try{
      final response = await http.get(Uri.parse('${baseUrl}buses'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody.map((data) => Buses.fromJson(data)).toList();
      } else {
        return [];
      }
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return [];
    }
  }

  Future<List<Special>> fetchUserSpecialUnits() async {
    try{
      final response = await http.get(Uri.parse('${baseUrl}special-units'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody.map((data) => Special.fromJson(data)).toList();
      } else {
        return [];
      }
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return [];
    }
  }

/*  Future<List<Equipment>> fetchUserEquipment() async {
    try{
      final response = await http.get(Uri.parse('${baseUrl}equipments'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody.map((data) => Equipment.fromJson(data)).toList();
      } else {
       commonWidgets.showToast('Failed to load equipments');
        return [];
      }
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return [];
    }
  }*/

  Future<List<Equipment>> fetchUserEquipment() async {
    try {
      final String response = await rootBundle.loadString('assets/equipments/equipments.json');
      final Map<String, dynamic> jsonData = jsonDecode(response);

      final List<dynamic> equipmentList = jsonData['equipment'] ?? [];

      return equipmentList.map((data) => Equipment.fromJson(data)).toList();
    } catch (e) {
      commonWidgets.showToast('An error occurred, please try again.');
      return [];
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
      if (response.statusCode == 201) {
        String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
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
      }
      return null;
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return null;
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
      if (response.statusCode == 201) {
        String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
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
      }
      return null;
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return null;
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
      if (response.statusCode == 201) {
        String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
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
      }
      return null;
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return null;
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
      if (response.statusCode == 201) {
        String bookingId = responseBody['_id'] ?? 'No Booking ID Found';
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
      }
      return null;
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return null;
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
        return vendors;
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return null;
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
      return null;
    }
  }


  Future<dynamic> updatePayment(String token,int amount, String status, String partnerId,String bookingId, int totalAmount,int oldQuotePrice) async {
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
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
      return null;
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
            return bookingData;
          } else {
            return [];
          }
        } else {
          return [];
        }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchBookingDetails(String id, String token) async {
    try {
      final url = Uri.parse('${baseUrl}getBookingsByBookingId/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.get(url, headers: headers);
      if (response.body.isEmpty) {
        return null;
      }

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseBody.containsKey('data')) {
          final Map<String, dynamic> bookingData = responseBody['data'];
          return bookingData;
        } else {
          return null;
        }
      }
      else if (response.statusCode == 404 && response.body.contains('Booking not found')) {
        return null;
      }
      else if (response.statusCode == 503) {
        return null;
      } else {
        return null;
      }
    } on SocketException {
     commonWidgets.showToast('No Internet connection');
      return null;
    } on FormatException {
      return null;
    } catch (e) {
     commonWidgets.showToast('An error occurred,Please try again.');
      return null;
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
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['data'] != null) {
          final partnerData = responseBody['data'];
          final partnerId = partnerData['_id'] ?? 'N/A';
          final partnerName = partnerData['partnerName'] ?? 'N/A';
          final type = partnerData['type'] ?? 'N/A';
          final operators = partnerData['operators'] ?? [];

          if (operators.isEmpty) {
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
              final message = responseBody['message'] ?? 'No Operator found';
              commonWidgets.showToast(message);
            }
          }
          return partnerDetails;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
      return [];
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
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'Please try again';
        commonWidgets.showToast(message);
      }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
      if (response.statusCode == 201) {
        try {
          final message = jsonDecode(responseBody)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } catch (e) {
          commonWidgets.showToast('An error occurred,Please try again.');
        }
      } else {
        final message = jsonDecode(responseBody)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
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
          return bookingId;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, String>>> getNotifications(String userId) async {
    try {
      final url = Uri.parse('${baseUrl}admin/getNotificationById/$userId');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseBody.containsKey('data') && responseBody['data'] != null) {
          final notifications = responseBody['data'] as List<dynamic>;
          return notifications.map((notification) {
            return {
              'messageTitle': notification['messageTitle']?.toString() ?? 'No Title',
              'messageBody': notification['messageBody']?.toString() ?? 'No Message',
              'notificationId': notification['notificationId']?.toString() ?? 'No Message',
              'seen': notification['seen']?.toString() ?? 'No Message',
            };
          }).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    }  on SocketException {
     commonWidgets.showToast('No Internet connection');
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> updateNotificationsAsSeen(List<String> notificationIds) async {
    try {
      for (var notificationId in notificationIds) {
        final response = await http.put(
          Uri.parse('https://prod.naqlee.com:443/api/admin/notifications/seen/$notificationId'),
          body: json.encode({
            'seen': true,
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        return UserDataModel.fromJson(jsonDecode(response.body));
      }
      else{
        throw Exception('Failed to load user data for user ID $userId');
      }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      throw Exception('An error occurred,Please try again.');
    }
  }

  Future<UserInvoiceModel> getUserInvoiceData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}bookings-with-invoice'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final filteredBookings = (data['bookings'] as List<dynamic>)
            .where((booking) => booking['user'] == userId)
            .toList();
        if (filteredBookings.isEmpty) {
          return UserInvoiceModel(success: true, message: 'No data found for the given user.', invoices: []);
        }

        return UserInvoiceModel(
          success: data['success'],
          message: data['message'],
          invoices: filteredBookings
              .map((booking) => Invoice.fromJson(booking))
              .toList(),
        );
      } else {
        return UserInvoiceModel(
          success: false,
          message: 'Failed to load user data for user ID $userId',
          invoices: [],
        );
      }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
      return UserInvoiceModel(
        success: false,
        message: 'Failed to load user data for user ID $userId',
        invoices: [],
      );
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
      return UserInvoiceModel(
        success: false,
        message: 'Failed to load user data for user ID $userId',
        invoices: [],
      );
    }
  }

  Future<void> updateProfile(
      String userId,
      String token,
      File? profileImage,
      String firstName,
      String lastName,
      String emailAddress,
      String password,
      String confirmPassword,
      String contactNumber,
      String address1,
      String address2,
      String city,
      String accountType,
      String govtId,
      String idNumber) async {

    final String url = 'https://prod.naqlee.com:443/api/users/edit-profile/$userId';

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $token',
        })
        ..fields['firstName'] = firstName
        ..fields['lastName'] = lastName
        ..fields['emailAddress'] = emailAddress
        ..fields['password'] = password
        ..fields['confirmPassword'] = confirmPassword
        ..fields['contactNumber'] = contactNumber
        ..fields['address1'] = address1
        ..fields['address2'] = address2
        ..fields['city'] = city
        ..fields['accountType'] = accountType
        ..fields['govtId'] = govtId
        ..fields['idNumber'] = idNumber;

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'userProfile',
          profileImage.path,
        ));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final message = jsonDecode(responseBody)['message'] as String?;
        if (message != null) {
         commonWidgets.showToast(message);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final message = jsonDecode(responseBody)['message'] as String?;
        if (message != null) {
         commonWidgets.showToast(message);
        }
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<void> postGetAnEstimate(context,{
    required String name,
    required String email,
    required String mobile,
  }) async {
    try{
      final url = Uri.parse('${baseUrl}get-an-estimate');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile
        })
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Send Successfully';
        commonWidgets.showToast(message);
      }  else {
          final message = responseBody['message'] ?? 'Failed to send';
         commonWidgets.showToast(message);
        }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred,Please try again.')),
      );
    }
  }

  Future<void> deleteUserAccount(context,String token,String userId) async {
    final String url = '${baseUrl}deleteUser';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
          body: jsonEncode({
            'userId': userId,
          })
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? responseBody;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'Please try again';
        commonWidgets.showToast(message);
      }
    } on SocketException {
      commonWidgets.showToast('No Internet connection');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }


}