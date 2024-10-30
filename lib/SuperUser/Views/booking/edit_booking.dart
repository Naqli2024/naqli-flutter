import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EditBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const EditBooking({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController pickUpPointController = TextEditingController();
  final TextEditingController dropPointController = TextEditingController();
  String selectedMode= 'Tralia';
  bool isLoading = false;
  int selectedUnit = 1;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool isChecked = false;
  int selectedLabour = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName +' '+ widget.lastName,
        userId: widget.id,
        showLeading: false,
        showLanguage: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: MediaQuery.of(context).size.height * 0.09,
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff807BE5),
            title: const Text(
              'Edit Booking',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookingManager(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        token: widget.token,
                        id: widget.id,
                        email: widget.email
                    ),
                  ),
                );
              },
              icon: CircleAvatar(
                backgroundColor: Color(0xffB7B3F1),
                child: const Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildUnitRadioList(setState),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,20,0,5,),
                child: Text('Pickup Point'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right:20,bottom: 5),
              child: TextFormField(
                controller: pickUpPointController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.circle,size: 15,color: Color(0xff009E10)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color(0xffBCBCBC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                child: Text('Drop Point'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,bottom: 15),
              child: TextFormField(
                controller: dropPointController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.circle,size: 15,color: Color(0xffE20808)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color(0xffBCBCBC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                child: Text('Mode'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffBCBCBC)),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: DropdownButton<String>(
                            value: selectedMode,
                            icon: Icon(Icons.keyboard_arrow_down),
                            items: <String>['Tralia', 'Bus', 'Lorry']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMode = newValue!;
                                // Add logic to update the chart data based on the selected duration
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                child: Text('Mode Classification'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffBCBCBC)),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: DropdownButton<String>(
                            value: selectedMode,
                            icon: Icon(Icons.keyboard_arrow_down),
                            items: <String>['Tralia', 'Bus', 'Lorry']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMode = newValue!;
                                // Add logic to update the chart data based on the selected duration
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                child: Text('Start Date'),
              ),
            ),
            GestureDetector(
              onTap: (){
                selectStartDate(context, setState);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffBCBCBC)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => selectStartDate(context, setState),
                      icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                    ),
                    Container(
                      height: 50,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        selectStartDate(context, setState);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(_selectedStartDate),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                child: Text('End Date'),
              ),
            ),
            GestureDetector(
              onTap: (){
                selectEndDate(context, setState);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffBCBCBC)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => selectEndDate(context, setState),
                      icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                    ),
                    Container(
                      height: 50,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        selectEndDate(context, setState);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(_selectedEndDate),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: const Color(0xff6A66D1),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Need Additional Labour',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            if (isChecked)
              Column(
                children: [
                  RadioListTile(
                    title: const Text('1'),
                    value: 1,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('2'),
                    value: 2,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('3'),
                    value: 3,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(top: 20,bottom: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.055,
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff6269FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUnitRadioList(StateSetter setState) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile(
                  dense: true,
                  title: const Text('Vehicle', style: TextStyle(fontSize: 14)),
                  value: 1,
                  groupValue: selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  dense: true,
                  title: const Text('Bus', style: TextStyle(fontSize: 14)),
                  value: 2,
                  groupValue: selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                title: const Text('Equipment',style: TextStyle(fontSize: 14)),
                value: 3,
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile(
                dense: true,
                title: const Text('Special',style: TextStyle(fontSize: 14)),
                value: 4,
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                title: const Text('Others',style: TextStyle(fontSize: 14)),
                value: 5,
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> selectStartDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }
}
