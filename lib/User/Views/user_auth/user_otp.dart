import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class UserOTP extends StatefulWidget {
  final String emailAddress;
  final String contactNumber;
  const UserOTP({super.key, required this.emailAddress, required this.contactNumber});

  @override
  State<UserOTP> createState() => _UserOTPState();
}

class _UserOTPState extends State<UserOTP> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  int _seconds = 120;
  Timer? _timer;
  final UserService userService = UserService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
  }

  void validateOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if(otp.isEmpty){
      CommonWidgets().showToast('please_enter_otp'.tr());
    }
    setState(() {
      isLoading = true;
    });
    await userService.verifyUserOTP(
        context,
        otp:otp,
    );
    setState(() {
      isLoading = false;
    });
  }

  void resendOtp() async {
    _startTimer();
    for (var controller in _otpControllers) {
      controller.clear();
    }
    await userService.resendUserOTP(
      context,
      emailAddress:widget.emailAddress,
    );
  }


  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.of(context).size.height * 0.31,
          title: Stack(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/otp_logo.svg',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: viewUtil.isTablet?280:200,
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserHomePage()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Color(0xffFFFFFF),
                          child: Icon(
                            Icons.clear,
                            color: Colors.black,
                            size: viewUtil.isTablet?26: 20,
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
            child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'otp_verification'.tr(),
                  style: TextStyle(
                      fontSize: viewUtil.isTablet?26: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    '${'enter_otp'.tr()} ${widget.contactNumber}',
                    style: TextStyle(color: Colors.black, fontSize: viewUtil.isTablet?20: 15),
                  ),
                ),
                Text(
                  "$_formattedTime",
                  style: TextStyle(fontSize: viewUtil.isTablet?20: 16, color: Colors.blue),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width:viewUtil.isTablet? 50: 40,
                          child: TextField(
                            controller: _otpControllers[index],
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: resendOtp,
                  child: RichText(
                    text: TextSpan(
                      text: "didn't_receive_otp".tr(),
                      style: TextStyle(color: Colors.black, fontSize: viewUtil.isTablet?20: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'resend'.tr(),
                          style: TextStyle(
                            color: Colors.blue,
                              fontSize: viewUtil.isTablet?20: 15
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: validateOtp,
                        child: Text(
                          'verify_continue'.tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet? 22: 15,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
