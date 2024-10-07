import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepThree.dart';
import 'package:intl/intl.dart';

class StepTwo extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String unitType;
  final String unitClassification;
  final String subClassification;
  final String plateInformation;
  final String istimaraNo;
  final String token;
  final PlatformFile? istimaraCard;
  final PlatformFile? pictureOfVehicle;
  const StepTwo({super.key, required this.partnerName, required this.unitType, required this.unitClassification, required this.subClassification, required this.plateInformation, required this.istimaraNo, this.istimaraCard, this.pictureOfVehicle, required this.partnerId, required this.token});

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController iqamaNoController = TextEditingController();
  final TextEditingController panelInfoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode mobileNoFocusNode = FocusNode();
  final FocusNode dobFocusNode = FocusNode();
  final FocusNode iqamaNoFocusNode = FocusNode();
  final FocusNode panelInfoFocusNode = FocusNode();
  final CommonWidgets commonWidgets = CommonWidgets();
  bool licenseUpload = false;
  bool nationalIdUpload = false;
  bool aramcoUpload = false;
  bool licenseError = false;
  bool nationalIdError = false;
  bool aramcoError = false;
  PlatformFile? licenseFile;
  PlatformFile? nationalIdFile;
  PlatformFile? aramcoFile;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set the initial date
      firstDate: DateTime(1900), // Set the first selectable date
      lastDate: DateTime(2100),  // Set the last selectable date
    );

    if (pickedDate != null) {
      // Format the selected date and set it in the TextEditingController
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.partnerName,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: const Text('Operator/Owner',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                  )),
            )),
      ),
        body: Form(
          key: _formKey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: commonWidgets.buildTextField('First name',firstNameController,focusNode: firstNameFocusNode),
                  ),
                  commonWidgets.buildTextField('Last name',lastNameController,focusNode: lastNameFocusNode),
                  commonWidgets.buildTextField('Email id',emailIdController,focusNode: emailFocusNode),
                  commonWidgets.buildTextField(focusNode: passwordFocusNode,
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
                  commonWidgets.buildTextField(focusNode: confirmPasswordFocusNode,
                    'Confirm Password',
                    confirmPasswordController,
                    obscureText: isConfirmPasswordObscured,
                    passwordController: passwordController,
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
                  commonWidgets.buildTextField('Mobile no',mobileNoController,focusNode: mobileNoFocusNode),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Date of birth',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                    child: TextField(focusNode: dobFocusNode,
                      controller: dobController,
                      readOnly: true, // Make the field read-only
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xffCCCCCC)),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: const BorderSide(
                            color: Color(0xffBCBCBC),
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: const BorderSide(
                            color: Color(0xffBCBCBC),
                            width: 1.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        _selectDate(context); // Open date picker on tap
                      },
                    ),
                  ),
                  commonWidgets.buildTextField('Iqama no',iqamaNoController,focusNode: iqamaNoFocusNode,),
                  commonWidgets.buildTextField('Panel Information',panelInfoController,focusNode: panelInfoFocusNode),
                  Container(
                      margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
                      alignment: Alignment.topLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Driving License',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      )),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        margin: const EdgeInsets.only(left: 40,bottom: 5),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.065,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.black)),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  setState(() {
                                    licenseFile = result!.files.first;
                                    licenseUpload = true;
                                    licenseError = false;
                                  });
                                  print(result.files.first.name);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      licenseUpload?licenseFile!.name:'Upload a file',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      if (licenseError)
                        Container(
                          margin: const EdgeInsets.only(left: 60, bottom: 20),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Please upload a file',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.fromLTRB(30, 20, 40, 0),
                      alignment: Alignment.topLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'National Id',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      )),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        margin: const EdgeInsets.only(left: 40,bottom: 5),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.065,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.black)),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  setState(() {
                                    nationalIdFile = result!.files.first;
                                    nationalIdUpload = true;
                                    nationalIdError = false;
                                  });
                                  print(result.files.first.name);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      nationalIdUpload?nationalIdFile!.name:'Upload a file',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      if (nationalIdError)
                        Container(
                          margin: const EdgeInsets.only(left: 60, bottom: 20),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Please upload a file',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.fromLTRB(30, 20, 40, 0),
                      alignment: Alignment.topLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Aramco Certificate',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      )),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        margin: const EdgeInsets.only(left: 40,bottom: 5),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.065,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.black)),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  setState(() {
                                    aramcoFile = result!.files.first;
                                    aramcoUpload =true;
                                    aramcoError =false;
                                  });
                                  print(result.files.first.name);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      aramcoUpload?aramcoFile!.name:'Upload a file',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      if (aramcoError)
                        Container(
                          margin: const EdgeInsets.only(left: 60, bottom: 20),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Please upload a file',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20,top: 20),
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
                          onPressed: () {
                            if (!licenseUpload && !nationalIdUpload && !aramcoUpload) {
                              licenseError =true;
                              nationalIdError =true;
                              aramcoError =true;
                              setState(() {});
                            }
                          if (_formKey.currentState!.validate() && licenseUpload && nationalIdUpload && aramcoUpload) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StepThree(
                                      unitType: widget.unitType,
                                      unitClassification: widget.unitClassification,
                                      subClassification: widget.subClassification,
                                      plateInformation: widget.plateInformation,
                                      istimaraNo: widget.istimaraNo,
                                      istimaraCard: widget.istimaraCard,
                                      pictureOfVehicle: widget.pictureOfVehicle,
                                      firstName: firstNameController.text,
                                      lastName: lastNameController.text,
                                      email: emailIdController.text,
                                      password: passwordController.text,
                                      confirmPassword: confirmPasswordController.text,
                                      mobileNo: mobileNoController.text,
                                      dateOfBirth: DateTime.parse(dobController.text),
                                      iqamaNo: iqamaNoController.text,
                                      panelInformation: panelInfoController.text,
                                      drivingLicense: licenseFile,
                                      nationalID: nationalIdFile,
                                      aramcoLicense: aramcoFile,
                                      partnerName: widget.partnerName,
                                      partnerId: widget.partnerId,
                                      token: widget.token
                                    )));
                          }
                          else{
                            FocusScope.of(context).unfocus();

                            if (firstNameController.text.isEmpty) {
                              _focusAndScroll(firstNameFocusNode);
                            } else if (lastNameController.text.isEmpty) {
                              _focusAndScroll(lastNameFocusNode);
                            } else if (emailIdController.text.isEmpty) {
                              _focusAndScroll(emailFocusNode);
                            } else if (mobileNoController.text.isEmpty) {
                                _focusAndScroll(mobileNoFocusNode);
                            } else if (passwordController.text.isEmpty || passwordController.text.length < 6) {
                              _focusAndScroll(passwordFocusNode);
                            } else if (confirmPasswordController.text.isEmpty || confirmPasswordController.text != passwordController.text) {
                              _focusAndScroll(confirmPasswordFocusNode);
                            } else if (dobController.text.isEmpty) {
                              _focusAndScroll(dobFocusNode);
                            } else if (iqamaNoController.text.isEmpty || !RegExp(r'^\d{10}$').hasMatch(iqamaNoController.text)) {
                              _focusAndScroll(iqamaNoFocusNode);
                            } else if (panelInfoController.text.isEmpty) {
                              _focusAndScroll(panelInfoFocusNode);
                            }
                          }
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  void _focusAndScroll(FocusNode focusNode) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    focusNode.requestFocus();
  }
}
