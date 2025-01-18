import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';

class StepThree extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String unitType;
  final String unitClassification;
  final String subClassification;
  final String plateInformation;
  final String istimaraNo;
  final PlatformFile? istimaraCard;
  final PlatformFile? pictureOfVehicle;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String mobileNo;
  final DateTime dateOfBirth;
  final String iqamaNo;
  final String panelInformation;
  final String token;
  final PlatformFile? drivingLicense;
  final PlatformFile? nationalID;
  final PlatformFile? aramcoLicense;
  const StepThree({super.key, required this.partnerName, required this.firstName, required this.lastName, required this.email, required this.mobileNo, required this.iqamaNo, this.drivingLicense, this.nationalID, this.aramcoLicense, required this.unitType, required this.unitClassification, required this.subClassification, required this.plateInformation, required this.istimaraNo, this.istimaraCard, this.pictureOfVehicle, required this.dateOfBirth, required this.panelInformation, required this.partnerId, required this.token, required this.password, required this.confirmPassword});

  @override
  State<StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends State<StepThree> {
  late TextEditingController partnerNameController = TextEditingController();
  bool isEditing = false;
  bool isLoading= false;
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  int _currentStep = 3;

  @override
  void initState() {
    partnerNameController = TextEditingController(text: widget.partnerName);
    super.initState();
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;

      if (isEditing) {
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus();
        });
      } else {

      }
    });
  }

  Future<void> _submitForm() async {
    try{
      setState(() {
        isLoading = true;
      });
      await _authService.addOperator(
        context,
        partnerName: partnerNameController.text,
        partnerId: widget.partnerId,
        token: widget.token,
        unitType: widget.unitType,
        unitClassification: widget.unitClassification,
        subClassification: widget.subClassification,
        plateInformation: widget.plateInformation,
        istimaraNo: widget.istimaraNo,
        istimaraCard: widget.istimaraCard,
        pictureOfVehicle: widget.pictureOfVehicle,
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        mobileNo: widget.mobileNo,
        dateOfBirth: widget.dateOfBirth,
        iqamaNo: widget.iqamaNo,
        panelInformation: widget.panelInformation,
        drivingLicense: widget.drivingLicense,
        nationalID: widget.nationalID,
        aramcoLicense: widget.aramcoLicense,
        stepThreeInstance: widget,
        controller: partnerNameController,
      );
      setState(() {
        isLoading = false;
      });
    }catch (e) {
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Partner Name'.tr(),
                    style: TextStyle(
                      fontSize: viewUtil.isTablet?24:20,
                      fontWeight: FontWeight.w500
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: TextField(
                  readOnly: !isEditing,
                  controller: partnerNameController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: (){
                          toggleEditMode();
                        },
                        icon: isEditing?Icon(Icons.check): Icon(Icons.edit)
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Container(
            margin: const EdgeInsets.fromLTRB(60, 0, 60, 20),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6269FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(viewUtil.isTablet?40:30),
                  ),
                ),
                onPressed: () {
                  _submitForm();
                },
                child: Text(
                  'Submit'.tr(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: viewUtil.isTablet?25:18,
                      fontWeight: FontWeight.w500),
                )),
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
}
