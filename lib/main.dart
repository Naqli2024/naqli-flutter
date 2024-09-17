import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'User/Views/user_createBooking/user_vendor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naqli',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 0.95),
          child: child ?? const LoginScreen(),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6A66D1)),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 0.95,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, String?>>(
        future: getSavedPartnerData(),  // Load partner data
        builder: (context, partnerSnapshot) {
          if (partnerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (partnerSnapshot.hasData) {
            final partnerData = partnerSnapshot.data;
            if (partnerData != null) {
              final partnerName = partnerData['partnerName'] ?? '';
              final partnerId = partnerData['partnerId'] ?? '';
              final token = partnerData['token'] ?? '';
              if (partnerId.isNotEmpty && token.isNotEmpty) {
                return BookingDetails(
                  partnerName: partnerName,
                  partnerId: partnerId,
                  token: token,
                  quotePrice: '',
                  paymentStatus: '',
                );
              }
            }
          }

          // If partner data is not found, try to load user data
          return FutureBuilder<Map<String, String?>>(
            future: getSavedUserData(),  // Load user data
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData) {
                final userData = userSnapshot.data;
                if (userData != null) {
                  final firstName = userData['firstName'] ?? '';
                  final lastName = userData['lastName'] ?? '';
                  final token = userData['token'] ?? '';
                  final id = userData['id'] ?? '';

                  print('User data: firstName=$firstName, lastName=$lastName, token=$token, id=$id');

                  if (id.isNotEmpty && token.isNotEmpty) {
                    // return ChooseVendor(unit: '', load: '',size: '',bookingId: '',unitType: '',);
                    return UserType(firstName: firstName, lastName: lastName,token: token,id: id,);
                  }
                }
              }

              return const UserHomePage();
            },
          );
        },
      ),
    );
  }
}

// --enable-software-rendering

