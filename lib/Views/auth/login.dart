import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_naqli/Views/auth/role.dart';
import 'package:flutter_naqli/Views/booking/booking_details.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 250.0,
          backgroundColor: const Color(0xff6A66D1),
          title: Center(
              child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.fitWidth,
            width: 200,
            height: 200,
          )),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
                    )),
              ),
            )
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
                        'Sign in Continue',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(30, 40, 30, 10),
                          alignment: Alignment.topLeft,
                          child: const Text(
                            'Partner id/Mobile No/Mail id',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                          alignment: Alignment.topLeft,
                          child: const Text(
                            'Password',
                            style: TextStyle(fontSize: 20),
                          )),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: const Text(
                          'Forget Password?',
                          style:
                              TextStyle(color: Color(0xff6A66D1), fontSize: 15),
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const BookingDetails()));
                              },
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Role()));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 30),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Color(0xff6A66D1),
                            width: 1.0,
                          ))),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color(0xff6A66D1),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
