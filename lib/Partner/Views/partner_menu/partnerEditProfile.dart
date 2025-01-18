import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';

class PartnerEditProfile extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String email;
  const PartnerEditProfile({super.key, required this.partnerName, required this.partnerId, required this.token, required this.email});

  @override
  State<PartnerEditProfile> createState() => _PartnerEditProfileState();
}

class _PartnerEditProfileState extends State<PartnerEditProfile> {
  final CommonWidgets commonWidgets = CommonWidgets();
  File? _profileImage;
  String? partnerEmailId;
  String? partnerMobileNo;
  String? partnerName;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails().then((data) {
      nameController.text = partnerName??'';
      mobileNoController.text = partnerMobileNo??'';
      emailController.text = partnerEmailId??'';
    }).catchError((e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    });
  }

  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      final bookingIds = await authService.getBookingData(widget.partnerId, widget.token);
      if (bookingIds.isEmpty) {
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final name = booking['name'] ?? 'Unknown Partner';
        final mobileNo = booking['mobileNo'] ?? 'No Mobile Number';
        final email = booking['email'] ?? 'No Email Address';

        partnerName = name;
        partnerMobileNo = mobileNo;
        partnerEmailId = email;
      }
      return bookingDetails;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.partnerName,
          showLeading: false,
          userId: widget.partnerId,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        'Edit Profile'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: viewUtil.isTablet?26:24),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                  size: viewUtil.isTablet?27: 24,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: viewUtil.isTablet?60:50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(Icons.person, color: Color(0xff6A66D1), size: viewUtil.isTablet?70:60)
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 1,
                      child: GestureDetector(
                        onTap: pickProfileImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: CircleAvatar(
                            maxRadius: viewUtil.isTablet?20:15,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, color: Colors.black, size: viewUtil.isTablet?20: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    commonWidgets.buildTextField('Partner Name'.tr(), nameController,context: context),
                    commonWidgets.buildTextField('Mobile No'.tr(), mobileNoController,context: context),
                    commonWidgets.buildTextField('Email Address'.tr(), emailController,context: context),
                    commonWidgets.buildTextField('Password'.tr(), passwordController,obscureText: isPasswordObscured,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordObscured = !isPasswordObscured;
                            });
                          },
                        ),context: context),
                    commonWidgets.buildTextField('Confirm Password'.tr(), confirmPasswordController,obscureText: isConfirmPasswordObscured,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordObscured = !isConfirmPasswordObscured;
                            });
                          },
                        ),context: context),
                    Container(
                      margin: const EdgeInsets.only(top:20,bottom: 20),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.057,
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6269FE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await authService.updatePartnerProfile(
                                  widget.partnerId,
                                  widget.token,
                                  _profileImage,
                                  nameController.text,
                                  mobileNoController.text,
                                  emailController.text,
                                  passwordController.text,
                                  confirmPasswordController.text
                              );
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Text(
                              'Save'.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: viewUtil.isTablet?25: 18,
                                  fontWeight: FontWeight.w500,),
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _profileImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }
}
