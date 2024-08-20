import 'package:flutter/material.dart';
import 'package:flutter_naqli/Model/sharedPreferences.dart';
import 'package:flutter_naqli/Views/auth/login.dart';
import 'package:flutter_naqli/Views/auth/otp.dart';
import 'package:flutter_naqli/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naqli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff6A66D1)),
        useMaterial3: true,
      ),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            final userData = snapshot.data;

            // Ensure userData is not null and has the required fields
            if (userData != null) {
              final partnerName = userData['partnerName'] ?? '';
              final partnerId = userData['_id'] ?? '';
              final token = userData['token'] ?? '';

              return BookingDetails(
                partnerName: partnerName,
                partnerId: partnerId,
                token: token,
                quotePrice: '',
                paymentStatus: '',
              );
            }
          }

          // Handle cases where snapshot has no data or is null
          return HomePage(partnerName: '', password: '', mobileNo: '', partnerId: '');
        },
      ),
    );
  }
}

