import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Views/auth/stepThree.dart';

class StepTwo extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String unitType;
  final String unitClassification;
  final String subClassification;
  final String plateInformation;
  final String istimaraNo;
  final PlatformFile? istimaraCard;
  final PlatformFile? pictureOfVehicle;
  const StepTwo({super.key, required this.partnerName, required this.unitType, required this.unitClassification, required this.subClassification, required this.plateInformation, required this.istimaraNo, this.istimaraCard, this.pictureOfVehicle, required this.partnerId});

  @override
  State<StepTwo> createState() => _StepTwoState();
}
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController emailIdController = TextEditingController();
final TextEditingController mobileNoController = TextEditingController();
final TextEditingController dobController = TextEditingController();
final TextEditingController iqamaNoController = TextEditingController();
final TextEditingController panelInfoController = TextEditingController();
bool licenseUpload = false;
bool nationalIdUpload = false;
bool aramcoUpload = false;
PlatformFile? licenseFile;
PlatformFile? nationalIdFile;
PlatformFile? aramcoFile;

class _StepTwoState extends State<StepTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        context,
        User: widget.partnerName,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
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
      drawer: createDrawer(context),
        body: Form(
          key: _formKey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildTextField('First name',firstNameController),
                  ),
                  _buildTextField('Last name',lastNameController),
                  _buildTextField('Email id',emailIdController),
                  _buildTextField('Mobile no',mobileNoController),
                  _buildTextField('Date of Birth',dobController,hintText: 'dd/mm/yyyy'),
                  _buildTextField('Iqama no',iqamaNoController),
                  _buildTextField('Panel Information',panelInfoController),
                  Container(
                      margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
                      alignment: Alignment.topLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Driving License',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      )),
                  Container(
                    alignment: Alignment.bottomLeft,
                    margin: const EdgeInsets.only(left: 40,bottom: 20),
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
                            FilePickerResult? result = await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                licenseFile = result!.files.first;
                                licenseUpload = true;
                              });
                              print(result.files.first.name);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  licenseUpload?licenseFile!.name:'Upload a file',
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
                      margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
                      alignment: Alignment.topLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'National Id',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      )),
                  Container(
                    alignment: Alignment.bottomLeft,
                    margin: const EdgeInsets.only(left: 40,bottom: 20),
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
                            FilePickerResult? result = await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                nationalIdFile = result!.files.first;
                                nationalIdUpload = true;
                              });
                              print(result.files.first.name);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  nationalIdUpload?nationalIdFile!.name:'Upload a file',
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
                      margin: const EdgeInsets.fromLTRB(30, 0, 40, 0),
                      alignment: Alignment.topLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Aramco Certificate',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      )),
                  Container(
                    alignment: Alignment.bottomLeft,
                    margin: const EdgeInsets.only(left: 40,bottom: 30),
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
                            FilePickerResult? result = await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                aramcoFile = result!.files.first;
                                aramcoUpload =true;
                              });
                              print(result.files.first.name);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  aramcoUpload?aramcoFile!.name:'Upload a file',
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
                          if (_formKey.currentState!.validate()) {
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
                                      mobileNo: mobileNoController.text,
                                      dateOfBirth: dobController.text,
                                      iqamaNo: iqamaNoController.text,
                                      panelInformation: panelInfoController.text,
                                      drivingLicense: licenseFile,
                                      nationalID: nationalIdFile,
                                      aramcoLicense: aramcoFile,
                                      partnerName: widget.partnerName,
                                      partnerId: widget.partnerId,
                                    )));
                          }
                          },
                          child: const Text(
                            'Next',
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
    );
  }
  Widget _buildTextField(String label,controller,{String ? hintText}) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText??'',
              hintStyle: const TextStyle(color: Color(0xffCCCCCC)),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              if(label == 'Email id') {
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
