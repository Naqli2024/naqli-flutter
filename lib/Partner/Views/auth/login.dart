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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      _authService.loginUser(
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
                  builder: (context) => const PartnerHomePage(mobileNo: '', partnerName: '', password: '',partnerId: '', token: '',),
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
                      margin: const EdgeInsets.only(top: 25, bottom: 7),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 30),
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
                            margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                            alignment: Alignment.topLeft,
                            child: const Text(
                              'Mobile No/Email ID',
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
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
  void showforgotPasswordBottomSheet(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0,
            maxChildSize: 0.75,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.sizeOf(context).width,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: const Text(
                              'Forgot password',
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Form(
                              key: otpKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  commonWidgets.buildTextField('Email ID', forgotPasswordEmailController),
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
                                          if (otpKey.currentState!.validate()) {
                                            _authService.forgotPassword(
                                              context,
                                                  (context) {
                                                forgotPasswordResetBottomSheet(context);
                                                return Container();
                                              },
                                              email: forgotPasswordEmailController.text,
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Send',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
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
                      Positioned(
                        top: -15,
                        right: -10,
                        child: IconButton(
                          alignment: Alignment.topRight,
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(FontAwesomeIcons.multiply),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  void forgotPasswordResetBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0,
          maxChildSize: 0.75,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: passwordKey,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    width: MediaQuery.sizeOf(context).width,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: const Text(
                                  'Forgot password',
                                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'OTP',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                            width: 40,
                                            child: TextField(
                                              controller: otpControllers[index],
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
                                  commonWidgets.buildTextField(
                                    'New Password',
                                    forgotPasswordController,
                                    obscureText: isNewPasswordObscured,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isNewPasswordObscured ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isNewPasswordObscured = !isNewPasswordObscured;
                                        });
                                      },
                                    ),
                                  ),
                                  commonWidgets.buildTextField(
                                    'Confirm New Password',
                                    confirmPasswordController,
                                    obscureText: isConfirmPasswordObscured,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isConfirmPasswordObscured = !isConfirmPasswordObscured;
                                        });
                                      },
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
                                          if (passwordKey.currentState!.validate()) {
                                            String otp = otpControllers.map((controller) => controller.text).join();
                                            _authService.forgotPasswordReset(
                                                context,
                                                otp: otp,
                                                newPassword: forgotPasswordController.text,
                                                confirmNewPassword: confirmPasswordController.text
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Reset Password',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Didn’t send OTP?',
                                          style: const TextStyle(color: Colors.black,fontSize: 17),
                                        ),
                                        TextSpan(
                                          text: 'Resend',
                                          style: const TextStyle(color: Color(0xff6A66D1),fontSize: 17),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              for (var controller in otpControllers) {
                                                controller.clear();
                                              }
                                              _authService.forgotPasswordResendOTP(
                                                  context,
                                                  email: forgotPasswordEmailController.text);
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: -15,
                            right: -10,
                            child: IconButton(
                              alignment: Alignment.topRight,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                    partnerName: '',
                                    mobileNo: '',
                                    password: '',
                                    token: '',
                                    partnerId: '',
                                  ),
                                ),
                              ),
                              icon: Icon(FontAwesomeIcons.multiply),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

}
