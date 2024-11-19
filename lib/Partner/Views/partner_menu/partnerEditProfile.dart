import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/Partner/Viewmodel/services.dart';

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
  bool partnerSelected = true;
  bool operatorSelected = false;
  bool unitSelected = false;
  File? _profileImage;
  int selectedUnit = 1;
  String? unitDropdownValue;
  String? subDropdownValue;
  List<String> _unitClassifications = [];
  List<String> _subClassifications = [];
  String? _selectedUnitClassification;
  String? _selectedSubClassification;
  PlatformFile? istimaraCardFile;
  PlatformFile? vehilePictureFile;
  final TextEditingController plateInfoController = TextEditingController();
  final TextEditingController istimaraNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController iqamaNoController = TextEditingController();
  final TextEditingController panelInfoController = TextEditingController();
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
  final AuthService authService = AuthService();
  bool istimaraUpload = false;
  bool vehicleUpload = false;
  bool istimaraError = false;
  bool vehicleError = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUnitData();
  }

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: partnerSelected ? Color(0xff6269FE) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Color(0xffBCBCBC)),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  partnerSelected = true;
                                  operatorSelected = false;
                                  unitSelected = false;
                                  fetchUnitData();
                                });
                              },
                              child: Text(
                                'Edit Partner'.tr(),
                                style: TextStyle(
                                  color: partnerSelected ? Colors.white : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: unitSelected ? Color(0xff6269FE) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Color(0xffBCBCBC)),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  unitSelected = true;
                                  partnerSelected = false;
                                  operatorSelected = false;
                                });
                              },
                              child: Text(
                                'Edit Unit'.tr(),
                                style: TextStyle(
                                  color: unitSelected ? Colors.white : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: operatorSelected ? Color(0xff6269FE) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Color(0xffBCBCBC)),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                operatorSelected = true;
                                partnerSelected = false;
                                unitSelected = false;
                              });
                            },
                            child: Text(
                              'Edit Operator'.tr(),
                              style: TextStyle(
                                color: operatorSelected ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: partnerSelected,
                  child: Column(
                    children: [
                      _buildTextField('Name'.tr(),nameController),
                      _buildTextField('Mobile No'.tr(),mobileController),
                      _buildTextField('Email ID'.tr(),emailController),
                      Container(
                        margin: const EdgeInsets.fromLTRB(40, 15, 40, 10),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Password'.tr(),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 30),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: isPasswordObscured,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordObscured = !isPasswordObscured;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0xff828080),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                              onPressed: () {

                              },
                              child: Text(
                                'Save'.tr(),
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
                Visibility(
                  visible: unitSelected,
                  child:  isLoading
                      ? CircularProgressIndicator()
                      : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(40, 20, 30, 5),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Select Unit'.tr(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      _buildUnitRadioList(),
                      _buildUnitClassificationDropdown(),
                      _buildSubClassificationDropdown(),
                      _buildTextField('Plate Information'.tr(),plateInfoController),
                      commonWidgets.buildTextField('Istimara No'.tr(),istimaraNoController,fontWeight: FontWeight.normal),
                      _buildIstimaraFileUploadButton('Istimara Card'.tr()),
                      _buildVehicleFileUploadButton('Picture of Vehicle'.tr()),
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
                              onPressed: () {

                              },
                              child: Text(
                                'Save'.tr(),
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
                Visibility(
                  visible: operatorSelected,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: commonWidgets.buildTextField('First Name'.tr(),firstNameController,fontWeight: FontWeight.normal),
                      ),
                      commonWidgets.buildTextField('Last Name'.tr(),lastNameController,fontWeight: FontWeight.normal),
                      commonWidgets.buildTextField('Email ID'.tr(),emailIdController,fontWeight: FontWeight.normal),
                      commonWidgets.buildTextField(
                        'PASSWORD'.tr(),
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
                        ),fontWeight: FontWeight.normal),
                      commonWidgets.buildTextField(
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
                        ),fontWeight: FontWeight.normal),
                      commonWidgets.buildTextField('Mobile No'.tr(),mobileNoController,fontWeight: FontWeight.normal),
                      Container(
                        margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Date of Birth'.tr(),
                            style: TextStyle(fontSize: 20),
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
                      commonWidgets.buildTextField('iqama No'.tr(),iqamaNoController,fontWeight: FontWeight.normal),
                      commonWidgets.buildTextField('Panel Information'.tr(),panelInfoController,fontWeight: FontWeight.normal),
                      Container(
                          margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Driving License'.tr(),
                              style: const TextStyle(
                                  fontSize: 20,
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
                              width: MediaQuery.of(context).size.width * 0.8,
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
                                        licenseFile = result.files.first;
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
                                        flex: 1,
                                        child: Icon(
                                          Icons.file_upload_outlined,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          licenseUpload?licenseFile!.name:'Upload a file'.tr(),
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
                        ],
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(30, 20, 40, 0),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'national ID'.tr(),
                              style: const TextStyle(fontSize: 20,),
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
                                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      setState(() {
                                        nationalIdFile = result.files.first;
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
                                        flex: 1,
                                        child: Icon(
                                          Icons.file_upload_outlined,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          nationalIdUpload?nationalIdFile!.name:'Upload a file'.tr(),
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
                        ],
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(30, 20, 40, 0),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Aramco Certificate'.tr(),
                              style: const TextStyle(fontSize: 20),
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
                                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      setState(() {
                                        aramcoFile = result.files.first;
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
                                        flex: 1,
                                        child: Icon(
                                          Icons.file_upload_outlined,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          aramcoUpload?aramcoFile!.name:'Upload a file'.tr(),
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
                                  onPressed: () {

                                  },
                                  child: Text(
                                    'Save'.tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String unitMap(int value) {
    switch (value) {
      case 1:
        return 'vehicle';
      case 2:
        return 'bus';
      case 3:
        return 'equipment';
      case 4:
        return 'special';
      default:
        return 'others';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
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
      print("Error picking profile image: $e");
    }
  }

  Future<void> fetchUnitData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String selectedUnitString = unitMap(selectedUnit);
      List<Map<String, dynamic>> data;

      if (selectedUnitString == 'vehicle') {
        data = await authService.fetchVehicleData();
      } else if (selectedUnitString == 'bus') {
        data = await authService.fetchBusData();
      } else if (selectedUnitString == 'equipment') {
        data = await authService.fetchEquipmentData();
      } else if (selectedUnitString == 'special') {
        data = await authService.fetchSpecialData();
      } else if (selectedUnitString == 'others') {
        data = await authService.fetchEquipmentData();
      } else {
        data = [];
      }

      setState(() {
        _unitClassifications = data
            .map((item) => (item['name'] as String?) ?? 'Unknown')
            .toSet()
            .toList();

        _selectedUnitClassification = _unitClassifications.isNotEmpty ? _unitClassifications[0] : null;

        _updateSubClassifications();
      });
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('Failed to load unit data: $error');
    }
  }

  Future<void> _updateSubClassifications() async {
    if (_selectedUnitClassification == null) {
      _subClassifications = [];
      _selectedSubClassification = null;
      return;
    }

    String selectedUnitString = unitMap(selectedUnit);
    List<Map<String, dynamic>> data;

    if (selectedUnitString == 'vehicle') {
      data = await authService.fetchVehicleData();
    } else if (selectedUnitString == 'bus') {
      data = await authService.fetchBusData();
    } else if (selectedUnitString == 'equipment') {
      data = await authService.fetchEquipmentData();
    } else if (selectedUnitString == 'special') {
      data = await authService.fetchSpecialData();
    } else if (selectedUnitString == 'others') {
      data = await authService.fetchEquipmentData(); // Fetch Loaders data
    } else {
      data = [];
    }

    setState(() {
      _subClassifications = data
          .where((item) => item['name'] == _selectedUnitClassification)
          .expand((item) {
        final types = item['type'] as List<dynamic>? ?? [];
        return types.map((typeItem) {
          final typeName = typeItem['typeName'] as String? ?? 'Unknown';
          return typeName;
        }).toList();
      }).toSet().toList();

      _selectedSubClassification = _subClassifications.isNotEmpty ? _subClassifications[0] : null;
    });
  }

  Widget _buildUnitRadioList() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
          ),
          child: RadioListTile(
            title: Text(
              'Vehicle'.tr(),
            ),
            value: 1,
            groupValue: selectedUnit,
            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
                fetchUnitData();
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
          ),
          child: RadioListTile(
            title: Text(
              'Bus'.tr(),
            ),
            value: 2,
            groupValue: selectedUnit,
            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
                fetchUnitData();
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
          ),
          child: RadioListTile(
            title: Text(
              'Equipment'.tr(),
            ),
            value: 3,
            groupValue: selectedUnit,
            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
                fetchUnitData();
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
          ),
          child: RadioListTile(
            title: Text(
              'Special'.tr(),
            ),
            value: 4,
            groupValue: selectedUnit,
            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
                fetchUnitData();
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
          ),
          child: RadioListTile(
            title: Text(
              'Others'.tr(),
            ),
            value: 5,
            groupValue: selectedUnit,
            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
                fetchUnitData();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnitClassificationDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Unit Classification'.tr(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              value: _selectedUnitClassification,
              hint: Text('Select Unit Classification'.tr()),
              icon: const Icon(Icons.keyboard_arrow_down, size: 25),
              items: _unitClassifications.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                      color:Colors.white,
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Row(
                          children: [
                            Text(value.tr()),
                          ],
                        ),
                      )),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnitClassification = value;
                  _updateSubClassifications();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubClassificationDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Sub Classification'.tr(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: _selectedSubClassification,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (newValue) {
                setState(() {
                  _selectedSubClassification = newValue;
                });
              },
              hint: Text('No Data for Sub Classification'.tr()),
              icon: const Icon(Icons.keyboard_arrow_down, size: 25),
              items: _subClassifications.map((subClass) {
                return DropdownMenuItem<String>(
                  value: subClass,
                  child: Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Row(
                      children: [
                        Text(subClass.tr()),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label,controller) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${'Please enter'.tr()} $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIstimaraFileUploadButton(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(left: 40, bottom: 10),
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
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    istimaraCardFile = result.files.first;
                    istimaraUpload = true;
                    istimaraError = false;
                  });
                  print(result.files.first.name);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.file_upload_outlined,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      istimaraUpload
                          ? istimaraCardFile!.name
                          : 'Upload a file'.tr(),
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
        if (istimaraError)
          Container(
            margin: const EdgeInsets.only(left: 60, bottom: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              'Please upload a file'.tr(),
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVehicleFileUploadButton(String label) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(left: 40, bottom: 5),
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
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      vehilePictureFile = result!.files.first;
                      vehicleUpload=true;
                      vehicleError=false;
                    });
                    print(result.files.first.name);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.file_upload_outlined,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        vehicleUpload?vehilePictureFile!.name:'Upload a file'.tr(),
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
        if (vehicleError)
          Container(
            margin: const EdgeInsets.only(left: 60, bottom: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              'Please upload a file'.tr(),
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
