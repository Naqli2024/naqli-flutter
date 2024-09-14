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
import 'package:flutter_naqli/User/user_home_page.dart';
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
      // I/flutter (12075): Full Response Body: {success: true, data: [{_id: 66dc0b53e920fbed22e09d37, name: Lorry 7 metres, unitType: vehicle, type: [{typeName: Slide, scale: (7m to 7.5m), typeImage: assets/images/lorry 7 meters-sides.svg, typeOfLoad: Auto parts, _id: 66dc0b53e920fbed22e09d38}], pickup: chennai, dropPoints: [coimbatore], productValue: 123, date: 2024-09-07, time: 13:43, additionalLabour: 2, bookingStatus: Running, user: 66d15f161946cb9cbadf3912, paymentStatus: Paid, paymentAmount: 0, remainingBalance: 0, additionalCharges: 0, additionalChargesReason: [], payout: 0, initialPayout: 0, finalPayout: 0, bookingId: 2c139b08-5879-413b-a194-2e5c0b8333da, createdAt: 2024-09-07T08:14:11.025Z, updatedAt: 2024-09-07T08:14:11.025Z, __v: 0}]}
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
            builder: (context) => UserType(firstName: firstName,lastName: lastName,token: token,id: id,),
          ),
        );
        // await fetchPaymentBookingHistory(id,token);
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
    final url = Uri.parse('https://naqli.onrender.com/api/bookings');

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
  }
  // http://10.0.2.2:4000/api/partner/filtered-vendors
  Future<List<Map<String, dynamic>>?> userVehicleVendor(
      BuildContext context, {
        required String bookingId,
        required String unitType,
        required String unitClassification,
        required String subClassification,
      }) async {
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
        final partnerName = item['partnerName'];
        final partnerId = item['partnerId'];
        final quotePrice = item['quotePrice'];
        final oldQuotePrice = item['oldQuotePrice'];

        vendors.add({
          'partnerName': item['partnerName'],
          'partnerId': item['partnerId'],
          'quotePrice': item['quotePrice'],
          'unitType': item['unitType'],
          'unitClassification': item['unitClassification'],
          'subClassification': item['subClassification'],
          'bookingId': item['bookingId'],
          'oldQuotePrice': item['oldQuotePrice'],
        });
      }

      print('Fetched Vendors: $vendors');
      CommonWidgets().showToast('Fetching Vendor...');
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
    } catch (error) {
      print('Error updating payment: $error');
      return null;
    }
  }

  Future<dynamic> updatePaymentCompleted(String token,String amount, String status, String partnerId,String bookingId) async {
    final url = Uri.parse('${baseUrl}bookings/$bookingId/payment');
    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          'bookingId': bookingId,
          'amount': amount,
          'partnerId': partnerId,
        }),
      );

      if (response.statusCode == 200) {
        print('Payment Complete successful: ${response.body}');
        return jsonDecode(response.body);  // return the decoded response
      } else {
        print('Failed to update payment: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null; // Avoid returning null, handle error properly
      }
    } catch (error) {
      print('Error updating payment: $error');
      return null;
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
    final url = Uri.parse('${baseUrl}bookings/user/$id/completed');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
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
    } catch (e) {
      print('Error occurred while fetching booking history: $e');
      return []; // Return an empty list in case of error
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
    final url = Uri.parse('${baseUrl}getBookingsByBookingId/$id');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('Fetching from URL: ${url.toString()}');

    try {
      final response = await http.get(url, headers: headers);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseBody.containsKey('data')) {
          final Map<String, dynamic> bookingData = responseBody['data'];
          print('Booking Data: $bookingData');
          return bookingData;
        } else {
          throw Exception('Unexpected response format: $responseBody');
        }
      } else {
        throw Exception('Failed to load booking details. Status code: ${response.statusCode}, Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while fetching booking details: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPartnerData(String partnerId, String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}partner/$partnerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Print the entire response body
    print('API Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Print decoded response
      print('Decoded API Response: $responseBody');

      final partnerId = responseBody['data']['_id'] ?? 'Unknown Partner ID';
      final partnerName = responseBody['data']['partnerName'] ?? 'Unknown Partner Name';
      final operators = responseBody['data']['operators'] ?? [];

      // Check if operators are available
      if (operators.isEmpty) {
        print('No operators available for this partner.');
        return [];
      }

      final partnerDetails = <Map<String, dynamic>>[];

      // Iterate over the operators array
      for (var operator in operators) {
        final firstName = operator['operatorsDetail'] != null && operator['operatorsDetail'].isNotEmpty
            ? operator['operatorsDetail'][0]['firstName'] ?? 'Unknown'
            : 'Unknown';
        final lastName = operator['operatorsDetail'] != null && operator['operatorsDetail'].isNotEmpty
            ? operator['operatorsDetail'][0]['lastName'] ?? 'Unknown'
            : 'Unknown';
        final mode = operator['unitType'] ?? 'Unknown Mode';
        final bookingRequests = operator['bookingRequest'] ?? [];
        final fullName = '$firstName $lastName';

        for (var booking in bookingRequests) {
          final bookingId = booking['bookingId']?.toString() ?? 'Unknown Booking ID';
          final bookingStatus = booking['bookingStatus']?.toString() ?? 'Pending';

          // Add booking and operator details to partnerDetails
          partnerDetails.add({
            'partnerId': partnerId,
            'partnerName': partnerName,
            'operatorName': fullName,
            'lastName': lastName,
            'mode': mode,
            'bookingId': bookingId,
            'bookingStatus': bookingStatus,
          });
        }
      }

      return partnerDetails;
    } else {
      print('Failed to load partner data: ${response.statusCode} ${response.body}');
      return [];
    }
  }


}