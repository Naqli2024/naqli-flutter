import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    } catch (e) {
      debugPrint("Error enabling debugging: $e");
    }
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
        Locale('hi', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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
          fontSizeFactor: viewUtil.isTablet?1.3:0.95,
        ),
      ),
      home: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: const LoginScreen()),
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
        future: getSavedPartnerData(),
        builder: (context, partnerSnapshot) {
          if (partnerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (partnerSnapshot.hasData) {
            final partnerData = partnerSnapshot.data;
            if (partnerData != null) {
              final partnerName = partnerData['partnerName'] ?? '';
              final partnerId = partnerData['partnerId'] ?? '';
              final token = partnerData['token'] ?? '';
              final email = partnerData['email'] ?? '';
              print('Partner data: partnerName=$partnerName, token=$token, id=$partnerId');
              if (partnerId.isNotEmpty && token.isNotEmpty && partnerName.isNotEmpty) {
                return BookingDetails(
                  partnerName: partnerName,
                  partnerId: partnerId,
                  token: token,
                  quotePrice: '',
                  paymentStatus: '',
                  email: email,
                );
              }
            }
          }

          return FutureBuilder<Map<String, String?>>(
            future: getSavedDriverData(),
            builder: (context, driverSnapshot) {
              if (driverSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (driverSnapshot.hasData) {
                final driverData = driverSnapshot.data;
                if (driverData != null) {
                  final firstName = driverData['firstName'] ?? '';
                  final lastName = driverData['lastName'] ?? '';
                  final mode = driverData['mode'] ?? '';
                  final id = driverData['id'] ?? '';
                  final token = driverData['token'] ?? '';
                  final driverPartnerId = driverData['partnerId'] ?? '';
                  print('Driver data: firstName=$firstName, lastName=$lastName, token=$token, id=$id');
                  if (id.isNotEmpty && token.isNotEmpty && driverPartnerId.isNotEmpty) {
                    return DriverHomePage(
                      firstName: firstName,
                      lastName: lastName,
                      token: token,
                      id: id,
                      partnerId: driverPartnerId,
                      mode: mode,
                    );
                  }
                }
              }


              return FutureBuilder<Map<String, String?>>(
                future: getSavedUserData(),
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
                      final email = userData['email'] ?? '';
                      final accountType = userData['accountType'] ?? '';
                      print('User data: firstName=$firstName, lastName=$lastName, token=$token, id=$id, accountType=$accountType');
                      if(accountType == 'Single User') {
                        if (id.isNotEmpty && token.isNotEmpty && accountType.isNotEmpty) {
                          return UserType(
                            firstName: firstName,
                            lastName: lastName,
                            token: token,
                            id: id,
                            email: email,
                            accountType: accountType,
                          );
                        }
                      }
                      else{
                        if (id.isNotEmpty && token.isNotEmpty && accountType.isNotEmpty) {
                          return SuperUserHomePage(
                            firstName: firstName,
                            lastName: lastName,
                            token: token,
                            id: id,
                            email: email,
                            accountType: accountType,
                          );
                        }
                      }
                    }
                  }

                  return const UserHomePage();
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --enable-software-rendering

