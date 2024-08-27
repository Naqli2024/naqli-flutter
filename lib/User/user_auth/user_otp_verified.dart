import 'package:flutter/material.dart';
import 'package:flutter_naqli/User/user_auth/user_login.dart';

class OTPVerified extends StatefulWidget {
  const OTPVerified({super.key});

  @override
  State<OTPVerified> createState() => _OTPVerifiedState();
}

class _OTPVerifiedState extends State<OTPVerified> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const UserLogin()
        ),
      );
    });
  }

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
                'assets/otp_verified.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: 200,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserLogin()
                  ),
                );
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text('Verified',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text('Your number have been verified successfully',
                style: TextStyle(
                  fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
