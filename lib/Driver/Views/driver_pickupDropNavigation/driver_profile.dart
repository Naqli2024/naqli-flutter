import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/PdfViewer.dart';
import 'package:flutter_naqli/Partner/Model/partner_model.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'dart:ui' as ui;

class DriverProfile extends StatefulWidget {
  final String operatorId;
  final String partnerId;
  final String firstName;
  final String lastName;
  const DriverProfile({super.key, required this.firstName, required this.lastName, required this.operatorId, required this.partnerId});

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController iqamaNoController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController panelInfoController = TextEditingController();
  final TextEditingController plateInfoController = TextEditingController();
  final TextEditingController IstimaraNoController = TextEditingController();
  final TextEditingController istimaraCardController = TextEditingController();
  final TextEditingController pictureOfVehicleController = TextEditingController();
  final TextEditingController partnerNameController = TextEditingController();
  String? drivingLicenseName;
  String? aramcoLicenseName;
  String? nationalIdName;
  PlatformFile? istimaraCard;
  PlatformFile? pictureOfVehicle;
  PlatformFile? drivingLicense;
  PlatformFile? aramcoLicense;
  PlatformFile? nationalId;
  String? operatorId;
  String? unitType;
  int? selectedUnit;
  bool isEditing = false;
  final DriverService driverService = DriverService();
  late Future<List<Operator>> futureOperators;
  OperatorDetail? operatorDetail;
  bool isLoading = true;


  @override
  void initState() {
    fetchOperatorDetail();
    super.initState();
  }

  Future<void> fetchOperatorDetail() async {
    try {
      OperatorDetail? fetchedOperatorDetail = await driverService.getOperatorDetail(context,widget.partnerId, widget.operatorId);

      if (fetchedOperatorDetail != null) {
        firstNameController.text = fetchedOperatorDetail.firstName;
        lastNameController.text = fetchedOperatorDetail.lastName;
        emailController.text = fetchedOperatorDetail.email;
        mobileNoController.text = fetchedOperatorDetail.mobileNo;
        iqamaNoController.text = fetchedOperatorDetail.iqamaNo;
        panelInfoController.text = fetchedOperatorDetail.panelInformation;
        dobController.text = fetchedOperatorDetail.dateOfBirth;
        operatorId = fetchedOperatorDetail.operatorId;
        drivingLicenseName = fetchedOperatorDetail.drivingLicense;
        aramcoLicenseName = fetchedOperatorDetail.aramcoLicense;
        nationalIdName = fetchedOperatorDetail.nationalID;
      }

      setState(() {
        operatorDetail = fetchedOperatorDetail;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
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
        appBar: commonWidgets.commonAppBar(context,
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false,
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
                            'Operator Profile'.tr(),
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
          child: Padding(
            padding: const EdgeInsets.only(top: 20,bottom: 40),
            child: Column(
              children: [
                commonWidgets.buildTextField(
                    'First Name'.tr(), firstNameController,
                    context: context,readOnly: true),
                commonWidgets.buildTextField(
                    'Last Name'.tr(), lastNameController,
                    context: context,readOnly: true),
                commonWidgets.buildTextField(
                    'Email Address'.tr(), emailController,
                    context: context,readOnly: true),
                commonWidgets.buildTextField(
                    'Mobile No'.tr(), mobileNoController,
                    context: context,readOnly: true),
                commonWidgets.buildTextField(
                    'Iqama No'.tr(), iqamaNoController,
                    context: context,readOnly: true),
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Date of Birth'.tr(),
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 24 : 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                  child: TextField(
                    controller: dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Color(0xffCCCCCC)),
                      border: OutlineInputBorder(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                        borderSide: const BorderSide(
                          color: Color(0xffBCBCBC),
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                        borderSide: const BorderSide(
                          color: Color(0xffBCBCBC),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                commonWidgets.buildTextField(
                    'Panel Information'.tr(), panelInfoController,
                    context: context,readOnly: true),
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Driving License'.tr(),
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 24 : 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FileDownloader.downloadAndOpenFile(
                        context,
                        "https://prod.naqlee.com/api/files/$drivingLicenseName",
                        "$drivingLicenseName.pdf",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "View File",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Aramco License'.tr(),
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 24 : 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FileDownloader.downloadAndOpenFile(
                        context,
                        "https://prod.naqlee.com/api/files/$aramcoLicenseName",
                        "$aramcoLicenseName.pdf",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "View File",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'National Id'.tr(),
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 24 : 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FileDownloader.downloadAndOpenFile(
                        context,
                        "https://prod.naqlee.com/api/files/$nationalIdName",
                        "$nationalIdName",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "View File",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
