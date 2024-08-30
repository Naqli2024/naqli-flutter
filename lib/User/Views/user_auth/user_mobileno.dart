
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_otp.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_register.dart';

class OTPMobileNo extends StatefulWidget {
  const OTPMobileNo({super.key});

  @override
  State<OTPMobileNo> createState() => _OTPMobileNoState();
}

class _OTPMobileNoState extends State<OTPMobileNo> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController mobileNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: MediaQuery.of(context).size.height * 0.31,
        title: Stack(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/otp_mobileno.png',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your Phone number',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text('We will send you a 4 digit verification code '),
              ),
              commonWidgets.buildTextField('', mobileNoController,labelText: 'Mobile no'),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserRegister(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff6A66D1),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color(0xff6A66D1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6269FE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserOTP(emailAddress: '',contactNumber: '',),
                          ),
                        );
                      },
                      child: const Text(
                        'GENERATE OTP',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
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
