import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class RegisterStepTwo extends StatefulWidget {
  final String name;
  final String mobileNo;
  final String emailId;
  final String password;
  final String selectedRole;
  const RegisterStepTwo({super.key, required this.name, required this.mobileNo, required this.emailId, required this.password, required this.selectedRole});

  @override
  State<RegisterStepTwo> createState() => _RegisterStepTwoState();
}

class _RegisterStepTwoState extends State<RegisterStepTwo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController bankController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController ibinController = TextEditingController();
  final TextEditingController CRNumberController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool isPasswordObscured = true;

  Future<void> _submitForm() async {
    setState(() {
      isLoading = true;
    });
    await _authService.registerPartner(
        context,
        partnerName: widget.name,
        mobileNo: widget.mobileNo,
        email: widget.emailId,
        password: widget.password,
        role: widget.selectedRole,
        region: regionController.text,
        city: cityController.text,
        bankName: bankController.text,
        companyName: companyController.text,
        ibanCode: ibinController.text,
        CRNumber: CRNumberController.text
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
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
                    'assets/register_stepTwo.svg',
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
                          size: viewUtil.isTablet?26: 20,
                        ),
                      ),
                    )),
              ),
            ],
          ),
                ),
                body: SingleChildScrollView(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  textCapitalization: TextCapitalization.sentences,
                  context: context,
                  controller: regionController,
                  label: 'Region'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your region'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: cityController,
                  label: 'City'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: bankController,
                  label: 'Bank Name'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bank name'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: companyController,
                  label: 'Company Name'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bank name'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: ibinController,
                  label: 'IBAN Code'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your iban code'.tr();
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  context: context,
                  controller: CRNumberController,
                  label: 'ID/CR Number'.tr(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID/CR number'.tr();
                    }
                    return null;
                  },
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
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
                            fontSize: viewUtil.isTablet?27:18,
                            fontWeight: FontWeight.w500),
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
}


Widget _buildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  bool obscureText = false,
  TextCapitalization textCapitalization = TextCapitalization.none,
  String? Function(String?)? validator,
}) {
  ViewUtil viewUtil = ViewUtil(context);
  return Padding(
    padding: const EdgeInsets.fromLTRB(40, 10, 40, 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: viewUtil.isTablet ?24 :20,color: Color(0xff828080)),
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
