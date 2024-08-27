import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';

class CreateBooking extends StatefulWidget {
  const CreateBooking({super.key});

  @override
  State<CreateBooking> createState() => _CreateBookingState();
}

class _CreateBookingState extends State<CreateBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController timeController = TextEditingController();
  int _currentStep = 1;
  List<String> _subClassifications = ['Truck', 'Lorry', 'Van', 'Bus'];
  String? _selectedSubClassification;
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false, // Set to true for 24-hour format
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
            backgroundColor: const Color(0xff6A66D1),
            title: Container(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Text(
                    'Create Booking',
                    style: TextStyle(color: Colors.white,fontSize: 24),
                  ),
                  Text(
                    'Step $_currentStep of 3 - booking',
                    style: TextStyle(color: Colors.white,fontSize: 17),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () {
                commonWidgets.logout(context);
              },
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            SizedBox(height: 20),
            // Step Content
            Expanded(
              child: _buildStepContent(_currentStep),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_currentStep == 1)
            Container(),
          if (_currentStep > 1)
            Container(
              padding: const EdgeInsets.only(left: 40,bottom: 6),
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    if (_currentStep > 1) {
                      _currentStep--;
                    }
                  });
                },
                 child: Text(
                  'Back',
                  style: TextStyle(
                      color: Color(0xff6269FE),
                      fontSize: 21,
                      fontWeight: FontWeight.w500),
                ),
              ),
                              ),
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.055,
              width: MediaQuery.of(context).size.width * 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6269FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (_currentStep < 3) {
                      _currentStep++;
                    }
                  });
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),


    );
  }

  Widget _buildStep(int step) {
    bool isActive = step == _currentStep;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xffACACAD),width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isActive ? Color(0xff6A66D1) : Colors.white,
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

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return UserStepOne();
      case 2:
        return UserStepTwo();
      case 3:
        return UserStepThree();
      default:
        return Container();
    }
  }

  Widget UserStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: 30, top: 20, bottom: 10),
          child: Text(
            'Available Vehicle Units',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.black),
                        SizedBox(width: 8.0),
                        Text(
                          'Lorry',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 100),
                          height: 30,
                          child: VerticalDivider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedSubClassification,
                            underline: SizedBox(),
                            isExpanded: true,
                            isDense: true,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedSubClassification = newValue;
                              });
                            },
                            hint: const Text('No Data for Sub Classification'),
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: const Icon(Icons.keyboard_arrow_down, size: 20),
                            ),
                            items: _subClassifications.map((subClass) {
                              return DropdownMenuItem<String>(
                                value: subClass,
                                child: Padding(
                                  padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.1),
                                  child: Text(subClass),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget UserStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonWidgets.buildTextField(
          readOnly: true,
          'Time',
          timeController,
          hintText: 'Selected Time: ${_selectedTime.format(context)}',
          suffixIcon: IconButton(
              onPressed: () => _selectTime(context),
              icon: Icon(Icons.timer_outlined))
        )
      ],
    );
  }

  Widget UserStepThree() {
    return Center(
      child: Column(
        children: [
          Text('Content for Step 3', style: TextStyle(fontSize: 24)),
        ],
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

