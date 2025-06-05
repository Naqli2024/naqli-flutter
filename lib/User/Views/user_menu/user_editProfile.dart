import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'dart:ui' as ui;
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';

class UserEditProfile extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const UserEditProfile({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController confirmPasswordController = TextEditingController();
  late TextEditingController contactNoController = TextEditingController();
  late TextEditingController altNoController = TextEditingController();
  late TextEditingController address1Controller = TextEditingController();
  late TextEditingController address2Controller = TextEditingController();
  late TextEditingController cityController = TextEditingController();
  late TextEditingController accountTypeController = TextEditingController();
  late TextEditingController idNoController = TextEditingController();
  File? _profileImage;
  String? selectedId;
  final List<String> govtIdItems = ['iqama No'.tr(), 'national ID'.tr()];
  late Future<UserDataModel> userData;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  bool isLoading = false;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    userData = userService.getUserData(widget.id,widget.token);
    userData.then((data) {
      firstNameController.text = data.firstName;
      lastNameController.text = data.lastName;
      emailController.text = data.emailAddress;
      contactNoController.text = data.contactNumber.toString();
      altNoController.text = data.alternateNumber;
      address1Controller.text = data.address1;
      address2Controller.text = data.address2;
      cityController.text = data.city;
      accountTypeController.text = data.accountType;
      idNoController.text = data.idNumber.toString();
      if (data.userProfile?.fileName != null) {
        profileImageUrl =
        'https://prod.naqlee.com/api/image/${data.userProfile!.fileName}';
      }

      setState(() {});
    }).catchError((e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    });
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

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false,
          userId: widget.id,
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
        body: Center(
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: userData,
              builder: (context,snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }else{
                  final data = snapshot.data!;
                  return Column(
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
                                maxRadius: viewUtil.isTablet ? 60 : 50,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!) as ImageProvider
                                    : null),
                                child: (_profileImage == null && profileImageUrl == null)
                                    ? Icon(Icons.person, color: Color(0xff6A66D1), size: viewUtil.isTablet ? 70 : 60)
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
                      commonWidgets.buildTextField('First Name'.tr(), firstNameController,context: context),
                      commonWidgets.buildTextField('Last Name'.tr(), lastNameController,context: context),
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
                      commonWidgets.buildTextField('Contact Number'.tr(), contactNoController,context: context),
                      commonWidgets.buildTextField('Alternate Number'.tr(), altNoController,context: context),
                      commonWidgets.buildTextField('Address 1'.tr(), address1Controller,context: context),
                      commonWidgets.buildTextField('Address 2'.tr(), address2Controller,context: context),
                      commonWidgets.buildTextField('City'.tr(), cityController,context: context),
                      commonWidgets.buildTextField('AccountType'.tr(), accountTypeController,readOnly: true,context: context),
                      govtIdDropdownWidget(data.govtId),
                      commonWidgets.buildTextField('Id Number'.tr(), idNoController,hintText: data.idNumber.toString(),context: context),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.055,
                          width: MediaQuery.of(context).size.width * 0.6,
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
                              await userService.updateProfile(
                                  widget.id,
                                  widget.token,
                                  _profileImage,
                                  firstNameController.text,
                                  lastNameController.text,
                                  emailController.text,
                                  passwordController.text,
                                  confirmPasswordController.text,
                                  contactNoController.text,
                                  address1Controller.text,
                                  address2Controller.text,
                                  cityController.text,
                                  accountTypeController.text,
                                  selectedId??"",
                                  idNoController.text
                              );
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Text(
                              'Save'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: viewUtil.isTablet?25: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget govtIdDropdownWidget(String govtId) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              'Govt ID'.tr(),
              style: TextStyle(fontSize: viewUtil.isTablet ?24 :20, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DropdownButtonFormField<String>(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              value: selectedId,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical:viewUtil.isTablet ?20 :14,horizontal:12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedId = newValue;
                });
              },
              hint: Text(govtId.tr()),
              icon: const Icon(Icons.keyboard_arrow_down, size: 25),
              items: govtIdItems.map((id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(id),
                );
              }).toList(),
              validator: (value) =>
              value == null ? 'Please select a Govt ID'.tr() : null,
            ),
          ),
        ],
      ),
    );
  }

}
