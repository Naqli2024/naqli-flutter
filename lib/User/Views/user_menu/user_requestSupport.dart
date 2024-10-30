import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Scaffold(
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
                    child: Text('Request Support',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 40),
                child: RichText(
                  text: TextSpan(
                    text: "Feel free to contact us through our email, if you have any more questions ",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black, // Set the text color
                    ),
                    children: [
                      TextSpan(
                        text: "naqlee45@gmail.com",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'naqlee45@gmail.com',
                            query: 'subject=Support&body=Hello, I have a question.', // Optional: Add pre-filled subject and body
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
                  child: Text('Enter your Email Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
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
                  child: Text('Description',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
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
                    hintText: 'Please be specific so that we can address it as soon as possible',
                    hintStyle: TextStyle(fontSize: 17,color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40,bottom: 10),
                  child: Text('Supporting documentation\n(Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
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
                    print(result.files.first.name);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      documentUpload
                          ? documentFile!.path.split('/').last
                          : 'Upload a Document',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
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
                              return AlertDialog(
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
                                              height: MediaQuery.of(context).size.height * 0.15,
                                            ),
                                          ),
                                          Positioned(
                                            top: -15,
                                            right: -15,
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(FontAwesomeIcons.multiply),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                                        child: Text(
                                          'Thank you',
                                          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.green),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          'Your ticket has been submitted Successfully',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      else{
                        commonWidgets.showToast('Please fill the description..');
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
    );
  }
}
