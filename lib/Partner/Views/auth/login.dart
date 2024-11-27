import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Views/auth/forgotPassword.dart';
import 'package:flutter_naqli/Partner/Views/auth/role.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class LoginPage extends StatefulWidget {
final String partnerName;
final String mobileNo;
final String password;
final String token;
final String partnerId;
  const LoginPage({super.key, required this.partnerName, required this.mobileNo, required this.password, required this.token, required this.partnerId});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final otpKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController emailOrMobileController = TextEditingController();
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
  void dispose() {
    emailOrMobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _authService.loginUser(
        context,
        emailOrMobile: emailOrMobileController.text,
        password: passwordController.text,
        partnerName: widget.partnerName,
        mobileNo: emailOrMobileController.text,
        token: widget.token,
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
        : WillPopScope(
            onWillPop: () async {
              Navigator.push(context, MaterialPageRoute(builder:  (context) => PartnerHomePage(mobileNo: '', partnerName: '', password: '', partnerId: '', token: '')));
              return false;
            },
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
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
                                  builder: (context) => const PartnerHomePage(mobileNo: '', partnerName: '', password: '',partnerId: '', token: '',),
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
                          borderRadius:
                          const BorderRadius.only(topRight: Radius.circular(95)),
                          child: Container(
                            height: MediaQuery.sizeOf(context).height * 0.7,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 25, bottom: 7),
                                  child: Text(
                                    'Partner Login'.tr(),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                                Text(
                                  'Sign in to Continue'.tr(),
                                  style: TextStyle(fontSize: 20),
                                ),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Mobile No/Email ID'.tr(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                                        child: TextFormField(
                                          controller: emailOrMobileController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your Mobile No or Email'.tr();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Password'.tr(),
                                          style: TextStyle(fontSize: 20),
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
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'Forgot Password?'.tr(),
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
                                      child: Text(
                                        'Log in'.tr(),
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
                                    child: Text(
                                      'Create Account'.tr(),
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
                  )
                ],
              ),
            ),
                  ),
                ),
          ),
        );
  }
}
