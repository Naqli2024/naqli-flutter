import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_register.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void userLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await userService.userLogin(
        context,
        emailAddress: emailAddressController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(context, MaterialPageRoute(builder:  (context) => UserHomePage()));
          return false;
        },
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
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 25, bottom: 7),
                                        child: const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Sign in to Continue',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                                              alignment: Alignment.topLeft,
                                              child: const Text(
                                                'EMAIL ID',
                                                style: TextStyle(
                                                  fontSize: 15,
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
                                                    return 'Please enter your Email ID';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                                              alignment: Alignment.topLeft,
                                              child: const Text(
                                                'PASSWORD',
                                                style: TextStyle(
                                                  fontSize: 15,
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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const UserForgotPassword()),
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
                                              userLogin();
                                            },
                                            child: const Text(
                                              'Log in',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal,
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
                                          child: const Text(
                                            'Create Account',
                                            style: TextStyle(
                                              color: Color(0xff6A66D1),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {

                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 7,bottom: 10),
                                          child: const Text(
                                            'Use without Login',
                                            style: TextStyle(
                                              color: Color(0xff6A66D1),
                                              fontSize: 12,
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
    );
  }

}
