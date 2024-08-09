import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Views/auth/stepTwo.dart';

class StepOne extends StatefulWidget {
  const StepOne({Key? key}) : super(key: key);

  @override
  State<StepOne> createState() => _StepOneState();
}

int selectedUnit = 1;
String unitdropdownvalue = 'Unit 1';
String subdropdownvalue = 'Sub Unit 1';

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

class _StepOneState extends State<StepOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
          context,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
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
                    title: const Text(
                      'Vehicle',
                      // style: TextStyle(fontSize: 1),
                    ),
                    value: 1,
                    groupValue: selectedUnit,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: RadioListTile(
                    title: const Text(
                      'Bus',
                      // style: TextStyle(fontSize: 23),
                    ),
                    value: 2,
                    groupValue: selectedUnit,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: RadioListTile(
                    title: const Text(
                      'Equipment',
                      // style: TextStyle(fontSize: 23),
                    ),
                    value: 3,
                    groupValue: selectedUnit,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: RadioListTile(
                    title: const Text(
                      'Special',
                      // style: TextStyle(fontSize: 23),
                    ),
                    value: 4,
                    groupValue: selectedUnit,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: RadioListTile(
                    title: const Text(
                      'Others',
                      // style: TextStyle(fontSize: 23),
                    ),
                    value: 5,
                    groupValue: selectedUnit,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value!;
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
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    value: unitdropdownvalue,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 25,
                    ),
                    items: unitItems.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        unitdropdownvalue = newValue!;
                      });
                    },
                  ),
                ),
                Container(
                    margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Sub Classification',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )),
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
                    )),
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
                    )),
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
                    )),
                Container(
                  alignment: Alignment.bottomLeft,
                  margin: const EdgeInsets.only(left: 30,bottom: 10),
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
                              color: Colors.black,),
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
                    )),
                Container(
                  alignment: Alignment.bottomLeft,
                  margin: const EdgeInsets.only(left: 30,bottom: 20),
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
                            color: Colors.black,),
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
                  margin: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.057,
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6A66D1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StepTwo()));
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
