import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Model/services.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Views/auth/stepTwo.dart';
import 'package:http/http.dart' as http;

class StepOne extends StatefulWidget {
  final String partnerName;
  final String name;
  final String unitType;
  const StepOne({Key? key, required this.partnerName, required this.name, required this.unitType}) : super(key: key);

  @override
  State<StepOne> createState() => _StepOneState();
}

int selectedUnit = 1;
String unitdropdownvalue = 'Unit 1';
String subdropdownvalue = 'Sub Unit 1';
List<String> _currentUnitClassifications = [];
String? _selectedUnitClassification;
File?selectedfile;
// List of items in our dropdown menu
var unitItems = [
  'Unit 1',
  'Unit 2',
  'Unit 3',
];

var subItems = [
  'Sub Unit 1',
  'Sub Unit 2',
  'Sub Unit 3',
];
Map<int, List<String>> unitClassifications = {
  1: ['Diana', 'Vehicle 2', 'Vehicle 3'],
  2: ['Bus 1', 'Bus 2', 'Bus 3'],
  3: ['Equipment 1', 'Equipment 2', 'Equipment 3'],
  4: ['Special 1', 'Special 2', 'Special 3'],
  5: ['Others 1', 'Others 2', 'Others 3'],
};


Map<int, String> unitMap = {
  1: 'vehicle',
  2: 'Bus',
  3: 'Equipment',
  4: 'Special',
  5: 'Others',
};

String? _getRoleString(int value) {
  String selectedUnitString = unitMap[selectedUnit]!;
  switch (value) {
    case 1:

      print('Selected Unit: $selectedUnitString');
    case 2:
      print('Selected Unit: $selectedUnitString');
    case 3:
      print('Selected Unit: $selectedUnitString');
    case 4:
      print('Selected Unit: $selectedUnitString');
    default:
      return 'Unknown';
  }
}



class _StepOneState extends State<StepOne> {
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> _vehicles = [];
  List<String> _vehicleDetails = [];
  List<String> subClassification = [];
  String? _selectedVehicle;
  List<String> _details = [];
  String? _selectedDetail;
  List<String> _typeNames = [];
  String? _selectedTypeName;

  void fetchUnitData() async {
    try {
      String selectedUnitString = unitMap[selectedUnit]!;
      List<dynamic> data;
      if (selectedUnitString == 'vehicle') {
        data = await AuthService().fetchVehicleData();
      }
      else if(selectedUnitString == 'Bus'){
        data = await AuthService().fetchBusData();
      }
      else if(selectedUnitString == 'Equipment'){
        data = await AuthService().fetchEquipmentData();
      }
      else if(selectedUnitString == 'Special'){
        data = await AuthService().fetchSpecialData();
      }
      else {
        data = await AuthService().fetchBusData();
      }

      setState(() {
        _details = List<String>.from(data.map((item) => item['name']));
        _selectedDetail = null; // Reset dropdown selection
      });
    } catch (error) {
      print('Failed to load data: $error');
    }
  }

  void fetchSubData() async {
    try {
      String selectedUnitString = unitMap[selectedUnit]!;
      List<dynamic> data;
      if (selectedUnitString == _details) {
        data = await AuthService().fetchVehicleTypes();
        print(data);
      }
      else if(selectedUnitString == _details){
        data = await AuthService().fetchBusData();
      }
      else if(selectedUnitString == _details){
        data = await AuthService().fetchEquipmentData();
      }
      else if(selectedUnitString == _details){
        data = await AuthService().fetchSpecialData();
      }
      else {
        data = await AuthService().fetchBusData();
      }

      setState(() {
        _details = List<String>.from(data.map((item) => item['name']));
        _selectedDetail = null; // Reset dropdown selection
      });
    } catch (error) {
      print('Failed to load data: $error');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchUnitClassification();
    _loadVehicleTypes();
  }
  Future<void> _loadVehicleTypes() async {
    AuthService().fetchVehicleTypes().then((types) {
      setState(() {
        _typeNames = types;
        _selectedTypeName = _typeNames.isNotEmpty ? _typeNames[0] : null;
        print(_selectedTypeName);
      });
    }).catchError((error) {
      print('Failed to load vehicle types: $error');
    });
  }

  void fetchUnitClassification(){
    AuthService().fetchVehicleData().then((data) {
      setState(() {
        // Directly mapping the list of vehicles to the names
        _vehicleDetails = List<String>.from(data.map((vehicle) => vehicle['name']));
        print(_vehicleDetails);
      });
    }).catchError((error) {
      print('Failed to load vehicle data: $error');
    });
  }

  Future<void> _submitForm() async {
    String selectedUnitString = unitMap[selectedUnit]!;
    AuthService().addOperator(
      context,
      unitType: selectedUnitString,
      unitClassification: unitdropdownvalue,
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        context,
        User: widget.partnerName,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: const Color(0xff6A66D1),
            title: Text(
              widget.unitType,
              style: const TextStyle(color: Colors.white),
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
      drawer: createDrawer(context),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(50, 10, 30, 10),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    'Select Unit',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: RadioListTile(
                  title: const Text('Vehicle'),
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
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: RadioListTile(
                  title: const Text('Bus'),
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
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: RadioListTile(
                  title: const Text('Equipment'),
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
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: RadioListTile(
                  title: const Text('Special'),
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
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: RadioListTile(
                  title: const Text('Others'),
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
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Unit Classification',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                child:  DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  hint: const Text('Select a vehicle or bus'),
                  value: _selectedDetail,
                  items: _details.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDetail = value;
                    });
                  },
                )
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Sub Classification',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  value: subdropdownvalue,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 25,
                  ),
                  items: subItems.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      subdropdownvalue = newValue!;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Plate Information',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Istimara No',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Istimara Card',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 30, bottom: 10),
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
                        var picked = await FilePicker.platform.pickFiles();

                        if (picked != null) {
                          print(picked.files.first.name);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                          ),
                          Text(
                            'Upload a File',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Picture of Vehicle',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 30, bottom: 20),
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
                        var picked = await FilePicker.platform.pickFiles();

                        if (picked != null) {
                          print(picked.files.first.name);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                          ),
                          Text(
                            'Upload a File',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Driving License',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 30, bottom: 20),
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
                        var picked = await FilePicker.platform.pickFiles();

                        if (picked != null) {
                          print(picked.files.first.name);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                          ),
                          Text(
                            'Upload a File',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Aramco License',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 30, bottom: 20),
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
                        var picked = await FilePicker.platform.pickFiles();

                        if (picked != null) {
                          print(picked.files.first.name);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                          ),
                          Text(
                            'Upload a File',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'National ID',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 30, bottom: 20),
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
                        var picked = await FilePicker.platform.pickFiles();

                        if (picked != null) {
                          print(picked.files.first.name);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                          ),
                          Text(
                            'Upload a File',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )),
                ),
              ),

              Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6A66D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _submitForm();
                    _getRoleString(selectedUnit);
                    // authService.addOperator(context, name: widget.name);
                    String selectedUnitString = unitMap[selectedUnit]!;
                    // print('Selected Unit: $selectedUnitString');
                    print(widget.name);
                    print(widget.partnerName);
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => StepTwo(
                    //           partnerName: widget.partnerName,
                    //           // name: widget.name,
                    //           // mobileNo: widget.mobileNo,
                    //           // selectedUnit: selectedUnitString,
                    //           // unitClassification: unitdropdownvalue,
                    //           // subClassification: subdropdownvalue,
                    //         )));
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
