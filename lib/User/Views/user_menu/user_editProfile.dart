import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:ui' as ui;

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
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController contactNoController = TextEditingController();
  late TextEditingController altNoController = TextEditingController();
  late TextEditingController address1Controller = TextEditingController();
  late TextEditingController address2Controller = TextEditingController();
  late TextEditingController cityController = TextEditingController();
  File? _profileImage;

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
      print("Error picking profile image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
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
        body: Center(
          child: SingleChildScrollView(
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
                          maxRadius: 50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person, color: Color(0xff6A66D1), size: 60)
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
                            maxRadius: 15,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.black, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                commonWidgets.buildTextField('First Name'.tr(), firstNameController),
                commonWidgets.buildTextField('Last Name'.tr(), lastNameController),
                commonWidgets.buildTextField('Email Address'.tr(), emailController),
                commonWidgets.buildTextField('Password'.tr(), passwordController),
                commonWidgets.buildTextField('Contact Number'.tr(), contactNoController),
                commonWidgets.buildTextField('Alternate Number'.tr(), altNoController),
                commonWidgets.buildTextField('Address 1'.tr(), address1Controller),
                commonWidgets.buildTextField('Address 2'.tr(), address2Controller),
                commonWidgets.buildTextField('City'.tr(), cityController),
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

                      },
                      child: Text(
                        'Save'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
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
