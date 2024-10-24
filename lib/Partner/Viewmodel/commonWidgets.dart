import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class CommonWidgets {
  AppBar commonAppBar(BuildContext context,
      {String? User, PreferredSizeWidget? bottom, bool showLeading = true, String? userId,bool showLanguage = true,}) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: showLeading
          ? Builder(
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
      )
          : null,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SvgPicture.asset('assets/naqlee-logo.svg',
            height: MediaQuery.of(context).size.height * 0.05),
      ),
      actions:  [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              showLanguage
                  ? PopupMenuButton<Locale>(
                color: Colors.white,
                offset: const Offset(0, 55),
                icon: Icon(Icons.language, color: Colors.blue),
                onSelected: (Locale locale) {
                  context.setLocale(locale);
                },
                itemBuilder: (BuildContext context) {
                  // Determine the current locale
                  Locale currentLocale = context.locale;
                  // Set text direction based on current locale
                  ui.TextDirection textDirection = ui.TextDirection.ltr;

                  return <PopupMenuEntry<Locale>>[
                    PopupMenuItem(
                      value: Locale('en', 'US'),
                      child: Text(
                        'English',
                        textDirection: textDirection,
                      ),
                    ),
                    PopupMenuItem(
                      value: Locale('ar', 'SA'),
                      child: Text(
                        'العربية',
                        textDirection: textDirection,
                      ),
                    ),
                    PopupMenuItem(
                      value: Locale('hi', 'IN'),
                      child: Text(
                        'हिन्दी',
                        textDirection: textDirection,
                      ),
                    ),
                  ];
                },
              )
                  : Container(),
              Text(
                User ?? 'user',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Stack(
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: userService.getNotifications(userId ?? ''),
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 9,right: 9,top: 8,bottom: 9),
                          child: const Icon(
                            Icons.notifications,
                            color: Color(0xff6A66D1),
                            size: 30,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 30,
                        );
                      } else if (snapshot.hasData) {
                        final notifications = snapshot.data!;
                        print('Fetched notifications: $notifications'); // Debugging

                        return PopupMenuButton(
                          color: Colors.white,
                          icon: const Icon(
                            Icons.notifications,
                            color: Color(0xff6A66D1),
                            size: 30,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 350,
                            maxWidth: 350,
                          ),
                          offset: const Offset(0, 55),
                          itemBuilder: (context) {
                            List<PopupMenuEntry<dynamic>> menuItems = [];

                            for (int i = 0; i < notifications.length; i++) {
                              final notification = notifications[i];

                              menuItems.add(
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: const Icon(Icons.message, color: Colors.blue),
                                    title: Text(notification['messageTitle'] ?? 'No Title'),
                                    subtitle: Text(notification['messageBody'] ?? 'No Message'),
                                    onTap: () {
                                      Navigator.pop(context); // Close the menu
                                    },
                                  ),
                                ),
                              );

                              // Add a divider after each notification except the last one
                              if (i < notifications.length - 1) {
                                menuItems.add(const PopupMenuDivider());
                              }
                            }

                            return menuItems;
                          },
                        );
                      } else {
                        return PopupMenuButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Color(0xff6A66D1),
                            size: 30,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              child: ListTile(
                                title: Text('No notifications'),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  // Display the count of notifications
                  Positioned(
                    right: 8,
                    top: 4,
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: userService.getNotifications(userId ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink(); // Hide while loading
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data?.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      bottom: bottom,
    );
  }

  Drawer createDrawer(BuildContext context,
      {VoidCallback? onBookingPressed,
      String? partnerName,
      String? partnerId,
      VoidCallback? onPaymentPressed,
      VoidCallback? onReportPressed}) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/naqlee-logo.svg',
                    height: MediaQuery.of(context).size.height * 0.05),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const CircleAvatar(
                        child: Icon(FontAwesomeIcons.multiply)))
              ],
            ),
          ),
          const Divider(),
          ListTile(
              leading: SvgPicture.asset('assets/booking_logo.svg'),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Booking',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: onBookingPressed
              //     () {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const BookingDetails(partnerId: '',partnerName: '',)));
              // },
              ),
          ListTile(
              leading: SvgPicture.asset('assets/payment_logo.svg'),
              title: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Payment',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: onPaymentPressed),
          ListTile(
              leading: SvgPicture.asset('assets/report_logo.svg'),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Report',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: onReportPressed),
          ListTile(
            leading: SvgPicture.asset('assets/help_logo.svg'),
            title: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Help',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
              size: 30,
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.red),
              ),
            ),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(fontSize: 19),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await clearPartnerData();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(
                            partnerName: '',
                            mobileNo: '',
                            password: '',
                            token: '',
                            partnerId: '',
                          )),
                );
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showBookingDialog({
    required BuildContext context,
    required String bookingId,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          title: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SvgPicture.asset(
                    'assets/generated_logo.svg',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ),
              ),
              Positioned(
                top: -15,
                right: -15,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(FontAwesomeIcons.multiply),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  'Booking Generated',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Booking id $bookingId',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    FocusNode? focusNode,
    String? hintText,
    String? labelText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? passwordController,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText ?? '',
              labelText: labelText ?? '',
              labelStyle: const TextStyle(color: Color(0xffCCCCCC)),
              hintStyle: const TextStyle(color: Color(0xffCCCCCC)),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              suffixIcon: suffixIcon,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              if (label == 'Email ID' &&
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              if ((label == 'Password' || label == 'Confirm Password') &&
                  value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              if (label == 'Confirm Password' &&
                  passwordController != null &&
                  passwordController.text != value) {
                return 'Passwords do not match';
              }
              if (label == 'Id Number' &&
                  !RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'ID number must be exactly 10 digits long';
              }
              if (label == 'Istimara no' &&
                  !RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Istimara number must be exactly 10 digits long';
              }
              if (label == 'Iqama no' && !RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Iqama number must be exactly 10 digits long';
              }
              if (label == 'Mobile no' &&
                  !RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Mobile number must be exactly 10 digits long';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
