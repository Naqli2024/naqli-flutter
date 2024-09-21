import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';

class UserOTP extends StatefulWidget {
  final String emailAddress;
  final String contactNumber;
  const UserOTP({super.key, required this.emailAddress, required this.contactNumber});

  @override
  State<UserOTP> createState() => _UserOTPState();
}

class _UserOTPState extends State<UserOTP> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  int _seconds = 120; // Timer duration in seconds (e.g., 1 minute 30 seconds)
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
    _seconds = 120; // Reset the timer to the initial duration
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height * 0.31,
        title: Stack(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/otp_logo.png',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                )),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                child: const Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Color(0xffFFFFFF),
                      child: Icon(
                        Icons.clear,
                        color: Colors.black,
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
              const Text('OTP Verification',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text('Enter the OTP sent to ${widget.contactNumber}'),
              ),
              Text(
                "$_formattedTime",
                style: const TextStyle(fontSize: 16,color: Colors.blue),
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
                        width: 40,
                        child: TextField(
                          controller: _otpControllers[index],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            counterText: '',
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
                  text: const TextSpan(
                    text: "Didn't receive OTP?",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' Resend',
                        style: TextStyle(
                          color: Colors.blue,
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
                      child: const Text(
                        'VERIFY & CONTINUE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
