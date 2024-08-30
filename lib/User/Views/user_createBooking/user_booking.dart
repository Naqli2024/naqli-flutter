import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CreateBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  const CreateBooking({super.key, required this.firstName, required this.lastName});

  @override
  State<CreateBooking> createState() => _CreateBookingState();
}

class _CreateBookingState extends State<CreateBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final TextEditingController timeController = TextEditingController();
  int _currentStep = 1;
  String? selectedLoad;

  // String? _selectedSubClassification;
  final List<String> loadItems = ['Load 1', 'Load 2', 'Load 3'];
  List<String> _subClassifications = ['Truck', 'Lorry', 'Van', 'Bus'];
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  bool isChecked = false;
  int selectedLabour = 1;
  late Future<List<Vehicle>> _futureVehicles;
  List<String> _typeNames = [];
  Map<String, String?> _selectedSubClassification = {};

  @override
  void initState() {
    super.initState();
    _futureVehicles = userService.fetchUserVehicle();
    // _futureVehicles.then((vehicles) {
    //   setState(() {
    //     _typeNames = vehicles.expand((v) => v.type.map((t) => t.typeName)).toList();
    //   });
    // });
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
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

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName + widget.lastName,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
            backgroundColor: const Color(0xff6A66D1),
            title: Container(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  const Text(
                    'Create Booking',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    'Step $_currentStep of 3 - booking',
                    style: const TextStyle(color: Colors.white, fontSize: 17),
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
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/naqlee-logo.svg',
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CircleAvatar(
                          child: Icon(FontAwesomeIcons.multiply)))
                ],
              ),
            ),
            const Divider(),
            ListTile(
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Booking', style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),),
                ),
                onTap: () {}
            ),
            ListTile(
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Booking History', style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),),
                ),
                onTap: () {}
            ),
            ListTile(
                leading: Image.asset('assets/payment_logo.png',
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('Payment', style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),),
                ),
                onTap: () {}
            ),
            ListTile(
              leading: Image.asset('assets/report_logo.png',
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Report',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: Image.asset('assets/help_logo.png',
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Help',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.logout, color: Color(0xff707070), size: 30,),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Logout',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30, bottom: 10),
                            child: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            await clearUserData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserLogin()),
                            );
                          },
                        ),
                        TextButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
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
            const SizedBox(height: 20),
            // Step Content
            Expanded(
              child: _buildStepContent(_currentStep),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_currentStep == 1)
                  Container(),
                if (_currentStep > 1)
                  Container(
                    padding: const EdgeInsets.only(left: 40, bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_currentStep > 1) {
                            _currentStep--;
                          }
                        });
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(
                            color: Color(0xff6269FE),
                            fontSize: 21,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                if (_currentStep < 3)
                  Container(
                    padding: const EdgeInsets.only(right: 10, bottom: 15),
                    child: SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.055,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.3,
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
                if (_currentStep == 3)
                  Container(
                    padding: const EdgeInsets.only(right: 10, bottom: 15),
                    child: SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.055,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.53,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChooseVendor()
                                ),
                              );
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.white,
                                  title: Stack(
                                    children: [
                                      Center(child: SvgPicture.asset(
                                        'assets/generated_logo.svg',
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * 0.2,
                                      )),
                                      Positioned(
                                        top: -15,
                                        right: -10,
                                        child: IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(
                                                FontAwesomeIcons.multiply)),
                                      )
                                    ],
                                  ),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          'Booking Generated',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          'Booking id #1233445',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          });
                        },
                        child: const Text(
                          'Create Booking',
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
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    bool isActive = step == _currentStep;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xffACACAD), width: 1),
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
    return FutureBuilder<List<Vehicle>>(
      future: _futureVehicles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No vehicles available'));
        } else {
          final vehicles = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: const Text(
                  'Available Vehicle Units',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    final selectedType = _selectedSubClassification[vehicle
                        .name] ?? '';

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/delivery-truck.png'),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                vehicle.name,
                                style: TextStyle(fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              height: 45,
                              child: const VerticalDivider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (newValue) {
                                setState(() {
                                  _selectedSubClassification[vehicle.name] =
                                      newValue;
                                });
                              },
                              itemBuilder: (context) {
                                return vehicle.types?.map((type) {
                                  return PopupMenuItem<String>(
                                    value: type.typeName,
                                    child: Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 5,
                                      // Adjust width as needed
                                      child: Row(
                                        children: [
                                          SvgPicture.network(
                                            type.typeImage,
                                            width: 24,
                                            height: 24,
                                            placeholderBuilder: (context) =>
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: Center(
                                                      child: CircularProgressIndicator()),
                                                ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text(type.typeName)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList() ?? [];
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedType.isNotEmpty
                                          ? selectedType
                                          : vehicle.types?.isNotEmpty == true
                                          ? vehicle.types!.first.typeName
                                          : 'No Data for Sub Classification',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }








  Widget UserStepTwo() {
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(FontAwesomeIcons.clock)),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${_selectedTime.format(context)}'),
                ),
              ],
            ),
            ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(FontAwesomeIcons.calendar)),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$formattedDate'),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Value of product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextFormField(
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Color(0xffCCCCCC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Load type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: DropdownButtonFormField<String>(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              value: selectedLoad,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedLoad = newValue;
                });
              },
              hint: const Text('Load type'),
              icon: const Icon(Icons.keyboard_arrow_down, size: 25),
              items: loadItems.map((load) {
                return DropdownMenuItem<String>(
                  value: load,
                  child: Text(load),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: _onCheckboxChanged,
                  checkColor: Colors.white,
                  activeColor: const Color(0xff6A66D1),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Need Additional Labour',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
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
                  // dense: true,
                  // visualDensity: VisualDensity(horizontal: 0, vertical: -4),
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
                  // dense: true,
                  // visualDensity: VisualDensity(horizontal: 0, vertical: -4),
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
                  // dense: true,
                  // visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget UserStepThree() {
    return Center(
      child: Stack(
        children: [
         Container(
           height: MediaQuery.sizeOf(context).height * 0.6,
           child: const GoogleMap(initialCameraPosition: CameraPosition(
             target: LatLng(0, 0),  // Default position
             zoom: 1,
           ),),
         ),
          Positioned(
              top: 15,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(backgroundColor: Color(0xff009E10),minRadius: 6),
                          ),
                          Container(
                            height: 40,
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Pick up',
                                hintStyle: TextStyle(color: Color(0xff707070),fontSize: 15),
                                border: InputBorder.none
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        indent: 5,
                        endIndent: 5,
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(backgroundColor: Color(0xffE20808),minRadius: 6),
                          ),
                          Container(
                            height: 40,
                            width:  MediaQuery.sizeOf(context).width * 0.7,
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                              ],
                              decoration: const InputDecoration(
                                  hintText: 'Drop PointA',
                                  hintStyle: TextStyle(color: Color(0xff707070),fontSize: 15),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          )
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

