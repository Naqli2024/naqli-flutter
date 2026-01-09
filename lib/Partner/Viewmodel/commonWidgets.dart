import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/vectorImage.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui' as ui;

class CommonWidgets {
  final ValueNotifier<List<Map<String, dynamic>>> _notificationsNotifier =
  ValueNotifier<List<Map<String, dynamic>>>([]);
  Future<void> _fetchNotifications(String? userId) async {
    try {
      final notifications = await userService.getNotifications(userId ?? '');
      _notificationsNotifier.value = notifications.map((notification) {
        return {
          ...notification,
          'seen': notification['seen'] == 'true' || notification['seen'] == true,
        };
      }).toList();
    } catch (e) {
      _notificationsNotifier.value = [];
    }
  }

  void _markAllAsSeen() async {
    final unseenNotifications = _notificationsNotifier.value.where((notification) => notification['seen'] == false).toList();
    final updatedNotifications = _notificationsNotifier.value.map((notification) {
      if (unseenNotifications.contains(notification)) {
        return {...notification, 'seen': true};
      }
      return notification;
    }).toList();
    _notificationsNotifier.value = updatedNotifications;
    try {
      final notificationIds = unseenNotifications
          .map<String>((notification) => notification['notificationId'].toString())
          .toList();
      if (notificationIds.isNotEmpty) {
        await userService.updateNotificationsAsSeen(notificationIds);
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  int _getUnseenCount() {
    return _notificationsNotifier.value
        .where((notification) => notification['seen'] == false)
        .length;
  }

  AppBar commonAppBar(BuildContext context,
      {String? User,
        PreferredSizeWidget? bottom,
        bool showLeading = true,
        String? userId,
        Locale? currentLocale,
        Function(Locale)? onLocaleChanged,
        bool showLanguage = true,
        ui.TextDirection? textDirection}) {
    if (_notificationsNotifier.value.isEmpty) {
      _fetchNotifications(userId);
    }
    ViewUtil viewUtil = ViewUtil(context);
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showLeading
          ? Builder(
        builder: (BuildContext context) => IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon:  Icon(
            Icons.menu,
            color: Color(0xff5D5151),
            size: viewUtil.isTablet ? 50 : 45,
          ),
        ),
      )
          : null,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SvgPicture.asset('assets/naqlee-logo.svg',
          height: viewUtil.isTablet ? 45 : 40),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(top: viewUtil.isTablet ?0:10),
          child: Row(
            children: [
              if (showLanguage)
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: PopupMenuButton<Locale>(
                    color: Colors.white,
                    offset: const Offset(0, 55),
                    icon: Icon(Icons.language, color: Color(0xff7f6bf6),size: viewUtil.isTablet ? 35 : 25),
                    onSelected: (Locale locale) {
                      if (onLocaleChanged != null) {
                        onLocaleChanged(locale);
                      }
                      context.setLocale(locale);
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<Locale>>[
                        PopupMenuItem(
                          value: Locale('en', 'US'),
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  'English'.tr(),
                                  style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: Locale('ar', 'SA'),
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  'Arabic'.tr(),
                                  style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),
                                  textDirection: textDirection ?? ui.TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: Locale('hi', 'IN'),
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  'Hindi'.tr(),
                                  style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),
                                  textDirection: ui.TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              Text(
                User ?? 'user',
                style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet ? 20 : 14,),
              ),
              Stack(
                children: [
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _notificationsNotifier,
                    builder: (context, notifications, _) {
                      return PopupMenuButton(
                        onOpened: _markAllAsSeen,
                        color: Colors.white,
                        icon: Icon(
                          Icons.notifications,
                          color: Color(0xff6A66D1),
                            size: viewUtil.isTablet ? 35 : 25
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 350,
                          maxWidth: 350,
                        ),
                        offset: const Offset(0, 55),
                        itemBuilder: (context) {
                          if (notifications.isEmpty) {
                            return [
                              const PopupMenuItem(
                                child: ListTile(
                                  title: Text('No Notifications'),
                                  leading: Icon(Icons.circle_notifications_sharp, color: Colors.blue),
                                ),
                              ),
                            ];
                          }
                          return notifications.map((notification) {
                            return PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.message, color: Colors.blue),
                                title: Text(notification['messageTitle'] ?? 'No Title'),
                                subtitle: Text(notification['messageBody'] ?? 'No Message'),
                                onTap: () {
                                  Navigator.pop(context); // Close the menu
                                },
                              ),
                            );
                          }).toList();
                        },
                      );
                    },
                  ),

                  // Unseen Notifications Badge
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _notificationsNotifier,
                    builder: (context, notifications, _) {
                      final unseenCount = _getUnseenCount();  // Get the count of unseen notifications

                      // Check if there are unseen notifications
                      if (unseenCount > 0) {
                        return Positioned(
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
                            child: Text(
                              '$unseenCount',  // Display the unseen notification count
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      // No badge if no unseen notifications
                      return const SizedBox.shrink();
                    },
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
      {
        String? profileImage,
        VoidCallback? onEditProfilePressed,
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
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: profileImage != null
                  ? NetworkImage("https://prod.naqlee.com/api/image/$profileImage")
                  : null,
              child: profileImage == null
                  ? Icon(Icons.person, color: Colors.grey, size: 30)
                  : null,
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
    ViewUtil viewUtil = ViewUtil(context);
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
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: viewUtil.isTablet?27:19),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('yes'.tr(),
                    style: TextStyle(fontSize: viewUtil.isTablet?22:16)),
                onPressed: () async {
                  await clearPartnerData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const LoginPage()),
                  );
                },
              ),
              TextButton(
                child: Text('no'.tr(),
                    style: TextStyle(fontSize: viewUtil.isTablet?22:16)),
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
      fontSize: 14.0,
    );
  }

  void showBookingDialog({
    required BuildContext context,
    required String bookingId,
  }) {
    ViewUtil viewUtil = ViewUtil(context);
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
                    height: viewUtil.isTablet
                        ? MediaQuery.of(context).size.height * 0.2
                        : MediaQuery.of(context).size.height * 0.13,
                  ),
                ),
              ),
              Positioned(
                top: viewUtil.isTablet?-10:-14,
                right: viewUtil.isTablet?-10:-13,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel,size: viewUtil.isTablet? 30 :25),
                ),
              ),
            ],
          ),
          content: Container(
            width: viewUtil.isTablet
              ? MediaQuery.of(context).size.width * 0.6
              : MediaQuery.of(context).size.width * 0.55,
            height: viewUtil.isTablet
                ? MediaQuery.of(context).size.height * 0.08
                : MediaQuery.of(context).size.height * 0.13,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    'Booking Generated'.tr(),
                    style: TextStyle(
                        fontSize: viewUtil.isTablet? 25 :20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${'Booking id'.tr()} $bookingId',textAlign: TextAlign.center,
                    style: TextStyle(fontSize: viewUtil.isTablet? 20 :16),
                  ),
                ),
              ],
            ),
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
        TextEditingController? passwordController, required BuildContext context,
      }) {
    ViewUtil viewUtil = ViewUtil(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(fontSize: viewUtil.isTablet ?24 :20, fontWeight: fontWeight),
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
              labelStyle: TextStyle(color: const Color(0xffCCCCCC),fontSize: viewUtil.isTablet ?24 :15,),
              hintStyle: TextStyle(color: Color(0xffCCCCCC)),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              suffixIcon: suffixIcon,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${'Please enter'.tr()} $label';
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
              if (label == 'Istimara No' &&
                  !RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Istimara number must be exactly 10 digits long';
              }
              if (label == 'Iqama no' && !RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Iqama number must be exactly 10 digits long';
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
    ViewUtil viewUtil = ViewUtil(context);
    return BottomAppBar(
      height: MediaQuery.sizeOf(context).height * 0.12,
      color: Colors.white,
      elevation: 20,
      shadowColor: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, 'assets/home.svg', viewUtil.isTablet ?30:25, 'Home'.tr(), selectedIndex, onTabTapped,context),
          _buildTabItem(1, 'assets/booking_manager.svg', viewUtil.isTablet ?30:26, 'Booking Manager'.tr(), selectedIndex, onTabTapped,context),
          _buildTabItem(2, 'assets/payment.svg', viewUtil.isTablet ?30:26, 'payment'.tr(), selectedIndex, onTabTapped,context),
          _buildTabItem(3, 'assets/profile.svg', viewUtil.isTablet ?30:26, 'Profile'.tr(), selectedIndex, onTabTapped,context),
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
      BuildContext context,
      ) {
    ViewUtil viewUtil = ViewUtil(context);
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
                fontSize: viewUtil.isTablet ?23:14
              )
            ),
          ),
        ],
      ),
    );
  }

  void loadingDialog(BuildContext context, bool isProcessing){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Visibility(
          visible: isProcessing,
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 90),
              backgroundColor: Colors.white,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 50),
                      LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.blue,
                        size: 80,
                      ),
                      SizedBox(height: 50)
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == false) {
      commonWidgets.showToast('Could not launch phone call');
    }
  }

  Widget buildFileUploadButton({
    required BuildContext context,
    required String title,
    required Function(FilePickerResult?) onFileSelected,
    String? fileName,
    bool isTablet = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    '(Only PDF, DOC, DOCX allowed)',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff808080)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.065,
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf','docx','doc']
                );
                if (result != null) {
                  PlatformFile file = result.files.first;

                  if (file.size > 100 * 1024) { // 100 KB
                    commonWidgets.showToast('File must be 100 KB or less');
                    return;
                  }

                  onFileSelected(result);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.file_upload_outlined,
                      color: Colors.black,
                      size: isTablet ? 30 : 25,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      fileName ?? 'Upload a file',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPictureFileUploadButton({
    required BuildContext context,
    required String title,
    required Function(FilePickerResult?) onFileSelected,
    String? fileName,
    bool isTablet = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    '(Only JPG, PNG, JPEG, SVG allowed)',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff808080)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.065,
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
                );
                if (result != null) {
                  PlatformFile file = result.files.first;

                  if (file.size > 100 * 1024) {
                    commonWidgets.showToast('File must be 100 KB or less');
                    return;
                  }

                  onFileSelected(result);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.file_upload_outlined,
                      color: Colors.black,
                      size: isTablet ? 30 : 25,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      fileName ?? 'Upload a file',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCarouselItem(BuildContext context, {
    required Widget svgWidget,
    required String text,
    bool alignRight = false,
  }) {
    ViewUtil viewUtil = ViewUtil(context);
    bool isTablet = viewUtil.isTablet;
    return Stack(
      children: [
        Container(
          height: isTablet
              ? MediaQuery.sizeOf(context).height * 0.35
              : MediaQuery.sizeOf(context).height * 0.22,
          width: double.infinity,
          child: svgWidget,
        ),
        Positioned(
          top: isTablet ? 24 : 14,
          left: alignRight ? null : (isTablet ? 24 : 16),
          right: alignRight ? (isTablet ? 24 : 16) : null,
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdown({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 24 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          value: selectedValue,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: isTablet ? 20 : 14,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onChanged: onChanged,
          icon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.keyboard_arrow_down, size: 25),
          ),
          hint: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text('${'Select'.tr()} ${label.tr()}'),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Row(
                    children: [
                      Text(item.tr()),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

      ],
    );
  }

  Widget buildCargoLabeledTextField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
    required bool isTablet,
    required String selectedUnit,
    required Function(String?) onUnitChanged,
    String hintText = '',
  }) {
    final List<String> units = ['mm', 'cm', 'feet','inch'];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isTablet ? 24 : 16),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              child: const VerticalDivider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText.tr(),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                value: selectedUnit,
                items: units.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: onUnitChanged,
              ),
            ),
          ),
          SizedBox(width: 10)
        ],
      ),
    );
  }

  Locale normalizeLocaleFromLocale(Locale locale) {
    if (locale.languageCode == 'ars') {
      return const Locale('ar', 'SA');
    }
    return locale;
  }



}
