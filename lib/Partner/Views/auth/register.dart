import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

class Register extends StatefulWidget {
  final String selectedRole;
  final String partnerId;
  final String token;

  const Register({Key? key, required this.selectedRole, required this.partnerId, required this.token}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool isPasswordObscured = true;

  Future<void> _submitForm() async {
      setState(() {
        isLoading = true;
      });
        await _authService.registerUser(
          context,
          partnerName: nameController.text,
          mobileNo: mobileController.text,
          email: emailController.text,
          password: passwordController.text,
          role: widget.selectedRole,
          partnerId: widget.partnerId,
          token: ''
        );
        setState(() {
          isLoading = false;
        });
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.of(context).size.height * 0.31,
          title: Stack(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/Register.svg',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Color(0xffFFFFFF),
                        child: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  textCapitalization: TextCapitalization.sentences,
                  context: context,
                  controller: nameController,
                  label: 'Name'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: mobileController,
                  label: 'Mobile No'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: emailController,
                  label: 'Email ID'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email ID'.tr();
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address'.tr();
                    }
                    return null;
                  },
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(40, 15, 40, 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Password'.tr(),
                    style: TextStyle(fontSize: 20,color: Color(0xff828080)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 30),
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
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xff828080),
                        ),
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
                Container(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6269FE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitForm();
                        }
                      },
                      child: Text(
                        'Register'.tr(),
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
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20,color: Color(0xff828080)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            textCapitalization: textCapitalization,
            controller: controller,
            obscureText: obscureText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff828080),
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            validator: validator, // Add the validator here
          ),
        ],
      ),
    );
  }
}
