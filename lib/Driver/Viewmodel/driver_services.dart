import 'dart:convert';
import 'dart:io';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
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
          final token = tokenData['token'] ?? '';
          final id = driverData['_id'] ?? '';
          print(driverData);

          Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverHomePage(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: id,)));
          await saveDriverData(firstName, lastName, token, id);
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
}