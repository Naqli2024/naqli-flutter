import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_naqli/Viewmodel/services.dart';
import 'package:flutter_naqli/Views/auth/role.dart';
import 'package:flutter_naqli/Views/home_page.dart';

class LoginPage extends StatefulWidget {
final String partnerName;
final String mobileNo;
final String password;
  const LoginPage({super.key, required this.partnerName, required this.mobileNo, required this.password});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final AuthService _authService = AuthService();

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailOrMobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _authService.loginUser(
        context,
        emailOrMobile: emailOrMobileController.text,
        password: passwordController.text,
        partnerName: widget.partnerName,
        mobileNo: widget.mobileNo,
      );
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(color: Colors.white,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        )
        : Scaffold(
      appBar: AppBar(
        toolbarHeight: 250.0,
        backgroundColor: const Color(0xff6A66D1),
        title: Center(
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.fitWidth,
            width: 200,
            height: 200,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(mobileNo: '', partnerName: '', password: '',partnerId: '',),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: Color(0xffB5B3F0),
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xff6A66D1),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.only(topRight: Radius.circular(95)),
              child: Container(
                color: Colors.white,
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 40, bottom: 7),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                    const Text(
                      'Sign in to Continue',
                      style: TextStyle(fontSize: 20),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 40, 30, 10),
                            alignment: Alignment.topLeft,
                            child: const Text(
                              'Partner ID/Mobile No/Email ID',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                            child: TextFormField(
                              controller: emailOrMobileController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your ID, Mobile No, or Email';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                            alignment: Alignment.topLeft,
                            child: const Text(
                              'Password',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Color(0xff6A66D1), fontSize: 15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6A66D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            login();
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Role(),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
