import 'package:flutter/material.dart';
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
                    User!,
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
      margin: EdgeInsets.only(top: 40),
      child: ListView(
        padding: EdgeInsets.all(40),
        children: <Widget>[
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/naqlee-logo.svg',
                    height: MediaQuery.of(context).size.height * 0.05),
                Icon(Icons.cancel)
              ],
            ),
          ),
          ListTile(
            title: Text('Booking',style: TextStyle(fontSize: 30),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewBooking()));
            },
          ),
          ListTile(
            title: Text('Payment',style: TextStyle(fontSize: 30),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentDetails()));
            },
          ),
          ListTile(
            title: Text('Report',style: TextStyle(fontSize: 30),),
            onTap: () {

            },
          ),
          ListTile(
            title: Text('Help',style: TextStyle(fontSize: 30),),
            onTap: () {

            },
          ),
        ],
      ),
    ),
  );
}
