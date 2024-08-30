import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/user_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6A66D1)),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.0,
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
    // _checkLoginState();
  }

  // Future<void> _checkLoginState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final partnerId = prefs.getString('partnerId');
  //   final userId = prefs.getString('userId');
  //   final token = prefs.getString('token');
  //
  //   if (partnerId != null && token != null) {
  //     // Navigate to BookingDetails page
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BookingDetails(
  //           partnerName: prefs.getString('partnerName') ?? '',
  //           partnerId: partnerId,
  //           token: token,
  //           quotePrice: '',
  //           paymentStatus: '',
  //         ),
  //       ),
  //     );
  //   } else if (userId != null && token != null) {
  //     // Navigate to CreateBooking page
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => CreateBooking(
  //           firstName: prefs.getString('firstName') ?? '',
  //           lastName: prefs.getString('lastName') ?? '',
  //         ),
  //       ),
  //     );
  //   }
  // }

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
                    return UserType(firstName: firstName, lastName: lastName);
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



/*
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.0,
        ),
      ),
      home: FutureBuilder<Map<String, String?>>(
        future: getSavedPartnerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            final userData = snapshot.data;
            if (userData != null) {
              final partnerName = userData['partnerName'] ?? '';
              final partnerId = userData['partnerId'] ?? '';
              final token = userData['token'] ?? '';
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
          return UserHomePage();
          // PartnerHomePage(
          //   partnerName: '',
          //   password: '',
          //   mobileNo: '',
          //   partnerId: '',
          //   token: '',
          // );
        },
      ),
    );
  }
}*/
