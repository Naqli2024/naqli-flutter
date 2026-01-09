import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_interaction.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
CommonWidgets commonWidgets = CommonWidgets();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    dotenv.load(fileName: ".env"),
  ]);
    runApp(
      EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ar', 'SA'),
          Locale('hi', 'IN'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: const MyApp(),
      ),
    );

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    Future.microtask(() async {
      try {
        await InAppWebViewController.setWebContentsDebuggingEnabled(true);
      } catch (e) {
      }
    });
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: commonWidgets.normalizeLocaleFromLocale(context.locale),
      title: 'Naqlee',
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final mediaQuery = MediaQuery.of(context);
            final viewUtil = ViewUtil(context);

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaleFactor: viewUtil.isTablet ? 1.3 : 0.87,
              ),
              child: child ?? const LoginScreen(),
            );
          },
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6A66D1)),
        useMaterial3: true,
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
  Future<Widget> _getHomeScreen() async {
    Map<String, String?>? partnerData = await getSavedPartnerData();
    if (partnerData != null &&
        partnerData['partnerId']?.isNotEmpty == true &&
        partnerData['partnerName']?.isNotEmpty == true &&
        partnerData['token']?.isNotEmpty == true) {
      return BookingDetails(
        partnerName: partnerData['partnerName'] ?? '',
        partnerId: partnerData['partnerId'] ?? '',
        token: partnerData['token'] ?? '',
        quotePrice: '',
        paymentStatus: '',
        email: partnerData['email'] ?? '',
      );
    }

    Map<String, String?>? driverData = await getSavedDriverData();
    if (driverData != null &&
        driverData['id']?.isNotEmpty == true &&
        driverData['token']?.isNotEmpty == true &&
        driverData['partnerId']?.isNotEmpty == true) {
      return DriverHomePage(
        firstName: driverData['firstName'] ?? '',
        lastName: driverData['lastName'] ?? '',
        token: driverData['token'] ?? '',
        id: driverData['id'] ?? '',
        partnerId: driverData['partnerId'] ?? '',
        mode: driverData['mode'] ?? '',
      );
    }

    Map<String, String?>? userData = await getSavedUserData();
    if (userData != null &&
        userData['id']?.isNotEmpty == true &&
        userData['token']?.isNotEmpty == true &&
        userData['accountType']?.isNotEmpty == true) {
      if (userData['accountType'] == 'Single User') {
        return UserType(
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          token: userData['token'] ?? '',
          id: userData['id'] ?? '',
          email: userData['email'] ?? '',
          accountType: userData['accountType'] ?? '',
        );
      } else {
        return SuperUserHomePage(
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          token: userData['token'] ?? '',
          id: userData['id'] ?? '',
          email: userData['email'] ?? '',
          accountType: userData['accountType'] ?? '',
        );
      }
    }

    return const UserHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Widget>(
        future: _getHomeScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data ?? const UserHomePage();
        },
      ),
    );
  }
}


