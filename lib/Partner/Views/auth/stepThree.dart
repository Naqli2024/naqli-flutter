import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';


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
      print('sssssssssssssssSending data:');
      print('partnerName: ${widget.partnerName}');
      print('unitType: ${widget.unitType}');
      print('unitClassification: ${widget.unitClassification}');
      print('subClassification: ${widget.subClassification}');
      print('plateInformation: ${widget.plateInformation}');
      print('istimaraNo: ${widget.istimaraNo}');
      print('firstName: ${widget.firstName}');
      print('lastName: ${widget.lastName}');
      print('email: ${widget.email}');
      print('mobileNo: ${widget.mobileNo}');
      print('dateOfBirth: ${widget.dateOfBirth}');
      print('iqamaNo: ${widget.iqamaNo}');
      print('panelInformation: ${widget.panelInformation}');
      print('id: ${widget.partnerId}');
      print('id: ${widget.istimaraCard}');
      print('id: ${widget.pictureOfVehicle}');
      print('id: ${widget.partnerId}');
      print('id: ${widget.drivingLicense}');
      print('id: ${widget.nationalID}');
      print('id: ${widget.aramcoLicense}');
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
      // Handle unexpected errors
      print('Error: $e');
      // Optionally show a user-friendly error message
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
              centerTitle: false,
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Partner Name',
                  style: TextStyle(
                    fontSize: 20,
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
        height: MediaQuery.of(context).size.height * 0.11,
        child: Container(
          margin: const EdgeInsets.fromLTRB(60, 0, 60, 20),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6269FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                _submitForm();
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              )),
        ),
      ),
    );
  }
}
