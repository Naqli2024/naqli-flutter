import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_register.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/user_home_page.dart';
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

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void userLogin() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      userService.userLogin(
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
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserHomePage()
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
      body: isLoading
        ?const Center(child: CircularProgressIndicator(),)
        : Container(
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
                        style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),
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
                              style: TextStyle(fontSize: 15,color: Color(0xff707070)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                            child: TextFormField(
                              controller: emailAddressController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xffBCBCBC),width: 2),
                                  borderRadius: BorderRadius.circular(10),
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
                              style: TextStyle(fontSize: 15,color: Color(0xff707070)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xffBCBCBC),width: 2),
                                  borderRadius: BorderRadius.circular(10),
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
                              builder: (context) => const UserForgotPassword()
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
                            userLogin();
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
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const Role(),
                        //   ),
                        // );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 7),
                        child: const Text(
                          'Use without Login',
                          style: TextStyle(
                            color: Color(0xff6A66D1),
                            fontSize: 12
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
