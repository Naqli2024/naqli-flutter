import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class OtpScreen extends StatefulWidget {
  final String mobileNo;
  final String email;
  final String password;
  final String partnerName;
  final String partnerId;

  const OtpScreen({Key? key, required this.mobileNo, required this.email, required this.password, required this.partnerName, required this.partnerId}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  int _seconds = 120;
  Timer? _timer;
  final AuthService _authService = AuthService();
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
    await _authService.validateOTP(
              context,
              email: widget.email,
              password: widget.password,
              mobileNo: widget.mobileNo,
              otp:otp,
              partnerName: widget.partnerName,
              partnerId: widget.partnerId
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
    String otp = _otpControllers.map((controller) => controller.text).join();
    await _authService.resendOTP(
        context,
        email: widget.email,
        password: widget.password,
        mobileNo: widget.mobileNo,
        partnerName: widget.partnerName,
        partnerId: widget.partnerId
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
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
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
                    MaterialPageRoute(builder: (context) => const PartnerHomePage()),
                  );
                },
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
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('otp_verification'.tr(),
                    style: TextStyle(
                        fontSize: viewUtil.isTablet?26:20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500)),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text('${'enter_otp'.tr()} ${widget.mobileNo}',
                    style: TextStyle(color: Colors.black, fontSize: viewUtil.isTablet?22: 15),),
                ),
                Text(
                  "$_formattedTime",
                  style: TextStyle(fontSize: viewUtil.isTablet?20: 16,color: Colors.blue),
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
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: viewUtil.isTablet? 50: 40,
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
                  onTap:resendOtp,
                  child: RichText(
                    text: TextSpan(
                      text: "didn't_receive_otp".tr(),
                      style: TextStyle(color: Colors.black, fontSize: viewUtil.isTablet?20:15),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'resend'.tr(),
                          style: TextStyle(
                            color: Colors.blue,
                              fontSize: viewUtil.isTablet?20:15
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
                              fontSize: viewUtil.isTablet? 24:18,
                              fontWeight: FontWeight.w500),
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
