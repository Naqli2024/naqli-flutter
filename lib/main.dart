import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
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
        future: getSavedUserData(),
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
}