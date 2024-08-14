import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Model/sharedPreferences.dart';
import 'package:flutter_naqli/Views/auth/login.dart';
import 'package:flutter_naqli/Views/auth/otp.dart';
import 'package:flutter_naqli/Views/auth/stepOne.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://naqli.onrender.com/api/partner/';

  Future<void> registerUser(context,{
    required String partnerName,
    required String mobileNo,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${baseUrl}register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': role,
        'partnerName': partnerName,
        'mobileNo': mobileNo,
        'email': email,
        'password': password,
      }),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(mobileNo: mobileNo,partnerName: partnerName,password: password, email: email,),
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

  Future<void> validateOTP(context,{
    required String otp,
    required String partnerName,
    required String email,
    required String mobileNo,
    required String password,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(mobileNo: mobileNo,partnerName: partnerName,password: password)
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

  Future<void> resendOTP(context,{
    required String email,
    required String partnerName,
    required String password,
    required String mobileNo,
  }) async {
    final url = Uri.parse('${baseUrl}resend-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Sent')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(mobileNo: mobileNo,partnerName: partnerName,password: password)
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

  Future<void> loginUser(
      BuildContext context, {
        required String emailOrMobile,
        required String mobileNo,
        required String partnerName,
        required String password,
      }) async {
    final url = Uri.parse('${baseUrl}login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'emailOrMobile': emailOrMobile,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);
    final userData = responseBody['data']['partner'];
    if (response.statusCode == 200) {
      print('Login successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      final token = responseBody['data']['token'];
      final partnerName = responseBody['data']['partner']['partnerName'];

      await storeUserData(token, userData);
      print(userData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StepOne(unitType:'',partnerName: partnerName, name: '',),
        ),
      );
    } else {
      final message = responseBody['message'] ?? 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to login user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> addOperator(
      BuildContext context, {
        required String unitType,
        required String unitClassification,
      }) async {
    final url = Uri.parse('https://naqli.onrender.com/api/vehicles');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'unitType': unitType,
        'unitClassification': unitClassification,
      }),
    );

    final responseBody = jsonDecode(response.body);
    final userData = responseBody['data']['partner'];
    if (response.statusCode == 200) {
      print('Login successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      final token = responseBody['data']['token'];
      final partnerName = responseBody['data']['partner']['operator'];

      print(userData);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => StepOne(unitType:unitType,partnerName: partnerName, name: '',),
      //   ),
      // );
    } else {
      final message = responseBody['message'] ?? 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to login user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchVehicleData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/vehicles'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load vehicle data');
    }
  }
  Future<List<String>> fetchVehicleTypes() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/vehicles'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Extract typeName from the response
      List<String> typeNames = [];
      for (var vehicle in data) {
        var types = vehicle['type'] as List<dynamic>;
        for (var type in types) {
          typeNames.add(type['typeName']);
        }
      }

      return typeNames;
    } else {
      throw Exception('Failed to load vehicle data');
    }
  }
  Future<List<dynamic>> fetchBusData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/buses'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Bus data');
    }
  }

  Future<List<dynamic>> fetchEquipmentData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/equipments'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to login user: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load Equipment data');
    }
  }

  Future<List<dynamic>> fetchSpecialData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/special-units'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Special data');
    }
  }


}

