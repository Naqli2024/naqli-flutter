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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),
      home: const HomePage(partnerName: '',password: '',mobileNo: '',),
      // home: const BookingDetails(),
      // home: FutureBuilder<Map<String, dynamic>?>(
      //   future: getUserData(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     } else if (snapshot.hasData) {
      //       final userData = snapshot.data!;
      //       final partnerName = userData['partnerName'];
      //       return StepOne(partnerName: partnerName, mobileNo: '', emailOrMobile: '',);
      //     } else {
      //       return LoginPage(partnerName: '', mobileNo: '', password: '',);
      //     }
      //   },
      // ),
    );
  }
}
