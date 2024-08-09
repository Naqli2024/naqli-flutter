import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Views/auth/stepThree.dart';

class StepTwo extends StatefulWidget {
  const StepTwo({super.key});

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
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
                    margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Operator name',
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
                      'Email id',
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
                      'Mobile no',
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
                      'Date of Birth',
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
                      'Iqama no',
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
                      'Panel Information',
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
                      'Driving License',
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
                      'National Id',
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
                      'Aramco Certificate',
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
                                  builder: (context) => const StepThree()));
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
        ),
    );
  }
}
