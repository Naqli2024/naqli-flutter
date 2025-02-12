import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class UserRequestSupport extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const UserRequestSupport({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<UserRequestSupport> createState() => _UserRequestSupportState();
}

class _UserRequestSupportState extends State<UserRequestSupport> {
  final UserService userService = UserService();
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  File? documentFile;
  bool documentUpload = false;
  bool documentError = false;

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
            userId: widget.id
        ),
        body: isLoading
            ? const Center(
            child: CircularProgressIndicator())
            : Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.sizeOf(context).width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(child: Icon(FontAwesomeIcons.arrowLeft,size: 20,))),
                    Padding(
                      padding: const EdgeInsets.only(top: 5,left: 45),
                      child: Text('Request Support'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: viewUtil.isTablet? 30 :25,
                        ),),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 40),
                  child: RichText(
                    text: TextSpan(
                      text: "Feel free to contact us through our email, if you have any more questions".tr(),
                      style: TextStyle(
                        fontSize: viewUtil.isTablet? 22 :17,
                        color: Colors.black, // Set the text color
                      ),
                      children: [
                        TextSpan(
                          text: "sales@naqlee.com",
                          style: TextStyle(
                            fontSize: viewUtil.isTablet? 22 :17,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'sales@naqlee.com',
                              query: 'subject=Support&body=Hello, I have a question.',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Enter your Email address'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 23,
                      ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: TextFormField(
                    readOnly: true,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: widget.email,
                      hintStyle: TextStyle(color: Colors.grey)
                    ),
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 10),
                    child: Text('Description'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 23,
                      ),),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    maxLines: 10,
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Please be specific so that we can address it as soon as possible'.tr(),
                      hintStyle: TextStyle(fontSize: viewUtil.isTablet? 22 :17,color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40,bottom: 10),
                    child: Text('Supporting documentation(Optional)'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                      ),),
                  ),
                ),
               Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(left: 0, bottom: 10),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.065,
            width: MediaQuery.of(context).size.width * 0.6,
            child: DottedBorder(
              color: Colors.black,
              strokeWidth: 1,
              borderType: BorderType.RRect,
              dashPattern: [6, 3],
              radius: const Radius.circular(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.first.path != null) {
                      setState(() {
                        documentFile = File(result.files.first.path!);
                        documentUpload = true;
                        documentError = false;
                      });
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        documentUpload
                            ? documentFile!.path.split('/').last
                            : 'Upload a Document'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: viewUtil.isTablet? 22 :18,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                      onPressed: () async {
                        if(widget.email.isNotEmpty && descriptionController.text.isNotEmpty)
                          {
                            setState(() {
                              isLoading = true;
                            });
                            await userService.userSubmitTicket(
                                context,
                                reportMessage: descriptionController.text,
                                email: widget.email,
                                pictureOfTheReport: documentFile);
                            setState(() {
                              isLoading = false;
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: AlertDialog(
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.white,
                                    contentPadding: EdgeInsets.zero,
                                    title: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height * 0.33,
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Center(
                                                child: SvgPicture.asset(
                                                  'assets/ticketSuccess.svg',
                                                  width: MediaQuery.of(context).size.width,
                                                  height: viewUtil.isTablet
                                                      ? MediaQuery.of(context).size.height * 0.2
                                                      : MediaQuery.of(context).size.height * 0.15,
                                                ),
                                              ),
                                              Positioned(
                                                top: -15,
                                                right: -15,
                                                child: IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(FontAwesomeIcons.multiply,size: viewUtil.isTablet? 30 :20,),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                                            child: Text(
                                              'Thank you!'.tr(),
                                              style: TextStyle(fontSize: viewUtil.isTablet ? 30:25, fontWeight: FontWeight.bold,color: Colors.green),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              'Your ticket has been submitted Successfully'.tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: viewUtil.isTablet ? 25:20,fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        else{
                          commonWidgets.showToast('Please fill the description..'.tr());
                        }
                      },
                      child: Text(
                        'Submit'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet? 24 : 18,
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
      ),
    );
  }
}
