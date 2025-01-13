import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class UserForgotPassword extends StatefulWidget {
  const UserForgotPassword({super.key});

  @override
  State<UserForgotPassword> createState() => _UserForgotPasswordState();
}

class _UserForgotPasswordState extends State<UserForgotPassword> {
  final otpKey = GlobalKey<FormState>();
  final UserService userService = UserService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  bool isLoading = false;
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SvgPicture.asset(
              'assets/naqlee-logo.svg',
              fit: BoxFit.fitWidth,
              height: viewUtil.isTablet ? 45 : 40,
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
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Form(
                key: otpKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/forgotLogo.svg',height: MediaQuery.sizeOf(context).height * 0.3,),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text('Forgot Password?'.tr(),
                        style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: viewUtil.isTablet ? 30 : 25,
                      ),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5,bottom: 40),
                      child: Text("We'll send you reset instruction".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: viewUtil.isTablet ? 22 : 17,
                        ),),
                    ),
                    commonWidgets.buildTextField('Email'.tr(), emailController,context: context),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6A66D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (otpKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              await userService.userForgotPassword(
                                context,
                                emailAddress: emailController.text,
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: Text(
                            'Reset Password'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet ? 26 : 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserLogin()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back),
                            Text("Back to login".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: viewUtil.isTablet ? 26 : 20,
                              ),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class UserResetPassword extends StatefulWidget {
  final String emailAddress;
  const UserResetPassword({super.key, required this.emailAddress});

  @override
  State<UserResetPassword> createState() => _UserResetPasswordState();
}

class _UserResetPasswordState extends State<UserResetPassword> {
  final passwordKey = GlobalKey<FormState>();
  final UserService userService = UserService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  bool isLoading = false;

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
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SvgPicture.asset(
                'assets/naqlee-logo.svg',
                fit: BoxFit.fitWidth,
                height: viewUtil.isTablet ? 45 : 40,
              ),
            ),
          ),
          body:  isLoading
              ? const Center(
              child: CircularProgressIndicator())
              : Form(
                key: passwordKey,
                child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.sizeOf(context).width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/verifyOtp.svg',
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      width: MediaQuery.sizeOf(context).width),
                    Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 30),
                      child: Text('Enter your verification code'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: viewUtil.isTablet ? 30 : 25,
                        ),),
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
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey)
                                ),
                                child: SizedBox(
                                  width: viewUtil.isTablet ?50 :40,
                                  child: TextField(
                                    controller: otpControllers[index],
                                    maxLength: 1,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6A66D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async{
                                String otp = otpControllers.map((controller) => controller.text).join();

                                if (otp.length < otpControllers.length) {
                                  commonWidgets.showToast('Please enter the complete OTP'.tr());
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserSetNewPassword(otp: otp), // Pass the combined OTP here
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Continue'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: viewUtil.isTablet ? 26 : 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Didn’t receive the email?'.tr(),
                                style: TextStyle(color: Colors.black,fontSize:viewUtil.isTablet ?20 :16),
                              ),
                              TextSpan(
                                text: 'Click to resend'.tr(),
                                style: TextStyle(color: Color(0xff6A66D1),fontSize: viewUtil.isTablet ?20 :16,decoration: TextDecoration.underline,),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async{
                                    for (var controller in otpControllers) {
                                      controller.clear();
                                    }
                                    await userService.userForgotPasswordResendOTP(
                                        context,
                                        emailAddress: widget.emailAddress);
                                  },
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserLogin()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back),
                                Text("Back to login".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: viewUtil.isTablet ? 26 : 20,
                                  ),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                ),
              )
      ),
    );
  }
}

class UserSetNewPassword extends StatefulWidget {
  final String otp;
  const UserSetNewPassword({super.key, required this.otp});

  @override
  State<UserSetNewPassword> createState() => _UserSetNewPasswordState();
}

class _UserSetNewPasswordState extends State<UserSetNewPassword> {
  final passwordKey = GlobalKey<FormState>();
  final UserService userService = UserService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  bool isLoading = false;

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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SvgPicture.asset(
              'assets/naqlee-logo.svg',
              fit: BoxFit.fitWidth,
              height: viewUtil.isTablet ? 45 : 40,
            ),
          ),
        ),
          body:  isLoading
              ? const Center(
              child: CircularProgressIndicator())
              : Form(
            key: passwordKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.sizeOf(context).width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/newPassword.svg',
                        height: MediaQuery.sizeOf(context).height * 0.25,
                        width: MediaQuery.sizeOf(context).width),
                    Padding(
                      padding: const EdgeInsets.only(top: 30,bottom: 30),
                      child: Text('Set new password'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: viewUtil.isTablet ? 30 : 25,
                        ),),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        commonWidgets.buildTextField(
                          'Password'.tr(),
                          passwordController,
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
                          ),context: context
                        ),
                        commonWidgets.buildTextField(
                          'Confirm Password'.tr(),
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
                          ),context: context
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6A66D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async{
                                if (passwordKey.currentState!.validate()) {
                                  String otp = otpControllers.map((controller) => controller.text).join();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await userService.userForgotPasswordReset(
                                      context,
                                      otp: widget.otp,
                                      newPassword: passwordController.text,
                                      confirmNewPassword: confirmPasswordController.text
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              child: Text(
                                'Reset Password'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: viewUtil.isTablet ? 26 : 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserLogin()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back),
                                Text("Back to login".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: viewUtil.isTablet ? 26 : 20,
                                  ),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}


class UserForgotPasswordSuccess extends StatefulWidget {
  const UserForgotPasswordSuccess({super.key});

  @override
  State<UserForgotPasswordSuccess> createState() => _UserForgotPasswordSuccessState();
}

class _UserForgotPasswordSuccessState extends State<UserForgotPasswordSuccess> {
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SvgPicture.asset(
              'assets/naqlee-logo.svg',
              fit: BoxFit.fitWidth,
              height: viewUtil.isTablet ? 45 : 40,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 40),
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset('assets/resetSuccess.svg',
                    height: MediaQuery.sizeOf(context).height * 0.25,
                    width: MediaQuery.sizeOf(context).width),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20,top: 40),
                child: Text('Your password has been reset'.tr(),
                    style: TextStyle(
                        fontSize: viewUtil.isTablet ?28:23,fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text('Successfully'.tr(),
                    style: TextStyle(
                        fontSize: viewUtil.isTablet ?29:23,fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6A66D1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async{
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserLogin()));
                    },
                    child: Text(
                      'Continue'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: viewUtil.isTablet ? 26 : 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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






