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
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class CommonWidgets {

  AppBar commonAppBar(BuildContext context,
      {String? User, PreferredSizeWidget? bottom, bool showLeading = true, String? userId, bool showLanguage = true,ui.TextDirection? textDirection}) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: showLeading
          ? Builder(
        builder: (BuildContext context) =>
            IconButton(
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
            height: MediaQuery
                .of(context)
                .size
                .height * 0.05),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              showLanguage
                  ? Directionality(
                textDirection: ui.TextDirection.ltr,
                child: PopupMenuButton<Locale>(
                  color: Colors.white,
                  offset: const Offset(0, 55),
                  icon: Icon(Icons.language, color: Colors.blue),
                  onSelected: (Locale locale) {
                    context.setLocale(locale);
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<Locale>>[
                      PopupMenuItem(
                        value: Locale('en', 'US'),
                        child: Text(
                          'English'.tr(),
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ),
                      PopupMenuItem(
                        value: Locale('ar', 'SA'),
                        child: Text(
                          'Arabic'.tr(),
                          textDirection: textDirection ??ui.TextDirection.rtl,
                        ),
                      ),
                      PopupMenuItem(
                        value: Locale('hi', 'IN'),
                        child: Text(
                          'Hindi'.tr(),
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ),
                    ];
                  },
                ),
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
                          padding: const EdgeInsets.only(
                              left: 9, right: 9, top: 8, bottom: 9),
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
                        print('Fetched notifications: $notifications');

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
                                    leading: const Icon(
                                        Icons.message, color: Colors.blue),
                                    title: Text(notification['messageTitle'] ??
                                        'No Title'),
                                    subtitle: Text(
                                        notification['messageBody'] ??
                                            'No Message'),
                                    onTap: () {
                                      Navigator.pop(context); // Close the menu
                                    },
                                  ),
                                ),
                              );
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
                          itemBuilder: (context) =>
                          [
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox
                                .shrink(); // Hide while loading
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
      String partnerId,
      String partnerName,
      {VoidCallback? onEditProfilePressed,
        VoidCallback? onBookingPressed,
        VoidCallback? onPaymentPressed,
        VoidCallback? onReportPressed,
        VoidCallback? onHelpPressed}) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person,color: Colors.grey,size: 30),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(partnerName,
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                Icon(Icons.edit,color: Colors.grey,size: 20),
              ],
            ),
            subtitle: Text(partnerId,
              style: TextStyle(color: Color(0xff8E8D96),
              ),),
            onTap: onEditProfilePressed,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Divider(),
          ),
          ListTile(
              leading: SvgPicture.asset('assets/booking_logo.svg'),
              title: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'booking'.tr(),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: onBookingPressed
          ),
          ListTile(
              leading: SvgPicture.asset('assets/payment_logo.svg'),
              title: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'payment'.tr(),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: onPaymentPressed),
          ListTile(
              leading: SvgPicture.asset('assets/report_logo.svg'),
              title: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'report'.tr(),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: onReportPressed),
          ListTile(
            leading: SvgPicture.asset('assets/help_logo.svg'),
            title: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'help'.tr(),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: onHelpPressed,
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
              size: 30,
            ),
            title: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'logout'.tr(),
                style: TextStyle(fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
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
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 10),
                  child: Text(
                    'are_you_sure_you_want_to_logout'.tr(),
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('yes'.tr()),
                onPressed: () async {
                  await clearPartnerData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const LoginPage(
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
                child: Text('no'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
                top: -14,
                right: -13,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel),
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
                  'Booking Generated'.tr(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${'Booking id'.tr()} $bookingId',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTextField(String label,
      TextEditingController controller, {
        FocusNode? focusNode,
        String? hintText,
        String? labelText,
        bool obscureText = false,
        bool readOnly = false,
        FontWeight fontWeight = FontWeight.w500,
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
              style: TextStyle(fontSize: 20, fontWeight: fontWeight),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: TextFormField(
            readOnly: readOnly,
            textCapitalization: label != 'Email ID' && label != 'Email Address' && label != 'Password' && label != 'Confirm Password'?TextCapitalization.sentences:TextCapitalization.none,
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
                return '${'Please enter'.tr()} $label';
              }
              if ((label == 'Email ID' || label == 'Email Address') &&
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

  Widget buildBottomNavigationBar({
    required BuildContext context,
    required int selectedIndex,
    required Function(int) onTabTapped,
  }) {
    return BottomAppBar(
      height: MediaQuery.sizeOf(context).height * 0.1,
      color: Colors.white,
      elevation: 20,
      shadowColor: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, 'assets/home.svg', 25, 'Home'.tr(), selectedIndex, onTabTapped),
          _buildTabItem(1, 'assets/booking_manager.svg', 26, 'Booking Manager'.tr(), selectedIndex, onTabTapped),
          _buildTabItem(2, 'assets/payment.svg', 26, 'payment'.tr(), selectedIndex, onTabTapped),
          _buildTabItem(3, 'assets/profile.svg', 26, 'Profile'.tr(), selectedIndex, onTabTapped),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      int index,
      String iconPath,
      double height,
      String label,
      int selectedIndex,
      Function(int) onTabTapped,
      ) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: height,
            color: isSelected ? Color(0xff7F6AFF) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xff7F6AFF) :null,
              )
            ),
          ),
        ],
      ),
    );
  }

}
