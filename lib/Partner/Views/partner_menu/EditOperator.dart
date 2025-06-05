import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Model/partner_model.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepThree.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';

class EditOperator extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  const EditOperator({super.key, required this.partnerId, required this.partnerName});

  @override
  State<EditOperator> createState() => _EditOperatorState();
}

class _EditOperatorState extends State<EditOperator> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController unitTypeController = TextEditingController();
  final TextEditingController unitClassificationController =
      TextEditingController();
  final TextEditingController subClassificationController =
      TextEditingController();
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
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  String? istimaraCardName;
  String? pictureOfVehicleName;
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
  String? unitDropdownValue;
  String? subDropdownValue;
  List<String> _unitClassifications = [];
  List<String> _subClassifications = [];
  String? _selectedUnitClassification;
  String? _selectedSubClassification;
  bool isEditing = false;
  final AuthService authService = AuthService();
  late Future<List<Operator>> futureOperators;
  List<Operator> operators = [];
  bool isLoading = true;

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

  @override
  void initState() {
    fetchOperators();
    fetchUnitData();
    updateSelectedUnit();
    partnerNameController.text = widget.partnerName;
    super.initState();
  }

  void updateSelectedUnit() {
    setState(() {
      switch (unitType?.toLowerCase()) {
        case 'vehicle':
          selectedUnit = 1;
          break;
        case 'bus':
          selectedUnit = 2;
          break;
        case 'equipment':
          selectedUnit = 3;
          break;
        case 'special':
          selectedUnit = 4;
          break;
        case 'others':
          selectedUnit = 5;
          break;
        default:
          selectedUnit = null;
      }
    });
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

  Future<void> fetchOperators() async {
    try {
      List<Operator> fetchedOperators = await authService.getOperatorData(widget.partnerId);
      if (fetchedOperators.isNotEmpty) {
        final operator = fetchedOperators.first;

        unitType = operator.unitType;
        unitClassificationController.text = operator.unitClassification;
        subClassificationController.text = operator.subClassification;
        plateInfoController.text = operator.plateInformation;
        IstimaraNoController.text = operator.istimaraNo;
        istimaraCardController.text = operator.istimaraCard;
        pictureOfVehicleController.text = operator.pictureOfVehicle;
        if (operator.operatorsDetail.isNotEmpty) {
          final operatorDetail = operator.operatorsDetail.first;
          firstNameController.text = operatorDetail.firstName;
          lastNameController.text = operatorDetail.lastName;
          emailController.text = operatorDetail.email;
          mobileNoController.text = operatorDetail.mobileNo;
          iqamaNoController.text = operatorDetail.iqamaNo;
          panelInfoController.text = operatorDetail.panelInformation;
          dobController.text = operatorDetail.dateOfBirth;
          operatorId = operatorDetail.operatorId;
          drivingLicenseName = operatorDetail.drivingLicense;
          aramcoLicenseName = operatorDetail.aramcoLicense;
          nationalIdName = operatorDetail.nationalID;
        }
      }

      setState(() {
        operators = fetchedOperators;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching operators: $error");
    }
  }

  Widget buildUnitRadioList() {
    ViewUtil viewUtil = ViewUtil(context);
    bool isEditable = unitType == null || unitType!.isEmpty;

    if (selectedUnit == null && unitType != null && unitType!.isNotEmpty) {
      selectedUnit = getUnitValueFromType(unitType!);
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Unit'.tr(),
              style: TextStyle(fontSize: viewUtil.isTablet ? 24 : 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<int>(
                  dense: true,
                  title: Text('Vehicle'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14, color: Colors.black)),
                  value: 1,
                  groupValue: selectedUnit,
                  onChanged: isEditable ? (value) {
                    setState(() {
                      selectedUnit = value;
                      fetchUnitData();
                    });
                  } : null,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  dense: true,
                  title: Text('Bus'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14, color: Colors.black)),
                  value: 2,
                  groupValue: selectedUnit,
                  onChanged: isEditable ? (value) {
                    setState(() {
                      selectedUnit = value;
                      fetchUnitData();
                    });
                  } : null,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<int>(
                  dense: true,
                  title: Text('Equipment'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14, color: Colors.black)),
                  value: 3,
                  groupValue: selectedUnit,
                  onChanged: isEditable ? (value) {
                    setState(() {
                      selectedUnit = value;
                      fetchUnitData();
                    });
                  } : null,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  dense: true,
                  title: Text('Special'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14, color: Colors.black)),
                  value: 4,
                  groupValue: selectedUnit,
                  onChanged: isEditable ? (value) {
                    setState(() {
                      selectedUnit = value;
                      fetchUnitData();
                    });
                  } : null,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<int>(
                  dense: true,
                  title: Text('Others'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14, color: Colors.black)),
                  value: 5,
                  groupValue: selectedUnit,
                  onChanged: isEditable ? (value) {
                    setState(() {
                      selectedUnit = value;
                      fetchUnitData();
                    });
                  } : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int getUnitValueFromType(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'vehicle':
        return 1;
      case 'bus':
        return 2;
      case 'equipment':
        return 3;
      case 'special':
        return 4;
      case 'others':
        return 5;
      default:
        return 1;
    }
  }

  Future<void> fetchUnitData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String selectedUnitString = unitMap(selectedUnit!);
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
      // commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<void> _updateSubClassifications() async {
    if (_selectedUnitClassification == null) {
      _subClassifications = [];
      _selectedSubClassification = null;
      return;
    }

    String selectedUnitString = unitMap(selectedUnit!);
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

  Widget _buildUnitClassificationDropdown() {
    ViewUtil viewUtil = ViewUtil(context);
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
              style: TextStyle(
                  fontSize: viewUtil.isTablet?24:20,
                  fontWeight: FontWeight.w500
              ),
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
    ViewUtil viewUtil = ViewUtil(context);
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
              style: TextStyle(
                  fontSize: viewUtil.isTablet?24:20,
                  fontWeight: FontWeight.w500
              ),
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

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 15),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          buildUnitRadioList(),
         operators.isEmpty
              ? Column(
            children: [
              _buildUnitClassificationDropdown(),
              _buildSubClassificationDropdown(),
              commonWidgets.buildTextField(
                  'Plate Information'.tr(), plateInfoController,
                  context: context),
              commonWidgets.buildTextField(
                  'Istimara No'.tr(), IstimaraNoController,
                  context: context),
              commonWidgets.buildFileUploadButton(
                  context: context,
                  title: 'Istimara Card',
                  onFileSelected: (FilePickerResult? result) {
                    if (result != null) {
                      setState(() {
                        istimaraCard = result.files.first;
                        istimaraCardName = result.files.first.name;
                      });
                    }
                  },
                  fileName: istimaraCardName),
              commonWidgets.buildPictureFileUploadButton(
                  context: context,
                  title: 'Picture of Vehicle',
                  onFileSelected: (FilePickerResult? result) {
                    if (result != null) {
                      setState(() {
                        pictureOfVehicle = result.files.first;
                        pictureOfVehicleName = result.files.first.name;
                      });
                    }
                  },
                  fileName: pictureOfVehicleName),
            ],
          )
          : Column(
           children: [
             commonWidgets.buildTextField('Unit Classification'.tr(),
                 unitClassificationController,
                 context: context,readOnly: true),
             commonWidgets.buildTextField('Sub Classification'.tr(),
                 subClassificationController,
                 context: context,readOnly: true),
             commonWidgets.buildTextField(
                 'Plate Information'.tr(), plateInfoController,
                 context: context,readOnly: true),
             commonWidgets.buildTextField(
                 'Istimara No'.tr(), IstimaraNoController,
                 context: context,readOnly: true),
             commonWidgets.buildTextField(
                 'Istimara Card'.tr(), istimaraCardController,
                 context: context,readOnly: true),
             commonWidgets.buildTextField(
                 'Picture of Vehicle'.tr(), pictureOfVehicleController,
                 context: context,readOnly: true),
    ]
         ),
          commonWidgets.buildTextField(
              'First Name'.tr(), firstNameController,
              context: context),
          commonWidgets.buildTextField(
              'Last Name'.tr(), lastNameController,
              context: context),
          commonWidgets.buildTextField(
              'Email Address'.tr(), emailController,
              context: context),
          commonWidgets.buildTextField(
              'Mobile No'.tr(), mobileNoController,
              context: context),
          commonWidgets.buildTextField(
              'Password'.tr(), passwordController,
              obscureText: isPasswordObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
              ),
              context: context),
          commonWidgets.buildTextField(
              'Confirm Password'.tr(), confirmPasswordController,
              obscureText: isConfirmPasswordObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  isConfirmPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isConfirmPasswordObscured =
                    !isConfirmPasswordObscured;
                  });
                },
              ),
              context: context),
          commonWidgets.buildTextField(
              'Iqama No'.tr(), iqamaNoController,
              context: context),
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
              onTap: () {
                _selectDate(context);
              },
            ),
          ),
          commonWidgets.buildTextField(
              'Panel Information'.tr(), panelInfoController,
              context: context),
          commonWidgets.buildFileUploadButton(
              context: context,
              title: 'Driving License'.tr(),
              onFileSelected: (FilePickerResult? result) {
                if (result != null) {
                  setState(() {
                    drivingLicense = result.files.first;
                    drivingLicenseName = result.files.first.name;
                  });
                }
              },
              fileName: drivingLicenseName),
          commonWidgets.buildFileUploadButton(
              context: context,
              title: 'Aramco License'.tr(),
              onFileSelected: (FilePickerResult? result) {
                if (result != null) {
                  setState(() {
                    aramcoLicense = result.files.first;
                    aramcoLicenseName = result.files.first.name;
                  });
                }
              },
              fileName: aramcoLicenseName),
          commonWidgets.buildFileUploadButton(
              context: context,
              title: 'national ID'.tr(),
              onFileSelected: (FilePickerResult? result) {
                if (result != null) {
                  setState(() {
                    nationalId = result.files.first;
                    nationalIdName = result.files.first.name;
                  });
                }
              },
              fileName: nationalIdName),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(40, 20, 40, 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Partner Name'.tr(),
                      style: TextStyle(
                          fontSize: viewUtil.isTablet?24:20,
                          fontWeight: FontWeight.w500
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
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
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height:
              MediaQuery.of(context).size.height * 0.057,
              width: MediaQuery.of(context).size.width * 0.6,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6269FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: ()  {
                    _submitForm();
                  },
                  child: Text(
                    'Save'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: viewUtil.isTablet ? 25 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ),
          ),
          Container(
            margin:
            const EdgeInsets.only(top: 10, bottom: 20),
            child: SizedBox(
              height:
              MediaQuery.of(context).size.height * 0.057,
              width: MediaQuery.of(context).size.width * 0.6,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    authService.deleteOperator(context, operatorId??'');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Delete Operator'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: viewUtil.isTablet ? 25 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  File? convertPlatformFileToFile(PlatformFile? platformFile) {
    if (platformFile == null || platformFile.path == null) return null;
    return File(platformFile.path!);
  }

  Future<void> _submitForm() async {
    try{
      String selectedUnitString = unitMap(selectedUnit!);
      if (operators.isEmpty) {
        await authService.addOperator(
          context,
          partnerName: partnerNameController.text,
          partnerId: widget.partnerId,
          token: '',
          unitType: selectedUnitString,
          unitClassification: _selectedUnitClassification.toString(),
          subClassification: _selectedSubClassification.toString(),
          plateInformation: plateInfoController.text,
          istimaraNo: IstimaraNoController.text,
          istimaraCard: istimaraCard,
          pictureOfVehicle: pictureOfVehicle,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
          mobileNo: mobileNoController.text,
          dateOfBirth: DateTime.parse(dobController.text),
          iqamaNo: iqamaNoController.text,
          panelInformation: panelInfoController.text,
          drivingLicense: drivingLicense,
          nationalID: nationalId,
          aramcoLicense: aramcoLicense,
          stepThreeInstance: StepThree(
            partnerName: partnerNameController.text,
            partnerId: widget.partnerId,
            token: '',
            unitType: selectedUnitString,
            unitClassification: _selectedUnitClassification.toString(),
            subClassification: _selectedSubClassification.toString(),
            plateInformation: plateInfoController.text,
            istimaraNo: IstimaraNoController.text,
            istimaraCard: istimaraCard,
            pictureOfVehicle: pictureOfVehicle,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
            mobileNo: mobileNoController.text,
            dateOfBirth: DateTime.parse(dobController.text),
            iqamaNo: iqamaNoController.text,
            panelInformation: panelInfoController.text,
            drivingLicense: drivingLicense,
            nationalID: nationalId,
            aramcoLicense: aramcoLicense,
          ),
          controller: partnerNameController,
        );
      } else {
        await authService.updateOperatorProfile(
          widget.partnerId,
          operatorId ?? '',
          firstNameController.text,
          lastNameController.text,
          emailController.text,
          mobileNoController.text,
          passwordController.text,
          confirmPasswordController.text,
          iqamaNoController.text,
          dobController.text,
          panelInfoController.text,
          plateInfoController.text,
          convertPlatformFileToFile(drivingLicense),
          convertPlatformFileToFile(aramcoLicense),
          convertPlatformFileToFile(nationalId),
        );
      }
    }catch (e) {
      commonWidgets.showToast('${e}');
    }

  }
}
