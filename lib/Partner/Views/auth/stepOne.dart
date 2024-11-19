import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepTwo.dart';
import 'dart:ui' as ui;

class StepOne extends StatefulWidget {
  final String partnerName;
  final String name;
  final String unitType;
  final String partnerId;
  final String token;
  final String bookingId;

  const StepOne({
    Key? key,
    required this.partnerName,
    required this.name,
    required this.unitType, required this.partnerId, required this.token, required this.bookingId,
  }) : super(key: key);

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CommonWidgets commonWidgets = CommonWidgets();
  final AuthService authService = AuthService();
  bool istimaraUpload = false;
  bool vehicleUpload = false;
  bool istimaraError = false;
  bool vehicleError = false;
  bool isLoading = false;
  int _currentStep = 1;

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

  @override
  void initState() {
    super.initState();
    fetchUnitData();
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


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.partnerName,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(125.0),
            child: Column(
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xff6A66D1),
                  title: Text(
                    'Operator/Owner'.tr(),
                    style: TextStyle(color: Colors.white),
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
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(40, 20, 30, 5),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Select Unit'.tr(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  _buildUnitRadioList(),
                  _buildUnitClassificationDropdown(),
                  _buildSubClassificationDropdown(),
                  _buildTextField('Plate Information'.tr(),plateInfoController),
                  commonWidgets.buildTextField('Istimara No'.tr(),istimaraNoController),
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
                            if (!istimaraUpload && !vehicleUpload) {
                              istimaraError =true;
                              vehicleError =true;
                              setState(() {});
                            }
                            if (_formKey.currentState!.validate() && istimaraUpload && vehicleUpload) {
                              String selectedUnitString = unitMap(selectedUnit);
                              print(selectedUnitString);
                              print(_selectedUnitClassification.toString());
                              print(_selectedSubClassification.toString());
                              print(plateInfoController.text);
                              print(istimaraNoController.text);
                              print(istimaraCardFile);
                              print(vehilePictureFile);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StepTwo(
                                            partnerName: widget.partnerName,
                                            partnerId: widget.partnerId,
                                            unitType: selectedUnitString,
                                            unitClassification: _selectedUnitClassification
                                                .toString(),
                                            subClassification: _selectedSubClassification
                                                .toString(),
                                            plateInformation: plateInfoController
                                                .text,
                                            istimaraNo: istimaraNoController
                                                .text,
                                            istimaraCard: istimaraCardFile,
                                            pictureOfVehicle: vehilePictureFile,
                                            token: widget.token,
                                          )));
                            }
                          },
                          child: Text(
                            'Next'.tr(),
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
      ),
    );
  }

  Widget _buildStep(int step) {
    bool isActive = step == _currentStep;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? const Color(0xff6A66D1) : const Color(0xffACACAD),
            width: 1),
      ),
      child: CircleAvatar(
        radius: 20,
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
              style: const TextStyle(
                  fontSize: 20,
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
              style: const TextStyle(
                  fontSize: 20,
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
              style: const TextStyle(
                fontSize: 20,
                  fontWeight: FontWeight.w500
              ),
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
              style: const TextStyle(
                fontSize: 20,
              ),
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
