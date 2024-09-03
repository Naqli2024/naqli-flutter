import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CreateBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String selectedType;
  const CreateBooking({super.key, required this.firstName, required this.lastName, required this.selectedType });

  @override
  State<CreateBooking> createState() => _CreateBookingState();
}

class _CreateBookingState extends State<CreateBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final TextEditingController timeController = TextEditingController();
  int _currentStep = 1;
  String? selectedLoad;
  // final List<String> loadItems = ['Load 1', 'Load 2', 'Load 3'];
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  bool isChecked = false;
  int selectedLabour = 1;
  late Future<List<Vehicle>> _futureVehicles;
  late Future<List<Buses>> _futureBuses;
  late Future<List<Equipment>> _futureEquipment;
  late Future<List<Special>> _futureSpecial;
  Map<String, String?> _selectedSubClassification = {};
  String? selectedTypeName;
  List<String> loadItems = [];
  int? selectedBus;

  @override
  void initState() {
    super.initState();
    _futureVehicles = userService.fetchUserVehicle();
    _futureBuses = userService.fetchUserBuses();
    _futureEquipment = userService.fetchUserEquipment();
    _futureSpecial = userService.fetchUserSpecialUnits();
    fetchLoadsForSelectedType(selectedTypeName??'');
  }

  Future<List<LoadType>> fetchLoadsForSelectedType(String selectedTypeName) async {
    try {
      List<Vehicle> vehicles = await userService.fetchUserVehicle(); // Fetch vehicles

      var selectedType = vehicles
          .expand((vehicle) => vehicle.types) // Flatten the list of types
          .firstWhere(
            (type) => type.typeName == selectedTypeName,
        orElse: () => VehicleType(typeName: '', typeOfLoad: [], typeImage: '', scale: ''), // Default value
      );

      print('Selected Type: ${selectedType.typeOfLoad}'); // Debugging line

      return selectedType.typeOfLoad; // Return the list of LoadType
    } catch (e) {
      print('Error fetching loads: $e');
      return [];
    }
  }

  Future<void> _fetchLoadParameters() async {
    try {
      const String baseUrl = 'https://naqli.onrender.com/api/';
      final response = await http.get(Uri.parse('${baseUrl}vehicles?name=${selectedTypeName}'));

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        List<String> loads = [];

        // Parse the response to extract typeOfLoad for the selected vehicle
        for (var item in responseBody) {
          if (item['name'] == selectedTypeName) {
            for (var type in item['type']) {
              for (var load in type['typeOfLoad']) {
                loads.add(load['load']);
              }
            }
          }
        }

        setState(() {
          loadItems = loads;
        });
      } else {
        throw Exception('Failed to load load parameters');
      }
    } catch (e) {
      // Handle error
      print('Error fetching load parameters: $e');
    }
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
                              print('Selected Type Name: $selectedTypeName'); // Debug print
                              widget.selectedType == 'Vehicle'
                                  ?  UserVehicleStepTwo(selectedName: selectedTypeName)
                                  : null;
                              widget.selectedType == 'Bus'
                                  ?  selectedBus!= null ?UserBusStepTwo():null
                                  : null;
                              widget.selectedType == 'Equipment'
                                  ?  UserEquipmentStepTwo()
                                  : null;
                              widget.selectedType == 'Special'
                                  ?  UserSpecialStepTwo()
                                  : null;
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
        return buildStepOneContent(widget.selectedType);
      case 2:
        return buildStepTwoContent(widget.selectedType);
      case 3:
        return UserStepThree();
      default:
        return Container();
    }
  }

  Widget buildStepOneContent(String selectedType) {
    switch (selectedType) {
      case 'Vehicle':
        return vehicleContent();
      case 'Bus':
        return busContent();
      case 'Equipment':
        return equipmentContent();
      case 'Special':
        return specialContent();
      case 'Others':
        return specialContent();
      default:
        return defaultContent(); // Default content if no type is selected
    }
  }

  Widget buildStepTwoContent(String selectedType) {
    switch (selectedType) {
      case 'Vehicle':
        return UserVehicleStepTwo(selectedName: selectedTypeName);
      case 'Bus':
        if (selectedBus != null) {
          // If a bus is selected, return the UserBusStepTwo widget.
          return UserBusStepTwo();
        } else {
          // If no bus is selected, show a message or return an empty container.
          Fluttertoast.showToast(
            msg: 'Please Select Bus...',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return Center(
            child: Container(
              child: Text('Please Select Bus...'),
            ),
          );
        }
      case 'Equipment':
        return UserEquipmentStepTwo();
      case 'Special':
        return UserSpecialStepTwo();
      case 'Others':
        return UserSpecialStepTwo();
      default:
        return defaultContent(); // Default content if no type is selected
    }
  }

  Widget busContent() {
    return FutureBuilder<List<Buses>>(
      future: _futureBuses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Buses available'));
        } else {
          final buses = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: const Text(
                  'Available Bus Units',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: 0, // Space between columns
                    mainAxisSpacing: 0, // Space between rows
                    childAspectRatio: 1, // Aspect ratio for card width and height
                  ),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index];
                    final isBusSelected = selectedBus == index;
                    return Padding(
                      padding: const EdgeInsets.only(left: 27),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.39,
                            height: MediaQuery.sizeOf(context).height * 0.18,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isBusSelected) {
                                    selectedBus=null;
                                  } else {
                                    selectedBus=index;
                                  }
                                });
                              },
                              child: Card(
                                color: isBusSelected ? Color(0xff6A66D1) : Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Color(0xffACACAD), width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FutureBuilder(
                                      future: _loadSvg(bus.image),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else {
                                          return SvgPicture.asset(
                                            bus.image,
                                            width: 30,
                                            height: 40,
                                          );
                                        }
                                      },
                                    ),
                                    // SvgPicture.asset(bus.image??''),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 10,bottom: 10),
                                      child: Divider(
                                        indent: 7,
                                        endIndent: 7,
                                        color: Color(0xffACACAD),
                                        thickness: 2,
                                      ),
                                    ),
                                    Text(
                                      bus.name,
                                      textAlign: TextAlign.center, // Center the text
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget equipmentContent() {
    return FutureBuilder<List<Equipment>>(
      future: _futureEquipment,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No vehicles available'));
        } else {
          final equipment = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: const Text(
                  'Available Equipments Units',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: equipment.length,
                  itemBuilder: (context, index) {
                    final equipments = equipment[index];
                    final selectedType = _selectedSubClassification[equipments.name] ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/delivery-truck.png', width: 50, height: 50),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                equipments.name,
                                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: const VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                width: double.infinity,
                                child: PopupMenuButton<String>(
                                  elevation: 5,
                                  constraints: BoxConstraints.tightFor(width: 350),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  offset: const Offset(0, 55),
                                  padding: EdgeInsets.zero,
                                  color: Colors.white,
                                  onSelected: (newValue) {
                                    setState(() {
                                      _selectedSubClassification[equipments.name] = newValue;
                                    });
                                  },
                                  itemBuilder: (context) {
                                    return equipments.types?.map((type) {
                                      return PopupMenuItem<String>(
                                        value: type.typeName,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: FutureBuilder(
                                                  future: _loadSvg(type.typeImage),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return const SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(),
                                                      );
                                                    } else if (snapshot.hasError) {
                                                      return const Icon(Icons.error);
                                                    } else {
                                                      return SvgPicture.asset(
                                                        type.typeImage,
                                                        width: 40,
                                                        height: 24,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 3,
                                                child: Text(type.typeName, style: const TextStyle(fontSize: 16.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList() ?? [];
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedType.isEmpty
                                              ? 'Select an option'
                                          : selectedType.isNotEmpty
                                              ? selectedType
                                              : equipments.types?.isNotEmpty == true
                                              ? equipments.types!.first.typeName
                                              : 'No Data for Sub Classification',
                                          style: const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          /*  Expanded(
                              flex: 7,
                              child: PopupMenuButton<String>(
                                elevation: 5,
                                constraints: BoxConstraints.tightFor(width: 350),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                offset: const Offset(0, 70), // Adjust as needed
                                padding: EdgeInsets.zero,
                                color: Colors.white,
                                onSelected: (newValue) {
                                  setState(() {
                                    _selectedSubClassification[equipments.name] = newValue;
                                  });
                                },
                                itemBuilder: (context) {
                                  return equipments.types?.map((type) {
                                    return PopupMenuItem<String>(
                                      value: type.typeName,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: MediaQuery.of(context).size.width -80, // Expand dropdown width
                                        child: Row(
                                          children: [
                                            FutureBuilder(
                                              future: _loadSvg(type.typeImage),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return const Icon(Icons.error);
                                                } else {
                                                  return SvgPicture.asset(
                                                    type.typeImage,
                                                    width: 24,
                                                    height: 24,
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              child: Text(
                                                type.typeName,
                                                style: const TextStyle(fontSize: 16.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList() ?? [];
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('assets/delivery-truck.png', width: 50, height: 50),
                                          ),
                                          const SizedBox(width: 10),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                equipments.name, // Static equipment name
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context).size.height * 0.07,
                                                child: const VerticalDivider(
                                                  color: Colors.grey,
                                                  thickness: 1,
                                                ),
                                              ),
                                              Text(
                                                _selectedSubClassification[equipments.name] ?? 'Select Type', // Dynamic hint text
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),*/


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

  Widget specialContent() {
    return FutureBuilder<List<Special>>(
      future: _futureSpecial,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Equipment available'));
        } else {
          final special = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: const Text(
                  'Available Special / Others Units',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: 0, // Space between columns
                    mainAxisSpacing: 0, // Space between rows
                    childAspectRatio: 1, // Aspect ratio for card width and height
                  ),
                  itemCount: special.length,
                  itemBuilder: (context, index) {
                    final specials = special[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 27),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.39,
                            height: MediaQuery.sizeOf(context).height * 0.18,
                            child: GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   _selectedType = 'Vehicle'; // Update the selected type
                                // });
                                //
                                // // Navigate to CreateBooking with the selected type
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => CreateBooking(
                                //       firstName: widget.firstName,
                                //       lastName: widget.lastName,
                                //       selectedType: _selectedType, // Pass the selected type here
                                //     ),
                                //   ),
                                // );
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Color(0xffACACAD), width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FutureBuilder(
                                      future: _loadSvg(specials.image),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else {
                                          return SvgPicture.asset(
                                            specials.image,
                                            width: 30,
                                            height: 40,
                                          );
                                        }
                                      },
                                    ),
                                    // SvgPicture.asset(bus.image??''),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 10,bottom: 10),
                                      child: Divider(
                                        indent: 7,
                                        endIndent: 7,
                                        color: Color(0xffACACAD),
                                        thickness: 2,
                                      ),
                                    ),
                                    Text(
                                      specials.name,
                                      textAlign: TextAlign.center, // Center the text
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget othersContent() {
    // Your content for Others
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Others Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // Add more widgets as needed
        ],
      ),
    );
  }

  Widget defaultContent() {
    // Default content
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Please select a type to see content', style: TextStyle(fontSize: 18)),
    );
  }

  Widget vehicleContent() {
    return FutureBuilder<List<Vehicle>>(
      future: _futureVehicles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No vehicles available'));
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
                    final selectedType = _selectedSubClassification[vehicle.name] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/delivery-truck.png', width: 50, height: 50),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Text(
                                vehicle.name,
                                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.09,
                                child: const VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                width: double.infinity,
                                child: PopupMenuButton<String>(
                                  elevation: 5,
                                  constraints: BoxConstraints.tightFor(width: 350),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  offset: const Offset(0, 55),
                                  padding: EdgeInsets.zero,
                                  color: Colors.white,
                                  onSelected: (newValue) {
                                    setState(() {
                                      _selectedSubClassification[vehicle.name] = newValue;
                                      selectedTypeName = newValue;
                                    });
                                  },
                                  itemBuilder: (context) {
                                    return vehicle.types?.map((type) {
                                      return PopupMenuItem<String>(
                                        value: type.typeName,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: FutureBuilder(
                                                  future: _loadSvg(type.typeImage),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return const SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: Icon(Icons.rotate_right),
                                                      );
                                                    } else if (snapshot.hasError) {
                                                      return const Icon(Icons.error);
                                                    } else {
                                                      return SvgPicture.asset(
                                                        type.typeImage,
                                                        width: 40,
                                                        height: 24,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(type.typeName, style: const TextStyle(fontSize: 16.0)),
                                                    Text(type.scale, style: const TextStyle(fontSize: 14.0)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList() ?? [];
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedType.isEmpty
                                          ? 'Select an option'
                                          : selectedType.isNotEmpty
                                              ? selectedType
                                              : vehicle.types?.isNotEmpty == true
                                              ? vehicle.types!.first.typeName
                                              : 'No Data ',
                                          style: const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
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





  Widget UserVehicleStepTwo({String? selectedName}) {
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
                  icon: const Icon(FontAwesomeIcons.clock),
                ),
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
                  icon: const Icon(FontAwesomeIcons.calendar),
                ),
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
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: LoadTypeDropdown(
              selectedName: selectedName,
              selectedLoad: selectedLoad,
              onLoadChanged: (newValue) {
                setState(() {
                  selectedLoad = newValue;
                });
              },
              fetchLoadsForSelectedType: fetchLoadsForSelectedType,
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
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
          ),
        ],
      ),
    );
  }

  Widget UserBusStepTwo() {
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
                  icon: const Icon(FontAwesomeIcons.clock),
                ),
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
                  icon: const Icon(FontAwesomeIcons.calendar),
                ),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
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
            ),
        ],
      ),
    );
  }

  Widget UserEquipmentStepTwo() {
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
                'From Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
                ),
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
                'To Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
                ),
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
                  icon: const Icon(FontAwesomeIcons.calendar),
                ),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
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
            ),
        ],
      ),
    );
  }

  Widget UserSpecialStepTwo() {
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
                'From Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
                ),
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
                'To Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
                ),
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
                  icon: const Icon(FontAwesomeIcons.calendar),
                ),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
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
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),  // Default position
                zoom: 10,
              ),
            ),
          ),
          Positioned(
            top: 15,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Card(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircleAvatar(backgroundColor: Color(0xff009E10), minRadius: 6),
                        ),
                        Container(
                          height: 40,
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            inputFormatters: [LengthLimitingTextInputFormatter(30)],
                            decoration: const InputDecoration(
                              hintText: 'Pick up',
                              hintStyle: TextStyle(color: Color(0xff707070), fontSize: 15),
                              border: InputBorder.none,
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
                          child: CircleAvatar(backgroundColor: Color(0xffE20808), minRadius: 6),
                        ),
                        Container(
                          height: 40,
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            inputFormatters: [LengthLimitingTextInputFormatter(30)],
                            decoration: const InputDecoration(
                              hintText: 'Drop Point',
                              hintStyle: TextStyle(color: Color(0xff707070), fontSize: 15),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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

Future<void> _loadSvg(String asset) async {
  // Simulate network delay for SVG loading
  await Future.delayed(const Duration(milliseconds: 300));
  // Normally, here you'd handle actual asset loading if needed
}

class LoadTypeDropdown extends StatefulWidget {
  final String? selectedName;
  final String? selectedLoad;
  final Function(String?) onLoadChanged;
  final Future<List<LoadType>> Function(String) fetchLoadsForSelectedType;

  LoadTypeDropdown({
    required this.selectedName,
    required this.selectedLoad,
    required this.onLoadChanged,
    required this.fetchLoadsForSelectedType,
  });

  @override
  _LoadTypeDropdownState createState() => _LoadTypeDropdownState();
}

class _LoadTypeDropdownState extends State<LoadTypeDropdown> {
  late Future<List<LoadType>> _loadTypesFuture;

  @override
  void initState() {
    super.initState();
    _loadTypesFuture = widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
  }

  @override
  void didUpdateWidget(covariant LoadTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedName != oldWidget.selectedName) {
      setState(() {
        _loadTypesFuture = widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoadType>>(
      future: _loadTypesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<LoadType> loadItems = snapshot.data ?? [];

          // Ensure loadItems is not empty and contains valid LoadType objects
          print('Load Items: $loadItems'); // Debugging line

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: PopupMenuButton<String>(
              onSelected: (String newValue) {
                widget.onLoadChanged(newValue);
              },
              elevation: 5,
              color: Colors.white,
              constraints: BoxConstraints.tightFor(width: 300),
              offset: const Offset(0, -280),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (widget.selectedLoad?.isNotEmpty ?? false) ? widget.selectedLoad! : 'Load type',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
              itemBuilder: (BuildContext context) {
                return loadItems.map((LoadType load) {
                  return PopupMenuItem<String>(
                    value: load.load,
                    child: Text(load.load),
                  );
                }).toList();
              },
            ),
          );
        } else {
          return Center(child: Text('No loads available'));
        }
      },
    );
  }
}



