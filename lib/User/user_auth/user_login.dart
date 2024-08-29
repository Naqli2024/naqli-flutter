import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/User/user_auth/user_register.dart';
import 'package:flutter_naqli/User/user_createBooking/user_booking.dart';
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
  final AuthService _authService = AuthService();
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
      // _authService.loginUser(
      //   context,
      //   emailOrMobile: emailOrMobileController.text,
      //   password: passwordController.text,
      //   partnerName: widget.partnerName,
      //   mobileNo: emailOrMobileController.text,
      //   token: widget.token,
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CreateBooking()
        ),
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
                              controller: emailOrMobileController,
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
                        showforgotPasswordBottomSheet(context);
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

  void showforgotPasswordBottomSheet(BuildContext context) {
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
            return  Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.sizeOf(context).width,
              child: SingleChildScrollView(
                child:  Stack(
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
                            key: userOtpKey,
                            child: Container(
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
                                          if (userOtpKey.currentState!.validate()) {
                                            forgotPasswordResetBottomSheet(context);
                                          }
                                        },
                                        child: const Text(
                                          'Send',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(FontAwesomeIcons.multiply)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void forgotPasswordResetBottomSheet(BuildContext context) {
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
            return  StatefulBuilder(
              builder: (BuildContext context, StateSetter setState){
                return Form(
                  key: userPasswordOtpKey,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    width: MediaQuery.sizeOf(context).width,
                    child: SingleChildScrollView(
                      child:  Stack(
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
                                                offset: const Offset(0, 3), // changes position of shadow
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
                                          userPasswordOtpKey.currentState!.validate();
                                        },
                                        child: const Text(
                                          'Reset Password',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
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
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => UserLogin()
                                      )
                                  );
                                },
                                icon: Icon(FontAwesomeIcons.multiply)),
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
