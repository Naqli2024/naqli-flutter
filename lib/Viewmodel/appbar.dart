import 'package:flutter/material.dart';
import 'package:flutter_naqli/Model/sharedPreferences.dart';
import 'package:flutter_naqli/Views/auth/login.dart';
import 'package:flutter_naqli/Views/booking/view_booking.dart';
import 'package:flutter_naqli/Views/payment/payment_details.dart';
import 'package:flutter_svg/flutter_svg.dart';

AppBar commonAppBar(BuildContext context,{String? User,PreferredSizeWidget? bottom}) {
  return AppBar(
      toolbarHeight: MediaQuery.of(context).size.height * 0.06,
      leading: Builder(
        builder: (BuildContext context) => IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Color(0xff5D5151),
            size: 45,
          ),
        ),
      ),
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SvgPicture.asset('assets/naqlee-logo.svg',
                height: MediaQuery.of(context).size.height * 0.05),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text(
                    User??'user',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Stack(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications,
                            color: Color(0xff6A66D1),
                            size: 30,
                          )),
                      Positioned(
                        right: 10,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          bottom: bottom
  );
}

Drawer createDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.white,
    child: Container(
      margin: const EdgeInsets.only(top: 40),
      child: ListView(
        padding: const EdgeInsets.all(40),
        children: <Widget>[
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/naqlee-logo.svg',
                    height: MediaQuery.of(context).size.height * 0.05),
                const Icon(Icons.cancel)
              ],
            ),
          ),
          ListTile(
            title: const Text('Booking',style: TextStyle(fontSize: 30),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewBooking()));
            },
          ),
          ListTile(
            title: const Text('Payment',style: TextStyle(fontSize: 30),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentDetails()));
            },
          ),
          ListTile(
            title: const Text('Report',style: TextStyle(fontSize: 30),),
            onTap: () {

            },
          ),
          ListTile(
            title: const Text('Help',style: TextStyle(fontSize: 30),),
            onTap: () {

            },
          ),
          ListTile(
            title: const Text('Logout',style: TextStyle(fontSize: 30),),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    ),
  );
}

void logout(BuildContext context) async {
  await clearUserData();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage(partnerName: '',mobileNo: '',password: '',)),
  );
}