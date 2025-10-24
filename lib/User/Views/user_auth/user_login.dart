import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_register.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final _formKey = GlobalKey<FormState>();
  final userOtpKey = GlobalKey<FormState>();
  final userPasswordOtpKey = GlobalKey<FormState>();
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  final TextEditingController forgotPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  bool isLoading = false;
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  bool isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void userLogin() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });
      await userService.userLogin(
        context,
        emailAddress: emailAddressController.text,
        password: passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(context, MaterialPageRoute(builder:  (context) => UserHomePage()));
          return false;
        },
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: MediaQuery.sizeOf(context).height * 0.35,
                                color: const Color(0xff6A66D1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/logo.svg',
                                      fit: BoxFit.fitWidth,
                                      width: 200,
                                      height: 200,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 30,right: 20),
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const UserHomePage(),
                                          ),
                                        );
                                      },
                                      child: const CircleAvatar(
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
                          Container(
                            color: const Color(0xff6A66D1),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(95)),
                                  child: Container(
                                    height: MediaQuery.sizeOf(context).height * 0.7,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 25, bottom: 7),
                                          child: Text(
                                            'Login'.tr(),
                                            style: TextStyle(
                                              fontSize: viewUtil.isTablet ?35 :28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Sign in to Continue'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ?20 :16),
                                        ),
                                        Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'EMAIL ID'.tr(),
                                                  style: TextStyle(
                                                    fontSize: viewUtil.isTablet ?20 :15,
                                                    color: Color(0xff707070),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                                                child: TextFormField(
                                                  controller: emailAddressController,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: Color(0xffBCBCBC), width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter your Email ID'.tr();
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'PASSWORD'.tr(),
                                                  style: TextStyle(
                                                    fontSize: viewUtil.isTablet ?20 :15,
                                                    color: Color(0xff707070),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                                child: TextFormField(
                                                  controller: passwordController,
                                                  obscureText: isPasswordObscured,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          isPasswordObscured = !isPasswordObscured;
                                                        });
                                                      },
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: Color(0xffBCBCBC), width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter your password'.tr();
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const UserForgotPassword()),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              'Forgot Password?'.tr(),
                                              style: TextStyle(
                                                  color: Color(0xff6A66D1), fontSize: viewUtil.isTablet ?20 :15),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: viewUtil.isTablet
                                              ? MediaQuery.of(context).size.height * 0.06
                                              : MediaQuery.of(context).size.height * 0.07,
                                            width: MediaQuery.of(context).size.width * 0.5,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xff6A66D1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                userLogin();
                                              },
                                              child: Text(
                                                'Log in'.tr(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: viewUtil.isTablet ?23 :18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const UserRegister()),
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
                                            child: Text(
                                              'Create Account'.tr(),
                                              style: TextStyle(
                                                color: Color(0xff6A66D1),
                                                fontSize: viewUtil.isTablet ?20 :15,
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
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

}
