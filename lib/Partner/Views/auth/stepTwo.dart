import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepThree.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

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
  int _currentStep = 2;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: commonWidgets.normalizeLocaleFromLocale(context.locale),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(pickedDate);
      });
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
          bottom: PreferredSize(
              preferredSize: viewUtil.isTablet
                  ? Size.fromHeight(170.0)
                  : Size.fromHeight(120.0),
              child: Column(
                children: [
                  AppBar(
                    toolbarHeight: viewUtil.isTablet?80:60,
                    scrolledUnderElevation: 0,
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xff6A66D1),
                    title: Text('Operator/Owner'.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_sharp,
                          color: Colors.white,
                          size: viewUtil.isTablet?27: 24,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStep(1),
                        _buildLine(),
                        _buildStep(2),
                        _buildLine(),
                        _buildStep(3),
                      ],
                    ),
                  ),
                ],
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
                      child: commonWidgets.buildTextField('First Name'.tr(),firstNameController,focusNode: firstNameFocusNode,context: context),
                    ),
                    commonWidgets.buildTextField('Last Name'.tr(),lastNameController,focusNode: lastNameFocusNode,context: context),
                    commonWidgets.buildTextField('Email ID'.tr(),emailIdController,focusNode: emailFocusNode,context: context),
                    commonWidgets.buildTextField(focusNode: passwordFocusNode,
                      'Password'.tr(),
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
                      ),context: context),
                    commonWidgets.buildTextField(focusNode: confirmPasswordFocusNode,
                      'Confirm Password'.tr(),
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
                      ),context: context),
                    commonWidgets.buildTextField('Mobile No'.tr(),mobileNoController,focusNode: mobileNoFocusNode,context: context),
                    Container(
                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date of Birth'.tr(),
                          style: TextStyle(fontSize: viewUtil.isTablet ?24 :20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                      child: TextField(focusNode: dobFocusNode,
                        controller: dobController,
                        readOnly: true,
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
                          _selectDate(context);
                        },
                      ),
                    ),
                    commonWidgets.buildTextField('iqama No'.tr(),iqamaNoController,focusNode: iqamaNoFocusNode,context: context),
                    commonWidgets.buildTextField('Panel Information'.tr(),panelInfoController,focusNode: panelInfoFocusNode,context: context),
                    Container(
                        margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                'Driving License'.tr(),
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet ?24 :20,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  '(Only PDF, DOC, DOCX allowed)',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff808080)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          margin: const EdgeInsets.only(left: 40,bottom: 5),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.065,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Colors.black)),
                                ),
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'doc', 'docx'],
                                  );

                                  if (result != null) {
                                    PlatformFile file = result.files.first;

                                    if (file.size > 100 * 1024) {
                                      commonWidgets.showToast('File must be 100 KB or less');
                                      return;
                                    }

                                    String? extension = file.extension?.toLowerCase();
                                    if (extension == null || !(extension == 'pdf' || extension == 'doc' || extension == 'docx')) {
                                      commonWidgets.showToast("Invalid file type. Only PDF, DOC, DOCX allowed");
                                      return;
                                    }
                                    setState(() {
                                      licenseFile = result!.files.first;
                                      licenseUpload = true;
                                      licenseError = false;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.file_upload_outlined,
                                        color: Colors.black,
                                        size: viewUtil.isTablet?35:30,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        licenseUpload?licenseFile!.name:'Upload a file'.tr(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: viewUtil.isTablet?24:18,
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
                            child: Text(
                              'Please upload a file'.tr(),
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: viewUtil.isTablet?17:12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(30, 20, 40, 0),
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                'national ID'.tr(),
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet?24:20,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  '(Only PDF, DOC, DOCX allowed)',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff808080)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          margin: const EdgeInsets.only(left: 40,bottom: 5),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.065,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Colors.black)),
                                ),
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'doc', 'docx'],
                                  );

                                  if (result != null) {
                                    PlatformFile file = result.files.first;

                                    if (file.size > 100 * 1024) {
                                      commonWidgets.showToast('File must be 100 KB or less');
                                      return;
                                    }

                                    String? extension = file.extension?.toLowerCase();
                                    if (extension == null || !(extension == 'pdf' || extension == 'doc' || extension == 'docx')) {
                                      commonWidgets.showToast("Invalid file type. Only PDF, DOC, DOCX allowed");
                                      return;
                                    }
                                    setState(() {
                                      nationalIdFile = result!.files.first;
                                      nationalIdUpload = true;
                                      nationalIdError = false;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.file_upload_outlined,
                                        color: Colors.black,
                                        size: viewUtil.isTablet?35:30,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        nationalIdUpload?nationalIdFile!.name:'Upload a file'.tr(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: viewUtil.isTablet?24:18,
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
                            child: Text(
                              'Please upload a file'.tr(),
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: viewUtil.isTablet?17:12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(30, 20, 40, 0),
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                'Aramco Certificate'.tr(),
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet?24:20,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  '(Only PDF, DOC, DOCX allowed)',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff808080)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          margin: const EdgeInsets.only(left: 40,bottom: 5),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.065,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Colors.black)),
                                ),
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'doc', 'docx'],
                                  );

                                  if (result != null) {
                                    PlatformFile file = result.files.first;

                                    if (file.size > 100 * 1024) {
                                      commonWidgets.showToast('File must be 100 KB or less');
                                      return;
                                    }

                                    String? extension = file.extension?.toLowerCase();
                                    if (extension == null || !(extension == 'pdf' || extension == 'doc' || extension == 'docx')) {
                                      commonWidgets.showToast("Invalid file type. Only PDF, DOC, DOCX allowed");
                                      return;
                                    }
                                    setState(() {
                                      aramcoFile = result!.files.first;
                                      aramcoUpload =true;
                                      aramcoError =false;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.file_upload_outlined,
                                        color: Colors.black,
                                        size: viewUtil.isTablet?35:30,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        aramcoUpload?aramcoFile!.name:'Upload a file'.tr(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: viewUtil.isTablet?24:18,
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
                            child: Text(
                              'Please upload a file'.tr(),
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: viewUtil.isTablet?17:12,
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
                              } else if (mobileNoController.text.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobileNoController.text)) {
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
                            child: Text(
                              'Next'.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: viewUtil.isTablet?25:18,
                                  fontWeight: FontWeight.w500),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildStep(int step) {
    ViewUtil viewUtil = ViewUtil(context);
    bool isActive = step == _currentStep;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? const Color(0xff6A66D1) : const Color(0xffACACAD),
            width: 1),
      ),
      child: CircleAvatar(
        radius: viewUtil.isTablet?30: 20,
        backgroundColor: isActive ? const Color(0xff6A66D1) : Colors.white,
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey,
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
