import 'dart:convert';
import 'dart:io';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_forgotPassword.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Model/partner_model.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DriverService{
  static const String baseUrl = 'https://prod.naqlee.com:443/api/partner/';

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
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Login Failed';
        commonWidgets.showToast(message);

        final driverData = responseBody['data']['operator'];
        final tokenData = responseBody['data'];

        if (driverData != null) {
          final firstName = driverData['firstName'] ?? '';
          final lastName = driverData['lastName'] ?? '';
          final mode = driverData['mode'] ?? '';
          final token = tokenData['token'] ?? '';
          final operatorId = driverData['_id'] ?? '';
          final partnerId = tokenData['associatedPartnerId'] ?? '';
          await driverMode(context, partnerId: partnerId, operatorId: operatorId, mode: mode);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverHomePage(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: operatorId,partnerId: partnerId,mode: mode,)));
          await saveDriverData(firstName, lastName, token, operatorId,partnerId,mode);
        } else {
          final message = responseBody['message'] ?? 'Login failed. Please try again.';
          commonWidgets.showToast(message);
        }
      } else {
        final message = responseBody['message'] ?? 'Login failed. Please try again.';
        commonWidgets.showToast(message);
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> DriverResetPassword(emailAddress: emailAddress),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An error occurred,Please try again.. Please try again.';
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> DriverForgotPasswordSuccess(),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An error occurred,Please try again.. Please try again.';
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Failed';
      }
      else {
        final message = responseBody['message'] ?? 'Please try again.';
        commonWidgets.showToast(message);
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        final message = responseBody['message'] ?? 'No Booking request found';
        commonWidgets.showToast(message);
        return null;
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
      return null;
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchBookingDetails(String id, String token) async {
    try {
      final url = Uri.parse('https://prod.naqlee.com:443/api/getBookingsByBookingId/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseBody.containsKey('data')) {
          final Map<String, dynamic> bookingData = responseBody['data'];
          return bookingData;
        } else {
          final message = responseBody['message'] ?? 'No Booking request found';
          commonWidgets.showToast(message);
          return null;
        }
      }
      else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'No Data found';
        commonWidgets.showToast(message);
        return null;
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>?> getUserDetails(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody != null) {
          final firstName = responseBody['firstName']?.toString() ?? '';
          final lastName = responseBody['lastName']?.toString() ?? '';
          final contactNo = responseBody['contactNumber']?.toString() ?? '';

          if (firstName.isNotEmpty || lastName.isNotEmpty || contactNo.isNotEmpty) {
            return {
              'firstName': firstName,
              'lastName': lastName,
              'contactNo': contactNo,
            };
          }
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'No Data found';
        commonWidgets.showToast(message);
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('Error fetching user details');
    }
    return null;
  }


  Future<void> driverCompleteOrder(
      BuildContext context, {
        required String bookingId,
        required bool status,
        required String token,
      }) async {
    try {
      final url = Uri.parse('https://prod.naqlee.com:443/api/bookings/update-booking-status');
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
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Failed';
        commonWidgets.showToast(message);
      }
      else {
        final message = responseBody['message'] ?? 'Please try again.';
        commonWidgets.showToast(message);
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }


  Future<OperatorDetail?> getOperatorDetail(BuildContext context, String partnerId, String operatorId) async {
    try {
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/partner/$partnerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final partnerData = responseBody['data'];

        // Function to search for the operator in a given list (for 'operators' list)
        OperatorDetail? findOperatorInOperatorsList(List<dynamic> operatorList) {
          for (var operator in operatorList) {
            if (operator['operatorsDetail'] != null) {
              for (var detail in operator['operatorsDetail']) {
                if (detail['_id'].toString().trim() == operatorId.trim()) {
                  return OperatorDetail.fromJson(detail);
                }
              }
            }
          }
          return null;
        }
        OperatorDetail? findOperatorInExtraOperatorsList(List<dynamic> extraOperatorsList) {
          for (var detail in extraOperatorsList) {
            if (detail['_id'].toString().trim() == operatorId.trim()) {
              return OperatorDetail.fromJson(detail);
            }
          }
          return null;
        }

        // Search in 'operators'
        if (partnerData['operators'] != null) {
          final operators = partnerData['operators'] as List<dynamic>;
          OperatorDetail? operatorDetail = findOperatorInOperatorsList(operators);
          if (operatorDetail != null) {
            return operatorDetail;
          }
        }

        // If not found, search in 'extraOperators'
        if (partnerData['extraOperators'] != null) {
          final extraOperators = partnerData['extraOperators'] as List<dynamic>;
          OperatorDetail? operatorDetail = findOperatorInExtraOperatorsList(extraOperators);
          if (operatorDetail != null) {
            return operatorDetail;
          }
        }
      }
      return null;
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
    return null;
  }

  Future<String?> driverCurrentCoordinates(
      BuildContext context, {
        required String partnerId,
        required String operatorId,
        required double latitude,
        required double longitude,
      }) async {
    try {
      final url = Uri.parse('https://prod.naqlee.com/api/driver-location');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "partnerId": partnerId,
          "operatorId": operatorId,
          "latitude": latitude,
          "longitude": longitude
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
      } else {
        return null;
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
      return null;
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
      return null;
    }
    return null;
  }

  Future<void> driverStartTripOTP(context,{
    required String bookingId,
  }) async {
    try{
      final url = Uri.parse('https://prod.naqlee.com/api/driver-to-take-trip');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
        }),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
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
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<bool> driverVerifyOTP(
      BuildContext context, {
        required String bookingId,
        required String otp,
      }) async {
    try {
      final url = Uri.parse('https://prod.naqlee.com/api/driver-verify-otp');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'otp': otp,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'OTP Verified Successfully, Start your Trip',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return true;
      } else {
        final message = responseBody['message'] ?? 'Invalid OTP';
        commonWidgets.showToast(message);
        return false;
      }
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
      return false;
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
      return false;
    }
  }


}