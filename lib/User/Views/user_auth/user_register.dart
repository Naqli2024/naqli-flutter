import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_mobileno.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController firstNameController =TextEditingController();
  final TextEditingController lastNameController =TextEditingController();
  final TextEditingController emailController =TextEditingController();
  final TextEditingController passwordController =TextEditingController();
  final TextEditingController confirmPasswordController =TextEditingController();
  final TextEditingController contactNoController =TextEditingController();
  final TextEditingController alternateNoController =TextEditingController();
  final TextEditingController address1Controller =TextEditingController();
  final TextEditingController address2Controller =TextEditingController();
  final TextEditingController cityController =TextEditingController();
  final TextEditingController idNoController =TextEditingController();
  final registerKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  String? selectedAccount;
  String? selectedId;
  final List<String> accountItems = ['Single User', 'Super User', 'Enterprise User'];
  final List<String> govtIdItems = ['iqama No', 'national ID'];
  final UserService userService = UserService();

  void registerUser(){
    if (registerKey.currentState!.validate()) {
      userService.userRegister(
          context,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          emailAddress: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
          contactNumber: contactNoController.text,
          alternateNumber: alternateNoController.text,
          address1: address1Controller.text,
          address2: address2Controller.text,
          city: cityController.text,
          accountType: selectedAccount.toString(),
          govtId: selectedId.toString(),
          idNumber: idNoController.text
      );
    }
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          'assets/naqlee-logo.svg',
          fit: BoxFit.fitWidth,
          height: 40,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff6A66D1),
            title: const Center(
              child: Text(
                'Create your account',
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
      body: SingleChildScrollView(
        child: Form(
          key: registerKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: commonWidgets.buildTextField('First Name', firstNameController),
            ),
            commonWidgets.buildTextField('Last Name', lastNameController),
            commonWidgets.buildTextField('Email Address', emailController),
              commonWidgets.buildTextField(
                'Password',
                passwordController,
                obscureText: isPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordObscured = !isPasswordObscured;
                    });
                  },
                ),),
            commonWidgets.buildTextField(
              'Confirm Password',
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
            ),),
            commonWidgets.buildTextField('Contact Number', contactNoController),
            commonWidgets.buildTextField('Alternate Number', alternateNoController),
            commonWidgets.buildTextField('Address 1', address1Controller),
            commonWidgets.buildTextField('Address 2', address2Controller),
            commonWidgets.buildTextField('City', cityController),
            accountDropdownWidget(),
            govtIdDropdownWidget(),
              commonWidgets.buildTextField('Id Number', idNoController),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      value: _isChecked,
                      onChanged: _onCheckboxChanged,
                      checkColor: Colors.white,
                      activeColor: Color(0xff6A66D1),
                      shape: CircleBorder(),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                          const TextSpan(
                                    text: 'Agree with',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' Terms & Conditions',
                                    style: const TextStyle(color: Color(0xff6A66D1), fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {

                                      },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6269FE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: registerUser,
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Already have an account?',
                        style: const TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: ' Sign in',
                        style: const TextStyle(color: Color(0xff6A66D1)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserLogin(),
                              ),
                            );
                          },
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

  Widget accountDropdownWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              'Account type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DropdownButtonFormField<String>(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              value: selectedAccount,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedAccount = newValue;
                });
              },
              hint: const Text('Account type'),
              icon: const Icon(Icons.keyboard_arrow_down, size: 25),
              items: accountItems.map((account) {
                return DropdownMenuItem<String>(
                  value: account,
                  child: Text(account),
                );
              }).toList(),
              validator: (value) =>
              value == null ? 'Please select an account type' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget govtIdDropdownWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              'Govt ID',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DropdownButtonFormField<String>(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              value: selectedId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedId = newValue;
                });
              },
              hint: const Text('Govt ID'),
              icon: const Icon(Icons.keyboard_arrow_down, size: 25),
              items: govtIdItems.map((id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(id),
                );
              }).toList(),
              validator: (value) =>
              value == null ? 'Please select a Govt ID' : null,
            ),
          ),
        ],
      ),
    );
  }

}
