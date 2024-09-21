import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final otpKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  final TextEditingController forgotPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  bool isLoading = false;
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            backgroundColor: const Color(0xff6A66D1),
            title: const Center(
              child: Text(
                'Forgot Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator())
          : Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Form(
                key: otpKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          onPressed: () async{
                            if (otpKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              await _authService.forgotPassword(
                                context,
                                    (context) => ResetPassword(),
                                email: forgotPasswordEmailController.text,
                              );
                              setState(() {
                                isLoading = false;
                              });
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
      ),
            ),
    );
  }
}


class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final passwordKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  final TextEditingController forgotPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              backgroundColor: const Color(0xff6A66D1),
              title: const Center(
                child: Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator())
          : Form(
        key: passwordKey,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.sizeOf(context).width,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _authService.forgotPasswordReset(
                                      context,
                                      otp: otp,
                                      newPassword: forgotPasswordController.text,
                                      confirmNewPassword: confirmPasswordController.text
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
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
              ],
            ),
          ),
        ),
      )
    );
  }
}

